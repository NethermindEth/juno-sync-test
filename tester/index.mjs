import { RpcProvider } from "starknet";

const feederNodeUrl = process.argv[2];
const syncingNodeUrls = process.argv.slice(3);

async function syncNodes() {
  const feederNode = new RpcProvider({ nodeUrl: feederNodeUrl });
  const targetBlock = (await feederNode.getBlockLatestAccepted()).block_number;
  console.log(`Target block number: ${targetBlock}`);

  for (let i = 0; i < syncingNodeUrls.length; i++) {
    console.log(`Checking sync for Node ${i + 1}`);
    await checkNodeSync(i + 1, syncingNodeUrls[i], targetBlock);
  }
  console.log("All nodes synced successfully.");
}

async function checkNodeSync(nodeIndex, nodeUrl, targetBlock) {
  return new Promise(async (resolve, reject) => {
    const syncingNode = new RpcProvider({ nodeUrl });
    let lastKnownBlock = 0;
    console.log(`Starting sync check for Node ${nodeIndex} at URL: ${nodeUrl}`);

    const intervalId = setInterval(async () => {
      try {
        const currentBlock = (await syncingNode.getBlockLatestAccepted()).block_number;
        lastKnownBlock = currentBlock;
        console.log(`Node ${nodeIndex} - Current block: ${currentBlock}`);

        if (currentBlock >= targetBlock) {
          console.log(`Node ${nodeIndex} has caught up. Sync time: ${Math.floor((Date.now() - startTime) / 1000 / 60)} minutes.`);
          clearInterval(intervalId);
          resolve();
        }
      } catch (error) {
        console.error(`Node ${nodeIndex} error: ${error.message}`);
        clearInterval(intervalId);
        reject(error);
      }
    }, 10000);

    const startTime = Date.now();
    setTimeout(() => {
      if (intervalId) {
        console.log(`Node ${nodeIndex} sync check timeout. Last known block: ${lastKnownBlock}, Target block: ${targetBlock}`);
        clearInterval(intervalId);
        reject(new Error(`Node ${nodeIndex} failed to sync within 1h.`));
      }
    }, 3600000);
  });
}

syncNodes().catch(error => {
  console.error(`Error occurred: ${error.message}`);
  process.exit(1);
});