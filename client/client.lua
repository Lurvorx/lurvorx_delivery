-- Framework initialization
local ESX, QBCore = nil, nil

if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

-- UTILITY FUNCTIONS --
local function ShowNotification(message, type, duration)
    if Config.Framework == "esx" then
        ESX.ShowNotification(message, type or "success", duration or (Config.NotificationTime * 1000))
    elseif Config.Framework == "qb" then
        QBCore.Functions.Notify(message, type or "success", duration or (Config.NotificationTime * 1000))
    end
end

local function GiveVehicleKeys(vehicle)
    if Config.Framework == "qb" then
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(vehicle))
    end
    if GetResourceState("zyke_garages") ~= "missing" then
        exports["zyke_garages"]:GiveTempKeys(vehicle)
    end
end

local function RemoveVehicleKeys(vehicle)
    if GetResourceState("zyke_garages") ~= "missing" then
        local vin = exports["zyke_garages"]:GetVinFromVehicle(vehicle, false, false)
        exports["zyke_garages"]:RemoveAsPersistent(vin)
    end
end

local function LoadModel(model)
    local modelHash = type(model) == "string" and GetHashKey(model) or model

    if not IsModelValid(modelHash) then
        print("^1[ERROR] Invalid model: " .. tostring(model) .. "^0")
        return false
    end

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Citizen.Wait(10)
        timeout = timeout + 1
    end

    if timeout >= 100 then
        print("^1[ERROR] Failed to load model: " .. tostring(model) .. "^0")
        return false
    end

    return true
end

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- STATE MANAGEMENT --
local questState = {
    isActive = false,
    currentDelivery = 0,
    questCar = nil,
    deliveries = {}
}

-- Delivery configuration table
local deliveryConfig = {
    {
        coords = Config.Blips.deliverPackageOne,
        pedCoords = Config.Peds.deliverPedCoordsOne,
        pedHeading = Config.Peds.deliverPedHeadingOne,
        pedModel = Config.Peds.deliverPedModelOne
    },
    {
        coords = Config.Blips.deliverPackageTwo,
        pedCoords = Config.Peds.deliverPedCoordsTwo,
        pedHeading = Config.Peds.deliverPedHeadingTwo,
        pedModel = Config.Peds.deliverPedModelTwo
    },
    {
        coords = Config.Blips.deliverPackageThree,
        pedCoords = Config.Peds.deliverPedCoordsThree,
        pedHeading = Config.Peds.deliverPedHeadingThree,
        pedModel = Config.Peds.deliverPedModelThree
    }
}

-- CLEANUP FUNCTIONS --
local function CleanupDelivery(index)
    local delivery = questState.deliveries[index]
    if delivery then
        if delivery.blip and DoesBlipExist(delivery.blip) then
            RemoveBlip(delivery.blip)
            delivery.blip = nil
        end
        if delivery.ped and DoesEntityExist(delivery.ped) then
            DeletePed(delivery.ped)
            delivery.ped = nil
        end
        delivery.completed = true
    end
end

local function CleanupAllDeliveries()
    for i = 1, #questState.deliveries do
        CleanupDelivery(i)
    end
    questState.deliveries = {}
end

local function CleanupQuest()
    CleanupAllDeliveries()

    if questState.questCar and DoesEntityExist(questState.questCar) then
        RemoveVehicleKeys(questState.questCar)
        DeleteVehicle(questState.questCar)
        questState.questCar = nil
    end

    questState.isActive = false
    questState.currentDelivery = 0
end

-- DELIVERY SETUP FUNCTIONS --
local function CreateDeliveryBlip(coords, index)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blips.deliverPackageType)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, Config.Blips.deliverPackageScale)
    SetBlipColour(blip, Config.Blips.deliverPackageColor)
    AddTextEntry("DELIVERYPACKAGEBLIP" .. index, Config.Blips.deliverPackageBlipName)
    BeginTextCommandSetBlipName("DELIVERYPACKAGEBLIP" .. index)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function CreateDeliveryPed(config)
    if not LoadModel(config.pedModel) then
        return nil
    end

    local ped = CreatePed(2, GetHashKey(config.pedModel),
        config.pedCoords.x, config.pedCoords.y, config.pedCoords.z - 1,
        config.pedHeading, false, false)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    SetModelAsNoLongerNeeded(GetHashKey(config.pedModel))

    return ped
end

local function SetupDeliveries()
    questState.deliveries = {}

    for i, config in ipairs(deliveryConfig) do
        questState.deliveries[i] = {
            blip = CreateDeliveryBlip(config.coords, i),
            ped = CreateDeliveryPed(config),
            completed = false,
            coords = config.coords
        }
    end
end

-- QUEST FUNCTIONS --
local function StartQuest()
    if questState.isActive then return end

    -- Notify server that quest is starting
    TriggerServerEvent("lurvorx_delivery:startQuest")

    -- Load car model
    if not LoadModel(Config.Car.questCarModel) then
        ShowNotification("Failed to load vehicle model", "error")
        return
    end

    -- Create quest vehicle
    local carHash = GetHashKey(Config.Car.questCarModel)
    questState.questCar = CreateVehicle(carHash,
        Config.Car.questCarCoords.x, Config.Car.questCarCoords.y, Config.Car.questCarCoords.z,
        Config.Car.questCarHeading, true, false)

    SetModelAsNoLongerNeeded(carHash)

    if not DoesEntityExist(questState.questCar) then
        ShowNotification("Failed to create vehicle", "error")
        return
    end

    -- Give vehicle keys
    GiveVehicleKeys(questState.questCar)

    -- Setup deliveries
    SetupDeliveries()

    -- Set waypoint to first delivery
    if questState.deliveries[1] and questState.deliveries[1].coords then
        SetNewWaypoint(questState.deliveries[1].coords.x, questState.deliveries[1].coords.y)
    end

    questState.isActive = true
    questState.currentDelivery = 1

    ShowNotification(Config.Strings.showNotification.startedQuest, "success")
end

local function CompleteDelivery(index)
    if not questState.deliveries[index] or questState.deliveries[index].completed then
        return
    end

    -- Check if player is in quest vehicle
    local playerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if playerVehicle == 0 or playerVehicle ~= questState.questCar then
        ShowNotification("You need to be in the delivery vehicle!", "error")
        return
    end

    CleanupDelivery(index)

    if index < #questState.deliveries then
        -- More deliveries to go
        ShowNotification(Config.Strings.showNotification.deliveredPackage, "success")
        questState.currentDelivery = index + 1

        local nextDelivery = questState.deliveries[index + 1]
        if nextDelivery and nextDelivery.coords then
            SetNewWaypoint(nextDelivery.coords.x, nextDelivery.coords.y)
        end
    else
        -- All deliveries completed
        ShowNotification(Config.Strings.showNotification.driveBack, "success")
        questState.currentDelivery = 0

        -- Set waypoint back to quest ped
        SetNewWaypoint(Config.Peds.questPedCoords.x, Config.Peds.questPedCoords.y)
    end
end

local function FinishQuest()
    -- Notify server for validation and payment
    TriggerServerEvent("lurvorx_delivery:finishQuest")

    ShowNotification(Config.Strings.showNotification.questDone, "success")

    CleanupQuest()
end

-- MAIN QUEST PED SETUP --
Citizen.CreateThread(function()
    -- Load quest ped model
    if not LoadModel(Config.Peds.questPedModel) then
        print("^1[ERROR] Failed to load quest ped model^0")
        return
    end

    -- Create quest ped
    local questPedHash = GetHashKey(Config.Peds.questPedModel)
    local questPed = CreatePed(2, questPedHash,
        Config.Peds.questPedCoords.x, Config.Peds.questPedCoords.y, Config.Peds.questPedCoords.z - 1,
        Config.Peds.questPedHeading, false, false)

    FreezeEntityPosition(questPed, true)
    SetEntityInvincible(questPed, true)
    SetBlockingOfNonTemporaryEvents(questPed, true)

    SetModelAsNoLongerNeeded(questPedHash)

    -- Create quest blip
    if Config.Blips.showBlip then
        local blip = AddBlipForCoord(Config.Blips.coords.x, Config.Blips.coords.y, Config.Blips.coords.z)
        SetBlipSprite(blip, Config.Blips.type)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, Config.Blips.scale)
        SetBlipColour(blip, Config.Blips.color)
        AddTextEntry("QUESTDELIVERYBLIP", Config.Blips.name)
        BeginTextCommandSetBlipName("QUESTDELIVERYBLIP")
        EndTextCommandSetBlipName(blip)
    end
end)

-- QUEST PED INTERACTION THREAD --
Citizen.CreateThread(function()
    local questPedCoords = Config.Peds.questPedCoords

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - vector3(questPedCoords.x, questPedCoords.y, questPedCoords.z))

        if distance < 10.0 then
            sleep = 0

            if distance < 1.5 then
                if not questState.isActive then
                    -- Start quest
                    Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5,
                        Config.Strings.helpNotification.startQuest)

                    if IsControlJustPressed(0, Config.Keybind) then
                        StartQuest()
                    end
                elseif questState.currentDelivery == 0 then
                    -- All deliveries done, collect reward
                    Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5,
                        Config.Strings.helpNotification.getMoney)

                    if IsControlJustPressed(0, Config.Keybind) then
                        FinishQuest()
                    end
                else
                    -- In progress
                    Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5,
                        Config.Strings.helpNotification.deliverAll)
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- DELIVERY INTERACTION THREAD --
Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if questState.isActive and questState.currentDelivery > 0 then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for i = questState.currentDelivery, #questState.deliveries do
                local delivery = questState.deliveries[i]

                if delivery and not delivery.completed and delivery.coords then
                    local deliveryCoords = vector3(delivery.coords.x, delivery.coords.y, delivery.coords.z)
                    local distance = #(playerCoords - deliveryCoords)

                    if distance < 10.0 then
                        sleep = 0

                        if distance < 1.5 then
                            Draw3DText(delivery.coords.x, delivery.coords.y, delivery.coords.z, 0.5,
                                Config.Strings.helpNotification.deliverPackage)

                            if IsControlJustPressed(0, Config.Keybind) then
                                CompleteDelivery(i)
                                break
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- CLEANUP ON RESOURCE STOP --
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupQuest()
    end
end)

-- CLEANUP ON PLAYER DEATH --
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local died = args[4]

        if victim == PlayerPedId() and died == 1 and questState.isActive then
            ShowNotification("Quest failed due to death!", "error")
            CleanupQuest()
        end
    end
end)
