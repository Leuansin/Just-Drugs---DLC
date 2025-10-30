--[[
==============================================================================
                                JustDrugsDLC Mod
                                 © 2025 [Leuan]
------------------------------------------------------------------------------
  Description: Project Zomboid mod that adds 51 different types of drugs.
  From Pharmaceutical ones to Heavy Drugs and Herbal Plant Based ones.
  Each one with a Crafting, Packaging, Injection and Overdose System
  Comes with some traits and funny easter-eggs. Configurable via sandbox.
------------------------------------------------------------------------------
   Autor:          [Leuan]
   Date:          [30th October 2025]
   Version:        2.0.0
   Contact:       [https://steamcommunity.com/leuanwastaken]
------------------------------------------------------------------------------
                                  LICENSE
    This file is part of the Just Drugs - DLC mod for Project Zomboid, I allow
    local modifications for communities / servers, as long as you leave credit
    for using this awesome project! Hope this bring awareness to the devs to add
    content like these into the official game.

    Please if you really like this mod and it's working flawlessly on your servers
    or communities, please feel free to leave a donation ^^

------------------------------------------------------------------------------
                             ¡Happy modding! ✨
==============================================================================
]]


--[[
==============================================================================
                                JustDrugsDLC Mod
                                 © 2024 [Leuan]
------------------------------------------------------------------------------
  Updated for Build 42
==============================================================================
]]

require 'Items/SuburbsDistributions'
require 'Items/ProceduralDistributions'
require 'Vehicles/VehicleDistributions'
require 'Items/Distribution_BagsAndContainers'

-- Sandbox variables initialization
local function setLocalSandboxVars()
    ZombieDrugLootSpawnRated = SandboxVars.JustDrugsDLC.ZombieDrugLootSpawnRate or 2
    ZombieDrugLootSpawnRate = ZombieDrugLootSpawnRated
  
    AlucinogenasSpawnRated = SandboxVars.JustDrugsDLC.AlucinogenasSpawnRate or 4
    AlucinogenasSpawnRate = AlucinogenasSpawnRated
  
    InhalablesSpawnRated = SandboxVars.JustDrugsDLC.InhalablesSpawnRate or 4
    InhalablesSpawnRate = InhalablesSpawnRated
  
    PolvoSpawnRated = SandboxVars.JustDrugsDLC.PolvoSpawnRate or 4
    PolvoSpawnRate = PolvoSpawnRated
  
    HerbalSpawnRated = SandboxVars.JustDrugsDLC.HerbalSpawnRate or 4
    HerbalSpawnRate = HerbalSpawnRated
  
    PillsSpawnRated = SandboxVars.JustDrugsDLC.PillsSpawnRate or 4
    PillsSpawnRate = PillsSpawnRated
  
    DesintoxicantesSpawnRated = SandboxVars.JustDrugsDLC.DesintoxicantesSpawnRate or 4
    DesintoxicantesSpawnRate = DesintoxicantesSpawnRated
  
    LibrosChem101SpawnRated = SandboxVars.JustDrugsDLC.LibrosChem101SpawnRate or 4
    LibrosChem101SpawnRate = LibrosChem101SpawnRated
  
    BottleCompoundSpawnRated = SandboxVars.JustDrugsDLC.BottleCompoundSpawnRate or 2
    BottleCompoundSpawnRate = BottleCompoundSpawnRated
  
    BolsasDeDrogaSpawnRated = SandboxVars.JustDrugsDLC.BolsasDeDrogaSpawnRate or 2
    BolsasDeDrogaSpawnRate = BolsasDeDrogaSpawnRated
end

setLocalSandboxVars()

-- Distribution insertion functions
function insertProceduralDistribution(itemsAndChances, locations)
    for item, chance in pairs(itemsAndChances) do
        for i, location in ipairs(locations) do
            if ProceduralDistributions.list[location] and ProceduralDistributions.list[location].items then
                table.insert(ProceduralDistributions.list[location].items, item)
                table.insert(ProceduralDistributions.list[location].items, chance)
            end
        end
    end
end

function insertSuburbsDistribution(itemsAndChances, locations)
    for item, chance in pairs(itemsAndChances) do
        for i, location in ipairs(locations) do
            if SuburbsDistributions.all[location] and SuburbsDistributions.all[location].items then
                table.insert(SuburbsDistributions.all[location].items, item)
                table.insert(SuburbsDistributions.all[location].items, chance)
            end
        end
    end
end

function insertVehicleDistribution(itemsAndChances, locations)
    for item, chance in pairs(itemsAndChances) do
        for i, location in ipairs(locations) do
            if VehicleDistributions[location] and VehicleDistributions[location].items then
                table.insert(VehicleDistributions[location].items, item)
                table.insert(VehicleDistributions[location].items, chance)
            end
        end
    end
end

function insertBagsDistribution(itemsAndChances, locations)
    for item, chance in pairs(itemsAndChances) do
        for i, location in ipairs(locations) do
            if BagsAndContainers[location] and BagsAndContainers[location].items then
                table.insert(BagsAndContainers[location].items, item)
                table.insert(BagsAndContainers[location].items, chance)
            end
        end
    end
end

-- Drug categories
local alucinogenos = {
    ["DrugsDLC.Acid"] = 0.01 * AlucinogenasSpawnRate,
    ["DrugsDLC.Shrooms"] = 0.01 * AlucinogenasSpawnRate,
}

local pastillas = {
    ["DrugsDLC.AcetaminophenBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.AdderallBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.ClonazepamBox"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.CodeineBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.MDMA"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.IbuprofenBox"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.MorphineBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.OxycodoneBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.PercoBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.PhenobarbitalBox"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.TentramitrozonBox"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.TramadolBox"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.VicodinBottle"] = 0.01 * PillsSpawnRate,
    ["DrugsDLC.Xanax"] = 0.01 * PillsSpawnRate,
}

local polvos = {
    ["DrugsDLC.Meth"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.Crack"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.DMT"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.Cocaine"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.Heroin"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.Amphetamines"] = 0.01 * PolvoSpawnRate,
    ["DrugsDLC.Fentanyl"] = 0.01 * PolvoSpawnRate,
}

local inhalables = {
    ["DrugsDLC.RexonaDesodorante"] = 0.01 * InhalablesSpawnRate,
    ["DrugsDLC.OldSpiceDesodorante"] = 0.01 * InhalablesSpawnRate,
    ["DrugsDLC.AxeDesodorante"] = 0.01 * InhalablesSpawnRate,
}

local desintoxicantes = {
    ["DrugsDLC.Bismuth"] = 0.01 * DesintoxicantesSpawnRate,
    ["DrugsDLC.NarcanSOS"] = 0.01 * DesintoxicantesSpawnRate,
    ["DrugsDLC.Loperamide"] = 0.01 * DesintoxicantesSpawnRate,
}

local libros = {
    ["DrugsDLC.AcidLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.HongosLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.AddyLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.ClonaLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.CodeineLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.MDMALibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.LeanLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.MorphineLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.OxyLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.PercLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.PhenoBLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.TramadolLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.VicodinLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.XanaxLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.AmphLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.CocaLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.CrackLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.DMTLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.FentLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.HeroinLibro"] = 0.01 * LibrosChem101SpawnRate,
    ["DrugsDLC.MethLibro"] = 0.01 * LibrosChem101SpawnRate,
}

local componentes = {
    ["DrugsDLC.EphedrineBottle"] = 0.01 * BottleCompoundSpawnRate,
    ["DrugsDLC.IodoricAcidBottle"] = 0.01 * BottleCompoundSpawnRate,
    ["DrugsDLC.AmmoniaBottle"] = 0.01 * BottleCompoundSpawnRate,
    ["DrugsDLC.PhenyBottle"] = 0.01 * BottleCompoundSpawnRate,
    ["DrugsDLC.PotassiumBottle"] = 0.01 * BottleCompoundSpawnRate,
    ["DrugsDLC.EthanolBottle"] = 0.01 * BottleCompoundSpawnRate,
}

local equipamiento = {
    ["DrugsDLC.DrugPipe"] = 0.003,
    ["DrugsDLC.Needle"] = 0.006,
    ["DrugsDLC.Blockcocaine"] = 0.001,
    ["DrugsDLC.BagShrooms"] = 0.002,

    -- Evento Halloween --
    ["DrugsDLC.HalloweenPumpkinDrug"] = 0.0005,

}

local bolsas = {
    ["DrugsDLC.BolsaDeDroga"] = 0.01 * BolsasDeDrogaSpawnRate,
}


-- Combine all drugs for general distribution
local todasLasDrogas = {}
for k, v in pairs(alucinogenos) do todasLasDrogas[k] = v end
for k, v in pairs(pastillas) do todasLasDrogas[k] = v end
for k, v in pairs(polvos) do todasLasDrogas[k] = v end
for k, v in pairs(inhalables) do todasLasDrogas[k] = v end
for k, v in pairs(desintoxicantes) do todasLasDrogas[k] = v end
for k, v in pairs(equipamiento) do todasLasDrogas[k] = v end
for k, v in pairs(bolsas) do todasLasDrogas[k] = v end

-- General locations for all drugs
local ubicacionesGenerales = {
    "Antiques",
    "ArmyBunkerLockers",
    "BackstageCounter",
    "BackstageDresser",
    "BackstageLockers",
    "BackstageRigging",
    "BandPracticeClothing",
    "BandPracticeInstruments",
    "BarCounterGlasses",
    "BarCounterMisc",
    "BarCrateDarts",
    "BarCratePool",
    "BathroomCabinet",
    "BathroomCounter",
    "BathroomCounterEmpty",
    "BathroomCounterMotel",
    "BathroomCounterNoMeds",
    "BathroomShelf",
    "BedroomDresser",
    "BedroomDresserClassy",
    "BedroomDresserRedneck",
    "BedroomSidetable",
    "BedroomSidetableClassy",
    "BedroomSidetableRedneck",
    "BowlingAlleyLockers",
    "BoxingLockers",
    "CampingLockers",
    "ControlRoomCounter",
    "CrateCamping",
    "CrateChips",
    "CrateCigarettes",
    "CrateEmptyBottles1",
    "CrateEmptyBottles2",
    "CrateEmptyMixed",
    "CrateEmptyTinCans",
    "CrateHumanitarian",
    "CrateLinens",
    "CrateNewspapers",
    "CratePeanuts",
    "CrateRandomJunk",
    "CrateSodaBottles",
    "CrateSodaCans",
    "CyberCafeDesk",
    "DinerBackRoomCounter",
    "DishCabinetGeneric",
    "DishCabinetVIPLounge",
    "FactoryLockers",
    "GeneratorRoom",
    "Gifts",
    "GymLockers",
    "Hiker",
    "Hobbies",
    "HolidayStuff",
    "HospitalLockers",
    "Hunter",
    "HuntingLockers",
    "ImprovisedCrafts",
    "JockeyLockers",
    "JunkHoard",
    "LaboratoryLockers",
    "Locker",
    "LockerArmyBedroom",
    "LockerArmyBedroomHome",
    "LockerClassy",
    "MedicalClinicDrugs",
    "MedicalClinicTools",
    "MedicalOfficeDesk",
    "MorgueTools",
    "OfficeDeskHome",
    "OfficeDeskHomeClassy",
    "PharmacyCosmetics",
    "PlankStashGun",
    "PlankStashMagazine",
    "PlankStashMisc",
    "PlankStashMoney",
    "PoliceCaptainCabinet",
    "PoliceCaptainDesk",
    "PoliceDesk",
    "PoliceEvidence",
    "PoliceLockers",
    "PoolLockers",
    "PrisonCellRandom",
    "PrisonCellRandomClassy",
    "PrisonGuardLockers",
    "SafehouseBin_Late",
    "SafehouseBin_Mid",
    "SafehouseBin",
    "SafehouseMedical_Late",
    "SafehouseMedical_Mid",
    "SafehouseMedical",
    "SchoolLockers",
    "SchoolLockersBad",
    "SecurityDesk",
    "SecurityLockers",
    "SmokingRoomCigars",
    "SmokingRoomPipes",
    "StoreCounterBagsPaper",
    "StoreCounterTobacco",
    "StripClubDressers",
    "SurvivalGear",
    "TobaccoStoreAccessories",
    "TobaccoStoreChew",
    "TobaccoStoreCigarettes",
    "TobaccoStoreCigarillos",
    "TobaccoStoreCigars",
    "TobaccoStorePipes",
    "Trapper",
    "UniversityWardrobe",
    "VacationStuff",
    "WardrobeClassy",
    "WardrobeGeneric",
    "WardrobeRedneck",
}

-- High-density drug locations
local ubicacionesAltaDensidad = {
    "DerelictHouseCrime",
    "DerelictHouseDrugs",
    "DerelictHouseJunk",
    "DerelictHouseParty",
    "DerelictHouseSquatter",
    "DrugLabMoney",
    "DrugLabOutfit",
    "DrugLabSupplies",
    "DrugShackDrugs",
    "DrugShackMisc",
    "DrugShackTools",
}

-- Medical locations
local ubicacionesMedicas = {
    "MedicalClinicDrugs",
    "MedicalStorageDrugs",
    "MedicalStorageTools",
    "StoreShelfMedical",
}

-- Insert distributions
insertProceduralDistribution(todasLasDrogas, ubicacionesGenerales)
insertProceduralDistribution(todasLasDrogas, ubicacionesAltaDensidad)
insertProceduralDistribution(pastillas, ubicacionesMedicas)

-- Suburbs distributions
insertSuburbsDistribution(todasLasDrogas, {"bin", "inventoryfemale", "inventorymale", "sidetable"})

-- Vehicle distributions
insertVehicleDistribution(todasLasDrogas, {"GloveBox", "TrunkStandard", "TrunkHeavy", "TrunkSports", "SeatRear"})

-- Bags and containers distributions
insertBagsDistribution(todasLasDrogas, {
    "ALICEpack_Army",
    "Bag_BigHikingBag",
    "Bag_GolfBag",
    "Bag_NormalHikingBag",
    "Bag_Schoolbag",
    "Bag_WorkerBag",
    "Handbag",
    "Purse",
    "Wallet",
    "Wallet_Female",
    "Wallet_Male",
})

-- Special distributions for books and components
insertProceduralDistribution(libros, {"OfficeDesk", "OfficeDeskHome", "DeskGeneric"})
insertProceduralDistribution(componentes, {"MedicalClinicTools", "HospitalLockers", "LaboratoryLockers"})

print("JustDrugsDLC Distributions loaded successfully for Build 42")