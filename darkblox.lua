-- LocalScript (coloque em StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variável que guardará o CFrame do spawn inicial do jogador
local savedSpawnCFrame = nil
local spawnSaved = false -- garante que só salva uma vez

-- Função que registra o spawn apenas uma vez
local function onCharacterAdded(character)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if hrp and not spawnSaved then
        savedSpawnCFrame = hrp.CFrame
        spawnSaved = true
        warn("Spawn inicial salvo em:", tostring(savedSpawnCFrame))
    end
end

-- Se o character já existir no momento do script, registramos também
if LocalPlayer.Character then
    task.spawn(function()
        onCharacterAdded(LocalPlayer.Character)
    end)
end

-- Conectamos para o caso de ser a primeira vez do spawn
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Função de criação do GUI simples
local function createTeleportGui()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("TeleportGui_v1") then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGui_v1"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 80)
    frame.Position = UDim2.new(0.5, -120, 0.82, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundTransparency = 0.15
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "Teleport"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Size = UDim2.new(0.9, 0, 0, 40)
    teleportBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
    teleportBtn.Text = "TELEPORTAR"
    teleportBtn.Font = Enum.Font.SourceSansBold
    teleportBtn.TextSize = 20
    teleportBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    teleportBtn.BorderSizePixel = 0
    teleportBtn.Parent = frame

    teleportBtn.MouseButton1Click:Connect(function()
        if savedSpawnCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            hrp.CFrame = savedSpawnCFrame + Vector3.new(0, 3, 0)
        else
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Teleport",
                    Text = "Spawn ainda não registrado.",
                    Duration = 3
                })
            end)
        end
    end)
end

-- Cria o GUI
createTeleportGui()
