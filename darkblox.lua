-- LocalScript (coloque em StarterPlayerScripts)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Variável que guardará o CFrame do spawn inicial do jogador
local savedSpawnCFrame = nil

-- Função que registra o spawn quando o personagem é criado (aparece no jogo)
local function onCharacterAdded(character)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        -- Guardamos o CFrame atual como "spawn" (posição onde o jogador nasceu/respawnou)
        savedSpawnCFrame = hrp.CFrame
        -- Opcional: descomente a linha abaixo para ver no Output que foi salvo
        -- warn("Spawn salvo em: ", tostring(savedSpawnCFrame))
    end
end

-- Se o character já existir no momento do script, registramos também
if LocalPlayer.Character then
    -- Use spawn() para evitar bloqueio caso Character ainda esteja inicializando
    task.spawn(function()
        onCharacterAdded(LocalPlayer.Character)
    end)
end

-- Conectamos para atualizações futuras (quando morrer e respawnar, por exemplo)
LocalPlayer.CharacterAdded:Connect(function(character)
    onCharacterAdded(character)
end)

-- Função de criação do GUI simples
local function createTeleportGui()
    -- Verifica PlayerGui e evita criar várias GUIs
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("TeleportGui_v1") then
        return
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGui_v1"
    screenGui.ResetOnSpawn = false -- mantém GUI entre respawns se preferir
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
    teleportBtn.AnchorPoint = Vector2.new(0, 0)
    teleportBtn.Text = "TELEPORTAR"
    teleportBtn.Font = Enum.Font.SourceSansBold
    teleportBtn.TextSize = 20
    teleportBtn.BackgroundTransparency = 0
    teleportBtn.BorderSizePixel = 0
    teleportBtn.Parent = frame

    -- Teleport handler
    teleportBtn.MouseButton1Click:Connect(function()
        if not savedSpawnCFrame then
            -- tenta procurar SpawnLocation como fallback
            local spawnPart = workspace:FindFirstChildWhichIsA("SpawnLocation")
            if spawnPart then
                savedSpawnCFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
            end
        end

        if savedSpawnCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            -- Segurança: usar Tween para evitar problemas de colisão / física brusca
            local ok, err = pcall(function()
                hrp.CFrame = savedSpawnCFrame + Vector3.new(0, 3, 0)
            end)
            if not ok then
                warn("Falha ao teleportar: "..tostring(err))
            end
        else
            -- Mensagem rápida ao jogador (usando StarterGui) — opcional
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Teleport",
                    Text = "Spawn não registrado ainda.",
                    Duration = 3
                })
            end)
        end
    end)
end

-- Cria o GUI
createTeleportGui()
