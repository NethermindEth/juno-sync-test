participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)

def run(plan, juno_version = "v0.11.9-23-g8670ea77", node_count=1):
    tester = plan.add_service(
        name="tester",
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
            "/ip4/35.243.137.203/tcp/7777/p2p/12D3KooWNKz9BJmyWVFUnod6SQYLG4dYZNhs3GrMpiot63Y1DLYS,/ip4/35.231.83.158/tcp/7777/p2p/12D3KooWPuESJuHpSPEzxNXVhEPKzsAM2XzQkHF5hGiSLfXytDCw,/ip4/35.237.118.253/tcp/7777/p2p/12D3KooWH74yt5NPvymHHq9BEbccpELjqzBJakdyYC7EwQp3uzm4,/ip4/34.74.209.221/tcp/7777/p2p/12D3KooWQfujjvm117NC6voD7yxPcwrFnnSbNq51AGnNRtwW3Rj8,/ip4/34.23.174.188/tcp/7777/p2p/12D3KooWHfngF8o6NLbUtEiWgfvVvchFhTqx1xMJAwNUr2dFxj4D,/ip4/35.196.2.192/tcp/7777/p2p/12D3KooWCgVW1s29YWkx3pt1RBbUrzLyb54NERUkKAWsKZ9iqLGV",
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

    for i in range(1, node_count + 1):
        node_name = "node-{}".format(i)
        participants.run_participant(plan, node_name, regular, None)
    