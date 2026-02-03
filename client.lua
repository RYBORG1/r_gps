---- APEX DEVELOPMENT 
-- DISCORD.GG/K3YnEJzzDA

local QBCore = exports['qb-core']:GetCoreObject()

local tracking = false
local patrolNumber = nil
local myBlips = {}

local pedModel = `s_m_y_cop_01`
local pedCoords = vector4(460.9411, -984.3556, 22.2982, 8.6081)

local blips = {
    foot = 1,
    car = 326,
    bike = 661,
    heli = 43
}

CreateThread(function()
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end

    local ped = CreatePed(0, pedModel, pedCoords.xyz, pedCoords.w, false, true)
    PlaceObjectOnGroundProperly(ped)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = 'Start GPS',
            icon = 'fa-solid fa-satellite',
            groups = { police = 0 },
            onSelect = function()
                startGPS()
            end
        },
        {
            label = 'Fjern GPS',
            icon = 'fa-solid fa-ban',
            groups = { police = 0 },
            onSelect = function()
                removeGPS()
            end
        }
    })
end)

function startGPS()
    if tracking then
        lib.notify({ type = 'error', description = 'GPS er allerede aktiv' })
        return
    end

    local patrol = lib.inputDialog('Patruljenummer', {
        { type = 'input', required = true }
    })

    if not patrol then return end

    patrolNumber = patrol[1]

    TriggerServerEvent('r-police:server:startTracking', patrolNumber)

    lib.notify({
        type = 'success',
        description = 'GPS aktiveret – Patrulje ' .. patrolNumber
    })
end

function removeGPS()
    if not tracking then
        lib.notify({ type = 'error', description = 'GPS er ikke aktiv' })
        return
    end

    TriggerServerEvent('r-police:server:stopTracking')

    lib.notify({
        type = 'inform',
        description = 'Du fjernede din GPS'
    })
end

RegisterNetEvent('r-police:client:startTracking', function(patrol)
    tracking = true
    patrolNumber = patrol

    CreateThread(function()
        while tracking do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local veh = GetVehiclePedIsIn(ped, false)

            local sprite = blips.foot

            if veh ~= 0 then
                local class = GetVehicleClass(veh)
                if class == 8 then
                    sprite = blips.bike
                elseif class == 15 then
                    sprite = blips.heli
                else
                    sprite = blips.car
                end
            end

            TriggerServerEvent(
                'r-police:server:updateBlip',
                coords,
                sprite,
                patrolNumber
            )

            Wait(1500)
        end
    end)
end)

RegisterNetEvent('r-police:client:updateBlip', function(src, coords, sprite, patrol)
    if myBlips[src] then
        RemoveBlip(myBlips[src])
    end

    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Patrulje ' .. patrol)
    EndTextCommandSetBlipName(blip)

    myBlips[src] = blip
end)

RegisterNetEvent('r-police:client:removeBlip', function(src)
    if myBlips[src] then
        RemoveBlip(myBlips[src])
        myBlips[src] = nil
    end
end)

RegisterNetEvent('r-police:client:stopTracking', function()
    tracking = false
    patrolNumber = nil
end)
