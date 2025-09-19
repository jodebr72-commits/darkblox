-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ANTI-CHEAT
local CE_Mode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CE_Mode = true end
if getgenv and not getgenv().shared then CE_Mode = true; getgenv().shared = {} end
if getgenv and not getgenv().debug then CE_Mode = true; getgenv().debug = {traceback = function(str) return str end} end

local function CheckExec()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc,res = pcall(function() return identifyexecutor() end)
        if suc and res then
            local black = {'solara','cryptic','xeno','ember','ronix'}
            for i,v in pairs(black) do
                if string.find(string.lower(tostring(res)), v) then
                    CE_Mode = true
                end
            end
        end
    end
end
task.spawn(function() pcall(CheckExec) end)

-- SPAWN SAVE
local savedSpawnCFrame = nil
local spawnSaved = false

local function recordOnce(character)
    task.wait(0.2)
    local hrp = character:WaitForChild("HumanoidRootPart",5)
    if hrp and not spawnSaved then
        savedSpawnCFrame = hrp.CFrame
        spawnSaved = true
        warn("Spawn inicial salvo:", savedSpawnCFrame)
        pcall(function()
            StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Spawn inicial salvo", Duration=2})
        end)
    end
end

if LocalPlayer.Character then
    task.spawn(function() recordOnce(LocalPlayer.Character) end)
end
LocalPlayer.CharacterAdded:Connect(recordOnce)

-- TELEPORT SEGURO (CLIENT+SERVER)
local function teleport()
    if CE_Mode then
        StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Não é seguro executar.", Duration=3})
        return
    end

    if not savedSpawnCFrame then
        local sp = workspace:FindFirstChildWhichIsA("SpawnLocation")
        if sp then savedSpawnCFrame = sp.CFrame + Vector3.new(0,5,0)
        else
            StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Spawn não definido.", Duration=2})
            return
        end
    end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- TELEPORTE GRADUAL + SERVER
    task.spawn(function()
        local hrp = char.HumanoidRootPart
        local startPos = hrp.Position
        local endPos = savedSpawnCFrame.Position + Vector3.new(0,3,0)
        local steps = 25

        for i = 1, steps do
            if humanoid.Health <= 0 then return end
            local interp = startPos:Lerp(endPos, i/steps)
            hrp.CFrame = CFrame.new(interp)
            RunService.Heartbeat:Wait()
        end

        -- Envia para o servidor para validar o teleporte
        local remote = ReplicatedStorage:FindFirstChild("SafeTeleport")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(endPos) end)
        else
            -- Fallback seguro MoveTo
            pcall(function() char:MoveTo(endPos) end)
        end

        StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Teleport seguro realizado", Duration=2})
    end)
end

-- GUI
local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("TeleportGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 240, 0, 80)
    frame.Position = UDim2.new(0.5, -120, 0.82, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundTransparency = 0.15
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,28)
    title.Position = UDim2.new(0,0,0,4)
    title.BackgroundTransparency = 1
    title.Text = "Teleport"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255,255,255)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9,0,0,40)
    btn.Position = UDim2.new(0.05,0,0.45,0)
    btn.Text = "TELEPORTAR"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.BackgroundColor3 = Color3.fromRGB(50,120,200)
    btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(teleport)
end

createGui()
