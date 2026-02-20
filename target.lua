-- bridge/target.lua
-- Abstraction Layer für ox_target, qb-target und ESX E-Key

TargetBridge = {}

---@param props table Liste der Prop-Namen
---@param label string Anzeige-Text
---@param callback function Wird aufgerufen wenn der Spieler interagiert
function TargetBridge.RegisterChairs(props, label, callback)
    local system = Config.TargetSystem

    -- ─── OX_TARGET ───────────────────────────────────────────────
    if system == 'ox' then
        exports.ox_target:addModel(props, {
            {
                name    = 'hm_sit_chair',
                label   = label,
                icon    = 'fas fa-chair',
                distance = 2.0,
                onSelect = function(data)
                    callback(data.entity)
                end,
            }
        })

    -- ─── QB-TARGET ────────────────────────────────────────────────
    elseif system == 'qb' then
        for _, prop in ipairs(props) do
            exports['qb-target']:AddTargetModel(prop, {
                options = {
                    {
                        type    = 'client',
                        event   = 'hm-sitting:client:sitOnChair',
                        label   = label,
                        icon    = 'fas fa-chair',
                    }
                },
                distance = 2.0,
            })
        end

        -- qb-target nutzt Events statt direktem Callback → Event registrieren
        AddEventHandler('hm-sitting:client:sitOnChair', function(data)
            callback(data.entity)
        end)

    -- ─── ESX / E-KEY (ox_lib drawText) ────────────────────────────
    elseif system == 'esx' then
        -- E-Key Logik läuft in client.lua via Tick
        -- Hier nur Dummy damit der Aufruf nicht crasht
        TargetBridge._esxCallback = callback
    end
end

-- Gibt den ESX-Callback zurück (wird in client.lua für den Tick genutzt)
function TargetBridge.GetESXCallback()
    return TargetBridge._esxCallback
end
