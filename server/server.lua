ESX = nil
ESX = exports["es_extended"]:getSharedObject()

SendToDiscord = function(playerName, discordMessage)
    local embeds = {
        {
            ['type'] = 'rich',
            ['title'] = 'DELIVERY LOGS',
            ['description'] = discordMessage,
            ['color'] = 10092339,
            ['footer'] = {
                ['text'] = 'Lurvorx Scripts Logs | ' .. os.date(),
                ['icon_url'] = 'https://cdn.discordapp.com/attachments/1185300625320329296/1185630929847337000/Lurvorx-Scripts-Logga.jpg?ex=6675b4d9&is=66746359&hm=154e4c80ac278286f9b24f7e1b832fe2afcddad8d4801c62e7656d4b1a79da55&'
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({ embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent("lurvorx_delivery:getMoney")
AddEventHandler("lurvorx_delivery:getMoney", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerName = GetPlayerName(_source)

    xPlayer.addMoney(Config.PayMoney)

    local discordid = string.gsub(GetPlayerIdentifier(_source, 1), "discord:", "") or "N/A"
    local fivem = GetPlayerIdentifier(_source, 2) or "N/A"
    local license = GetPlayerIdentifier(_source) or "N/A"
    local license2 = GetPlayerIdentifier(_source, 3) or "N/A"

    SendToDiscord(
        discordMessage, "**" .. playerName .. "** have delivered **3** packages." .. "\n\n`👤` **PLAYER:** `" .. playerName .. "`\n`🔢` **SERVER ID:** `" .. _source .. "`\n`💬` **DISCORD:** " .. "<@" .. discordid .. "> [||" .. discordid .. "||]" .. "\n`🎮` **FIVEM:** ||" .. fivem .. "||\n`💿` **LICENSE:** ||" .. license .. "||\n`📀` **LICENSE 2:** ||" .. license2 .. "||"
    )
end)