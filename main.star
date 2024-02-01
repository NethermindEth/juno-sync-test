participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)


BOOTNODE = {
    "type": "juno",
    "image": "nethermindeth/juno:p2p-syncing-88058f7",
    "extra_args": [
        "--p2p", 
        "--p2p-feeder-node", 
        "--p2p-addr", 
        "/ip4/0.0.0.0/tcp/7777", 
        "--p2p-private-key",
        "5f6cdc3aebcc74af494df054876100368ef6126e3a33fa65b90c765b381ffc37a0a63bbeeefab0740f24a6a38dabb513b9233254ad0020c721c23e69bc820089",
        "--network",
        "sepolia",
    ],
    "ports": {
        "p2p": {
            "number": 7777,
            "transport_protocol": "TCP",   
        }
    }
}

URL = "http://{}:6060/rpc/v0_5"
TESTER_SERVICE_NAME="tester"


def run(plan, args={}):
    bootnode = participants.run_participant(plan, "bootnode", BOOTNODE, None)
    bootnode_url = URL.format(bootnode.ip_address)

    tester = plan.add_service(
        name=TESTER_SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="sync-test",
                build_context_dir="./tester",
            ),
            cmd=["bash", "ensure_node_is_running.sh", bootnode_url],
        ),
    )

    
    regular = {
        "type": "juno",
        "image": "nethermindeth/juno:p2p-syncing-88058f7",
        "extra_args": [
            "--p2p", 
            "--p2p-peers", 
            "/dns/{}/tcp/7777/p2p/12D3KooWLdURCjbp1D7hkXWk6ZVfcMDPtsNnPHuxoTcWXFtvrxGG".format(bootnode.ip_address),
            "--network",
            "sepolia",
            "--p2p-addr", 
            "/ip4/0.0.0.0/tcp/7777", 
        ],
        "ports": {
            "p2p": {
                "number": 7777,
                "transport_protocol": "TCP",   
            }
        }
    }
    node = participants.run_participant(plan, "node-1", regular, None)

    plan.exec(TESTER_SERVICE_NAME, ExecRecipe(
        ["node", "index.mjs", "https://alpha-sepolia.starknet.io/feeder_gateway/", URL.format(node.ip_address)]
        )
    )
