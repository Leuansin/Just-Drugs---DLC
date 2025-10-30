--[[
==============================================================================
                     JustDrugsDLC - Mod Combinado (B42)
                        © 2025 [Leuan]
------------------------------------------------------------------------------
  Descripción:
  Combina el sistema de adicción y efectos de JustDrugsDLC con un sistema
  de alucinaciones dinámicas activado por el consumo de hongos.

  Lógica de Alucinaciones adaptada de TAW (Mistor Love).
------------------------------------------------------------------------------
  Autor:         [Leuan]
  Versión:       2.0.0 (B42 Compatible)
==============================================================================
--]]

-- Envoltura global del Mod
DrugsDLC = DrugsDLC or {}

-- Variables locales para el estado de alucinación visual
local fakeZombie = nil
local zX, zY, zZ = nil, nil, nil

-- MODO DEBUG
DrugsDLC.DebugMode = false

-- Configuración de Alucinaciones (Valores por defecto de TAW, ahora internos)
local minBaseChance = 3.2
local maxBaseChance = 10.0
local shouldNightsAffect = true
local soundMultiplier = 1.0

-- Contadores globales de viaje (de tu script original)
DrugsDLC.alucinogenosConsumidosTripping = 0
DrugsDLC.alucinogenosConsumidosTrippingHardcore = 0

---
--- Tablas de Alucinaciones (Portadas de TAW)
---

local AudioHallucinations = {
    Inside = {
        "fakethump",
        "fakethumpsqueak",
        "fakedooropen",
        "fakewindowSmash",
    },
    Outside = {
        "arbustofalso",
        "maderarota",
    }
}

local AudioDirections = {"", "_left", "_right"}

local AudioSchizoPersonality = {
    Male = {
        "m_laugh_01",
        "m_laugh_02",
        "m_laugh_03",
        "m_laugh_04",
        "m_laugh_05",
    },
    Female = {
        "risa_mujer_01",
        "risa_mujer_02",
        "risa_mujer_03",
        "risa_mujer_04",
        "risa_mujer_05",
    },
    Whisper = {
        "whisper_01",
        "whisper_02",
        "whisper_03",
        "whisper_04",
    }
}

local VisualHallucinations = {
    Inside = {
        "FakeZombie",
        "FakeInfected",
    },
    Outside = {
        "FakeZombie",
        "FakeInfected",
    }
}

local GenericOutfits = {
    "Generic01",
    "Generic02",
    "Generic03",
    "Generic04",
    "Generic05",
}

--[[
==============================================================================
  REEMPLAZO DE 'HallucinationsLines.lua'
  Como no se proporcionó el archivo, se crea una tabla local con ejemplos.
  Puedes expandir esto con más líneas.
==============================================================================
--]]
local DrugsDLC_Lines = {
    RandomLines = {
        DayTime = {
            Inside = {
                Whispers = {"¿Qué fue eso?", "Escuché algo...", "No estoy solo."},
                Confusing = {"¿Dónde estoy?", "Esto no es real.", "¿Qué está pasando?"},
                Panic = {"¡No, no, no!", "¡Tengo que salir de aquí!", "¡Van a atraparme!"}
            },
            Outside = {
                Whispers = {"Shhh...", "Alguien me mira.", "¿Hay alguien ahí?"},
                Confusing = {"El cielo se mueve...", "Estos colores...", "¿Por qué todo brilla?"},
                Panic = {"¡Están en los árboles!", "¡Correee!", "¡No me sigas!"}
            }
        },
        NightTime = {
            Inside = {
                Whispers = {"(Susurros ininteligibles)", "Detrás de ti...", "No mires."},
                Confusing = {"Las paredes se cierran.", "No puedo... respirar.", "¿Es sangre?"},
                Panic = {"¡Déjenme en paz!", "¡Está en la casa!", "¡VOY A MORIR!"}
            },
            Outside = {
                Whispers = {"Te estamos viendo.", "Huye...", "Ven con nosotros..."},
                Confusing = {"La luna... me habla.", "No siento mis piernas.", "Todo da vueltas."},
                Panic = {"¡NO ME TOQUES!", "¡SOMBRAS, SOMBRAS POR TODAS PARTES!", "¡AYUDA!"}
            }
        }
    },
    AudioReactions = {
        fakethump = {"¿Qué fue ese golpe?", "¿Hola?", "Hay alguien arriba..."},
        fakethumpsqueak = {"¡Un portazo!", "¿Quién cerró?", "Mierda, mierda..."},
        fakedooropen = {"¿Quién abrió la puerta?", "No... no te acerques."},
        fakewindowSmash = {"¡Un cristal!", "¡Están entrando!", "¡Tengo que esconderme!"},
        fakebush = {"Algo se mueve ahí fuera...", "Es... es solo el viento, ¿verdad?"},
        fakecrackwood = {"Una rama... ¿o un paso?", "Shhh, silencio."}
    },
    VisualReactions = {
        FakeZombie = {"¡AHÍ HAY UNO!", "¿Cómo entró?", "¡No es real, no es real!", "¡Aléjate de mí!"},
        FakeInfected = {"¿Me... me mordieron?", "Siento... frío.", "No, no puedo estar infectado.", "Me estoy convirtiendo..."}
    }
}


---
--- Funciones Auxiliares (Combinadas de tus scripts)
---

-- B42 Compatible: Obtener jugador de forma segura
local function getSafePlayer()
    local player = getPlayer()
    if not player then
        print("DrugsDLC: ERROR - Player not found!")
        return nil
    end
    return player
end

-- B42 Compatible: Calcular factor emocional
local function calculateEmotionalFactor(stats)
    local fatigue = stats:getFatigue()
    local stress = stats:getStress()
    local panic = stats:getPanic()
    local fear = stats:getFear()
    
    local emotionalFactor = (fatigue + stress + panic + fear) / 4
    return math.min(emotionalFactor, 1.0)
end

-- B42 Compatible: Normalizar probabilidades
local function normalizeChances(good, bad, horrible)
    local total = good + bad + horrible
    if total <= 0 then return 50, 35, 15 end
    
    local scale = 100 / total
    return good * scale, bad * scale, horrible * scale
end

-- B42 COMPATIBLE: Aplicar modificadores de estado
local function applyStatModifiersB42(stats, bodyDamage, modifiers)
    if modifiers.fatigue then
        local currentFatigue = stats:getFatigue()
        stats:setFatigue(math.max(math.min(currentFatigue + modifiers.fatigue, 1.0), 0))
    end
    if modifiers.stress then
        local currentStress = stats:getStress()
        stats:setStress(math.max(math.min(currentStress + modifiers.stress, 1.0), 0))
    end
    if modifiers.panic then
        local currentPanic = stats:getPanic()
        stats:setPanic(math.max(math.min(currentPanic + modifiers.panic, 1.0), 0))
    end
    if modifiers.pain then
        local currentPain = stats:getPain()
        stats:setPain(math.max(math.min(currentPain + modifiers.pain, 1.0), 0))
    end
    if modifiers.boredom then
        bodyDamage:setBoredomLevel(math.max(math.min(
            bodyDamage:getBoredomLevel() + modifiers.boredom, 1.0), 0))
    end
    if modifiers.foodSickness then
        bodyDamage:setFoodSicknessLevel(math.max(math.min(
            bodyDamage:getFoodSicknessLevel() + modifiers.foodSickness, 100), 0))
    end
    if modifiers.endurance then
        local currentEndurance = stats:getEndurance()
        stats:setEndurance(math.max(math.min(currentEndurance + modifiers.endurance, 1.0), 0))
    end
end

---
--- Lógica de Alucinaciones (Portada de TAW y adaptada a DrugsDLC)
---

function DrugsDLC.getTimeMultiplier()
    local hour = getGameTime():getHour()
    if shouldNightsAffect and (hour >= 20 or hour < 6) then
        return 1.5
    else
        return 1.0
    end
end

function DrugsDLC.applyMood(panicAmount, stressAmount, playBreathing, forceAwake, player)
    if not player then return end
    local stats = player:getStats()
    local timeMult = DrugsDLC.getTimeMultiplier()

    local panic = stats:getPanic() + (panicAmount * timeMult)
    local stress = stats:getStress() + (stressAmount * timeMult)

    stats:setPanic(math.min(100, panic))
    stats:setStress(math.min(1.0, stress))

    if playBreathing == true and ZombRand(3) == 0 then
        if player:isFemale() then getSoundManager():PlaySound("female_heavybreathpanic", false, 5):setVolume(0.035 * soundMultiplier)
        else getSoundManager():PlaySound("male_heavybreathpanic", false, 5):setVolume(0.035 * soundMultiplier) end
    end
    if forceAwake == true then player:forceAwake() end
end

-- ¿Debería el jugador alucinar?
function DrugsDLC.shouldHallucinate(player, stress, panic)
    if not player then return false end
    if player:isAsleep() then return false end

    local modData = player:getModData()
    local currentHour = getGameTime():getWorldAgeHours()

    -- El "cooldown" de la alucinación
    if modData.nextHallucinationTime and currentHour < modData.nextHallucinationTime then
        return false
    end

    if not modData.hallucinationAccumulator then
        modData.hallucinationAccumulator = 0
    end

    local panicNorm = panic / 100 or player:getStats():getPanic() / 100
    local stress = stress or player:getStats():getStress()
    
    local basechance = ZombRandFloat(minBaseChance / 100, maxBaseChance / 100)
    local timeMult = DrugsDLC.getTimeMultiplier()
    local chance = basechance + (stress * 0.15) + (panicNorm * 0.25) * timeMult
    modData.hallucinationAccumulator = modData.hallucinationAccumulator + chance

    if modData.hallucinationAccumulator >= 1 or ZombRandFloat(0,1) <= chance + modData.hallucinationAccumulator then
        modData.hallucinationAccumulator = 0
        local cooldown = ZombRandFloat(0.2, 0.9) -- Cooldown en horas
        modData.nextHallucinationTime = currentHour + cooldown
        return true
    else
        return false
    end
end

-- ¿Debería el jugador decir una línea?
function DrugsDLC.shouldSayLine(player, stress, panic)
    if not player then return false end
    if player:isAsleep() then return false end
    local currentHour = getGameTime():getWorldAgeHours()

    local modData = player:getModData()

    if modData.nextLineTime and currentHour < modData.nextLineTime then
        return false
    end

    if not modData.lineAccumulator then
        modData.lineAccumulator = 0
    end

    local panicNorm = panic / 100 or player:getStats():getPanic() / 100
    local stress = stress or player:getStats():getStress()
    
    local basechance = ZombRandFloat(minBaseChance / 100, maxBaseChance / 100)
    local chance = basechance + (stress * 0.2) + (panicNorm * 0.3)
    modData.lineAccumulator = modData.lineAccumulator + chance

    if modData.lineAccumulator >= 1 or ZombRandFloat(0,1) <= chance + modData.lineAccumulator then
        modData.lineAccumulator = 0
        modData.nextLineTime = currentHour + ZombRandFloat(0.2, 0.5) -- Cooldown en horas
        return true
    else
        return false
    end
end

-- Elige el tipo de línea según el estado
function DrugsDLC.pickLineType(player, stress, panic)
    local panicNorm = panic / 100 or player:getStats():getPanic() / 100
    local stress = stress or player:getStats():getStress()
    local score = (stress * 0.6) + (panicNorm * 0.4)

    if score < 0.33 then
        return "Whispers"
    elseif score < 0.66 then
        return "Confusing"
    else
        return "Panic"
    end
end

function DrugsDLC.getTimeOfDay()
    local hour = getGameTime():getHour()
    return (hour >= 20 or hour < 6) and "NightTime" or "DayTime"
end

-- Decir una línea de alucinación (usa la tabla local DrugsDLC_Lines)
function DrugsDLC.sayHallucinationLine(player, location)
    if not player or not location then return end

    local panic = player:getStats():getPanic()
    local stress = player:getStats():getStress()

    if not DrugsDLC.shouldSayLine(player, stress, panic) then return end

    local lineType = DrugsDLC.pickLineType(player, stress, panic)
    local timeOfDay = DrugsDLC.getTimeOfDay()
    
    -- Manejo seguro de tablas
    local linesTable = DrugsDLC_Lines.RandomLines[timeOfDay]
    if linesTable then linesTable = linesTable[location] end
    if linesTable then linesTable = linesTable[lineType] end

    if linesTable and #linesTable > 0 then
        local line = linesTable[ZombRand(#linesTable)+1]
        player:Say(line)
    end
end

-- Funciones del Zombie Falso
function DrugsDLC.canPlayerSee(player)
    if not player then return end
    if not fakeZombie then
        Events.OnTick.Remove(DrugsDLC.canPlayerSee)
        return
    end

    if fakeZombie:DistTo(player) <= 2.25 and player:CanSee(fakeZombie) then
        fakeZombie:removeFromWorld()
        fakeZombie:removeFromSquare()
        DrugsDLC.applyMood(40, 0.25, true, false, player)

        local location = player:getBuilding() and "Inside" or "Outside"
        local hallucinationType = "FakeZombie"
        local reactionsTable = DrugsDLC_Lines.VisualReactions[hallucinationType]
        
        if reactionsTable and #reactionsTable > 0 then
            local line = reactionsTable[ZombRand(#reactionsTable)+1]
            player:Say(line)
        else
            DrugsDLC.sayHallucinationLine(player, location)
        end
        fakeZombie = nil
        Events.OnTick.Remove(DrugsDLC.canPlayerSee) -- Asegurarse de remover el evento
    end
end

function DrugsDLC.makeZombieUseless(zombie)
    if zombie == fakeZombie then
        if zombie:getX() ~= zX or zombie:getY() ~= zY or zombie:getZ() ~= zZ then
            zX, zY, zZ = nil, nil, nil
            zombie:setUseless(true)
            zombie:setHealth(100000)
            Events.OnZombieUpdate.Remove(DrugsDLC.makeZombieUseless)
        else
            zX, zY, zZ = nil, nil, nil
            Events.OnZombieUpdate.Remove(DrugsDLC.makeZombieUseless)
        end
     end
end

function DrugsDLC.spawnFakeZombie(player)
    if not player then return end

    if fakeZombie then
        fakeZombie:removeFromWorld()
        fakeZombie:removeFromSquare()
        fakeZombie = nil
        Events.OnTick.Remove(DrugsDLC.canPlayerSee)
    end

    local x, y, z = player:getX(), player:getY(), player:getZ()
    local offsetX = ZombRand(-5, 5)
    local offsetY = ZombRand(-5, 5)

    local square = player:getCell():getGridSquare(x + offsetX, y + offsetY, z)
    if not square or not square:TreatAsSolidFloor() then return end
    local outfitName = GenericOutfits[ZombRand(#GenericOutfits) + 1]

    local zombieList = addZombiesInOutfit(square:getX(), square:getY(), player:getZ(), 1, outfitName, 50)
    if zombieList and zombieList:size() > 0 then
        local zombie = zombieList:get(0)
        fakeZombie = zombie

        zX, zY, zZ = fakeZombie:getX(), fakeZombie:getY(), fakeZombie:getZ()
        zombie:pathToCharacter(player)
        zombie:setUseless(true)
        zombie:setHealth(100000)
        Events.OnTick.Add(function ()
            DrugsDLC.canPlayerSee(player)
        end)
        Events.OnZombieUpdate.Add(function()
            DrugsDLC.makeZombieUseless(zombie)
        end)
    end
end

-- Funciones de Falsa Infección
function DrugsDLC.checkPlayerFakeSickness(player)
    if not player then return end
    local modData = player:getModData()

    if not modData.IsFakeInfected then
        Events.OnTick.Remove(DrugsDLC.checkPlayerFakeSickness)
        return
    end

    local stats = player:getStats()
    local bodydamage = player:getBodyDamage()
    local sickness = stats:getSickness()
    local currentHour = getGameTime():getWorldAgeHours()
    local clearChancePerTick = 0.0005

    if (modData.FakeInfectedEnds and currentHour >= modData.FakeInfectedEnds) or (sickness > 0.25 and ZombRandFloat(0, 1) <= clearChancePerTick) then
        bodydamage:setIsFakeInfected(false)
        bodydamage:setFakeInfectionLevel(0)
        modData.IsFakeInfected = false
        modData.FakeInfectedEnds = nil
        Events.OnTick.Remove(DrugsDLC.checkPlayerFakeSickness)
    end
end

function DrugsDLC.doFakeInfect(player)
    if not player then return end
    
    local modData = player:getModData()
    local currentHour = getGameTime():getWorldAgeHours()
    local bodydamage = player:getBodyDamage()
    local cooldown = 2

    if modData.IsFakeInfected then return end
    if modData.LastFakeInfected and currentHour < modData.LastFakeInfected + cooldown then return end

    modData.IsFakeInfected = true
    modData.FakeInfectedEnds = currentHour + 8
    modData.FakeInfectedStart = currentHour
    modData.LastFakeInfected = currentHour

    bodydamage:setIsFakeInfected(true)
    Events.OnTick.Add(function()
        DrugsDLC.checkPlayerFakeSickness(player)
    end)
end

-- Reacción principal a la alucinación
function DrugsDLC.HallucinationReaction(player, location, hallucinationType, specific)
    if not player or not location or not hallucinationType then return end

    local reacted = false

    if hallucinationType == "Audio" then
        if DrugsDLC.DebugMode then print("[DrugsDLC] Alucinación Auditiva") end
        local dirSuffix = AudioDirections[ZombRand(#AudioDirections)+1]
        local soundName = specific..dirSuffix
        getSoundManager():PlaySound(soundName, false, 0):setVolume(0.45 * soundMultiplier)

        local reactionsTable = DrugsDLC_Lines.AudioReactions[specific]
        if reactionsTable and #reactionsTable > 0 then
            local line = reactionsTable[ZombRand(#reactionsTable)+1]
            player:Say(line)
            reacted = true
        end
        DrugsDLC.applyMood(8, 0.08, false, false, player)
        
    elseif hallucinationType == "Visual" then
        if specific == "FakeZombie" then
            if DrugsDLC.DebugMode then print("[DrugsDLC] Alucinación: Zombie Falso") end
            DrugsDLC.spawnFakeZombie(player)
        elseif specific == "FakeInfected" then
            if DrugsDLC.DebugMode then print("[DrugsDLC] Alucinación: Infección Falsa") end
            DrugsDLC.doFakeInfect(player)
        end
        
    elseif hallucinationType == "Line" then
        if DrugsDLC.DebugMode then print("[DrugsDLC] Alucinación: Línea de Voz") end
        DrugsDLC.sayHallucinationLine(player, location)
        reacted = true
        DrugsDLC.applyMood(1, 0.02, false, false, player)
    end

    if not reacted then
        DrugsDLC.sayHallucinationLine(player, location)
        DrugsDLC.applyMood(2, 0.05, false, false, player)
    end
end

-- Manejador principal de alucinaciones
function DrugsDLC.HandleHallucination(player, location)
    if not player or not location then return end

    local panic = player:getStats():getPanic()
    local stress = player:getStats():getStress()

    if not DrugsDLC.shouldHallucinate(player, stress, panic) then return end

    local roll = ZombRandFloat(0, 1)
    local hallucinationType, specific

    if roll < 0.2 then
        hallucinationType = "Visual"
        local visualList = VisualHallucinations[location]
        if not visualList or #visualList == 0 then return end
        specific = visualList[ZombRand(#visualList)+1]
    elseif roll > 0.4 then
        hallucinationType = "Audio"
        local audioList = AudioHallucinations[location]
        if not audioList or #audioList == 0 then return end
        specific = audioList[ZombRand(#audioList)+1]
    else
        hallucinationType = "Line"
        specific = nil
    end
    DrugsDLC.HallucinationReaction(player, location, hallucinationType, specific)
end

-- Sonidos de personalidad (risas, susurros)
function DrugsDLC.SchizoPersonality(player)
    if not player then return end

    local modData = player:getModData()
    local currentHour = getGameTime():getWorldAgeHours()

    if modData.nextPersonalityTime and currentHour < modData.nextPersonalityTime then
        return
    end

    local panic = player:getStats():getPanic() / 100
    local stress = player:getStats():getStress()

    if not DrugsDLC.shouldHallucinate(player, stress, panic) then return end

    local gender = player:isFemale() and "Female" or "Male"

    if ZombRand(2) == 0 then
        -- Susurro
        local idx = ZombRand(#AudioSchizoPersonality.Whisper) + 1
        getSoundManager():PlaySound(AudioSchizoPersonality.Whisper[idx], false, 0):setVolume(0.45 * soundMultiplier)
    else
        -- Risa (hombre/mujer)
        local laughTable = AudioSchizoPersonality[gender]
        local idx = ZombRand(#laughTable) + 1
        getSoundManager():PlaySound(laughTable[idx], false, 0):setVolume(0.35 * soundMultiplier)
    end
    
    -- Establecer cooldown para el próximo sonido de personalidad
    modData.nextPersonalityTime = currentHour + ZombRandFloat(0.1, 0.3) -- Cooldown corto
end


---
--- Lógica de Adicción (Tu script original)
---

local function handleAddiction(drugType, addictionPoints)
    local player = getSafePlayer()
    if not player then return end
    
    local modData = player:getModData()
    
    if not modData.drugAddictionCounter then
        modData.drugAddictionCounter = 0
    end
    
    modData.drugAddictionCounter = modData.drugAddictionCounter + addictionPoints
    
    local addictionThreshold = SandboxVars.JustDrugsDLC.AddictionThreshold or 20
    
    if modData.drugAddictionCounter >= addictionThreshold then
        if player:HasTrait("Drogadicto") then
            modData.drugAddictionCounter = addictionThreshold
            player:Say(getText("IGUI_AlreadyAddicted") or "Necesito mi dosis...")
        else
            player:getTraits():add("Drogadicto")
            modData.drugAddictionCounter = addictionThreshold
            player:Say(getText("IGUI_BecameAddicted") or "Creo que estoy enganchado...")
            
            local stats = player:getStats()
            stats:setStress(math.min(stats:getStress() + 0.3, 1.0))
            stats:setPanic(math.min(stats:getPanic() + 0.2, 1.0))
        end
    else
        local progress = (modData.drugAddictionCounter / addictionThreshold) * 100
        if progress >= 75 then
            player:Say(getText("IGUI_AddictionWarning") or "Me estoy volviendo dependiente...")
        elseif progress >= 50 then
            player:Say(getText("IGUI_AddictionBuilding") or "Esto sienta demasiado bien...")
        end
    end
end

-- Drogas genéricas
OnEat_HasTakenDrugs = function(player, item, character)
    handleAddiction("general", 1)
end

-- Cocaína
OnEat_HasTakenCocaine = function(player, item, character)
    handleAddiction("cocaine", 2)
    local stats = character:getStats()
    stats:setFatigue(math.max(stats:getFatigue() - 0.3, 0))
    stats:setPanic(math.max(stats:getPanic() - 0.4, 0))
end

-- Fentanilo
OnEat_HasTakenFentanyl = function(player, item, character)
    handleAddiction("fentanyl", 3)
    local stats = character:getStats()
    stats:setPain(math.max(stats:getPain() - 0.6, 0))
    
    if ZombRand(100) < 5 then -- 5% riesgo de sobredosis
        local bodyDamage = character:getBodyDamage()
        bodyDamage:setPoisonLevel(math.min(bodyDamage:getPoisonLevel() + 30, 100))
        character:Say(getText("IGUI_FentanylOverdose") or "Esto fue demasiado fuerte...")
    end
end

-- Xanax
OnEat_HasTakenXanax = function(player, item, character)
    handleAddiction("xanax", 2)
    local stats = character:getStats()
    stats:setStress(math.max(stats:getStress() - 0.5, 0))
    stats:setPanic(math.max(stats:getPanic() - 0.3, 0))
end

-- Reducción de adicción con el tiempo
local function reduceAddictionOverTime()
    local player = getSafePlayer()
    if not player then return end
    
    local modData = player:getModData()
    
    if modData.drugAddictionCounter and modData.drugAddictionCounter > 0 then
        local reductionRate = SandboxVars.JustDrugsDLC.AddictionRecoveryRate or 0.1
        modData.drugAddictionCounter = math.max(modData.drugAddictionCounter - reductionRate, 0)
        
        local addictionThreshold = SandboxVars.JustDrugsDLC.AddictionThreshold or 20
        if modData.drugAddictionCounter < (addictionThreshold * 0.5) and player:HasTrait("Drogadicto") then
            if ZombRand(100) < 2 then -- 2% chance de recuperarse por día
                player:getTraits():remove("Drogadicto")
                modData.drugAddictionCounter = 0
                player:Say(getText("IGUI_OvercameAddiction") or "¡Creo que finalmente estoy limpio!")
            end
        end
    end
    
    -- Reducir dosis de hongos si no se está alucinando
    if modData.shroomHallucinationDose and modData.shroomHallucinationDose > 0 and not modData.isHallucinating then
        modData.shroomHallucinationDose = math.max(modData.shroomHallucinationDose - 1, 0)
    end
end

-- Inicialización del sistema
local function initializeAddictionSystem()
    local player = getSafePlayer()
    if not player then return end
    
    local modData = player:getModData()
    
    if modData.drugAddictionCounter == nil then
        modData.drugAddictionCounter = 0
    end
    if modData.shroomsAddictionCounter == nil then
        modData.shroomsAddictionCounter = 0
    end
    if modData.shroomHallucinationDose == nil then
        modData.shroomHallucinationDose = 0
    end
    
    print("DrugsDLC: Sistema de Adicción y Alucinaciones inicializado para Build 42")
end


---
--- Lógica de Viajes (Tu script original)
---

function OnEat_Tripping()
    local player = getSafePlayer()
    if not player then return end
    
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    -- 1. LÓGICA DE VIAJE (CADA 3 HONGOS)
    DrugsDLC.alucinogenosConsumidosTripping = DrugsDLC.alucinogenosConsumidosTripping + 1
    
    if DrugsDLC.alucinogenosConsumidosTripping >= 3 then
        DrugsDLC.alucinogenosConsumidosTripping = 0
        
        local emotionalFactor = calculateEmotionalFactor(stats)

        local baseGoodTripChance = 50
        local baseBadTripChance = 35
        local baseHorribleTripChance = 15

        local adjustedGoodTripChance = math.max(baseGoodTripChance - (emotionalFactor * 25), 5)
        local adjustedBadTripChance = math.min(baseBadTripChance + (emotionalFactor * 15), 70)
        local adjustedHorribleTripChance = math.min(baseHorribleTripChance + (emotionalFactor * 10), 30)

        local goodChance, badChance, horribleChance = normalizeChances(
            adjustedGoodTripChance, adjustedBadTripChance, adjustedHorribleTripChance
        )

        local randomNumber = ZombRand(100) + 1

        if randomNumber <= goodChance then
            -- Viaje bueno
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = -bodyDamage:getBoredomLevel(), stress = -stats:getStress(),
                fatigue = -0.3, pain = -0.4, panic = -stats:getPanic(), foodSickness = 10
            })
            player:Say("What a beautiful trip...")
            
        elseif randomNumber <= goodChance + badChance then
            -- Viaje malo
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = 0.2, stress = 0.4, fatigue = 0.2, panic = 0.6, foodSickness = 15
            })
            player:Say("This is getting scary...")
            
        else
            -- Viaje horrible
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = 0.5, stress = 1.0 - stats:getStress(), fatigue = 0.5,
                panic = 1.0 - stats:getPanic(), foodSickness = 20
            })
            player:Say("I'm losing my mind!")
        end
        
    else
        local remaining = 3 - DrugsDLC.alucinogenosConsumidosTripping
    end

    ---
    --- 2. ¡NUEVA LÓGICA DE ALUCINACIÓN (CADA 1 HONGO, SE ACTIVA CON 3+)
    ---
    
    local modData = player:getModData()
    
    -- Usamos el contador de dosis de hongos
    if not modData.shroomHallucinationDose then
        modData.shroomHallucinationDose = 0
    end
    modData.shroomHallucinationDose = modData.shroomHallucinationDose + 1

    -- Si el jugador ha comido MÁS DE 2 (o sea, 3), comienza el estado de alucinación
    if modData.shroomHallucinationDose > 2 then
        modData.isHallucinating = true
        -- Las alucinaciones durarán entre 1.5 y 3 horas
        modData.hallucinationEnds = getGameTime():getWorldAgeHours() + ZombRandFloat(1.5, 3.0)
        
        -- Reiniciar el contador de dosis
        modData.shroomHallucinationDose = 0 
        
        player:Say("Oh no... this is... this is too much...")
        
        -- Forzar un aumento de pánico y estrés
        DrugsDLC.applyMood(15, 0.1, true, false, player)
    end
end

function OnEat_TrippingHardcore()
    local player = getSafePlayer()
    if not player then return end
    
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    DrugsDLC.alucinogenosConsumidosTrippingHardcore = DrugsDLC.alucinogenosConsumidosTrippingHardcore + 1
    
    if DrugsDLC.alucinogenosConsumidosTrippingHardcore >= 2 then
        DrugsDLC.alucinogenosConsumidosTrippingHardcore = 0
        
        local emotionalFactor = calculateEmotionalFactor(stats)

        local baseGoodTripChance = 40
        local baseBadTripChance = 40
        local baseHorribleTripChance = 20

        local adjustedGoodTripChance = math.max(baseGoodTripChance - (emotionalFactor * 20), 5)
        local adjustedBadTripChance = math.min(baseBadTripChance + (emotionalFactor * 10), 60)
        local adjustedHorribleTripChance = math.min(baseHorribleTripChance + (emotionalFactor * 10), 40)

        local goodChance, badChance, horribleChance = normalizeChances(
            adjustedGoodTripChance, adjustedBadTripChance, adjustedHorribleTripChance
        )

        local randomNumber = ZombRand(100) + 1

        if randomNumber <= goodChance then
            -- Viaje bueno hardcore
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = -bodyDamage:getBoredomLevel(), stress = -stats:getStress(),
                fatigue = -stats:getFatigue(), pain = -stats:getPain(),
                panic = -stats:getPanic(), endurance = 0.2, foodSickness = 15
            })
            player:Say("Puedo ver el universo!")
            
        elseif randomNumber <= goodChance + badChance then
            -- Viaje malo hardcore
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = 0.5, stress = 0.6, fatigue = 0.4, panic = 0.7, foodSickness = 25
            })
            player:Say("Las paredes respiran...")
            
        else
            -- Viaje horrible hardcore
            applyStatModifiersB42(stats, bodyDamage, {
                boredom = 1.0 - bodyDamage:getBoredomLevel(), stress = 1.0 - stats:getStress(),
                fatigue = 0.8, panic = 1.0 - stats:getPanic(), foodSickness = 35
            })
            
            if ZombRand(100) < 30 then
                applyStatModifiersB42(stats, bodyDamage, { fatigue = 0.9 })
                player:Say("No puedo... mantenerme despierto...")
            else
                player:Say("¡Esto es el infierno!")
            end
        end
        
    else
        local remaining = 1 - DrugsDLC.alucinogenosConsumidosTrippingHardcore
    end

    ---
    --- ¡NUEVA LÓGICA DE ALUCINACIÓN AÑADIDA AQUÍ!
    ---
    
    local modData = player:getModData()
    
    -- Usamos un contador NUEVO y separado para el ácido
    if not modData.acidHallucinationDose then
        modData.acidHallucinationDose = 0
    end
    modData.acidHallucinationDose = modData.acidHallucinationDose + 1

    -- Si el jugador ha comido MÁS DE 0 (o sea, 1), comienza el estado de alucinación
    if modData.acidHallucinationDose > 0 then
        modData.isHallucinating = true
        -- Las alucinaciones durarán más que los hongos (ej. 2-4 horas)
        modData.hallucinationEnds = getGameTime():getWorldAgeHours() + ZombRandFloat(2.0, 4.0)
        
        -- Reiniciar el contador de dosis
        modData.acidHallucinationDose = 0 
        
        player:Say("Siento... que todo se derrite...")
        
        -- Forzar un aumento de pánico y estrés MÁS FUERTE
        DrugsDLC.applyMood(25, 0.15, true, false, player)
    end
    
end


---
--- ¡EL GANCHO! (Función modificada para activar alucinaciones)
---

OnEat_HasTakenShrooms = function(player, item, character)
    -- 1. Manejar adicción (de tu script original)
    -- Lógica de adicción de hongos (potencial bajo)
    handleAddiction("shrooms", 1)
    
    local modData = character:getModData()
    if not modData.shroomsAddictionCounter then
        modData.shroomsAddictionCounter = 0
    end
    
    modData.shroomsAddictionCounter = modData.shroomsAddictionCounter + 1
    local shroomsThreshold = 50 -- Umbral alto
    
    if modData.shroomsAddictionCounter >= shroomsThreshold then
        if not character:HasTrait("Drogadicto") then
            character:getTraits():add("Drogadicto")
            modData.shroomsAddictionCounter = shroomsThreshold
            character:Say("Necesito las visiones...")
        end
    end

    -- 2. Ejecutar el "viaje" (bueno/malo/horrible) (de tu script OnEat)
    OnEat_Tripping() -- Llama a la función de viaje normal

    -- 3. ¡NUEVA LÓGICA! Activar sistema de alucinaciones TAW
    if not modData.shroomHallucinationDose then
        modData.shroomHallucinationDose = 0
    end
    modData.shroomHallucinationDose = modData.shroomHallucinationDose + 1

    -- Si el jugador ha comido más de 5 hongos, comienza el estado de alucinación
    if modData.shroomHallucinationDose > 5 then
        modData.isHallucinating = true
        -- Las alucinaciones durarán entre 1.5 y 3 horas de juego
        modData.hallucinationEnds = getGameTime():getWorldAgeHours() + ZombRandFloat(1.5, 3.0)
        
        -- Reiniciar el contador de dosis para que no se acumule infinitamente
        modData.shroomHallucinationDose = 0 
        
        player:Say("Oh... oh no... esto es demasiado...")
        
        -- Forzar un pequeño aumento de pánico y estrés al entrar en este estado
        DrugsDLC.applyMood(15, 0.1, true, false, player)
    end
end


---
--- NUEVO MOTOR DE ALUCINACIONES (Se ejecuta cada 10 mins)
---

function DrugsDLC.HallucinationUpdate()
    local player = getSafePlayer()
    if not player or not player:isAlive() then return end
    
    local modData = player:getModData()
    
    -- Si no está alucinando, no hacer nada
    if not modData.isHallucinating then return end
    
    local currentHour = getGameTime():getWorldAgeHours()
    
    -- Comprobar si el efecto ha terminado
    if currentHour > modData.hallucinationEnds then
        modData.isHallucinating = false
        modData.shroomHallucinationDose = 0 -- Reiniciar la dosis
        player:Say("Se... se está acabando. Por fin.")
        
        -- Limpiar acumuladores
        modData.hallucinationAccumulator = 0
        modData.lineAccumulator = 0
        
        -- Limpiar cualquier zombie falso restante
        if fakeZombie then
            fakeZombie:removeFromWorld()
            fakeZombie:removeFromSquare()
            fakeZombie = nil
            Events.OnTick.Remove(DrugsDLC.canPlayerSee)
        end
        return
    end
    
    -- Si sigue alucinando, ejecutar la lógica
    
    -- 1. Ejecutar sonidos de personalidad (susurros, risas)
    DrugsDLC.SchizoPersonality(player)
    
    -- 2. Ejecutar alucinaciones principales (visuales, auditivas, líneas)
    local location = player:getBuilding() and "Inside" or "Outside"
    DrugsDLC.HandleHallucination(player, location)
end


---
--- Registro de Eventos y Exportaciones Globales
---

-- Eventos de Adicción y Efectos
Events.OnGameStart.Add(initializeAddictionSystem)
Events.OnNewGame.Add(initializeAddictionSystem)
Events.EveryDays.Add(reduceAddictionOverTime) -- Reducción diaria de adicción y dosis

-- ¡NUEVO EVENTO!
-- Este es el motor principal que impulsa las alucinaciones mientras duren
Events.EveryTenMinutes.Add(DrugsDLC.HallucinationUpdate)

-- Exportar funciones OnEat a Global para que los items las usen
_G.OnEat_HasTakenDrugs = OnEat_HasTakenDrugs
_G.OnEat_HasTakenCocaine = OnEat_HasTakenCocaine
_G.OnEat_HasTakenFentanyl = OnEat_HasTakenFentanyl
_G.OnEat_HasTakenXanax = OnEat_HasTakenXanax
_G.OnEat_HasTakenShrooms = OnEat_HasTakenShrooms -- MUY IMPORTANTE
_G.OnEat_Tripping = OnEat_Tripping
_G.OnEat_TrippingHardcore = OnEat_TrippingHardcore