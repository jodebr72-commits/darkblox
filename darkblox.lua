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

-- GUI (Darkblocks atualizado)
local function createGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("DarkblocksGui") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkblocksGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Painel principal
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 160)
    frame.Position = UDim2.new(0.5, -140, 0.7, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Título
    local titleBar = Instance.new("TextLabel", frame)
    titleBar.Size = UDim2.new(1, -30, 0, 28)
    titleBar.Position = UDim2.new(0, 5, 0, 5)
    titleBar.BackgroundTransparency = 1
    titleBar.Text = "Darkblocks"
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextSize = 20
    titleBar.TextColor3 = Color3.fromRGB(255,255,255)
    titleBar.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão minimizar
    local minimizeBtn = Instance.new("TextButton", frame)
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.Position = UDim2.new(1, -28, 0, 5)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.TextSize = 20
    minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    minimizeBtn.BorderSizePixel = 0

    -- Switch de Teleportar
    local container = Instance.new("Frame", frame)
    container.Size = UDim2.new(0.9,0,0,30)
    container.Position = UDim2.new(0.05,0,0,50)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.7,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = "Teleportar"
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local switch = Instance.new("TextButton", container)
    switch.Size = UDim2.new(0.25,0,0.8,0)
    switch.Position = UDim2.new(0.75,0,0.1,0)
    switch.Text = "OFF"
    switch.Font = Enum.Font.SourceSansBold
    switch.TextSize = 14
    switch.BackgroundColor3 = Color3.fromRGB(120,0,0)
    switch.TextColor3 = Color3.fromRGB(255,255,255)
    switch.BorderSizePixel = 0

    local state = false
    switch.MouseButton1Click:Connect(function()
        if not state then
            state = true
            switch.Text = "ON"
            switch.BackgroundColor3 = Color3.fromRGB(0,170,0)

            -- Chama teleporte
            teleport()

            -- volta pro OFF depois
            task.delay(1, function()
                state = false
                switch.Text = "OFF"
                switch.BackgroundColor3 = Color3.fromRGB(120,0,0)
            end)
        end
    end)

    -- Botão Discord
    local discordBtn = Instance.new("TextButton", frame)
    discordBtn.Size = UDim2.new(0.9,0,0,30)
    discordBtn.Position = UDim2.new(0.05,0,0,100)
    discordBtn.Text = "Atualizações no Discord"
    discordBtn.Font = Enum.Font.SourceSansBold
    discordBtn.TextSize = 16
    discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
    discordBtn.BackgroundColor3 = Color3.fromRGB(50,120,200)
    discordBtn.BorderSizePixel = 0
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/7SMSD3Cf")
        StarterGui:SetCore("SendNotification", {Title="Darkblocks", Text="Link do Discord copiado!", Duration=2})
    end)

    -- Logo minimizada
    local logoButton = Instance.new("ImageButton")
    logoButton.Name = "MiniLogo"
    logoButton.Size = UDim2.new(0,50,0,50)
    logoButton.Position = UDim2.new(0.5, -25, 0.8, 0)
    logoButton.AnchorPoint = Vector2.new(0.5,0)
    logoButton.BackgroundTransparency = 1
    logoButton.Image = "https://cdn.discordapp.com/attachments/1324111511123398708/1416978424412770425/file_00000000bc9c52308ad733d54b761129.png"
    logoButton.Visible = false
    logoButton.Active = true
    logoButton.Draggable = true
    logoButton.Parent = screenGui

    -- Minimizar / restaurar
    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        logoButton.Visible = true
    end)
    logoButton.MouseButton1Click:Connect(function()
        frame.Visible = true
        logoButton.Visible = false
    end)
end

createGui()
