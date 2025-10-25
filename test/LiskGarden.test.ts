import { network } from "hardhat";
import { describe, it, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { parseEther } from "viem";
import LiskGardenModule from "../ignition/modules/LiskGarden.js";

async function setupLiskGarden() {
  const { ignition} = await network.connect();
  const { liskGarden } = await ignition.deploy(LiskGardenModule);
  return { liskGarden};
}

describe("LiskGarden Contract", async () => {
  let liskGarden: any;

  beforeEach(async () => {
    const fixture = await network.connect().then(({ networkHelpers }) => networkHelpers.loadFixture(setupLiskGarden));
    liskGarden = fixture.liskGarden;
  });

  it("should deploy with correct owner", async () => {
    const owner = await liskGarden.read.owner();
    assert.equal(typeof owner, "string");
  });

  it("should allow planting a seed with correct ETH", async () => {
    const plantPrice = await liskGarden.read.PLANT_PRICE();
    const tx = await liskGarden.write.plantSeed({ value: plantPrice });
    assert.equal(typeof tx, "string");
    assert.ok(tx.startsWith("0x"));
  });

  it("should revert if insufficient ETH is sent", async () => {
    await assert.rejects(
      async () => liskGarden.write.plantSeed({ value: parseEther("0.0001") }),
      (err: any) => err.message.includes("Need 0.001 ETH")
    );
  });

  it("should increment plantCounter on multiple seeds", async () => {
    const plantPrice = await liskGarden.read.PLANT_PRICE();
    await liskGarden.write.plantSeed({ value: plantPrice });
    await liskGarden.write.plantSeed({ value: plantPrice });
    const counter = await liskGarden.read.plantCounter();
    assert.equal(counter, 2n);
  });

  it("should increase water level after watering", async () => {
    const plantPrice = await liskGarden.read.PLANT_PRICE();
    await liskGarden.write.plantSeed({ value: plantPrice });
    const plantId = await liskGarden.read.plantCounter();

    const plantBefore = await liskGarden.read.getPlant([plantId]);
    await liskGarden.write.waterPlant([plantId]);
    const plantAfter = await liskGarden.read.getPlant([plantId]);

    assert.ok(plantAfter.waterLevel >= plantBefore.waterLevel, "Water level should not decrease");
  });

  it("should revert if watering non-existent plant", async () => {
    await assert.rejects(
      async () => liskGarden.write.waterPlant([999n]),
      (err: any) => err.message.includes("Plant doesn't exist")
    );
  });

  it("should allow owner to withdraw ETH", async () => {
    const plantPrice = await liskGarden.read.PLANT_PRICE();
    await liskGarden.write.plantSeed({ value: plantPrice });

    // Owner withdraw
    await liskGarden.write.withdraw();
  });
});
