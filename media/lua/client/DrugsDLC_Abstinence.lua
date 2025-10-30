--[[
==============================================================================
                         JustDrugsDLC - Withdrawal System (B42)
                            © 2025 [Leuan]
------------------------------------------------------------------------------
  Description: B42 compatible progressive withdrawal system.
  Replaces the B41 logic with a smooth, ramping system that triggers
  on drug consumption, not possession.
------------------------------------------------------------------------------
  Author:         [Leuan] (Logic refactored by Gemini)
  Version:        2.0.0 (B42 Compatible)
==============================================================================
--]]

DrugsDLC = DrugsDLC or {}

-- Local sandbox variables
local WithdrawalBoredomRate = 3
local AddictionCureTime = 504 -- 504 hours = 21 days

-- B42 Compatible sandbox variable loader
local function initSandboxVars()
    WithdrawalBoredomRate = SandboxVars.JustDrugsDLC.BoredomIncrement or 3
    AddictionCureTime = SandboxVars.JustDrugsDLC.SuperarAddicion or 504
end

-- B42 Compatible: Safe player check
local function getSafePlayer()
    local player = getPlayer()
    if not player then
        print("DrugsDLC (Withdrawal): ERROR - Player not found!")
        return nil
    end
    return player
end

-- B42 Compatible: Apply stat modifiers safely
local function applyStatModifiers(player, stats, bodyDamage, modifiers)
    if modifiers.stress then
        stats:setStress(math.max(0, math.min(stats:getStress() + modifiers.stress, 1.0)))
    end
    if modifiers.fatigue then
        stats:setFatigue(math.max(0, math.min(stats:getFatigue() + modifiers.fatigue, 1.0)))
    end
    if modifiers.pain then
        stats:setPain(math.max(0, math.min(stats:getPain() + modifiers.pain, 1.0)))
    end
    if modifiers.panic then
        stats:setPanic(math.max(0, math.min(stats:getPanic() + modifiers.panic, 1.0)))
    end
    if modifiers.boredom then
        bodyDamage:setBoredomLevel(math.max(0, math.min(bodyDamage:getBoredomLevel() + modifiers.boredom, 1.0)))
    end
end

--[[
==============================================================================
  CORE LOGIC: PROGRESSIVE WITHDRAWAL
  This function calculates how bad the withdrawal symptoms should be
  based on how long the player has been "clean".
==============================================================================
--]]
local function applyProgressiveWithdrawal(player, stats, bodyDamage, abstinenceHours)
    -- Grace period: No effects for the first 6 hours.
    if abstinenceHours < 6 then return end
    
    -- We define "peak" withdrawal at 7 days (168 hours).
    -- Severity is a 0.0 to 1.0 value based on time.
    local peakTime = 168.0
    local severity = math.min(abstinenceHours / peakTime, 1.0)
    
    -- Calculate progressive debuffs
    -- These will ramp up from 0 and max out at the defined value at 'peakTime'.
    local modifiers = {
        -- Boredom is constant, a nagging feeling.
        boredom = (WithdrawalBoredomRate / 100),
        -- Stress and Depression ramp up quickly.
        stress = 0.01 + (0.02 * severity),   -- Maxes at 0.03 per hour
        depression = 0.05 + (0.1 * severity), -- Maxes at 0.15 per hour
        -- Panic and Pain are less severe but grow.
        panic = 0.01 * severity,
        pain = 0.01 * severity,
        -- Fatigue is a slow, creeping debuff.
        fatigue = 0.005 * severity
    }
    
    -- Apply all calculated debuffs
    applyStatModifiers(player, stats, bodyDamage, modifiers)
end

local function sayWithdrawalLine(player, abstinenceHours)
    -- Using ZombRand to avoid message spam every single hour
    if ZombRand(4) ~= 0 then return end
    
    if abstinenceHours > 6 and abstinenceHours < 24 then
        player:Say("I need a fix...")
    elseif abstinenceHours > 48 and abstinenceHours < 72 then
        player:Say("It's getting hard... I just need one...")
    elseif abstinenceHours > 120 and abstinenceHours < 168 then
        player:Say("I can't take this anymore!")
    elseif abstinenceHours > 336 and abstinenceHours < 360 then
        player:Say("Two weeks... I think... I think the worst is over.")
    end
end

--[[
==============================================================================
  MASTER HOURLY FUNCTION
  This replaces BOTH of the old hourly functions.
  It's the only hourly event this script needs.
==============================================================================
--]]
function DrugsDLC.WithdrawalSystemUpdate()
    local player = getSafePlayer()
    if not player then return end

    if not player:HasTrait("Drogadicto") then
        return -- Only process for drug addicts
    end

    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    local modData = player:getModData()

    -- Initialize abstinence timer if needed
    if modData.abstinenceTimer == nil then
        modData.abstinenceTimer = 0
    end

    -- 1. Increment the timer every hour.
    --    (It only gets reset to 0 when a drug is *consumed*)
    modData.abstinenceTimer = modData.abstinenceTimer + 1
    local abstinenceHours = modData.abstinenceTimer

    -- 2. Check if the player is cured
    if abstinenceHours >= AddictionCureTime then
        -- Reset all withdrawal effects
        stats:setStress(0)
        stats:setFatigue(0)
        stats:setPain(0)
        stats:setPanic(0)
        bodyDamage:setDepression(0)
        bodyDamage:setBoredomLevel(0)
        
        player:getTraits():remove("Drogadicto")
        modData.abstinenceTimer = 0
        
        -- Reset addiction counter from the other file
        if modData.drugAddictionCounter then
             modData.drugAddictionCounter = 0
        end
        
        player:Say(getText("IGUI_Beat_DrugAddiction") or "I... I did it. I'm free.")
        return -- Stop processing, player is cured
    end

    -- 3. If not cured, apply progressive withdrawal effects
    applyProgressiveWithdrawal(player, stats, bodyDamage, abstinenceHours)
    
    -- 4. Make the player comment on their suffering
    sayWithdrawalLine(player, abstinenceHours)
end


--[[
==============================================================================
  FUNCTION WRAPPERS
  This is the new "reset" logic. We "wrap" the OnEat functions
  When they are called, we run their original code,
  and THEN we add our logic to reset the abstinence timer.
==============================================================================
--]]

-- A helper function to create the wrappers
local function createDrugWrapper(originalFuncName)
    -- Store the original OnEat function (from your other file)
    local originalFunc = _G[originalFuncName]
    
    -- Overwrite the global function with our new wrapper
    _G[originalFuncName] = function(player, item, character)
        
        -- 1. Run the original OnEat code (applies effects, addiction points, etc.)
        if originalFunc then
            originalFunc(player, item, character)
        end
        
        -- 2. Add our new logic: Reset the withdrawal timer
        if character then
            local modData = character:getModData()
            if modData then
                -- If player was in withdrawal, they feel ashamed
                if modData.abstinenceTimer and modData.abstinenceTimer > 6 then
                    character:Say("I shouldn't have done that...")
                end
                
                -- Reset the timer!
                modData.abstinenceTimer = 0
            end
        end
    end
end

-- This function runs on game start to create all the wrappers
function DrugsDLC.WrapOnEatFunctions()
    -- We wrap every function that counts as "taking a drug"
    createDrugWrapper("OnEat_HasTakenDrugs")
    createDrugWrapper("OnEat_HasTakenCocaine")
    createDrugWrapper("OnEat_HasTakenFentanyl")
    createDrugWrapper("OnEat_HasTakenXanax")
    
    print("Just Drugs DLC: Withdrawal System Succesfully Loaded in B42.")
end


--[[
==============================================================================
  EVENT REGISTRATION
==============================================================================
--]]

-- B42 Compatible: Initialize mod data
local function onGameLoad()
    local player = getSafePlayer()
    if not player then return end
    
    local modData = player:getModData()
    modData.abstinenceTimer = modData.abstinenceTimer or 0
    
    print("DrugsDLC (Withdrawal): System initialized.")
end

-- Initialize sandbox vars first
Events.OnGameStart.Add(initSandboxVars)
Events.OnGameBoot.Add(initSandboxVars) -- For sandbox changes mid-game

-- Initialize timers for new or loaded games
Events.OnGameStart.Add(onGameLoad)
Events.OnNewGame.Add(onGameLoad)

-- This is CRITICAL. It waits for your *other* OnEat file to load,
-- and *then* it wraps the functions.
Events.OnGameStart.Add(DrugsDLC.WrapOnEatFunctions)

-- This is now the ONLY hourly event we need.
Events.EveryHours.Add(DrugsDLC.WithdrawalSystemUpdate)