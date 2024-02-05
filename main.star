participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)

BOOTNODE_IP = "35.237.92.52"
URL = "http://{}:6060"
BOOTNODE_URL = URL.format(BOOTNODE_IP)
TESTER_SERVICE_NAME = "tester"

def run(plan, args={}):
    tester = plan.add_service(
        name=TESTER_SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="sync-test",
                build_context_dir="./tester",
            ),
            cmd=["bash", "ensure_node_is_running.sh", BOOTNODE_URL],
        ),
    )
    
    regular = {
        "type": "juno",
        "image": "nethermindeth/juno:p2p-syncing-1828673",
        "extra_args": [
            "--p2p", 
            "--p2p-peers", 
            "/dns/{}/tcp/7777/p2p/12D3KooWLdURCjbp1D7hkXWk6ZVfcMDPtsNnPHuxoTcWXFtvrxGG".format(BOOTNODE_IP),
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
        ["node", "index.mjs", BOOTNODE_URL, URL.format(node.ip_address)]
        )
    )