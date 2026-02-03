---- APEX DEVELOPMENT 
-- DISCORD.GG/K3YnEJzzDA

local QBCore = exports['qb-core']:GetCoreObject()
local activeUnits = {}

RegisterNetEvent('r-police:server:startTracking', function(patrol)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'police' then return end

    activeUnits[src] = patrol
    TriggerClientEvent('r-police:client:startTracking', src, patrol)
end)

RegisterNetEvent('r-police:server:updateBlip', function(coords, sprite, patrol)
    local src = source
    if not activeUnits[src] then return end

    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(id)
        if Player and Player.PlayerData.job.name == 'police' then
            TriggerClientEvent(
                'r-police:client:updateBlip',
                id,
                src,
                coords,
                sprite,
                patrol
            )
        end
    end
end)

RegisterNetEvent('r-police:server:stopTracking', function()
    local src = source
    activeUnits[src] = nil
    TriggerClientEvent('r-police:client:stopTracking', src)
    TriggerClientEvent('r-police:client:removeBlip', -1, src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    activeUnits[src] = nil
    TriggerClientEvent('r-police:client:removeBlip', -1, src)
end)
