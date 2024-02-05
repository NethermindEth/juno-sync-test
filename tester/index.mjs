import { RpcProvider } from "starknet";

const feederNodeUrl = process.argv[2];
const syncingNodeUrls = process.argv.slice(3);

async function syncNodes() {
  const feederNode = new RpcProvider({ nodeUrl: feederNodeUrl });
  const targetBlock = (await feederNode.getBlockLatestAccepted()).block_number;
  console.log(`Target block number: ${targetBlock}`);

  const promises = syncingNodeUrls.map((nodeUrl, index) => 
    checkNodeSync(index + 1, nodeUrl, targetBlock)
  );

  try {
    await Promise.all(promises);
    console.log("All nodes synced successfully.");
    process.exit(0);
  } catch (error) {
    console.error(`Sync failed: ${error.message}`);
    process.exit(1);
  }
}

function checkNodeSync(nodeIndex, nodeUrl, targetBlock) {
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
        clearInterval(intervalId);
        reject(new Error(`Node ${nodeIndex} error: ${error.message}`));
      }
    }, 10000);

    const startTime = Date.now();
    setTimeout(() => {
      clearInterval(intervalId);
      reject(new Error(`Node ${nodeIndex} failed to sync within 1h. Last known block: ${lastKnownBlock}, Target block: ${targetBlock}`));
    }, 3600000);
  });
}

syncNodes().catch(error => {
  console.error(`Error occurred: ${error.message}`);
});
