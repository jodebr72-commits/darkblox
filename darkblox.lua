--[[
██████╗  █████╗ ██████╗ ██╗  ██╗     ██████╗ ██╗      ██████╗ ██╗  ██╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝    ██╔═══██╗██║     ██╔═══██╗██║ ██╔╝██╔═══██╗██║ ██╔╝
██████╔╝███████║██████╔╝█████╔╝     ██║   ██║██║     ██║   ██║█████╔╝ ██║   ██║█████╔╝ 
██╔═══╝ ██╔══██║██╔═══╝ ██╔═██╗     ██║   ██║██║     ██║   ██║██╔═██╗ ██║   ██║██╔═██╗ 
██║     ██║  ██║██║     ██║  ██╗    ╚██████╔╝███████╗╚██████╔╝██║  ██╗╚██████╔╝██║  ██╗
╚═╝     ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝     ╚═════╝ ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝

                🚀 DARK BLOX — 99 Nights In The Forest 🚀
----------------------------------------------------------------------------
  IMPORTANT:
  You must copy and use the FULL script below. Do NOT press on the link.

  loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/loader.lua", true))()

----------------------------------------------------------------------------
  For support head over to discord.gg/7SMSD3Cf
----------------------------------------------------------------------------
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
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport disabled!') end
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

if game.PlaceId == 79546208627805 then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Dark Blox | 99 Nights In The Forest",
            Text = "Entre no jogo para Dark Blox carregar :D [Você está no lobby]",
            Duration = 10
        })
    end)
    return
end 

task.spawn(function()
    pcall(function()
        local Services = setmetatable({}, {
            __index = function(self, key)
                local suc, service = pcall(game.GetService, game, key)
                if suc and service then
                    self[key] = service
                    return service
                else
                    warn(`[Services] Warning: "{key}" is not a valid Roblox service.`)
                    return nil
                end
            end
        })

        local Players = Services.Players
        local TextChatService = Services.TextChatService
        local ChatService = Services.ChatService
        repeat
            task.wait()
        until game:IsLoaded() and Players.LocalPlayer ~= nil
        local chatVersion = TextChatService and TextChatService.ChatVersion or Enum.ChatVersion.LegacyChatService
        local TagRegister = shared.TagRegister or {}
        if not shared.CheatEngineMode then
            if chatVersion == Enum.ChatVersion.TextChatService then
                TextChatService.OnIncomingMessage = function(data)
                    TagRegister = shared.TagRegister or {}
                    local properties = Instance.new("TextChatMessageProperties", game:GetService("Workspace"))
                    local TextSource = data.TextSource
                    local PrefixText = data.PrefixText or ""
                    if TextSource then
                        local plr = Players:GetPlayerByUserId(TextSource.UserId)
                        if plr then
                            local prefix = ""
                            if TagRegister[plr] then
                                prefix = prefix .. TagRegister[plr]
                            end
                            if plr:GetAttribute("__OwnsVIPGamepass") and plr:GetAttribute("VIPChatTag") ~= false then
                                prefix = prefix .. "<font color='rgb(255,210,75)'>[VIP]</font> "
                            end
                            local currentLevel = plr:GetAttribute("_CurrentLevel")
                            if currentLevel then
                                prefix = prefix .. string.format("<font color='rgb(173,216,230)'>[</font><font color='rgb(255,255,255)'>%s</font><font color='rgb(173,216,230)'>]</font> ", tostring(currentLevel))
                            end
                            local playerTagValue = plr:FindFirstChild("PlayerTagValue")
                            if playerTagValue and playerTagValue.Value then
                                prefix = prefix .. string.format("<font color='rgb(173,216,230)'>[</font><font color='rgb(255,255,255)'>#%s</font><font color='rgb(173,216,230)'>]</font> ", tostring(playerTagValue.Value))
                            end
                            prefix = prefix .. PrefixText
                            properties.PrefixText = string.format("<font color='rgb(255,255,255)'>%s</font>", prefix)
                        end
                    end
                    return properties
                end
            elseif chatVersion == Enum.ChatVersion.LegacyChatService then
                ChatService:RegisterProcessCommandsFunction("CustomPrefix", function(speakerName, message)
                    TagRegister = shared.TagRegister or {}
                    local plr = Players:FindFirstChild(speakerName)
                    if plr then
                        local prefix = ""
                        if TagRegister[plr] then
                            prefix = prefix .. TagRegister[plr]
                        end
                        if plr:GetAttribute("__OwnsVIPGamepass") and plr:GetAttribute("VIPChatTag") ~= false then
                            prefix = prefix .. "[VIP] "
                        end
                        local currentLevel = plr:GetAttribute("_CurrentLevel")
                        if currentLevel then
                            prefix = prefix .. string.format("[%s] ", tostring(currentLevel))
                        end
                        local playerTagValue = plr:FindFirstChild("PlayerTagValue")
                        if playerTagValue and playerTagValue.Value then
                            prefix = prefix .. string.format("[#%s] ", tostring(playerTagValue.Value))
                        end
                        prefix = prefix .. speakerName
                        return prefix .. " " .. message
                    end
                    return message
                end)
            end
        end
    end)
end)

local commit = shared.CustomCommit and tostring(shared.CustomCommit) or shared.StagingMode and "staging" or "3b3b6b58e840cad9ae32a59b77c15d89218c6147"

loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/"..tostring(commit).."/newnightsintheforest.lua", true))()


--[[
  Branding override: replace displayed "Voidware" texts, discord links and logos with "Dark Blocks" equivalents.
  This block runs after the remote UI is loaded and attempts to find/replace relevant TextLabels/TextButtons/TextBoxes
  and ImageLabels/ImageButtons inside CoreGui and the LocalPlayer's PlayerGui. It only replaces visible strings/images,
  and runs a few times to catch GUIs that may spawn after initial load.
]]

task.spawn(function()
    local Players = game:GetService("Players")
    if not Players.LocalPlayer then
        Players.PlayerAdded:Wait()
    end

    local newName = "Dark Blocks"
    local newDiscord = "https://discord.gg/HhM4GnrCz9"
    local newImage = "https://cdn.discordapp.com/attachments/1324111511123398708/1416978424412770425/file_00000000bc9c52308ad733d54b761129.png?ex=68cc1b3e&is=68cac9be&hm=0dcdd892fca344ab3201c4ed03491f572736ae0bf86aecb620496c555ae16107"

    local function replaceInObject(obj)
        pcall(function()
            if not obj.Parent then return end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local txt = obj.Text
                if type(txt) == "string" then
                    -- Tradução do painel dos players
                    txt = string.gsub(txt, "Information", "Informações")
                    txt = string.gsub(txt, "Automation", "Automação")
                    txt = string.gsub(txt, "Bring Stuff", "Trazer Itens")
                    txt = string.gsub(txt, "Main", "Principal")
                    txt = string.gsub(txt, "Fishing", "Pesca")
                    txt = string.gsub(txt, "FasterBring %[BETA%]", "Trazer Rápido [BETA]")
                    txt = string.gsub(txt, "Bring Location", "Trazer Localização")
                    txt = string.gsub(txt, "Max Per item", "Máx Por Item")
                    txt = string.gsub(txt, "Bring cooldowm", "Tempo de Recarga")
                    txt = string.gsub(txt, "No Bring Amount Limit", "Sem Limite de Quantidade")
                    txt = string.gsub(txt, "Bring Height", "Altura de Trazer")
                    txt = string.gsub(txt, "Bring Fuel %[BETA%]", "Trazer Combustível [BETA]")
                    txt = string.gsub(txt, "Fuel", "Combustível")
                    txt = string.gsub(txt, "Bring Logs %[Beta%]", "Trazer Troncos [BETA]")
                    txt = string.gsub(txt, "Bring Food & Healing", "Trazer Comida & Cura")
                    txt = string.gsub(txt, "Food & Healing", "Comida & Cura")
                    txt = string.gsub(txt, "Bring Gears", "Trazer Equipamentos")
                    txt = string.gsub(txt, "Gears", "Equipamentos")
                    txt = string.gsub(txt, "Bring Guns &  Armor", "Trazer Armas & Armaduras")
                    txt = string.gsub(txt, "Other", "Outros")

                    if string.find(txt, "Voidware") or string.find(txt, "voidware") or string.find(txt, "discord.gg") then
                        txt = string.gsub(txt, "Voidware Official", newName)
                        txt = string.gsub(txt, "Voidware", newName)
                        txt = string.gsub(txt, "voidware", newName)
                        txt = string.gsub(txt, "discord.gg/voidware", newDiscord)
                        txt = string.gsub(txt, "discord.gg/7SMSD3Cf", newDiscord)
                    end
                    obj.Text = txt
                end
            elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                local img = obj.Image
                if type(img) == "string" and (string.find(string.lower(img), "void") or string.find(string.lower(img), "vw") or string.find(string.lower(img), "vape") ) then
                    obj.Image = newImage
                end
            end
        end)
    end

    local function scanAndReplace(root)
        for _,v in pairs(root:GetDescendants()) do
            replaceInObject(v)
        end
    end

    -- Try a few times to catch GUIs that spawn with delay
    for i=1,30 do
        pcall(function()
            scanAndReplace(game:GetService("CoreGui"))
            if Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") then
                scanAndReplace(Players.LocalPlayer.PlayerGui)
            end
        end)
        task.wait(1)
    end
end)
