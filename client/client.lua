if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

-- CLIENT SIDE CODE --
Citizen.CreateThread(function()
    local blipQuestCoords = Config.Blips.coords

    local questPedCoords = Config.Peds.questPedCoords
    local questPedHeading = Config.Peds.questPedHeading
    local questPedModel = GetHashKey(Config.Peds.questPedModel)

    local deliverPedCoordsOne = Config.Peds.deliverPedCoordsOne
    local deliverPedHeadingOne = Config.Peds.deliverPedHeadingOne
    local deliverPedModelOne = GetHashKey(Config.Peds.deliverPedModelOne)

    local deliverPedCoordsTwo = Config.Peds.deliverPedCoordsTwo
    local deliverPedHeadingTwo = Config.Peds.deliverPedHeadingTwo
    local deliverPedModelTwo = GetHashKey(Config.Peds.deliverPedModelTwo)

    local deliverPedCoordsThree = Config.Peds.deliverPedCoordsThree
    local deliverPedHeadingThree = Config.Peds.deliverPedHeadingThree
    local deliverPedModelThree = GetHashKey(Config.Peds.deliverPedModelThree)

    local deliverPackageOne = Config.Blips.deliverPackageOne
    local deliverPackageTwo = Config.Blips.deliverPackageTwo
    local deliverPackageThree = Config.Blips.deliverPackageThree

    local questCarCoords = Config.Car.questCarCoords
    local questCarHeading = Config.Car.questCarHeading
    local questCarModel = GetHashKey(Config.Car.questCarModel)

    local inActiveQuest = false
    local hasDeliverAllPackages = false
    local hasDeliverPackageOne = false
    local hasDeliverPackageTwo = false
    local hasDeliverPackageThree = false

    if Config.Blips.showBlip then
        blip = nil
        blip = AddBlipForCoord(blipQuestCoords.x, blipQuestCoords.y, blipQuestCoords.z)
    
        SetBlipSprite(blip, Config.Blips.type)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, Config.Blips.scale)
        SetBlipColour(blip, Config.Blips.color)
        AddTextEntry("QUESTDELIVERYBLIP", Config.Blips.name)
        BeginTextCommandSetBlipName("QUESTDELIVERYBLIP")
        EndTextCommandSetBlipName(blip)
    end

    RequestModel(questCarModel)

    RequestModel(questPedModel)
    RequestModel(deliverPedModelOne)
    RequestModel(deliverPedModelTwo)
    RequestModel(deliverPedModelThree)

    while not HasModelLoaded(questPedModel) do
        Citizen.Wait(10)
    end

    local questPed = CreatePed(2, questPedModel, questPedCoords.x, questPedCoords.y, questPedCoords.z - 1, questPedHeading, false, false)

    FreezeEntityPosition(questPed, true)
    SetEntityInvincible(questPed, true)
    SetBlockingOfNonTemporaryEvents(questPed, true)

    while true do
        while not inActiveQuest do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), questPedCoords.x, questPedCoords.y, questPedCoords.z, true) < 1.5 then
                Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5, Config.Strings.helpNotification.startQuest)
                if IsControlJustPressed(0, Config.Keybind) then
                    if Config.Framework == "esx" then
                        ESX.ShowNotification(Config.Strings.showNotification.startedQuest, "success", Config.NotificationTime * 1000)
                    elseif Config.Framework == "qb" then
                        QBCore.Functions.Notify(Config.Strings.showNotification.startedQuest, "success", Config.NotificationTime * 1000)
                    end
                    questCar = CreateVehicle(questCarModel, questCarCoords.x, questCarCoords.y, questCarCoords.z, questCarHeading, true, false)
                    if Config.Framework == "qb" then
                        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(questCar))
                    end
                    SetNewWaypoint(deliverPackageOne.x, deliverPackageOne.y)
                    inActiveQuest = true
                    hasDeliverPackageOne = false
                    hasDeliverPackageTwo = false
                    hasDeliverPackageThree = false
                    hasDeliverAllPackages = false
                end
            end
            Citizen.Wait(0)
        end

        if inActiveQuest then
            if not hasDeliverPackageOne then
                blipDeliveryPackageOne = nil
                blipDeliveryPackageOne = AddBlipForCoord(deliverPackageOne.x, deliverPackageOne.y, deliverPackageOne.z)
        
                SetBlipSprite(blipDeliveryPackageOne, Config.Blips.deliverPackageType)
                SetBlipDisplay(blipDeliveryPackageOne, 2)
                SetBlipScale(blipDeliveryPackageOne, Config.Blips.deliverPackageScale)
                SetBlipColour(blipDeliveryPackageOne, Config.Blips.deliverPackageColor)
                AddTextEntry("DELIVERYPACKAGECLIPTHREE", Config.Blips.deliverPackageBlipName)
                BeginTextCommandSetBlipName("DELIVERYPACKAGECLIPTHREE")
                EndTextCommandSetBlipName(blipDeliveryPackageOne)

                deliverPedOne = CreatePed(2, questPedModel, deliverPedCoordsOne.x, deliverPedCoordsOne.y, deliverPedCoordsOne.z - 1, deliverPedHeadingOne, false, false)

                FreezeEntityPosition(deliverPedOne, true)
                SetEntityInvincible(deliverPedOne, true)
                SetBlockingOfNonTemporaryEvents(deliverPedOne, true)
            end

            if not hasDeliverPackageTwo then
                blipDeliveryPackageTwo = nil
                blipDeliveryPackageTwo = AddBlipForCoord(deliverPackageTwo.x, deliverPackageTwo.y, deliverPackageTwo.z)
        
                SetBlipSprite(blipDeliveryPackageTwo, Config.Blips.deliverPackageType)
                SetBlipDisplay(blipDeliveryPackageTwo, 2)
                SetBlipScale(blipDeliveryPackageTwo, Config.Blips.deliverPackageScale)
                SetBlipColour(blipDeliveryPackageTwo, Config.Blips.deliverPackageColor)
                AddTextEntry("DELIVERYPACKAGECLIPTHREE", Config.Blips.deliverPackageBlipName)
                BeginTextCommandSetBlipName("DELIVERYPACKAGECLIPTHREE")
                EndTextCommandSetBlipName(blipDeliveryPackageTwo)

                deliverPedTwo = CreatePed(2, questPedModel, deliverPedCoordsTwo.x, deliverPedCoordsTwo.y, deliverPedCoordsTwo.z - 1, deliverPedHeadingTwo, false, false)

                FreezeEntityPosition(deliverPedTwo, true)
                SetEntityInvincible(deliverPedTwo, true)
                SetBlockingOfNonTemporaryEvents(deliverPedTwo, true)
            end

            if not hasDeliverPackageThree then
                blipDeliveryPackageThree = nil
                blipDeliveryPackageThree = AddBlipForCoord(deliverPackageThree.x, deliverPackageThree.y, deliverPackageThree.z)
        
                SetBlipSprite(blipDeliveryPackageThree, Config.Blips.deliverPackageType)
                SetBlipDisplay(blipDeliveryPackageThree, 2)
                SetBlipScale(blipDeliveryPackageThree, Config.Blips.deliverPackageScale)
                SetBlipColour(blipDeliveryPackageThree, Config.Blips.deliverPackageColor)
                AddTextEntry("DELIVERYPACKAGECLIPTHREE", Config.Blips.deliverPackageBlipName)
                BeginTextCommandSetBlipName("DELIVERYPACKAGECLIPTHREE")
                EndTextCommandSetBlipName(blipDeliveryPackageThree)

                deliverPedThree = CreatePed(2, questPedModel, deliverPedCoordsThree.x, deliverPedCoordsThree.y, deliverPedCoordsThree.z - 1, deliverPedHeadingThree, false, false)

                FreezeEntityPosition(deliverPedThree, true)
                SetEntityInvincible(deliverPedThree, true)
                SetBlockingOfNonTemporaryEvents(deliverPedThree, true)
            end
        end

        while inActiveQuest and not hasDeliverPackageOne and not hasDeliverAllPackages do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), questPedCoords.x, questPedCoords.y, questPedCoords.z, true) < 1.5 then
                Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5, Config.Strings.helpNotification.deliverAll)
            end

            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), deliverPackageOne.x, deliverPackageOne.y, deliverPackageOne.z, true) < 1.5 then
                Draw3DText(deliverPackageOne.x, deliverPackageOne.y, deliverPackageOne.z, 0.5, Config.Strings.helpNotification.deliverPackage)
                if IsControlJustPressed(0, Config.Keybind) then
                    if Config.Framework == "esx" then
                        ESX.ShowNotification(Config.Strings.showNotification.deliveredPackage, "success", Config.NotificationTime * 1000)
                    elseif Config.Framework == "qb" then
                        QBCore.Functions.Notify(Config.Strings.showNotification.deliveredPackage, "success", Config.NotificationTime * 1000)
                    end
                    RemoveBlip(blipDeliveryPackageOne)
                    DeletePed(deliverPedOne)
                    SetNewWaypoint(deliverPackageTwo.x, deliverPackageTwo.y)
                    hasDeliverPackageOne = true
                end
            end
            Citizen.Wait(0)
        end

        while inActiveQuest and not hasDeliverPackageTwo do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), deliverPackageTwo.x, deliverPackageTwo.y, deliverPackageTwo.z, true) < 1.5 then
                Draw3DText(deliverPackageTwo.x, deliverPackageTwo.y, deliverPackageTwo.z, 0.5, Config.Strings.helpNotification.deliverPackage)
                if IsControlJustPressed(0, Config.Keybind) then
                    if Config.Framework == "esx" then
                        ESX.ShowNotification(Config.Strings.showNotification.deliveredPackage, "success", Config.NotificationTime * 1000)
                    elseif Config.Framework == "qb" then
                        QBCore.Functions.Notify(Config.Strings.showNotification.deliveredPackage, "success", Config.NotificationTime * 1000)
                    end
                    RemoveBlip(blipDeliveryPackageTwo)
                    DeletePed(deliverPedTwo)
                    SetNewWaypoint(deliverPackageThree.x, deliverPackageThree.y)
                    hasDeliverPackageTwo = true
                end
            end
            Citizen.Wait(0)
        end

        while inActiveQuest and not hasDeliverPackageThree do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), deliverPackageThree.x, deliverPackageThree.y, deliverPackageThree.z, true) < 1.5 then
                Draw3DText(deliverPackageThree.x, deliverPackageThree.y, deliverPackageThree.z, 0.5, Config.Strings.helpNotification.deliverPackage)
                if IsControlJustPressed(0, Config.Keybind) then
                    if Config.Framework == "esx" then
                        ESX.ShowNotification(Config.Strings.showNotification.driveBack, "success", Config.NotificationTime * 1000)
                    elseif Config.Framework == "qb" then
                        QBCore.Functions.Notify(Config.Strings.showNotification.driveBack, "success", Config.NotificationTime * 1000)
                    end
                    RemoveBlip(blipDeliveryPackageThree)
                    DeletePed(deliverPedThree)
                    SetNewWaypoint(questPedCoords.x, questPedCoords.y)
                    hasDeliverPackageThree = true
                    hasDeliverAllPackages = true
                end
            end
            Citizen.Wait(0)
        end

        while inActiveQuest and hasDeliverAllPackages do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), questPedCoords.x, questPedCoords.y, questPedCoords.z, true) < 1.5 then
                Draw3DText(questPedCoords.x, questPedCoords.y, questPedCoords.z, 0.5, Config.Strings.helpNotification.getMoney)
                if IsControlJustPressed(0, Config.Keybind) then
                    TriggerServerEvent("lurvorx_delivery:getMoney")
                    if Config.Framework == "esx" then
                        ESX.ShowNotification(Config.Strings.showNotification.questDone, "success", Config.NotificationTime * 1000)
                    elseif Config.Framework == "qb" then
                        QBCore.Functions.Notify(Config.Strings.showNotification.questDone, "success", Config.NotificationTime * 1000)
                    end
                    DeleteVehicle(questCar)
                    inActiveQuest = false
                    hasDeliverAllPackages = false
                end
            end
            Citizen.Wait(0)
        end
    end
end)

-- FUNCTIONS --
function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
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
