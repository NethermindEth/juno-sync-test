import { RpcProvider } from "starknet";

const base = new RpcProvider({ nodeUrl: process.argv[2] });
const syncing = new RpcProvider({ nodeUrl: process.argv[3] });

async function syncNode() {
    let baseBlock = await base.getBlockLatestAccepted();
    console.log(`Initial base block: ${baseBlock.block_number}`);

    const timer = setInterval(async () => {
        try {
            const syncingBlock = await syncing.getBlockLatestAccepted();
            console.log(`Base: ${baseBlock.block_number}, Syncing: ${syncingBlock.block_number}`);
            
            if (syncingBlock.block_number >= baseBlock.block_number) {
                console.log("Syncing node has caught up or surpassed the base node.");
                baseBlock = await base.getBlockLatestAccepted();
                if (syncingBlock.block_number >= baseBlock.block_number) {
                    console.log("Confirmed: Syncing node is up-to-date or ahead. Stopping checks.");
                    clearInterval(timer);
                }
            }
        } catch (error) {
            console.error(`Error during sync check: ${error.message}`);
            clearInterval(timer);
        }
    }, 10000);

    setTimeout(() => {
        console.log("Stopping automatic checks after 30 minutes.");
        clearInterval(timer);
    }, 30 * 60 * 1000);
}

syncNode().catch(error => {
    console.error(`Error occurred: ${error.message}`);
    process.exit(1);
});
