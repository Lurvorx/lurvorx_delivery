if Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

if Config.Webhook.useWebhook then
    SendToDiscord = function(playerName, discordMessage)
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

RegisterNetEvent("lurvorx_delivery:getMoney")
AddEventHandler("lurvorx_delivery:getMoney", function()
    local _source = source
    if Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(_source)
    elseif Config.Framework == "qb" then
        Player = QBCore.Functions.GetPlayer(_source)
    end
    local playerName = GetPlayerName(_source)

    if Config.Framework == "esx" then
        xPlayer.addMoney(Config.PayMoney)
    elseif Config.Framework == "qb" then
        Player.Functions.AddMoney('cash', Config.PayMoney)
    end

    for k,v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("license2:")) == "license2:" then
            license2 = v
        elseif string.sub(v, 1, string.len("fivem:")) == "fivem:" then
            fivem = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end

    steamhex = steamid or "N/A"
    fivemlicense = license or "N/A"
    fivemlicense2 = license2 or "N/A"
    fivemid = fivem or "N/A"
    discordid = string.gsub(discord, "discord:", "") or "N/A"

    SendToDiscord(
        discordMessage, "**" .. playerName .. "** have delivered **3** packages." .. "\n\n`👤` **PLAYER:** `" .. playerName .. "`\n`🔢` **SERVER ID:** `" .. source .. "`\n`💬` **DISCORD:** " .. "<@" .. discordid .. "> [||" .. discordid .. "||]" .. "\n`🎮` **STEAM HEX:** ||" .. steamhex .. "||\n`🎮` **FIVEM:** ||" .. fivemid .. "||\n`💿` **LICENSE:** ||" .. fivemlicense .. "||\n`📀` **LICENSE 2:** ||" .. fivemlicense2 .. "||"
    )
end)
