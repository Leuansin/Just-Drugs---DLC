--[[
==============================================================================
                                JustDrugsDLC Mod
                                 © 2025 [Leuan]
------------------------------------------------------------------------------
  Description: Project Zomboid mod that adds 51 different types of drugs.
  Updated for Build 42 compatibility with logic fixes
------------------------------------------------------------------------------
   Author:          [Leuan]
   Version:        2.0.0 (B42 Compatible)
==============================================================================
--]]

DrugsDLC = DrugsDLC or {}

-- B42 Compatible: Safe player check
local function getSafePlayer()
    local player = getPlayer()
    if not player then
        print("DrugsDLC: ERROR - Player not found!")
        return nil
    end
    return player
end

-- Crear el trait "Drogadicto" (B42 Compatible)
DrugsDLC.TraitDrogadicto = function()
    local TraitAdicto = TraitFactory.addTrait("Drogadicto", getText("Drug Addict"), -8,
        getText("You are a Drug Addict. Your body will ask for drugs and you will get bored.\nYou're going to experience Withdrawal effects if you don't consume for 12 hours.\nYou can eventually outgrow your addiction if you don't consume in 21 days.\n(This trait will be added automatically if you consume a lot of drugs ingame)"), false, false)
    
    -- B42 Compatible: Add custom icon if available
    if TraitAdicto.setIcon then
        TraitAdicto:setIcon("media/ui/traits/trait_drogadicto.png")
    end

    -- B42 Compatible: Update trait system
    TraitFactory.sortList()
    
    -- B42 Compatible: Ensure trait descriptions are properly set
    local traitList = TraitFactory.getTraits()
    for i = 0, traitList:size() - 1 do
        local trait = traitList:get(i)
        if trait and BaseGameCharacterDetails.SetTraitDescription then
            BaseGameCharacterDetails.SetTraitDescription(trait)
        end
    end
    
    print("DrugsDLC: Drogadicto trait added successfully")
end

-- Crear el trait "Drug Lord" (B42 Compatible)
DrugsDLC.TraitWalterWhite = function()
    local TraitWalterWhite = TraitFactory.addTrait("WalterWhite", getText("Drug Dealer"), 4,
        getText("You were always smarter than the rest. You were the one making & selling the drugs to them!\nStart with the Recipes Learned of How to Cook Drug (Only hard drugs, not pharmaceutical drugs)"), false, false)

    -- B42 Compatible: Add custom icon if available
    if TraitWalterWhite.setIcon then
        TraitWalterWhite:setIcon("media/ui/traits/trait_walterwhite.png")
    end

    -- B42 Compatible: Recipe list - using table for better organization
    local walterWhiteRecipes = {
        "Make Ephedrine Compound", "Produce Meth Compound", "Dry the Meth Compound",
        "Make Acid Base", "Make Acid Compound", "Dry the Acid Compound",
        "Make Benzodiazepine Compound", "Produce Xanax Compound", "Dry Xanax Compound",
        "Make Raw Cocaine Compound", "Refine Cocaine Compound", "Dry Refined Cocaine",
        "Extract Psilocybin", "Mix Psilocybin Compound", "Grow and Pack Shrooms",
        "Extract Morphine Compound", "Produce Refined Heroin", "Dry Refined Morphine",
        "Make Fentanyl Compound", "Dry and Pack Fentanyl",
        "Make Amphetamine Salts", "Dry Amphetamine Salts",
        "Extract Crack Compound", "Dry and Pack the Crack",
        "Extract Phenylethylamine"
    }

    -- B42 Compatible: Add recipes safely
    for _, recipe in ipairs(walterWhiteRecipes) do
        if TraitWalterWhite.getFreeRecipes then
            TraitWalterWhite:getFreeRecipes():add(recipe)
        end
    end

    TraitFactory.sortList()
    
    -- B42 Compatible: Update trait descriptions
    local traitList = TraitFactory.getTraits()
    for i = 0, traitList:size() - 1 do
        local trait = traitList:get(i)
        if trait and BaseGameCharacterDetails.SetTraitDescription then
            BaseGameCharacterDetails.SetTraitDescription(trait)
        end
    end
    
    print("DrugsDLC: WalterWhite trait added successfully")
end

-- Crear el trait "Farmaceutico" (B42 Compatible)
DrugsDLC.TraitFarmaceutico = function()
    local TraitJesseWhite = TraitFactory.addTrait("Farmaceutico", getText("Pharmaceutical"), 2,
        getText("You went to university to study medicine\nEnd up being Pharmaceutical and knowing all pharmacy drugs recipes."), false, false)

    -- B42 Compatible: Add custom icon if available
    if TraitJesseWhite.setIcon then
        TraitJesseWhite:setIcon("media/ui/traits/trait_farmaceutico.png")
    end

    -- B42 Compatible: Recipe list - using table for better organization
    local farmaceuticoRecipes = {
        "Make Adderall Compound", "Produce Adderall", "Make Clonazepam Compound",
        "Make Clonazepam", "Make Codeine Compound", "Make Codeine", "Make Lean",
        "Make Morphine Compound", "Make Morphine", "Make Oxycodone Compound",
        "Make Oxycodone", "Make Percocet Compound", "Make Percocet",
        "Make Phenobarbital Compound", "Make Phenobarbital", "Make Tramadol Compound",
        "Make Tramadol", "Make Vicodin Compound", "Make Vicodin",
        "Make Benzodiazepine Compound", "Produce Xanax Compound", "Dry Xanax Compound"
    }

    -- B42 Compatible: Add recipes safely
    for _, recipe in ipairs(farmaceuticoRecipes) do
        if TraitJesseWhite.getFreeRecipes then
            TraitJesseWhite:getFreeRecipes():add(recipe)
        end
    end

    TraitFactory.sortList()
    
    -- B42 Compatible: Update trait descriptions
    local traitList = TraitFactory.getTraits()
    for i = 0, traitList:size() - 1 do
        local trait = traitList:get(i)
        if trait and BaseGameCharacterDetails.SetTraitDescription then
            BaseGameCharacterDetails.SetTraitDescription(trait)
        end
    end
    
    print("DrugsDLC: Farmaceutico trait added successfully")
end

-- Dar items al spawnear el personaje (B42 Compatible)
DrugsDLC.GivePlayerItem = function(player)
    -- B42 Compatible: Use provided player parameter
    local targetPlayer = player or getSafePlayer()
    if not targetPlayer then return end
    
    local inventory = targetPlayer:getInventory()
    if not inventory then return end

    -- B42 Compatible: Safe item addition with validation
    local function safeAddItem(itemType)
        local item = inventory:AddItem(itemType)
        if item then
            return true
        else
            print("DrugsDLC: WARNING - Could not add item: " .. tostring(itemType))
            return false
        end
    end

    -- Give items based on traits
    if targetPlayer:HasTrait("Drogadicto") then
        safeAddItem("DrugsDLC.Cocaine")
        safeAddItem("DrugsDLC.Fentanyl")
        safeAddItem("DrugsDLC.NarcanSOS")
        safeAddItem("DrugsDLC.Bismuth")
        safeAddItem("DrugsDLC.Loperamide")
        safeAddItem("DrugsDLC.DrugPipe") -- Added missing DrugPipe mentioned in comment
        
        targetPlayer:Say(getText("IGUI_AddictStartingItems") or "I need my medicine...")
    end

    if targetPlayer:HasTrait("Farmaceutico") then
        safeAddItem("DrugsDLC.NarcanSOS")
        safeAddItem("DrugsDLC.IbuprofenBox") -- Fixed: Changed from Ibuprofen to IbuprofenBox
        safeAddItem("DrugsDLC.Loperamide")
        safeAddItem("DrugsDLC.MedicalBag") -- Added medical bag for roleplay
        
        targetPlayer:Say(getText("IGUI_PharmacistStartingItems") or "Time to help people.")
    end
    
    if targetPlayer:HasTrait("WalterWhite") then
        safeAddItem("DrugsDLC.EphedrineBottle")
        safeAddItem("DrugsDLC.AmmoniaBottle")
        safeAddItem("DrugsDLC.DrugPipe")
        safeAddItem("DrugsDLC.NeopreneBag")
        
        targetPlayer:Say(getText("IGUI_CookStartingItems") or "Let's cook.")
    end
end

-- B42 Compatible: Initialize traits on mod load
local function initializeTraits()
    DrugsDLC.TraitDrogadicto()
    DrugsDLC.TraitFarmaceutico()
    DrugsDLC.TraitWalterWhite()
    
    print("==============================================================================")
    print("------Just Drugs DLC: All 3 traits initialized succesfully for Build 42------")
    print("==============================================================================")

end

-- B42 Compatible: Give items when player is created (more reliable than OnNewGame)
local function onCreatePlayer(module, player)
    if module == 'JustDrugsDLC' then
        DrugsDLC.GivePlayerItem(player)
    end
end

-- B42 Compatible: Give items when game is loaded
local function onGameStart()
    local player = getSafePlayer()
    if player then
        -- Check if this is a new game by looking for mod data
        local modData = player:getModData()
        if not modData.drugsDLCInitialized then
            DrugsDLC.GivePlayerItem(player)
            modData.drugsDLCInitialized = true
        end
    end
end

-- B42 Compatible event registration
Events.OnGameBoot.Add(initializeTraits)
Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnGameStart.Add(onGameStart)