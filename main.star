participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)

URL = "http://{}:6060"
BOOTNODE_IP = "35.237.92.52"
BOOTNODE_URL = URL.format(BOOTNODE_IP);
TESTER_SERVICE_NAME = "tester"
NODE_NUMBER = 3

def run(plan, args={}):
    tester = plan.add_service(
        name=TESTER_SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="sync-test",
                build_context_dir="./tester",
            ),
        ),
    )

    node_urls = []
    for i in range(NODE_NUMBER):
        node_name = "node-{}".format(i+1)
        node = participants.run_participant(plan, node_name, {
            "type": "juno",
            "image": "nethermindeth/juno:p2p-syncing-88058f7",
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
        }, None)
        node_url = URL.format(node.ip_address)
        node_urls.append(node_url)

    plan.exec(TESTER_SERVICE_NAME, ExecRecipe(
        ["node", "index.mjs", BOOTNODE_URL] + node_urls
    ))
