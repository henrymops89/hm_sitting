-- client.lua
-- HM Sitting – Haupt-Logik

local isSitting   = false
local currentChair = nil

-- ──────────────────────────────────────────────
-- Helper: Nächsten Stuhl in Radius finden
-- ──────────────────────────────────────────────
local function GetNearestChair(radius)
    local ped    = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local models = {}

    for _, name in ipairs(Config.ChairProps) do
        models[#models + 1] = GetHashKey(name)
    end

    local nearest, nearestDist = nil, radius

    for _, model in ipairs(models) do
        local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, radius, model, false, false, false)
        if obj ~= 0 then
            local dist = #(coords - GetEntityCoords(obj))
            if dist < nearestDist then
                nearestDist = dist
                nearest     = obj
            end
        end
    end

    return nearest
end

-- ──────────────────────────────────────────────
-- Sitzen starten
-- ──────────────────────────────────────────────
local function SitDown(chairEntity)
    if isSitting then return end

    local ped         = PlayerPedId()
    local chairCoords = GetEntityCoords(chairEntity)
    local chairHeading = GetEntityHeading(chairEntity)
    local sitPos      = chairCoords + Config.SitOffset

    -- Spieler teleportieren + ausrichten
    SetEntityCoords(ped, sitPos.x, sitPos.y, sitPos.z, false, false, false, true)
    SetEntityHeading(ped, chairHeading)

    -- Anim laden
    RequestAnimDict(Config.Anim.dict)
    local timeout = 0
    while not HasAnimDictLoaded(Config.Anim.dict) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    TaskPlayAnim(ped, Config.Anim.dict, Config.Anim.clip, 2.0, -1.0, -1, 1, 0, false, false, false)

    isSitting    = true
    currentChair = chairEntity

    -- Freeze Ped leicht damit er nicht rutscht
    FreezeEntityPosition(ped, true)

    -- First Person View erzwingen (optional)
    if Config.ForceFPV then
        SetFollowPedCamViewMode(4)
    end
end

-- ──────────────────────────────────────────────
-- Aufstehen
-- ──────────────────────────────────────────────
local function StandUp()
    if not isSitting then return end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)

    -- First Person View zurücksetzen
    if Config.ForceFPV then
        SetFollowPedCamViewMode(1)
    end

    isSitting    = false
    currentChair = nil
end

-- ──────────────────────────────────────────────
-- Target / E-Key registrieren
-- ──────────────────────────────────────────────
TargetBridge.RegisterChairs(Config.ChairProps, 'Hinsetzen', function(entity)
    if isSitting then
        StandUp()
    else
        SitDown(entity)
    end
end)

-- ──────────────────────────────────────────────
-- ESX: E-Key Tick + ox_lib drawText Prompt
-- ──────────────────────────────────────────────
if Config.TargetSystem == 'esx' then
    local cb = TargetBridge.GetESXCallback()

    CreateThread(function()
        while true do
            Wait(0)

            if isSitting then
                -- Sitzen → E zum Aufstehen
                lib.showTextUI('[E] Aufstehen', { position = 'left-center' })

                if IsControlJustPressed(0, 38) then -- E
                    lib.hideTextUI()
                    StandUp()
                end

            else
                -- Suche nächsten Stuhl
                local chair = GetNearestChair(Config.SearchRadius)

                if chair then
                    lib.showTextUI('[E] Hinsetzen', { position = 'left-center' })

                    if IsControlJustPressed(0, 38) then -- E
                        lib.hideTextUI()
                        if cb then cb(chair) end
                    end
                else
                    lib.hideTextUI()
                    Wait(300) -- Weniger Checks wenn kein Stuhl in der Nähe
                end
            end
        end
    end)
end

-- ──────────────────────────────────────────────
-- Aufstehen wenn Spieler sich bewegt (alle Frameworks)
-- ──────────────────────────────────────────────
CreateThread(function()
    while true do
        Wait(500)
        if isSitting then
            local ped = PlayerPedId()
            -- Wenn Spieler eine Bewegungstaste hält → aufstehen
            if IsControlPressed(0, 30) or IsControlPressed(0, 31) or -- WASD
               IsControlPressed(0, 32) or IsControlPressed(0, 33) then
                StandUp()
            end
        end
    end
end)

-- ──────────────────────────────────────────────
-- Cleanup beim Ressource Stop
-- ──────────────────────────────────────────────
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if isSitting then
            StandUp()
        end
    end
end)
