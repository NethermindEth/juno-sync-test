participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)


BOOTNODE = {
    "type": "juno",
    "image": "nethermindeth/juno:p2p-syncing-3737b85",
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


def run(plan, args={}):
    bootnode = participants.run_participant(plan, "bootnode", BOOTNODE, None)
    # TODO: health check to make sure bootnode has started? Could e.g. curl to make sure GET [ip]:6060/ returns 200 OK

    regular = {
        "type": "juno",
        "image": "nethermindeth/juno:p2p-syncing-3737b85",
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


    plan.add_service(
        name="tester",
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="sync-test",
                build_context_dir="./tester",
            ),
            cmd=["node", "index.mjs", URL.format(bootnode.ip_address), URL.format(node.ip_address)],
        ),
    )
