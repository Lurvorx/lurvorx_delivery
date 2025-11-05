-- Framework initialization
local ESX, QBCore = nil, nil

if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

-- Player quest state tracking
local activeQuests = {}
local questCooldowns = {}

-- Configuration
local COOLDOWN_TIME = 300 -- 5 minutes in seconds (adjust as needed)

-- Discord webhook function
local SendToDiscord = nil

if Config.Webhook.useWebhook then
    SendToDiscord = function(playerName, discordMessage)
        if not Config.Webhook.webhook or Config.Webhook.webhook == "" then
            print("^3[WARNING] Webhook is enabled but webhook URL is not configured^0")
            return
        end

        local embeds = {
            {
                ['type'] = 'rich',
                ['title'] = '`📦` DELIVERY LOGS',
                ['description'] = discordMessage,
                ['color'] = 10092339,
                ['footer'] = {
                    ['text'] = 'Lurvorx Scripts Logs | ' .. os.date(),
                    ['icon_url'] = 'https://cdn.discordapp.com/attachments/1185300625320329296/1185630929847337000/Lurvorx-Scripts-Logga.jpg?ex=6675b4d9&is=66746359&hm=154e4c80ac278286f9b24f7e1b832fe2afcddad8d4801c62e7656d4b1a79da55&'
                }
            }
        }

        PerformHttpRequest(Config.Webhook.webhook, function(err, text, headers) end, 'POST', json.encode({ embeds = embeds}), { ['Content-Type'] = 'application/json' })
    end
end

-- Utility function to get player identifiers
local function GetPlayerIdentifiersTable(source)
    local identifiers = {
        steamid = "N/A",
        license = "N/A",
        license2 = "N/A",
        fivem = "N/A",
        discord = "N/A"
    }

    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifiers.steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            identifiers.license = v
        elseif string.sub(v, 1, string.len("license2:")) == "license2:" then
            identifiers.license2 = v
        elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
            identifiers.fivem = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifiers.discord = string.gsub(v, "discord:", "")
        end
    end

    return identifiers
end

-- Start quest event
RegisterNetEvent("lurvorx_delivery:startQuest")
AddEventHandler("lurvorx_delivery:startQuest", function()
    local _source = source

    -- Check if player is already in a quest
    if activeQuests[_source] then
        print(string.format("^3[WARNING] Player %s tried to start quest while already in one^0", GetPlayerName(_source)))
        return
    end

    -- Check cooldown
    if questCooldowns[_source] and os.time() < questCooldowns[_source] then
        local remainingTime = questCooldowns[_source] - os.time()
        TriggerClientEvent('chat:addMessage', _source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Delivery]", string.format("You need to wait %d seconds before starting another quest", remainingTime)}
        })
        return
    end

    -- Initialize quest state for player
    activeQuests[_source] = {
        startTime = os.time(),
        deliveriesCompleted = 0
    }

    print(string.format("^2[INFO] Player %s started a delivery quest^0", GetPlayerName(_source)))
end)

-- Complete delivery event (optional tracking)
RegisterNetEvent("lurvorx_delivery:completeDelivery")
AddEventHandler("lurvorx_delivery:completeDelivery", function(deliveryIndex)
    local _source = source

    if not activeQuests[_source] then
        print(string.format("^1[ERROR] Player %s tried to complete delivery without active quest^0", GetPlayerName(_source)))
        return
    end

    activeQuests[_source].deliveriesCompleted = (activeQuests[_source].deliveriesCompleted or 0) + 1
end)

-- Finish quest and get money
RegisterNetEvent("lurvorx_delivery:finishQuest")
AddEventHandler("lurvorx_delivery:finishQuest", function()
    local _source = source

    -- Validate that player has an active quest
    if not activeQuests[_source] then
        print(string.format("^1[EXPLOIT ATTEMPT] Player %s tried to finish quest without starting one^0", GetPlayerName(_source)))
        return
    end

    local questData = activeQuests[_source]
    local questDuration = os.time() - questData.startTime

    -- Anti-cheat: Check if quest was completed too quickly (minimum 60 seconds)
    if questDuration < 60 then
        print(string.format("^1[EXPLOIT ATTEMPT] Player %s completed quest too quickly (%d seconds)^0", GetPlayerName(_source), questDuration))
        activeQuests[_source] = nil
        return
    end

    -- Get player object
    local xPlayer, Player
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(_source)
        if not xPlayer then
            print(string.format("^1[ERROR] Could not get ESX player object for %s^0", GetPlayerName(_source)))
            activeQuests[_source] = nil
            return
        end
    elseif Config.Framework == "qb" then
        Player = QBCore.Functions.GetPlayer(_source)
        if not Player then
            print(string.format("^1[ERROR] Could not get QBCore player object for %s^0", GetPlayerName(_source)))
            activeQuests[_source] = nil
            return
        end
    end

    -- Give money reward
    if Config.Framework == "esx" then
        xPlayer.addMoney(Config.PayMoney)
    elseif Config.Framework == "qb" then
        Player.Functions.AddMoney('cash', Config.PayMoney)
    end

    -- Set cooldown
    questCooldowns[_source] = os.time() + COOLDOWN_TIME

    -- Log to Discord
    if SendToDiscord then
        local playerName = GetPlayerName(_source)
        local identifiers = GetPlayerIdentifiersTable(_source)

        local logMessage = string.format(
            "**%s** have delivered **3** packages in **%d** seconds." ..
            "\n\n`👤` **PLAYER:** `%s`" ..
            "\n`🔢` **SERVER ID:** `%d`" ..
            "\n`💬` **DISCORD:** <@%s> [||%s||]" ..
            "\n`🎮` **STEAM HEX:** ||%s||" ..
            "\n`🎮` **FIVEM:** ||%s||" ..
            "\n`💿` **LICENSE:** ||%s||" ..
            "\n`📀` **LICENSE 2:** ||%s||" ..
            "\n`💰` **REWARD:** $%d",
            playerName, questDuration, playerName, _source,
            identifiers.discord, identifiers.discord,
            identifiers.steamid, identifiers.fivem,
            identifiers.license, identifiers.license2,
            Config.PayMoney
        )

        SendToDiscord(playerName, logMessage)
    end

    -- Clean up quest state
    activeQuests[_source] = nil

    print(string.format("^2[INFO] Player %s completed delivery quest and received $%d^0", GetPlayerName(_source), Config.PayMoney))
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function(reason)
    local _source = source

    if activeQuests[_source] then
        activeQuests[_source] = nil
        print(string.format("^3[INFO] Player %s disconnected during quest^0", GetPlayerName(_source)))
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        activeQuests = {}
        questCooldowns = {}
        print("^2[INFO] Delivery script stopped and cleaned up all active quests^0")
    end
end)

-- Admin command to reset player cooldown (optional)
RegisterCommand('resetdeliverycooldown', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if args[1] then
            local targetId = tonumber(args[1])
            if targetId and questCooldowns[targetId] then
                questCooldowns[targetId] = nil
                print(string.format("^2[INFO] Reset delivery cooldown for player %s^0", GetPlayerName(targetId)))
            else
                print("^3[WARNING] Player not found or has no cooldown^0")
            end
        else
            print("^3[USAGE] resetdeliverycooldown <player_id>^0")
        end
    end
end, false)
