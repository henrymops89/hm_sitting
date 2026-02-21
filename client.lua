-- Variables --
local Models = GetModels()
local PolyZones = GetPolyZones()

local metadata = {
    isSitting = false,
    isLaying = false,
    entity = 0,
    poly = false,
    type = nil,
    lastPos = nil,
    targetPos = nil,
    teleportOut = false,
    frozen = false,
    plyFrozen = false,
    animation = {},
    scenario = false,
    showingPrompt = false,
    attAction = false,
    lastViewMode = 1,
}

local sittingScenarios = {
    "WORLD_HUMAN_SEAT_LEDGE", "WORLD_HUMAN_SEAT_LEDGE_EATING", "WORLD_HUMAN_SEAT_STEPS", "WORLD_HUMAN_SEAT_WALL",
    "WORLD_HUMAN_SEAT_WALL_EATING", "WORLD_HUMAN_SEAT_WALL_TABLET",
    "PROP_HUMAN_SEAT_ARMCHAIR", "PROP_HUMAN_SEAT_BAR", "PROP_HUMAN_SEAT_BENCH", "PROP_HUMAN_SEAT_BENCH_FACILITY",
    "PROP_HUMAN_SEAT_BENCH_DRINK", "PROP_HUMAN_SEAT_BENCH_DRINK_FACILITY",
    "PROP_HUMAN_SEAT_BENCH_DRINK_BEER", "PROP_HUMAN_SEAT_BENCH_FOOD", "PROP_HUMAN_SEAT_BENCH_FOOD_FACILITY",
    "PROP_HUMAN_SEAT_BUS_STOP_WAIT", "PROP_HUMAN_SEAT_CHAIR",
    "PROP_HUMAN_SEAT_CHAIR_DRINK", "PROP_HUMAN_SEAT_CHAIR_DRINK_BEER", "PROP_HUMAN_SEAT_CHAIR_FOOD",
    "PROP_HUMAN_SEAT_CHAIR_UPRIGHT", "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER",
    "PROP_HUMAN_SEAT_COMPUTER", "PROP_HUMAN_SEAT_COMPUTER_LOW", "PROP_HUMAN_SEAT_DECKCHAIR",
    "PROP_HUMAN_SEAT_DECKCHAIR_DRINK", "PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS",
    "PROP_HUMAN_SEAT_MUSCLE_BENCH_PRESS_PRISON", "PROP_HUMAN_SEAT_SEWING", "PROP_HUMAN_SEAT_STRIP_WATCH",
    "PROP_HUMAN_SEAT_SUNLOUNGER"
}

-- Ignore this if you don't use the TMC framework
local TMC = nil
if Config.UseTMCFramework then
    TMC = exports.core:getCoreObject()
end

-- Functions --
local function DisplayNotification(msg)
    -- Ignore this if you don't use the TMC framework
    if Config.UseTMCFramework then
        TMC.Functions.SimpleNotify(msg, "error", 5000)
        return
    end

    -- Native Notification (just comment out this and un-comment/add what notifcation you would like to use)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)

    -- QBCore
    --TriggerEvent('QBCore:Notify', msg, "success", 5000)

    -- Mythic Notify (Variant)
    --exports.mythic_notify:SendAlert('error', msg)
end

-- TODO: Add missing keys in the list + rename some of the mouse related ones
local specialKeyCodes = {
    ['b_100'] = 'LMB', ['b_101'] = 'RMB', ['b_102'] = 'MMB', ['b_103'] = 'Mouse.ExtraBtn1', ['b_104'] = 'Mouse.ExtraBtn2',
    ['b_105'] = 'Mouse.ExtraBtn3', ['b_106'] = 'Mouse.ExtraBtn4', ['b_107'] = 'Mouse.ExtraBtn5',
    ['b_108'] = 'Mouse.ExtraBtn6', ['b_109'] = 'Mouse.ExtraBtn7', ['b_110'] = 'Mouse.ExtraBtn8',
    ['b_115'] = 'MouseWheel.Up', ['b_116'] = 'MouseWheel.Down', ['b_130'] = 'NumSubstract', ['b_131'] = 'NumAdd',
    ['b_134'] = 'Num Multiplication', ['b_135'] = 'Num Enter', ['b_137'] = 'Num1', ['b_138'] = 'Num2', ['b_139'] = 'Num3',
    ['b_140'] = 'Num4', ['b_141'] = 'Num5', ['b_142'] = 'Num6', ['b_143'] = 'Num7', ['b_144'] = 'Num8',
    ['b_145'] = 'Num9', ['b_170'] = 'F1', ['b_171'] = 'F2', ['b_172'] = 'F3', ['b_173'] = 'F4', ['b_174'] = 'F5',
    ['b_175'] = 'F6', ['b_176'] = 'F7', ['b_177'] = 'F8', ['b_178'] = 'F9', ['b_179'] = 'F10', ['b_180'] = 'F11',
    ['b_181'] = 'F12', ['b_182'] = 'F13', ['b_183'] = 'F14', ['b_184'] = 'F15', ['b_185'] = 'F16', ['b_186'] = 'F17',
    ['b_187'] = 'F18', ['b_188'] = 'F19', ['b_189'] = 'F20', ['b_190'] = 'F21', ['b_191'] = 'F22', ['b_192'] = 'F23',
    ['b_193'] = 'F24', ['b_194'] = 'Arrow Up', ['b_195'] = 'Arrow Down', ['b_196'] = 'Arrow Left',
    ['b_197'] = 'Arrow Right', ['b_198'] = 'Delete', ['b_199'] = 'Escape', ['b_200'] = 'Insert', ['b_201'] = 'End',
    ['b_210'] = 'Delete', ['b_211'] = 'Insert', ['b_212'] = 'End', ['b_1000'] = 'Shift', ['b_1002'] = 'Tab',
    ['b_1003'] = 'Enter', ['b_1004'] = 'Backspace', ['b_1009'] = 'PageUp', ['b_1008'] = 'Home', ['b_1010'] = 'PageDown',
    ['b_1012'] = 'CapsLock', ['b_1013'] = 'Control', ['b_1014'] = 'Right Control', ['b_1015'] = 'Alt',
    ['b_1055'] = 'Home', ['b_1056'] = 'PageUp', ['b_2000'] = 'Space'
}

---Get's the label of a key mapping command
---@param commandHash any
---@return string
function GetKeyLabel(commandHash)
    local key = GetControlInstructionalButton(0, commandHash | 0x80000000, true)
    if string.find(key, "t_") then
        local label, _count = string.gsub(key, "t_", "")
        return label
    else
        return specialKeyCodes[key] or "unknown"
    end
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function GetAmountOfSeats(model)
    return #Models[model].sit.seats
end

local function HandleLooseEntity(entity)
    if not IsEntityPositionFrozen(entity) then
        NetworkRequestControlOfEntity(entity)
        FreezeEntityPosition(entity, true)
        metadata.frozen = true
    end
end

local function UnhandleLooseEntity(entity)
    if metadata.frozen then
        FreezeEntityPosition(entity, false)
        metadata.frozen = false
    end
end

local function HeadingToRotation(heading)
    local rotation = heading
    if rotation > 180.0 then
        rotation = 180.0 - math.abs(rotation - 180.0)
        rotation = rotation * -1
    end
    return rotation
end

local function GetOffsetFromCoordsInWorldCoords(position, rotation, offset)
    local rotX, rotY, rotZ = math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z)
    local matrix = {}

    matrix[1] = {}
    matrix[1][1] = math.cos(rotZ) * math.cos(rotY) - math.sin(rotZ) * math.sin(rotX) * math.sin(rotY)
    matrix[1][2] = math.cos(rotY) * math.sin(rotZ) + math.cos(rotZ) * math.sin(rotX) * math.sin(rotY)
    matrix[1][3] = -math.cos(rotX) * math.sin(rotY)
    matrix[1][4] = 1

    matrix[2] = {}
    matrix[2][1] = -math.cos(rotX) * math.sin(rotZ)
    matrix[2][2] = math.cos(rotZ) * math.cos(rotX)
    matrix[2][3] = math.sin(rotX)
    matrix[2][4] = 1

    matrix[3] = {}
    matrix[3][1] = math.cos(rotZ) * math.sin(rotY) + math.cos(rotY) * math.sin(rotZ) * math.sin(rotX)
    matrix[3][2] = math.sin(rotZ) * math.sin(rotY) - math.cos(rotZ) * math.cos(rotY) * math.sin(rotX)
    matrix[3][3] = math.cos(rotX) * math.cos(rotY)
    matrix[3][4] = 1

    matrix[4] = {}
    matrix[4][1], matrix[4][2], matrix[4][3] = position.x, position.y, position.z
    matrix[4][4] = 1

    local x = offset.x * matrix[1][1] + offset.y * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
    local y = offset.x * matrix[1][2] + offset.y * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
    local z = offset.x * matrix[1][3] + offset.y * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]

    return vector3(x, y, z)
end

local function IsEntityPlayingAnyLayAnim(entity)
    local checked = {}
    for _type, settings in pairs(Config.LayTypes) do
        local anim = settings.animation
        if not checked[anim.dict] then
            if IsEntityPlayingAnim(entity, anim.dict, anim.name, 3) then
                return true
            else
                checked[anim.dict] = true
            end
        end
    end
    return false
end

local function IsPedSitting(ped)
    for index, scenario in pairs(sittingScenarios) do
        if IsPedUsingScenario(ped, scenario) then
            return true
        end
    end
    return false
end

local function IsSeatAvailable(coords, action)
    local playerPed = PlayerPedId()
    for _index, ped in pairs(GetGamePool('CPed')) do
        if ped ~= playerPed then
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < 1.35 then
                if action == 'sit' then
                    if IsEntityPlayingAnyLayAnim(ped) or dist < 0.55 then
                        return false
                    end
                elseif action == 'lay' then
                    if IsEntityPlayingAnyLayAnim(ped) or IsPedSitting(ped) then
                        return false
                    end
                end
            end
        end
    end
    return true
end

local function SeatSort(a, b)
    return a.dist < b.dist
end

local function Raycast(startCoords, destination, ignoreEntity)
    local rayHandle = StartShapeTestLosProbe(startCoords.x, startCoords.y, startCoords.z, destination.x, destination.y,
        destination.z, -1, ignoreEntity, 4)

    while true do
        local result, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
        if result ~= 1 then
            return hit, endCoords, surfaceNormal, entityHit
        end

        Wait(0)
    end
end

local function RaycastCamera()
    local worldVector, normalVector = GetWorldCoordFromScreenCoord(0.5, 0.5)
    local destination = worldVector + normalVector * 10
    local hit, endCoords = Raycast(worldVector, destination, PlayerPedId())

    if hit then
        return endCoords
    else
        return false
    end
end

local function SortSeatsByDistance(seatCoords, seats, raycast)
    local sortedSeats = {}
    local coords = GetEntityCoords(PlayerPedId())

    if raycast and Config.Target and Config.UseTargetingCoords then
        local endCoords = RaycastCamera()
        if endCoords then
            coords = endCoords
        end
    end

    for k, v in pairs(seats) do
        sortedSeats[k] = {}
        if seatCoords then
            local heading = seatCoords.w
            local rotation = vector3(0.0, 0.0, HeadingToRotation(seatCoords.w))
            sortedSeats[k].coords = GetOffsetFromCoordsInWorldCoords(seatCoords.xyz, rotation, v)
            heading = heading + v.w
            if heading > 360.0 then
                heading = heading - 360.0
            end
            sortedSeats[k].heading = heading
        else
            sortedSeats[k].coords = v.xyz
            sortedSeats[k].heading = v.w
        end
        sortedSeats[k].dist = #(coords - sortedSeats[k].coords)
    end
    table.sort(sortedSeats, SeatSort)

    return sortedSeats
end

local function GetAvailableSeat(seatCoords, seats, raycast)
    local coords = nil
    local heading = nil
    local sortedSeats = SortSeatsByDistance(seatCoords, seats, raycast)

    for _index, data in pairs(sortedSeats) do
        if IsSeatAvailable(data.coords, 'sit') then
            coords = data.coords
            heading = data.heading
            break
        end
    end

    return coords, heading
end

local function LeaveSeat(clearTask, clearTaskImmediately, waitIfAttached)
    metadata.isSitting = false
    metadata.isLaying = false
    metadata.scenario = false
    local playerPed = PlayerPedId()

    if metadata.plyFrozen then
        SetEntityCollision(playerPed, true, false)
        FreezeEntityPosition(playerPed, false)
        metadata.plyFrozen = false
    end

    if metadata.entity ~= 0 then
        UnhandleLooseEntity(metadata.entity)
        metadata.entity = 0
    end

    if clearTask or clearTaskImmediately then
        if waitIfAttached then
            -- Wait until the person is no longer attached to another ped (aka. getting escorted or carried).
            CreateThread(function()
                while true do
                    if not IsEntityAttachedToAnyPed(PlayerPedId()) then
                        break
                    end
                    Wait(200)
                end
                ClearPedTasksImmediately(PlayerPedId())
            end)
        elseif clearTask then
            ClearPedTasks(playerPed)
        else
            ClearPedTasksImmediately(playerPed)
        end
    end

    if Config.FirstPerson then
        SetFollowPedCamViewMode(metadata.lastViewMode)
    end
end

local function StopSitting()
    if metadata.lastPos and
        (
        Config.AlwaysTeleportOutOfSeat or Config.TeleportToLastPosWhenNoRoute or
            Config.SitTypes[metadata.type].teleportOut or metadata.teleportOut) then
        SetEntityCoords(PlayerPedId(), metadata.lastPos.x, metadata.lastPos.y, metadata.lastPos.z, false, false, false,
            false)
    end
    LeaveSeat(true, false, false)
end

local function GetScenario(type)
    local scenarios = Config.SitTypes[type].scenarios
    if not scenarios then return false, vector4(0.0, 0.0, 0.0, 0.0) end

    local index = 1
    if #scenarios > 1 then
        index = math.floor(math.random(100, #scenarios * 100) / 100 + 0.5)
    end

    return scenarios[index].name, scenarios[index].offset or Config.SitTypes['default'].scenarios[1].offset
end

local function IsPlayerDoingAnyAction()
    if IsPedUsingScenario(PlayerPedId(), metadata.scenario) or metadata.isSitting or metadata.isLaying then
        return true
    else
        return false
    end
end

local function CanPlayerReachSeat(destination, entity)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local start = vector3(coords.x, coords.y, coords.z + 0.25)

    local _hit, endCoords, _surfaceNormal, entityHit = Raycast(start, destination, playerPed)
    while true do
        -- If a ped stands in the way just ignore it and start a new raycast from behind them
        if GetEntityType(entityHit) ~= 1 then
            local dist = #(endCoords - destination)
            if (dist < 0.5 or endCoords.x == 0.0) or entityHit == entity then
                return true
            else
                return false
            end
        else
            _hit, endCoords, _surfaceNormal, entityHit = Raycast(GetEntityCoords(entityHit), destination, entityHit)
        end

        Wait(0)
    end
end

-- Checks if the seat is "sitable"
local function CanPlayerSitInSeat(coords, heading, entity)
    local rotation = HeadingToRotation(heading)
    local start = GetOffsetFromCoordsInWorldCoords(coords, vector3(0.0, 0.0, rotation), vector3(0.0, 0.25, 0.0))
    local destination = vector3(start.x, start.y, start.z + 0.30)

    local hit, _endCoords, _surfaceNormal, entityHit = Raycast(start, destination, entity)
    if hit == 0 or entityHit == entity or entityHit == PlayerPedId() then
        return true
    else
        return false
    end
end

---Find the closest sit or lay position of spesified type
---@param type string sit, lay or "both"
---@return boolean found if any position was found or not
---@return table closest table containing the data about the closest position
local function GetClosestPositionOfType(type)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closest = {
        type = "unknown",
        distance = 10000.0
    }

    local entites = GetGamePool('CObject')
    for _index, entity in pairs(entites) do
        local model = GetEntityModel(entity)
        if Models[model] and (Models[model][type] or type == "both") then
            local coords = GetEntityCoords(entity)
            local dist = #(coords - playerCoords)
            if dist < closest.distance then
                closest.type = (Models[model].sit and Models[model].lay and "both") or (Models[model].sit and "sit") or
                    (Models[model].lay and "lay") or "unknown"
                closest.entity = entity
                closest.coords = coords
                closest.distance = dist
            end
        end
    end

    for group, data in pairs(PolyZones) do
        if data.enabled then
            if not data.radius or (#(data.center.xy - playerCoords.xy) < data.radius) then
                for name, information in pairs(data.polys) do
                    for typeset, info in pairs(information) do
                        if typeset == type or (type == "both" and (typeset == "sit" or typeset == "lay")) then
                            for _index, coords in pairs(info.seats) do
                                local dist = #(playerCoords - coords.xyz)
                                if dist < closest.distance then
                                    closest.type = (information.sit and information.lay and "both") or
                                        (information.sit and "sit") or (information.lay and "lay") or "unknown"
                                    closest.entity = 0
                                    closest.coords = coords.xyz
                                    closest.distance = dist
                                    closest.name = name
                                    closest.group = group
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closest.type ~= "unknown", closest
end

local function SitOnSeat(data)
    metadata.attAction = true
    metadata.entity = data.entity
    metadata.poly = data.poly
    metadata.type = data.sit.type

    local seat = data.sit
    local settings = Config.SitTypes[seat.type]
    local seatLocation = nil

    if not settings then
        print("^3Warning: No settings were set for type^2", seat.type,
            "^3 in Config.SitTypes, the default settings were used instead!")
        seat.type = 'default'
        settings = Config.SitTypes['default']
    end

    if data.entity ~= nil and data.entity ~= 0 then
        local rot = GetEntityRotation(data.entity)
        local xRot = rot.x
        local yRot = rot.y

        if xRot < 0.0 then xRot = xRot * -1 end
        if yRot < 0.0 then yRot = yRot * -1 end

        local tilt = xRot + yRot
        if tilt > Config.MaxTilt then
            DisplayNotification(Config.Lang.Notification.TooTilted)
            metadata.attAction = false
            return
        end

        local seatCoords = GetEntityCoords(data.entity)
        seatLocation = vector4(seatCoords.x, seatCoords.y, seatCoords.z, GetEntityHeading(data.entity))
    end

    local coords, heading = GetAvailableSeat(seatLocation, seat.seats, data.raycast)
    if coords == nil then
        local model = GetEntityModel(data.entity)
        if model ~= 0 and GetAmountOfSeats(model) ~= 1 then
            DisplayNotification(Config.Lang.Notification.NoAvailable)
        else
            DisplayNotification(Config.Lang.Notification.OccupiedSit)
        end
        metadata.attAction = false
        return
    end

    if heading == nil then
        DisplayNotification(Config.Lang.Notification.NoAvailable)
        metadata.attAction = false
        error("Heading of seat was nil!")
        return
    end

    local skipReachCheck = seat.skipSeeCheck or false
    if not skipReachCheck and not CanPlayerReachSeat(coords, data.entity) then
        DisplayNotification(Config.Lang.Notification.CannotReachSeat)
        metadata.attAction = false
        return
    end

    if data.entity ~= 0 and not CanPlayerSitInSeat(coords, heading, data.entity) then
        DisplayNotification(Config.Lang.Notification.CannotSitInSeat)
        metadata.attAction = false
        return
    end

    -- Scenario offsets
    local scenario, offset = GetScenario(seat.type)
    heading = heading + offset.w
    if heading > 360.0 then
        heading = heading - 360.0
    end
    local rotation = HeadingToRotation(heading)
    coords = GetOffsetFromCoordsInWorldCoords(coords, vector3(0.0, 0.0, rotation), offset.xyz)

    local playerPed = PlayerPedId()
    local lastPos = GetEntityCoords(playerPed)

    metadata.teleportOut = false
    metadata.lastPos = nil
    if Config.AlwaysTeleportOutOfSeat or settings.teleportOut or seat.teleportOut then
        metadata.teleportOut = true
        metadata.lastPos = lastPos
    end

    -- If we are already sitting then leave the current seat first, however if we are attempting to sit on the current seat then stop sitting.
    if metadata.isSitting or metadata.isLaying then
        if #(coords - lastPos) < 0.2 then
            StopSitting()
            metadata.attAction = false
            return
        else
            if metadata.teleportOut then
                LeaveSeat(false, true, false)
            else
                LeaveSeat(true, false, false)
                Wait(2000)
            end
            metadata.entity = data.entity
        end
    end

    metadata.scenario = scenario
    metadata.isLaying = false
    metadata.animation = {}

    ClearPedTasks(playerPed)
    if data.entity ~= 0 then
        HandleLooseEntity(data.entity)
    end

    local timeout = settings.timeout or Config.SitTypes['default'].timeout
    local skipGoStraightTask = settings.skipGoStraightTask
    local prevDist = #(coords.xy - GetEntityCoords(playerPed).xy)
    local dist = prevDist
    local teleport = Config.AlwaysTeleportToSeat or seat.teleportIn or settings.teleportIn
    local breakCounter = 0
    local tick = 0

    if not teleport and not skipGoStraightTask then
        local gotoCoords = GetOffsetFromCoordsInWorldCoords(coords, vector3(0.0, 0.0, rotation), vector3(0.0, 0.695, 0.0))
        local _, groundZ = GetGroundZFor_3dCoord(gotoCoords.x, gotoCoords.y, gotoCoords.z, 0)
        TaskGoStraightToCoord(playerPed, gotoCoords.x, gotoCoords.y, groundZ ~= 0 and groundZ or gotoCoords.z, 1,
            timeout * 500, heading, 0.15)

        while true do
            Wait(500)
            if not metadata.attAction then
                return
            end

            local playerCoords = GetEntityCoords(playerPed)
            dist = #(gotoCoords.xy - playerCoords.xy)
            tick = tick + 1

            if dist < prevDist then
                lastPos = playerCoords
                prevDist = dist
            end

            local diff = math.abs(dist - prevDist)
            local taskStatus = GetScriptTaskStatus(playerPed, "SCRIPT_TASK_GO_STRAIGHT_TO_COORD")

            if taskStatus == 0 or taskStatus == 7 then
                break
            elseif tick > timeout then
                break
            elseif dist > prevDist + 0.1 and dist > 0.85 then
                breakCounter = breakCounter + 1
            elseif diff <= 0.085 and dist < Config.MaxInteractionDist and dist > 0.05 and tick > 1 then
                breakCounter = breakCounter + 1
            else
                breakCounter = breakCounter - 1
                if breakCounter < 0 then
                    breakCounter = 0
                end
            end

            if breakCounter > 2 and seat.type ~= "sunlounger" then
                break
            end
        end
        teleport = dist > 0.5 or false
        tick = 0
    end

    if metadata.scenario then
        metadata.targetPos = coords
        TaskStartScenarioAtPosition(playerPed, metadata.scenario, coords.x, coords.y, coords.z, heading, -1, false,
            teleport)

        while true do
            Wait(500)
            local playerCoords = GetEntityCoords(playerPed)
            dist = #(coords.xy - playerCoords.xy)
            tick = tick + 1

            local taskStatus = GetScriptTaskStatus(playerPed, "SCRIPT_TASK_START_SCENARIO_AT_POSITION")
            if taskStatus == 0 or taskStatus == 7 then
                break
            elseif IsPedUsingScenario(playerPed, metadata.scenario) and dist < 0.40 then
                metadata.isSitting = true
                break
            elseif tick > timeout then
                break
            elseif not IsPedUsingScenario(playerPed, metadata.scenario) then
                break
            end
        end
    else
        local animation = settings.animation
        if animation.offset then
            coords = coords + animation.offset.xyz
            heading = heading + animation.offset.w
        end
        metadata.targetPos = coords

        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(playerPed, heading)

        LoadAnimDict(animation.dict)
        TaskPlayAnim(playerPed, animation.dict, animation.name, 2.0, 2.0, -1, animation.flag or 1, 0, false, false, false)
        RemoveAnimDict(animation.dict)
        metadata.plyFrozen = true
        metadata.isSitting = true
        metadata.animation = animation
    end

    if metadata.isSitting then
        Wait(350)
        if Config.ShowHelpText then
            TriggerEvent('sit:helpTextThread', 'isSitting')
        end
        TriggerEvent('sit:checkThread', 'isSitting')
        TriggerEvent('sit:onSit')

        if Config.FirstPerson then
            metadata.lastViewMode = GetFollowPedCamViewMode()
            SetFollowPedCamViewMode(4)
        end
    elseif dist <= 2.0 then
        TaskStartScenarioAtPosition(playerPed, metadata.scenario, coords.x, coords.y, coords.z, heading, -1, false, true)
        metadata.lastPos = lastPos
        metadata.isSitting = true

        Wait(350)
        if Config.ShowHelpText then
            TriggerEvent('sit:helpTextThread', 'isSitting')
        end
        TriggerEvent('sit:checkThread', 'isSitting')
        TriggerEvent('sit:onSit')

        if Config.FirstPerson then
            metadata.lastViewMode = GetFollowPedCamViewMode()
            SetFollowPedCamViewMode(4)
        end
    else
        LeaveSeat(true, false, false)
    end
    metadata.attAction = false
end

local function SitOnClosestSeat()
    if metadata.attAction then
        DisplayNotification(Config.Lang.Notification.AlreadyAttemptingToSit)
        return
    end

    local found, closest = GetClosestPositionOfType("sit")
    if not found or closest.distance > Config.MaxInteractionDist then
        DisplayNotification(Config.Lang.Notification.NoFound)
    elseif closest.name ~= nil then
        local seat = PolyZones[closest.group].polys[closest.name]
        SitOnSeat({ entity = 0, poly = closest.name, sit = seat.sit, raycast = false })
    elseif closest.entity ~= 0 then
        SitOnSeat({ entity = closest.entity, poly = false, sit = Models[GetEntityModel(closest.entity)].sit,
            raycast = false })
    else
        error('SitOnClosestSeat: Found a chair, but it was missing critical data')
    end
end

local function LayDownOnBed(data)
    metadata.attAction = true
    metadata.isSitting = false
    metadata.plyFrozen = true
    metadata.scenario = false
    metadata.teleportOut = false
    metadata.entity = data.entity
    metadata.poly = data.poly
    metadata.type = data.bed.type

    local bed = data.bed
    local bedLocation = nil

    if data.entity then
        local rot = GetEntityRotation(data.entity)
        local xRot = rot.x
        local yRot = rot.y

        if xRot < 0.0 then xRot = xRot * -1 end
        if yRot < 0.0 then yRot = yRot * -1 end

        local tilt = xRot + yRot
        if tilt > Config.MaxTilt then
            DisplayNotification(Config.Lang.Notification.TooTilted)
            metadata.attAction = false
            return
        end

        local bedCoords = GetEntityCoords(data.entity)
        bedLocation = vector4(bedCoords.x, bedCoords.y, bedCoords.z, GetEntityHeading(data.entity))
    end

    local coords, heading = GetAvailableSeat(bedLocation, bed.seats, data.raycast)
    if coords == nil then
        local model = GetEntityModel(data.entity)
        if Config.SitTypes[bed.type] and GetAmountOfSeats(model) ~= 1 then
            DisplayNotification(Config.Lang.Notification.NoAvailable)
        else
            DisplayNotification(Config.Lang.Notification.OccupiedSit)
        end
        metadata.attAction = false
        return
    end

    if heading == nil then
        DisplayNotification(Config.Lang.Notification.NoAvailable)
        metadata.attAction = false
        error('Heading of bed was nil!')
        return
    end

    if not IsSeatAvailable(coords, 'lay') then
        DisplayNotification(Config.Lang.Notification.OccupiedLay)
        metadata.attAction = false
        return
    end

    local skipReachCheck = bed.skipSeeCheck or false
    if not skipReachCheck and not CanPlayerReachSeat(coords, data.entity) then
        DisplayNotification(Config.Lang.Notification.CannotReachBed)
        metadata.attAction = false
        return
    end

    -- If we are already sitting or laying then leave the current seat first, however if we are attempting to lay on the current seat then stop laying.
    if metadata.isSitting or metadata.isLaying then
        if #(coords - (GetEntityCoords(playerPed))) < 0.2 then
            GetUpFromBed()
            metadata.attAction = false
            return
        else
            if metadata.teleportOut then
                LeaveSeat(false, true, false)
            else
                LeaveSeat(true, false, false)
                Wait(1500)
            end
            metadata.entity = data.entity
        end
    end

    metadata.isSitting = false
    metadata.scenario = false
    metadata.isLaying = false
    metadata.animation = {}

    if data.entity ~= 0 then
        HandleLooseEntity(data.entity)
    end

    local animation = nil
    if Config.LayTypes[bed.type] then
        animation = Config.LayTypes[bed.type].animation
    else
        print("^3Warning: No animation settings were set for type^2", bed.type,
            "^3 in Config.LayTypes, the default animation settings were used instead!")
        animation = Config.LayTypes['default'].animation
    end

    metadata.animation = animation
    if animation.offset then
        coords = GetOffsetFromCoordsInWorldCoords(coords, vector3(0.0, 0.0, HeadingToRotation(heading)),
            animation.offset.xyz)
        heading = heading + animation.offset.w
        if heading > 360 then
            heading = heading - 360
        end
    end

    LoadAnimDict(animation.dict)
    ClearPedTasksImmediately(playerPed)
    SetEntityCollision(playerPed, false, false) -- TODO: figure out why this is causing issues for some people but not others
    FreezeEntityPosition(playerPed, true)
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(playerPed, heading)

    TaskPlayAnim(playerPed, animation.dict, animation.name, 2.0, 2.0, -1, animation.flag or 1, 0, false, false, false)
    RemoveAnimDict(animation.dict)

    Wait(350)
    metadata.isLaying = true
    metadata.attAction = false
    metadata.targetPos = coords
    if Config.ShowHelpText then
        TriggerEvent('sit:helpTextThread', 'isLaying')
    end
    TriggerEvent('sit:checkThread', 'isLaying')
    TriggerEvent('sit:onLay')

    if Config.FirstPerson then
        metadata.lastViewMode = GetFollowPedCamViewMode()
        SetFollowPedCamViewMode(4)
    end
end

local function LayOnClosestBed()
    if metadata.attAction then
        DisplayNotification(Config.Lang.Notification.AlreadyAttemptingToLay)
        return
    end

    local found, closest = GetClosestPositionOfType("lay")
    if not found or closest.distance > Config.MaxInteractionDist then
        DisplayNotification(Config.Lang.Notification.NoBedFound)
    elseif closest.name ~= nil then
        local seat = PolyZones[closest.group].polys[closest.name]
        LayDownOnBed({ entity = 0, poly = closest.name, bed = seat.lay, raycast = false })
    elseif closest.entity ~= 0 then
        LayDownOnBed({ entity = closest.entity, poly = false, bed = Models[GetEntityModel(closest.entity)].lay,
            raycast = false })
    else
        error('LayOnClosestBed: Found a bed, but it lacked critical data.')
    end
end

local function GetUpFromBed()
    local clearTask = true
    local exitAnim = Config.LayTypes[metadata.type].exitAnim or Config.LayTypes['default'].exitAnim
    metadata.isLaying = false

    if metadata.teleportOut then
        local playterPed = PlayerPedId()
        ClearPedTasksImmediately(playterPed)
        SetEntityCoords(playterPed, metadata.lastPos.x, metadata.lastPos.y, metadata.lastPos.z, false, false, false,
            false)
        clearTask = false
    elseif exitAnim then
        local exitAnimType = Config.LayTypes[metadata.type].exitAnimType or Config.LayTypes['default'].exitAnimType
        local direction = nil

        if exitAnimType == 0 then
            if GetGameplayCamRelativeHeading() < 0 then
                direction = "m_getout_l"
            else
                direction = "m_getout_r"
            end
        elseif exitAnimType == 1 then
            direction = "m_getout_l"
        elseif exitAnimType == 2 then
            direction = "m_getout_r"
        else
            print('^3Warning: exitAnimType:', exitAnimType,
                'was not an expcted type, please correct this, setting type to 1 for this instance ("m_getout_r").')
            direction = "m_getout_r"
        end

        LoadAnimDict("savem_default@")
        TaskPlayAnim(PlayerPedId(), "savem_default@", direction, 1.0, 1.0, 3000, 0, 0, false, false, false)
        RemoveAnimDict("savem_default@")
        Wait(1400)
        clearTask = false
    end
    metadata.animation = {}
    LeaveSeat(clearTask, false, false)
end

local function StopCurrentAction()
    if IsPedUsingScenario(PlayerPedId(), metadata.scenario) or metadata.isSitting then
        StopSitting()
    elseif metadata.isLaying then
        GetUpFromBed()
    elseif metadata.attAction then
        metadata.attAction = false
        LeaveSeat(true, false, false)
    end
end

local function AddTargetModel(models, options)
    if Config.Target == 'ox_target' then
        exports.ox_target:addModel(models, options)
    else
        exports[Config.Target]:AddTargetModel(models, { options = options, distance = Config.MaxInteractionDist })
    end
end

local function AddCircleZone(name, center, radius, heading, minZ, maxZ, useZ, options, debug)
    if Config.Target == 'ox_target' then
        exports.ox_target:addSphereZone({
            coords = center,
            radius = radius,
            debug = Config.DebugPoly or debug,
            options = options
        })
    else
        exports[Config.Target]:AddCircleZone(name, center, radius, {
            name = name,
            heading = heading,
            debugPoly = Config.DebugPoly or debug,
            minZ = minZ,
            maxZ = maxZ,
            useZ = useZ
        }, {
            options = options,
            distance = Config.MaxInteractionDist
        })
    end
end

local function AddBoxZone(name, center, heading, length, width, height, minZ, maxZ, useZ, options, debug)
    if Config.Target == 'ox_target' then
        exports.ox_target:addBoxZone({
            coords = center,
            size = vector3(width, length, height),
            rotation = heading,
            debug = Config.DebugPoly or debug,
            options = options
        })
    else
        exports[Config.Target]:AddBoxZone(name, center, length, width, {
            name = name,
            heading = heading,
            debugPoly = Config.DebugPoly or debug,
            minZ = minZ,
            maxZ = maxZ
        }, {
            options = options,
            distance = Config.MaxInteractionDist
        })
    end
end

local function AttemptToLay(entity, poly, info)
    if not metadata.attAction then
        if metadata.isLaying then
            GetUpFromBed()
        else
            LayDownOnBed({ entity = entity, poly = poly, bed = info.lay, raycast = true })
        end
    else
        DisplayNotification(Config.Lang.Notification.AlreadyAttemptingToLay)
    end
end

local function AttemptToSit(entity, poly, info)
    if not metadata.attAction then
        if metadata.isSitting or metadata.isLaying then
            if poly == metadata.poly then
                SitOnSeat({ entity = entity, poly = poly, sit = info.sit, raycast = true })
            else
                StopSitting()
            end
        else
            SitOnSeat({ entity = entity, poly = poly, sit = info.sit, raycast = true })
        end
    else
        DisplayNotification(Config.Lang.Notification.AlreadyAttemptingToSit)
    end
end

local function SetupBeds()
    local models = {}
    for model, data in pairs(Models) do
        if data.lay then
            models[#models + 1] = model
        end
    end

    local options = {
        {
            name = 'hm_chair_lay',
            icon = Config.Targeting.LayIcon,
            label = Config.Targeting.LayLabel
        }
    }

    if Config.Target == 'ox_target' then
        options[1].distance = Config.MaxInteractionDist
        options[1].onSelect = function(data)
            local model = GetEntityModel(data.entity)
            local info = Models[model]
            if info then
                CreateThread(function()
                    AttemptToLay(data.entity, false, info)
                end)
            end
        end
    else
        options[1].action = function(entity)
            local model = GetEntityModel(entity)
            local info = Models[model]
            if info then
                AttemptToLay(entity, false, info)
            end
        end
    end

    AddTargetModel(models, options)
end

local function SetupSeats()
    local models = {}
    for model, data in pairs(Models) do
        if data.sit then
            models[#models + 1] = model
        end
    end

    local options = {
        {
            name = 'hm_chair_sit',
            icon = Config.Targeting.SitIcon,
            label = Config.Targeting.SitLabel
        }
    }

    if Config.Target == 'ox_target' then
        options[1].distance = Config.MaxInteractionDist
        options[1].onSelect = function(data)
            local model = GetEntityModel(data.entity)
            local info = Models[model]
            if info then
                CreateThread(function()
                    AttemptToSit(data.entity, false, info)
                end)
            end
        end
    else
        options[1].action = function(entity)
            local model = GetEntityModel(entity)
            local info = Models[model]
            if info then
                AttemptToSit(entity, false, info)
            end
        end
    end

    AddTargetModel(models, options)
end

local function SetupPolyZones()
    for group, data in pairs(PolyZones) do
        if data.enabled then
            for name, info in pairs(data.polys) do
                -- Remove the zone if it already exists. (targeting script does the checking, ox_target does on resource restart so no need)
                if Config.Target ~= 'ox_target' then
                    exports[Config.Target]:RemoveZone(name)
                end

                if info.poly == nil then
                    error("^PolyZone '" .. name .. "' could not be generated! (lacks poly specifications)")
                elseif info.lay == nil and info.sit == nil then
                    error("PolyZone '" .. name .. "' could not be generated! (no action assinged)")
                else
                    local type = 'sit'
                    local options = {}

                    if info.lay then
                        local index = #options + 1
                        type = 'lay'

                        options[index] = {
                            name = 'hm_poly_lay_' .. name,
                            icon = Config.Targeting.LayIcon,
                            label = Config.Targeting.LayLabel
                        }

                        if Config.Target == 'ox_target' then
                            options[index].distance = Config.MaxInteractionDist
                            options[index].onSelect = function()
                                CreateThread(function()
                                    AttemptToLay(0, name, info)
                                end)
                            end

                            -- This is to prevent duplicate interaction options
                            options[index].canInteract = function(entity, _distance, _coords, _name, _bone)
                                if not entity or GetEntityType(entity) == 0 then
                                    return true
                                end

                                local model = GetEntityModel(entity)
                                if Models[model] and Models[model].lay then
                                    return false
                                end

                                return true
                            end
                        else
                            options[index].action = function()
                                AttemptToLay(0, name, info)
                            end
                        end
                    end

                    if info.sit then
                        local index = #options + 1
                        type = 'sit'

                        options[index] = {
                            name = 'hm_poly_sit_' .. name,
                            icon = Config.Targeting.SitIcon,
                            label = Config.Targeting.SitLabel
                        }

                        if Config.Target == 'ox_target' then
                            options[index].distance = Config.MaxInteractionDist
                            options[index].onSelect = function()
                                CreateThread(function()
                                    AttemptToSit(0, name, info)
                                end)
                            end

                            -- This is to prevent duplicate interaction options
                            options[index].canInteract = function(entity, _distance, _coords, _name, _bone)
                                if not entity or GetEntityType(entity) == 0 then
                                    return true
                                end

                                local model = GetEntityModel(entity)
                                if Models[model] and Models[model].sit then
                                    return false
                                end

                                return true
                            end
                        else
                            options[index].action = function()
                                AttemptToSit(0, name, info)
                            end
                        end
                    end

                    local minZ = info.poly.minZ or (info.poly.center and info.poly.center.z - (info.poly.height / 2)) or
                        info[type].seats[1].z - (info.poly.height / 2)
                    local maxZ = info.poly.maxZ or (info.poly.center and info.poly.center.z + (info.poly.height / 2)) or
                        info[type].seats[1].z + (info.poly.height / 2)
                    local heading = info.poly.heading or info[type].seats[1].w
                    local center = info.poly.center or info[type].seats[1].xyz

                    if info.poly.type == "circle" then
                        local radius = info.poly.radius
                        if radius == nil then
                            print("^3Warning: PolyZone '" ..
                                name .. "' did not have a specified radius! Radius was automatically set to 1.5!")
                            radius = 1.5
                        end

                        AddCircleZone(name, center, radius, heading, minZ, maxZ, true, options, data.debug)
                    else
                        AddBoxZone(name, center, heading, info.poly.length, info.poly.width, info.poly.height, minZ, maxZ
                            , true, options, data.debug)
                    end
                end
            end
            print("^2Info: PolyZone group '" .. group .. "' was generated.")
        else
            print("^3Info: PolyZone group '" .. group .. "' is disabled.")
        end
    end
end

local function SetupLocalization()
    AddTextEntry("sit_getup_keyboard", string.format(Config.Lang.KeyMapping.GetUp, "~INPUT_BA1F4C6D~"))
    AddTextEntry("sit_getup_controller", string.format(Config.Lang.KeyMapping.GetUp, "~INPUT_6ED7AA10~"))

    if Config.UsePrompts then
        AddTextEntry("sit_on_keyboard", string.format(Config.Lang.KeyMapping.SitDown, "~INPUT_93A2CC75~"))
        AddTextEntry("sit_down_controller", string.format(Config.Lang.KeyMapping.SitDown, "~INPUT_53FA0B5E~"))
        AddTextEntry("lay_on_keyboard", string.format(Config.Lang.KeyMapping.LayDown, "~INPUT_C15C4337~"))
        AddTextEntry("lay_down_controller", string.format(Config.Lang.KeyMapping.LayDown, "~INPUT_49E4480F~"))
        AddTextEntry("both_on_keyboard",
            string.format(Config.Lang.KeyMapping.SitDown, "~INPUT_93A2CC75~") ..
            "\n" .. string.format(Config.Lang.KeyMapping.LayDown, "~INPUT_C15C4337~"))
        AddTextEntry("both_down_controller",
            string.format(Config.Lang.KeyMapping.SitDown, "~INPUT_53FA0B5E~") ..
            "\n" .. string.format(Config.Lang.KeyMapping.LayDown, "~INPUT_49E4480F~"))
    end
end

-- Prompt System
local function StartPromptSystem()
    -- Commands
    RegisterCommand("siton", function()
        if metadata.showingPrompt then
            ExecuteCommand("sit")
        end
    end, false)
    RegisterCommand("sitdown", function()
        if metadata.showingPrompt then
            ExecuteCommand("sit")
        end
    end, false)

    RegisterCommand("layon", function()
        if metadata.showingPrompt then
            ExecuteCommand("lay")
        end
    end, false)
    RegisterCommand("laydown", function()
        if metadata.showingPrompt then
            ExecuteCommand("lay")
        end
    end, false)

    -- Keymapping
    RegisterKeyMapping('siton', Config.Lang.KeyBindingDesc.Keyboard.SitDown, 'keyboard',
        Config.DefaultKeybinds.SitDown.SitKeyboard)
    RegisterKeyMapping('sitdown', Config.Lang.KeyBindingDesc.PadAnalog.SitDown, 'PAD_ANALOGBUTTON',
        Config.DefaultKeybinds.SitDown.SitPadAnalog)
    RegisterKeyMapping('layon', Config.Lang.KeyBindingDesc.Keyboard.LayDown, 'keyboard',
        Config.DefaultKeybinds.SitDown.LayKeyboard)
    RegisterKeyMapping('laydown', Config.Lang.KeyBindingDesc.PadAnalog.LayDown, 'PAD_ANALOGBUTTON',
        Config.DefaultKeybinds.SitDown.LayPadAnalog)

    -- A nested function!
    local function ShowPromptText(type)
        metadata.showingPrompt = true
        local textHash = "sit_on_keyboard"

        if IsUsingKeyboard(1) then
            textHash = type .. "_on_keyboard"
        else
            textHash = type .. "_down_controller"
        end

        for _tick = 1, 25 do
            DisplayHelpTextThisFrame(textHash, false)
            Wait(0)
        end
    end

    -- Prompt Thread
    CreateThread(function()
        while true do
            local wait = 500
            if not metadata.isSitting and not metadata.isLaying and not metadata.attAction then
                local found, closest = GetClosestPositionOfType("both")
                if found and closest.distance < Config.MaxPromptDist and
                    CanPlayerReachSeat(closest.coords, closest.entity) then
                    -- Make sure that no other help message is being displayed when we start showing the prompt text, this will stop the annoying pling sounds when two help texts fights over priority
                    if metadata.showingPrompt or
                        not (IsHelpMessageBeingDisplayed() and Config.PreventHelpTextOverwrites
                        ) then
                        ShowPromptText(closest.type)
                        wait = 0
                    end
                else
                    metadata.showingPrompt = false
                end
            else
                wait = 1000
            end

            Wait(wait)
        end
    end)
end

-- Commands --
RegisterCommand("sit", function()
    if not IsPauseMenuActive() then
        if IsPlayerDoingAnyAction() then
            if not Config.UsePrompts then
                StopCurrentAction()
            end
        else
            SitOnClosestSeat()
        end
    end
end, false)

RegisterCommand("lay", function()
    if not IsPauseMenuActive() then
        if IsPlayerDoingAnyAction() then
            if not Config.UsePrompts then
                StopCurrentAction()
            end
        else
            LayOnClosestBed()
        end
    end
end, false)


-- KeyMapping --
RegisterKeyMapping('getup', Config.Lang.KeyBindingDesc.Keyboard.GetUp, 'keyboard', Config.DefaultKeybinds.GetUp.Keyboard)
RegisterCommand('getup', function()
    if not IsPauseMenuActive() then
        StopCurrentAction()
    end
end, false)

RegisterKeyMapping('standup', Config.Lang.KeyBindingDesc.PadAnalog.GetUp, 'PAD_ANALOGBUTTON',
    Config.DefaultKeybinds.GetUp.PadAnalog)
RegisterCommand('standup', function()
    if not IsPauseMenuActive() then
        StopCurrentAction()
    end
end, false)


-- Events --
-- Add your type of persistent notifcations here
AddEventHandler('sit:helpTextThread', function(type)
    CreateThread(function()
        -- Ignore this if you don't use the TMC framework
        if Config.UseTMCFramework then
            TMC.Functions.Notify({
                message = string.format(Config.Lang.KeyMapping.GetUp, GetKeyLabel('getup')),
                id = 'sit_notif',
                persist = true,
                notifType = 'info'
            })

            while metadata[type] do
                Wait(50)
            end

            TMC.Functions.StopNotify("sit_notif")
            return
        end

        while metadata[type] do
            if IsUsingKeyboard(1) then
                DisplayHelpTextThisFrame("sit_getup_keyboard", false)
            else
                DisplayHelpTextThisFrame("sit_getup_controller", false)
            end
            Wait(0)
        end
    end)
end)

AddEventHandler('sit:checkThread', function(type)
    CreateThread(function()
        while true do
            Wait(500)
            if not metadata[type] then
                break
            end

            -- Reduce stress
            -- if Config.ReduceStress then
            -- 	TriggerEvent("status:reduceStress", 0.15) -- keep in mind this is per 500 ms (500 ms = half a second).
            -- end

            -- Distance and animation check
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local distance = #(playerPos.xy - metadata.targetPos.xy)
            local distZ = playerPos.z - metadata.targetPos.z - 1.25
            if distZ > 0.0 then
                distance = distance + distZ
            end

            if distance > 0.5 or
                (
                metadata.scenario and not IsPedUsingScenario(playerPed, metadata.scenario) or
                    (
                    metadata.animation and metadata.animation.dict and
                        not IsEntityPlayingAnim(playerPed, metadata.animation.dict, metadata.animation.name, 3))) or
                IsEntityDead(playerPed) or (metadata.entity ~= 0 and not DoesEntityExist(metadata.entity)) then
                local clearTask = true
                if IsEntityDead(playerPed) or IsPedRagdoll(playerPed) then
                    clearTask = false
                end

                LeaveSeat(clearTask, false, true)
                break
            end
        end

        if type == 'isSitting' then
            TriggerEvent('sit:onGetUp', 'sit')
        else
            TriggerEvent('sit:onGetUp', 'lay')
        end
    end)
end)

AddEventHandler('sit:sitDown', function()
    SitOnClosestSeat()
end)

AddEventHandler('sit:layDown', function()
    LayOnClosestBed()
end)

AddEventHandler('sit:getUp', function()
    StopCurrentAction()
end)

if Config.InvalidateIdleCam then
    AddEventHandler('sit:onSit', function()
        local sitting = true

        -- Register get up event
        local getupEvent = AddEventHandler('sit:onGetUp', function(type)
            if type == "sit" then
                sitting = false
            end
        end)

        -- We don't use DisableIdleCamera as we can't check if the idle cam already was disabled, and we don't want to overwrite any other scripts.
        CreateThread(function()
            while sitting do
                InvalidateIdleCam()
                Wait(1000)
            end

            RemoveEventHandler(getupEvent)
        end)
    end)

    AddEventHandler('sit:onLay', function()
        local laying = true

        -- Register get up event
        local getupEvent = AddEventHandler('sit:onGetUp', function(type)
            if type == "lay" then
                laying = false
            end
        end)

        -- We don't use DisableIdleCamera as we can't check if the idle cam already was disabled, and we don't want to overwrite any other scripts.
        CreateThread(function()
            while laying do
                InvalidateIdleCam()
                Wait(1000)
            end

            RemoveEventHandler(getupEvent)
        end)
    end)
end


-- Initialization --
CreateThread(function()
    -- Set up localization
    SetupLocalization()

    -- Chat command suggestions
    if Config.AddChatSuggestions then
        TriggerEvent('chat:addSuggestion', '/sit', Config.Lang.ChatSuggestions.Sit)
        TriggerEvent('chat:addSuggestion', '/lay', Config.Lang.ChatSuggestions.Lay)
    end

    -- Prompts
    if Config.UsePrompts then
        if Config.Target then
            Config.UsePrompts = false
        else
            StartPromptSystem()
        end
    end

    -- Yes this is needed, people are just... not very good a reading.
    if Config.Target == 'false' then
        print("^3Warning: Config.Target was set to 'false' (string), but it needs to be set to false (boolean).^7")
        Config.Target = false
    end

    -- Targeting
    if Config.Target then
        SetupBeds()
        SetupSeats()
        SetupPolyZones()
    end
end)


-- Debugging --
-- This is some of the code I used when I was debugging/adding new models and polys.
if Config.Debugmode then
    local debugging = true
    local function DrawText3D(coords, text, rgb)
        SetTextColour(rgb.r, rgb.g, rgb.b, 255)
        SetTextScale(0.0, 0.35)
        SetTextFont(4)
        SetTextOutline()
        SetTextCentre(true)

        -- Diplay the text
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        SetDrawOrigin(coords.x, coords.y, coords.z, 0)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()
        DrawRect(coords.x, coords.y, 1.0, 1.0, 230, 230, 230, 255)
    end

    local function GetDebugEntities(playerPed)
        local playerCoords = GetEntityCoords(playerPed)
        local objectPool = GetGamePool('CObject')
        local objects = {}

        for i = 1, #objectPool do
            local pos = GetEntityCoords(objectPool[i])
            local distance = #(playerCoords - pos)
            if distance < 8.0 then
                objects[i] = { pos = pos, entity = objectPool[i] }
            end
        end

        return objects
    end

    local function DebugIsSeatAvailable(coords, action)
        for _index, ped in pairs(GetGamePool('CPed')) do
            local dist = #(GetEntityCoords(ped) - coords)
            if dist < 1.35 then
                if action == 'sit' then
                    if IsEntityPlayingAnyLayAnim(ped) or dist < 0.55 then
                        return false
                    end
                elseif action == 'lay' then
                    if IsEntityPlayingAnyLayAnim(ped) or IsPedSitting(ped) then
                        return false
                    end
                end
            end
        end
        return true
    end

    -- A debug thread, the messiest shit I've ever made.
    local function StartDebuging()
        local toDisplay = {}
        local colors = {
            ['occupied'] = { r = 200, g = 0, b = 0 },
            ['sit'] = { r = 255, g = 255, b = 255 },
            ['lay'] = { r = 150, g = 150, b = 150 },
            ['sit_line'] = { r = 255, g = 0, b = 0, a = 200 },
            ['lay_line'] = { r = 0, g = 102, b = 204, a = 255 }
        }

        CreateThread(function()
            while debugging do
                local globalIndex = 0
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                toDisplay = {}

                local entites = GetDebugEntities(playerPed)
                for _key, info in pairs(entites) do
                    local model = GetEntityModel(info.entity)
                    local information = Models[model]
                    if information then
                        for typeset, data in pairs(information) do
                            for seatIndex, seat in pairs(data.seats) do
                                local subName = typeset .. ": " .. model
                                if #data.seats > 1 then
                                    subName = subName .. " (" .. seatIndex .. ")"
                                end
                                local heading = GetEntityHeading(info.entity)
                                local coords = nil
                                if typeset == "lay" then
                                    coords = GetOffsetFromCoordsInWorldCoords(info.pos,
                                        vector3(0.0, 0.0, HeadingToRotation(heading)),
                                        vector3(seat.x, seat.y, seat.z + 0.25))
                                else
                                    coords = GetOffsetFromCoordsInWorldCoords(info.pos,
                                        vector3(0.0, 0.0, HeadingToRotation(heading)), seat.xyz)
                                end
                                local newHeading = heading + seat.w
                                if newHeading > 360 then
                                    newHeading = newHeading - 360
                                end

                                local textColor = colors[typeset]
                                if not DebugIsSeatAvailable(coords.xyz, typeset) then
                                    textColor = colors['occupied']
                                end
                                globalIndex = globalIndex + 1
                                toDisplay[globalIndex] = { vector4(coords.x, coords.y, coords.z, newHeading), subName,
                                    textColor, colors[typeset .. "_line"] }
                            end
                        end
                    end
                end

                for _group, data in pairs(PolyZones) do
                    if data.enabled then
                        if not data.radius or (#(data.center.xy - playerCoords.xy) < data.radius) then
                            for name, information in pairs(data.polys) do
                                for typeset, info in pairs(information) do
                                    if typeset == "sit" or typeset == "lay" then
                                        for index, coords in pairs(info.seats) do
                                            if #(playerCoords - coords.xyz) < 8.0 then
                                                local subName = typeset .. ": " .. name
                                                if #info.seats > 1 then
                                                    subName = subName .. " (" .. index .. ")"
                                                end
                                                local location = coords.xyz
                                                if typeset == "lay" then
                                                    location = GetOffsetFromCoordsInWorldCoords(coords,
                                                        vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.25))
                                                end

                                                local textColor = colors[typeset]
                                                if not DebugIsSeatAvailable(location, typeset) then
                                                    textColor = colors['occupied']
                                                end
                                                globalIndex = globalIndex + 1
                                                toDisplay[globalIndex] = { vector4(location.x, location.y, location.z,
                                                    coords.w), subName, textColor, colors[typeset .. "_line"] }
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                Wait(1000)
            end
        end)

        CreateThread(function()
            while debugging do
                for _index, data in pairs(toDisplay) do
                    DrawText3D(data[1].xyz, data[2], data[3])
                end
                Wait(0)
            end
        end)

        CreateThread(function()
            while debugging do
                for _index, data in pairs(toDisplay) do
                    if data[1].w ~= nil then
                        local offset = GetOffsetFromCoordsInWorldCoords(data[1].xyz,
                            vector3(0.0, 0.0, HeadingToRotation(data[1].w)), vector3(0.0, 0.50, 0.0))
                        local offset2 = GetOffsetFromCoordsInWorldCoords(data[1].xyz,
                            vector3(0.0, 0.0, HeadingToRotation(data[1].w)), vector3(0.0, 0.00, 0.20))
                        DrawLine(data[1].x, data[1].y, data[1].z, offset.x, offset.y, offset.z, data[4].r, data[4].g,
                            data[4].b, data[4].a)
                        DrawLine(data[1].x, data[1].y, data[1].z, offset2.x, offset2.y, offset2.z, data[4].r, data[4].g,
                            data[4].b, data[4].a)
                    end
                end
                Wait(0)
            end
        end)
    end

    RegisterKeyMapping('sit:debug', 'Sit Debuging', 'keyboard', 'G')
    RegisterCommand('sit:debug', function()
        debugging = not debugging
        if debugging then
            StartDebuging()
        end
    end, false)

    local function GetAverage(table)
        local sum = 0
        for key, value in pairs(table) do
            sum = sum + value
        end
        return sum / #table
    end

    -- Not a true "center", as it calculates the average of all the points, but it's good enough for our purpose.
    RegisterCommand('sit:getcenter', function(_source, args, _rawCommand)
        local group = args[1]
        if PolyZones[group] then
            local xPoints = {}
            local yPoints = {}
            local zPoints = {}

            local index = 0
            for k, v in pairs(PolyZones[group].polys) do
                index = index + 1
                xPoints[index] = (v.poly.center and v.poly.center.x) or (v.sit and v.sit.seats[1].x) or
                    (v.lay and v.lay.seats[1].x)
                yPoints[index] = (v.poly.center and v.poly.center.y) or (v.sit and v.sit.seats[1].y) or
                    (v.lay and v.lay.seats[1].y)
                zPoints[index] = (v.poly.center and v.poly.center.z) or (v.sit and v.sit.seats[1].z) or
                    (v.lay and v.lay.seats[1].z)
            end

            local average = vector3(GetAverage(xPoints), GetAverage(yPoints), GetAverage(zPoints))
            print('average "center":', average)
        else
            print(group, 'is not a valid poly group!')
        end
    end, false)

    RegisterCommand('sit:getfarthestdist', function(_source, args, _rawCommand)
        local group = args[1]
        if PolyZones[group] and PolyZones[group].center then
            local center = PolyZones[group].center
            local farthest = {
                dist = 0,
                name = 'error'
            }

            for name, data in pairs(PolyZones[group].polys) do
                local pos = data.poly.center or (data.sit and data.sit.seats[1].xyz) or
                    (data.lay and data.lay.seats[1].xyz)
                local distance = #(center - pos)
                if distance > farthest.dist then
                    farthest.dist = distance
                    farthest.name = name
                end
            end

            print(farthest.name, farthest.dist)
        else
            print(group, 'is not a valid poly group!')
        end
    end, false)

    -- Load poly groups (only on your client)
    RegisterCommand('sit:loadGroup', function(_source, args, _rawCommand)
        local group = args[1]
        if PolyZones[group] and PolyZones[group].center then
            PolyZones[group].enabled = true
            SetupPolyZones()
        else
            print(group, 'is not a valid poly group!')
        end
    end, false)

    -- Unload poly groups (only on your client)
    RegisterCommand('sit:unloadGroup', function(_source, args, _rawCommand)
        if Config.Target == 'ox_target' then
            print("ox_target does not support this action!")
            return
        end

        local group = args[1]
        if PolyZones[group] and PolyZones[group].center then
            PolyZones[group].enabled = false
            for name, _info in pairs(PolyZones[group].polys) do
                exports[Config.Target]:RemoveZone(name)
            end
        else
            print(group, 'is not a valid poly group!')
        end
    end, false)

    -- Events with some prints
    AddEventHandler('sit:onSit', function()
        print('sit:onSit')
    end)

    AddEventHandler('sit:onLay', function()
        print('sit:onLay')
    end)

    AddEventHandler('sit:onGetUp', function(type)
        print('sit:onGetUp', type)
    end)

    StartDebuging()
end


-- Exports --
local function IsSitting()
    return metadata.isSitting
end

local function IsLaying()
    return metadata.isLaying
end

local function IsNearSeat()
    local found, closest = GetClosestPositionOfType("sit")
    return found and closest.distance < Config.MaxInteractionDist or false
end

local function IsNearBed()
    local found, closest = GetClosestPositionOfType("lay")
    return found and closest.distance < Config.MaxInteractionDist or false
end

local function GetClosestSeat()
    return GetClosestPositionOfType("sit")
end

local function GetClosestBed()
    return GetClosestPositionOfType("lay")
end

exports('IsSitting', IsSitting)
exports('IsLaying', IsLaying)
exports('IsNearSeat', IsNearSeat)
exports('IsNearBed', IsNearBed)
exports('GetClosestSeat', GetClosestSeat)
exports('GetClosestBed', GetClosestBed)
exports('SitOnClosestSeat', SitOnClosestSeat)
exports('LayOnClosestBed', LayOnClosestBed)
exports('StopCurrentAction', StopCurrentAction)
