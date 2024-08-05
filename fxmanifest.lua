----------------------------------------------------
--                                                --
--                 Lurvorx Scripts                --
--      Basic FiveM scripts made with quality     --
--           https://github.com/Lurvorx           --
--          https://discord.gg/jJnE7yTYZW         --
--                                                --
----------------------------------------------------

fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Lurvorx Scripts"
description "A simple and basic delivery script made by Lurvorx Scripts"

client_script {
    "client/client.lua"
}

server_script {
    "server/server.lua"
}

shared_script {
    "config.lua"
}