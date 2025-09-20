-- LocalScript (StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- =========================
-- ANTI-CHEAT PROFISSIONAL REFORÇADO
-- =========================
local CE_Mode = false

-- Proteção getgenv/shared
if getgenv then
    local _genv = getgenv()
    if not rawget(_genv, "shared") then rawset(_genv, "shared", {}) end
    if not rawget(_genv, "debug") then rawset(_genv, "debug", {traceback = function(str) return str end}) end
end

-- Executor blacklist
task.spawn(function()
    local blacklisted = {"solara","cryptic","xeno","ember","ronix"}
    local execName
    pcall(function()
        if identifyexecutor then execName = identifyexecutor() end
    end)
    if execName then
        execName = string.lower(tostring(execName))
        for _, name in pairs(blacklisted) do
            if string.find(execName, name) then
                CE_Mode = true
                break
            end
        end
    end
end)

-- Proteção contra hooks em RemoteEvents críticos
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt,false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and tostring(self) == "SafeTeleport" then
            return old(self,...)
        end
        return old(self,...)
    end)
    setreadonly(mt,true)
end)

-- =========================
-- SPAWN SAVE
-- =========================
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

-- =========================
-- TELEPORT SEGURO (CLIENT+SERVER)
-- =========================
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

    task.spawn(function()
        local hrp = char.HumanoidRootPart
        local startPos = hrp.Position
        local endPos = savedSpawnCFrame.Position + Vector3.new(0,3,0)
        local steps = 40

        -- Teleporte gradual e natural, simula movimento humano
        for i = 1, steps do
            if humanoid.Health <= 0 then return end
            local interp = startPos:Lerp(endPos, i/steps)
            hrp.CFrame = CFrame.new(interp + Vector3.new(math.random()*0.03,0,math.random()*0.03))
            RunService.Heartbeat:Wait()
        end

        local remote = ReplicatedStorage:FindFirstChild("SafeTeleport")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(endPos) end)
        else
            pcall(function() char:MoveTo(endPos) end)
        end

        StarterGui:SetCore("SendNotification", {Title="Teleport", Text="Teleport seguro realizado", Duration=2})
    end)
end

-- =========================
-- FUNÇÃO PARA DRAG (PAINEL E BOLINHA)
-- =========================
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UserInputService.InputChanged:Connect(function(mouse)
                if dragging and mouse.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = mouse.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end)
end

-- =========================
-- GUI PRINCIPAL
-- =========================
local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("DarkblocksGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkblocksGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Painel principal
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

    -- =========================
    -- BOLINHA MINIMIZADA
    -- =========================
    local logoBtn = Instance.new("ImageButton", screenGui)
    logoBtn.Size = UDim2.new(0, 50, 0, 50)
    logoBtn.Position = frame.Position
    logoBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    logoBtn.BackgroundTransparency = 0
    logoBtn.Image = "https://cdn.discordapp.com/attachments/1324111511123398708/1416978424412770425/file_00000000bc9c52308ad733d54b761129.png"
    logoBtn.Visible = false
    makeDraggable(logoBtn)

    local corner = Instance.new("UICorner", logoBtn)
    corner.CornerRadius = UDim.new(1,0)

    -- Minimizar/restaurar
    minimize.MouseButton1Click:Connect(function()
        frame.Visible = false
        logoBtn.Position = frame.Position
        logoBtn.Visible = true
    end)

    logoBtn.MouseButton1Click:Connect(function()
        frame.Position = logoBtn.Position
        frame.Visible = true
        logoBtn.Visible = false
    end)
end

createGui()
