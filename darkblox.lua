--[[
██████╗  █████╗ ██████╗ ██╗  ██╗     ██████╗ ██╗      ██████╗ ██╗  ██╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ██╔═══██╗██║     ██╔═══██╗██║ ██╔╝██╔═══██╗██║ ██╔╝
██████╔╝███████║██████╔╝█████╔╝     ██║   ██║██║     ██║   ██║█████╔╝ ██║   ██║█████╔╝ 
██╔═══╝ ██╔══██║██╔═══╝ ██╔═██╗     ██║   ██║██║     ██║   ██║██╔═██╗ ██║   ██║██╔═██╗ 
██║     ██║  ██║██║     ██║  ██╗    ╚██████╔╝███████╗╚██████╔╝██║  ██╗╚██████╔╝██║  ██╗
╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝     ╚═════╝ ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝

                🚀 DARK BLOX — 99 Noites na Floresta 🚀
----------------------------------------------------------------------------
  IMPORTANTE:
  Você deve copiar e usar o script COMPLETO abaixo. NÃO clique no link.

  loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/loader.lua", true))()

----------------------------------------------------------------------------
  Para suporte entre em: https://discord.gg/HhM4GnrCz9
----------------------------------------------------------------------------
  🌐 Idioma: 🇧🇷 BR
]]
if not game:IsLoaded() then return end
local CheatEngineMode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().shared then CheatEngineMode = true; getgenv().shared = {}; end
if getgenv and not getgenv().debug then CheatEngineMode = true; getgenv().debug = {traceback = function(string) return string end} end
if getgenv and not getgenv().require then CheatEngineMode = true; end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end
local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}
local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function()
            return identifyexecutor()
        end)   
        local blacklist = {'solara', 'cryptic', 'xeno', 'ember', 'ronix'}
        local core_blacklist = {'solara', 'xeno'}
        if suc then
            for i,v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then CheatEngineMode = true end
            end
            for i,v in pairs(core_blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    pcall(function()
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport desativado!') end
                    end)
                end
            end
            if string.find(string.lower(tostring(res)), "delta") then
                getgenv().isnetworkowner = function()
                    return true
                end
            end
        end
    end
end
task.spawn(function() pcall(checkExecutor) end)
local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then 
        CheatEngineMode = true 
    else 
        if type(debug) ~= debugChecks.Type then 
            CheatEngineMode = true
        else 
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then 
                    CheatEngineMode = true 
                else 
                    local suc, res = pcall(debug[v]) 
                    if tostring(res) == "Not Implemented" then 
                        CheatEngineMode = true 
                    end
                end
            end
        end
    end
end
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode
shared.ForcePlayerGui = true

-- 🔔 Notificação traduzida
if game.PlaceId == 79546208627805 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Dark Blox | 99 Noites na Floresta",
            Text = "Entre no jogo para o Dark Blox carregar :D [Você está no lobby atualmente]",
            Duration = 10
        })
    end)
    return
end 
