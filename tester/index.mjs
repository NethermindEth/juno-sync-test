import fetch from 'node-fetch';
import { RpcProvider } from "starknet";

const baseUrl = process.argv[2];
const syncingNodeUrl = process.argv[3];

fetch(`${baseUrl}get_block?blockNumber=latest`)
  .then(response => response.json())
  .then(async data => {
    const baseBlockNumber = data.block_number;
    console.log("Base block number:", baseBlockNumber);

    const syncing = new RpcProvider({ nodeUrl: syncingNodeUrl });

    const intervalId = setInterval(async () => {
      const targetLatestBlock = await syncing.getBlockLatestAccepted();
      console.log("Target latest block number:", targetLatestBlock.block_number);

      if (targetLatestBlock.block_number >= baseBlockNumber) {
        console.log("Target node block number has caught up.");
        clearInterval(intervalId);
        process.exit(0);
      }
    }, 60000);

    setTimeout(() => {
      console.error("Failed to sync within 1h.");
      clearInterval(intervalId);
      process.exit(1);
    }, 3600000);
  })
  .catch(error => {
    console.error('Error occurred:', error);
    process.exit(1);
  });

