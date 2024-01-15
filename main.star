participants = import_module(
    "github.com/piwonskp/startnet/src/participants.star"
)


BOOTNODE = {
    "type": "juno",
    "image": "nethermindeth/juno:p2p-syncing",
    "extra_args": [
        "--p2p", 
        "--p2p-bootnode", 
        "--p2p-addr", 
        "/ip4/0.0.0.0/tcp/7777", 
        "--p2p-private-key",
        "5f6cdc3aebcc74af494df054876100368ef6126e3a33fa65b90c765b381ffc37a0a63bbeeefab0740f24a6a38dabb513b9233254ad0020c721c23e69bc820089",
        "--network",
        "sepolia",
    ]
}


def run(plan, args={}):
    bootnode = participants.run_participant(plan, "bootnode", BOOTNODE, None)
    
    regular = {
        "type": "juno",
        "image": "nethermindeth/juno:p2p-syncing",
        "extra_args": [
            "--p2p", 
            "--p2p-boot-peers", 
            "/ip4/{}/tcp/7777/p2p/12D3KooWLdURCjbp1D7hkXWk6ZVfcMDPtsNnPHuxoTcWXFtvrxGG".format(bootnode.ip_address),
            "--network",
            "sepolia",
            ]
    }
    node = participants.run_participant(plan, "node-1", regular, None)
