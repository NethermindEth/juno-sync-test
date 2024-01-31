import { RpcProvider } from "starknet";


const base = new RpcProvider({ nodeUrl: process.argv[2] })
const syncing = new RpcProvider({ nodeUrl: process.argv[3] });
console.log(await base.getSyncingStats())
console.log(await syncing.getSyncingStats())
let baseBlock = await base.getBlockLatestAccepted();
const timer = setInterval(async function () {
    const targetLatestBlock = await syncing.getBlockLatestAccepted();
    console.log("base: " + baseBlock.block_number + ", target: " + targetLatestBlock.block_number);
    console.log(await base.getSyncingStats())
    console.log(await syncing.getSyncingStats())
    if (targetLatestBlock.block_number >= baseBlock.block_number) {
        baseBlock = await base.getBlockLatestAccepted();
        if (targetLatestBlock.block_number >= baseBlock.block_number) {
            clearInterval(timer);
        }
    }
}, 10000)
// setTimeout(() => {
//     clearInterval(timer)
// }, 24 * 60 * 60 * 1000)
