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
local function makeDraggable(frame)
    local UserInputService = game:GetService("UserInputService")
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("DarkblocksGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkblocksGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 260, 0, 150)
    frame.Position = UDim2.new(0.5, -130, 0.7, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0

    makeDraggable(frame)

    -- Título
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -30, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Dark Blocks"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão minimizar
    local minimize = Instance.new("TextButton", frame)
    minimize.Size = UDim2.new(0, 30, 0, 30)
    minimize.Position = UDim2.new(1, -30, 0, 0)
    minimize.BackgroundTransparency = 1
    minimize.Text = "−"
    minimize.Font = Enum.Font.SourceSansBold
    minimize.TextSize = 24
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)

    -- Switch Teleportar
    local switchFrame = Instance.new("Frame", frame)
    switchFrame.Size = UDim2.new(0.9, 0, 0, 40)
    switchFrame.Position = UDim2.new(0.05, 0, 0, 40)
    switchFrame.BackgroundTransparency = 1

    local switchLabel = Instance.new("TextLabel", switchFrame)
    switchLabel.Size = UDim2.new(0.7, 0, 1, 0)
    switchLabel.Position = UDim2.new(0, 0, 0, 0)
    switchLabel.BackgroundTransparency = 1
    switchLabel.Text = "Teleportar"
    switchLabel.Font = Enum.Font.SourceSansBold
    switchLabel.TextSize = 18
    switchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    switchLabel.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", switchFrame)
    switch.Size = UDim2.new(0.3, 0, 0.8, 0)
    switch.Position = UDim2.new(0.7, 0, 0.1, 0)
    switch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    switch.Text = "OFF"
    switch.Font = Enum.Font.SourceSansBold
    switch.TextSize = 16
    switch.TextColor3 = Color3.fromRGB(255, 255, 255)

    switch.MouseButton1Click:Connect(function()
        switch.Text = "ON"
        switch.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        teleport()
        task.wait(0.5)
        switch.Text = "OFF"
        switch.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)

    -- Botão Discord
    local discordBtn = Instance.new("TextButton", frame)
    discordBtn.Size = UDim2.new(0.9, 0, 0, 40)
    discordBtn.Position = UDim2.new(0.05, 0, 0, 90)
    discordBtn.Text = "Atualizações no Discord"
    discordBtn.Font = Enum.Font.SourceSansBold
    discordBtn.TextSize = 18
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
    discordBtn.BorderSizePixel = 0

    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/7SMSD3Cf")
        StarterGui:SetCore("SendNotification", {Title="Dark Blocks", Text="Link do Discord copiado!", Duration=2})
    end)

    -- Logo quando minimizado
    local logoBtn = Instance.new("ImageButton", screenGui)
    logoBtn.Size = UDim2.new(0, 60, 0, 60)
    logoBtn.Position = UDim2.new(0.5, -30, 0.8, 0)
    logoBtn.BackgroundTransparency = 1
    logoBtn.Image = "https://cdn.discordapp.com/attachments/1324111511123398708/1416978424412770425/file_00000000bc9c52308ad733d54b761129.png?ex=68cebe3e&is=68cd6cbe&hm=086ee4d4aeb4b8681b1a3493b9a9148938016e4c9dd731a4c2ff5ef3e2c69a8e&"
    logoBtn.Visible = false

    local corner = Instance.new("UICorner", logoBtn)
    corner.CornerRadius = UDim.new(1, 0)

    makeDraggable(logoBtn)

    minimize.MouseButton1Click:Connect(function()
        frame.Visible = false
        logoBtn.Visible = true
    end)

    logoBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        logoBtn.Visible = false
    end)
end

createGui()
