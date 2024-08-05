Config = {}

-- Your discord webhook, for the delivery logs.
Config.Webhook = ""

-- The amount the player will get after delivering all the packages.
Config.PayMoney = 2000

-- For how long the notification time wil be shown for (in seconds).
Config.NotificationTime = 8

-- The keybind the players are gonna use to interact with the peds.
-- Find information about controls here: https://docs.fivem.net/docs/game-references/controls/
Config.Keybind = 38

-- Config all of the blips under.
-- Find information about blips here: https://docs.fivem.net/docs/game-references/blips/
Config.Blips = {

    -- The blip that will show where the quest ped is.
    showBlip = true,
    name = "Help Karen",
    type = 280,
    scale = 1.0,
    color = 5,
    coords = {x = 970.9639, y = -2405.5630, z = 31.4937},

    -- All the other blips for where to deliver the packages.
    deliverPackageBlipName = "Deliver here!",
    deliverPackageType = 1,
    deliverPackageScale = 1.0,
    deliverPackageColor = 3,

    deliverPackageOne = {x = 869.6987, y = -2327.1013, z = 30.6029},
    deliverPackageTwo = {x = 844.5034, y = -2118.2617, z = 30.5211},
    deliverPackageThree = {x = 1092.7313, y = -2252.0068, z = 31.2339}

}

-- Config all of the peds under.
-- Find information about peds here: https://docs.fivem.net/docs/game-references/ped-models/
Config.Peds = {

    -- The ped to interact with to start the delivery quest.
    questPedCoords = {x = 970.9639, y = -2405.5630, z = 31.4937},
    questPedHeading = 262.9022,
    questPedModel = "a_f_m_tourist_01",

    -- The first ped to deliver the package to.
    deliverPedCoordsOne = {x = 869.6987, y = -2327.1013, z = 30.6029},
    deliverPedHeadingOne = 176.6996,
    deliverPedModelOne = "a_f_m_tramp_01",

    -- The second ped to deliver the package to.
    deliverPedCoordsTwo = {x = 844.5034, y = -2118.2617, z = 30.5211},
    deliverPedHeadingTwo = 88.8697,
    deliverPedModelTwo = "a_m_m_genfat_02",

    -- The thrid ped to deliver the package to.
    deliverPedCoordsThree = {x = 1092.7313, y = -2252.0068, z = 31.2339},
    deliverPedHeadingThree = 265.9628,
    deliverPedModelThree = "a_m_m_soucent_03"

}

-- Config the car that the players are gonna use to deliver the packages under.
-- Find information about cars here: https://docs.fivem.net/docs/game-references/vehicle-models/
Config.Car = {

    -- The quest car
    questCarCoords = {x = 983.1087, y = -2410.2227, z = 30.4503},
    questCarHeading = 352.9906,
    questCarModel = "burrito3",

}

-- Config the language you want to use.
Config.Strings = {

    -- The top-right helo notification.
    helpNotification = {
        startQuest = "~INPUT_CONTEXT~ To help Karen delivering the packages",
        deliverAll = "Deliver all the packages",
        deliverPackage = "~INPUT_CONTEXT~ To deliver the package",
        getMoney = "~INPUT_CONTEXT~ To get your money"
    },

    -- The notifications.
    showNotification = {
        startedQuest = "Great, now take the truck and drive to your waypoint.",
        deliveredPackage = "Thanks for the package!",
        driveBack = "Thanks for the package! Now, drive back to Karen.",
        questDone = "Thanks for helping me deliver all the packages! Heres your money."
    }

}
