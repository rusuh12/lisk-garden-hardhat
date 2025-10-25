// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LiskGarden {
    // Enums
    enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }

    // Structs
    struct Plant {
        uint256 id;
        address owner;
        GrowthStage stage;
        uint256 plantedDate;
        uint256 lastWatered;
        uint8 waterLevel;
        bool exists;
        bool isDead;
    }

    // State variables
    mapping(uint256 => Plant) public plants;
    mapping(address => uint256[]) public userPlants;
    uint256 public plantCounter;
    address public owner;

    // Constants
    uint256 public constant PLANT_PRICE = 0.001 ether;
    uint256 public constant HARVEST_REWARD = 0.003 ether;
    uint256 public constant STAGE_DURATION = 1 minutes;
    uint256 public constant WATER_DEPLETION_TIME = 30 seconds;
    uint8 public constant WATER_DEPLETION_RATE = 2;

    // Events
    event PlantSeeded(address indexed owner, uint256 indexed plantId);
    event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel);
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);
    event StageAdvanced(uint256 indexed plantId, GrowthStage newStage);
    event PlantDied(uint256 indexed plantId);

    constructor() {
        owner = msg.sender;
    }

    // Plant a seed
    function plantSeed() external payable returns (uint256) {
        require(msg.value >= PLANT_PRICE, "Need 0.001 ETH to plant");

        plantCounter++;
        uint256 newPlantId = plantCounter;

        plants[newPlantId] = Plant({
            id: newPlantId,
            owner: msg.sender,
            stage: GrowthStage.SEED,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            waterLevel: 100,
            exists: true,
            isDead: false
        });

        userPlants[msg.sender].push(newPlantId);

        emit PlantSeeded(msg.sender, newPlantId);

        return newPlantId;
    }

    // Calculate current water level
    function calculateWaterLevel(uint256 plantId) public view returns (uint8) {
        Plant storage plant = plants[plantId];

        if (!plant.exists || plant.isDead) {
            return 0;
        }

        uint256 timeSinceWatered = block.timestamp - plant.lastWatered;
        uint256 depletionIntervals = timeSinceWatered / WATER_DEPLETION_TIME;

        uint256 waterLost = depletionIntervals * WATER_DEPLETION_RATE;

        if (waterLost >= plant.waterLevel) {
            return 0;
        }

        return plant.waterLevel - uint8(waterLost);
    }

    // Update water level and check if plant died
    function updateWaterLevel(uint256 plantId) internal {
        Plant storage plant = plants[plantId];

        uint8 currentWater = calculateWaterLevel(plantId);
        plant.waterLevel = currentWater;

        if (currentWater == 0 && !plant.isDead) {
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    // Water a plant
    function waterPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant doesn't exist");
        require(plant.owner == msg.sender, "Not your plant");
        require(!plant.isDead, "Plant is dead");

        plant.waterLevel = 100;
        plant.lastWatered = block.timestamp;

        emit PlantWatered(plantId, 100);

        updatePlantStage(plantId);
    }

    // Update plant stage based on time
    function updatePlantStage(uint256 plantId) public {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant doesn't exist");

        // Update water level first
        updateWaterLevel(plantId);

        // Dead plants can't grow
        if (plant.isDead) {
            return;
        }

        uint256 timeSincePlanted = block.timestamp - plant.plantedDate;
        GrowthStage oldStage = plant.stage;

        if (timeSincePlanted >= STAGE_DURATION && plant.stage == GrowthStage.SEED) {
            plant.stage = GrowthStage.SPROUT;
        }
        else if (timeSincePlanted >= 2 * STAGE_DURATION && plant.stage == GrowthStage.SPROUT) {
            plant.stage = GrowthStage.GROWING;
        }
        else if (timeSincePlanted >= 3 * STAGE_DURATION && plant.stage == GrowthStage.GROWING) {
            plant.stage = GrowthStage.BLOOMING;
        }

        if (plant.stage != oldStage) {
            emit StageAdvanced(plantId, plant.stage);
        }
    }

    // Harvest a blooming plant
    function harvestPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.exists, "Plant doesn't exist");
        require(plant.owner == msg.sender, "Not your plant");
        require(!plant.isDead, "Plant is dead");

        updatePlantStage(plantId);

        require(plant.stage == GrowthStage.BLOOMING, "Plant not ready");

        plant.exists = false;

        emit PlantHarvested(plantId, msg.sender, HARVEST_REWARD);

        (bool success, ) = msg.sender.call{value: HARVEST_REWARD}("");
        require(success, "Transfer failed");
    }

    // Get plant info with current water level
    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    // Get user's plants
    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    // Owner can withdraw contract balance
    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    // Receive ETH
    receive() external payable {}
}