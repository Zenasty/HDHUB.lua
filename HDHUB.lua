
-- Verifica se o script já foi executado
if _G.HDHUB then
    return
end
_G.HDHUB = true

-- Carrega biblioteca de UI (compatível com Synapse X, KRNL, etc.)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("HD HUB - Dead Rails", "Synapse")

-- Inicializa variáveis
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game.Workspace
local replicatedStorage = game:GetService("ReplicatedStorage")
local isCollecting = false
local collectSpeed = 0.1 -- Velocidade de coleta (editável)

-- Função para teletransportar
local function teleportTo(position)
    if humanoidRootPart and position then
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Função para coletar Bonds
local function collectBonds()
    while isCollecting do
        local runtimeItems = workspace:WaitForChild("RuntimeItems", 5)
        if not runtimeItems then
            Library:Notify("Erro: RuntimeItems não encontrado!", 3)
            break
        end

        for _, item in pairs(runtimeItems:GetChildren()) do
            if item.Name == "Bond" and isCollecting then
                local bondPart = item:FindFirstChild("Part")
                if bondPart and bondPart:IsA("BasePart") then
                    teleportTo(bondPart.Position + Vector3.new(0, 3, 0)) -- Teleporta acima do Bond
                    wait(collectSpeed)
                    -- Tenta coletar o Bond
                    local activateEvent = replicatedStorage:FindFirstChild("ActivateObjectClient")
                    if activateEvent then
                        activateEvent:FireServer(item)
                        Library:Notify("Bond coletado!", 1)
                    end
                end
            end
        end
        wait(collectSpeed)
    end
end

-- Função para zerar o jogo (loop de coleta até completar)
local function speedrunGame()
    Library:Notify("Iniciando speedrun... Coletando Bonds!", 3)
    isCollecting = true
    collectBonds()
end

-- Seção principal da interface
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("HD HUB - Auto Farm")

-- Toggle para ativar/desativar coleta
Section:NewToggle("Auto Collect Bonds", "Ativa/desativa a coleta automática de Bonds", function(state)
    isCollecting = state
    if state then
        spawn(collectBonds) -- Inicia a coleta em uma nova thread
        Library:Notify("Coleta automática ativada!", 2)
    else
        Library:Notify("Coleta automática desativada!", 2)
    end
end)

-- Botão para speedrun
Section:NewButton("Speedrun Game", "Tenta zerar o jogo coletando todos os Bonds", function()
    speedrunGame()
end)

-- Slider para ajustar a velocidade
Section:NewSlider("Collect Speed", "Ajusta a velocidade de coleta (menor = mais rápido)", 1, 0.1, 0.5, 0.05, function(value)
    collectSpeed = value
    Library:Notify("Velocidade de coleta ajustada para: " .. value, 2)
end)

-- Seção de utilitários
local UtilityTab = Window:NewTab("Utilities")
local UtilitySection = UtilityTab:NewSection("Player Utilities")

-- Botão para teletransporte manual
UtilitySection:NewButton("Teleport to Random Bond", "Teleporta para um Bond aleatório", function()
    local bonds = {}
    for _, item in pairs(workspace.RuntimeItems:GetChildren()) do
        if item.Name == "Bond" then
            table.insert(bonds, item)
        end
    end
    if #bonds > 0 then
        local randomBond = bonds[math.random(1, #bonds)]
        local bondPart = randomBond:FindFirstChild("Part")
        if bondPart then
            teleportTo(bondPart.Position + Vector3.new(0, 3, 0))
            Library:Notify("Teleportado para um Bond!", 2)
        end
    else
        Library:Notify("Nenhum Bond encontrado!", 2)
    end
end)

-- Notificação de inicialização
Library:Notify("HD HUB carregado com sucesso! Use os controles para coletar Bonds.", 5)

-- Mantém o personagem atualizado
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)
