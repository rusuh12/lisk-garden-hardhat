import { network } from "hardhat";

async function main() {
  try {
    const { viem } = await network.connect();
    const CONTRACT_ADDRESS = "0x77B39033Ba0CD7DC1F2C305BE4B6Df90ab717267";

    const LiskGarden = await viem.getContractAt(
      "LiskGarden",
      CONTRACT_ADDRESS
    );

    console.log("LiskGarden contract:", CONTRACT_ADDRESS);

    // Get plant counter
    const plantCounter = await LiskGarden.read.plantCounter();
    console.log("Total plants:", plantCounter.toString());

    // Plant a seed (costs 0.001 ETH)
    console.log("\n🌱 Planting a seed...");
    const plantPrice = await LiskGarden.read.PLANT_PRICE();
    
    const tx = await LiskGarden.write.plantSeed({ value: plantPrice });
    console.log("✅ Seed planted! Transaction:", tx);

    // Get new plant ID
    const newPlantCounter = await LiskGarden.read.plantCounter();
    const plantId = newPlantCounter;
    console.log("Your plant ID:", plantId.toString());

    //get detail
    const plant = await LiskGarden.read.getPlant([plantId]);
    console.log("\n🌿 Plant details:");
    console.log("  - ID:", plant.id.toString());
    console.log("  - Owner:", plant.owner);
    console.log("  - Stage:", plant.stage, "(0=SEED, 1=SPROUT, 2=GROWING, 3=BLOOMING)");
    console.log("  - Water Level:", plant.waterLevel.toString());
    console.log("  - Is Alive:", !plant.isDead);
  } catch (error: any) {
    console.error("\n Error:", error.message || error);
    throw error;
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
  
  
  
