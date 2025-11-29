ESX = exports['es_extended']:getSharedObject()

-- Ensure cooldown table exists
MySQL.ready(function()
    MySQL.query([[ 
        CREATE TABLE IF NOT EXISTS drugplug_cooldowns (
            license VARCHAR(100) NOT NULL PRIMARY KEY,
            next_use BIGINT NOT NULL
        );
    ]], {})
end)

RegisterCommand("drugplug", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Get player license
    local license
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find("license:") then
            license = id
            break
        end
    end

    if not license then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'No license found'})
        return
    end

    -- Check if license is authorized
    local plug = Config.Plugs[license]
    if not plug then
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'You are not authorized'})
        return
    end

    -- Check cooldown
    MySQL.query('SELECT next_use FROM drugplug_cooldowns WHERE license = ?', {license}, function(result)
        local nextUse = result[1] and result[1].next_use
        local now = os.time()

        if nextUse and now < nextUse then
            local remaining = nextUse - now
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Please wait ' .. math.floor(remaining/60) .. ' minutes'})
            return
        end

        -- Give item via ox_inventory
        exports.ox_inventory:AddItem(source, plug.item, plug.amount)
        TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = 'You received: ' .. plug.item})

        -- Update cooldown
        local newTime = now + Config.Cooldown
        MySQL.query([[INSERT INTO drugplug_cooldowns (license, next_use) VALUES (?, ?)
            ON DUPLICATE KEY UPDATE next_use = VALUES(next_use)]], {license, newTime})
    end)
end)
