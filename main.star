participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)

URL = "http://{}:6060"
BOOTNODE_IP="35.231.83.158"
BOOTNODE_URL = URL.format(BOOTNODE_IP)
TESTER_SERVICE_NAME = "tester"

def run(plan, juno_version = "v0.11.1"):
    tester = plan.add_service(
        name=TESTER_SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="sync-test",
                build_context_dir="./tester",
            ),
        ),
    )
    
    regular = {
        "type": "juno",
        "image": "nethermindeth/juno:{}".format(juno_version),
        "extra_args": [
            "--p2p", 
            "--p2p-peers", 
            "/ip4/35.231.83.158/tcp/7777/p2p/12D3KooWPuESJuHpSPEzxNXVhEPKzsAM2XzQkHF5hGiSLfXytDCw,/ip4/34.74.209.221/tcp/7777/p2p/12D3KooWH74yt5NPvymHHq9BEbccpELjqzBJakdyYC7EwQp3uzm4,/ip4/35.237.118.253/tcp/7777/p2p/12D3KooWQfujjvm117NC6voD7yxPcwrFnnSbNq51AGnNRtwW3Rj8,/ip4/34.148.79.4/tcp/7777/p2p/12D3KooWNKz9BJmyWVFUnod6SQYLG4dYZNhs3GrMpiot63Y1DLYS",
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