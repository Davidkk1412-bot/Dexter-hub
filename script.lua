local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

repeat task.wait() until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then warn("❌ WindUI não carregou.") return end

local Window = WindUI:CreateWindow({
    Title = "💀 Dexter Hub",
    Icon = "https://i.imgur.com/B1x2kaP.png",
    IconThemed = true,
    Author = "DEXTER",
    Folder = "DexterHubFolder",
    Size = UDim2.fromOffset(520,440),
    Transparent = true,
    Theme = "Dark",
})

task.spawn(function()
    local hue = 0
    while task.wait(0.03) do
        hue = (hue + 0.007) % 1
        local cor = Color3.fromHSV(hue,1,1)
        pcall(function()
            if Window.SetTitleColor then Window:SetTitleColor(cor) end
            if Window.SetIconColor then Window:SetIconColor(cor) end
        end)
    end
end)

local TabMovimento = Window:Tab({Title = "🏃 Movimento"})
local TabJogadores = Window:Tab({Title = "👥 Jogadores"})
local TabTrollagens = Window:Tab({Title = "😈 Trollagens"})
local TabVisual = Window:Tab({Title = "👁 Visual"})
local TabFerramentas = Window:Tab({Title = "📡 Ferramentas"})
local TabAdmin = Window:Tab({Title = "🔧 Admin"})

-- MOVIMENTO
local speedAtual, maxSpeed, minSpeed = 50, 250, 16
local superSpeedAtivo, noclip = false, false

local function atualizarWalkSpeed()
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = superSpeedAtivo and speedAtual or 16 end
end

TabMovimento:Toggle({
    Title = "⚡ Super Velocidade",
    Default = false,
    Callback = function(v)
        superSpeedAtivo = v
        atualizarWalkSpeed()
    end,
})

TabMovimento:Button({
    Title = "➕ Aumentar Velocidade",
    Callback = function()
        speedAtual = math.min(speedAtual + 10, maxSpeed)
        if superSpeedAtivo then atualizarWalkSpeed() end
    end,
})

TabMovimento:Button({
    Title = "➖ Diminuir Velocidade",
    Callback = function()
        speedAtual = math.max(speedAtual - 10, minSpeed)
        if superSpeedAtivo then atualizarWalkSpeed() end
    end,
})

RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

TabMovimento:Toggle({
    Title = "🚪 Noclip",
    Default = false,
    Callback = function(v) noclip = v end,
})

TabMovimento:Button({
    Title = "🔄 Resetar Posição",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,10,0) end
    end,
})

TabMovimento:Button({
    Title = "🛸 Fly All (Universal)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Gui-Fly-v3-37111"))()
    end,
})

-- JOGADORES
local playersList = {}

local function atualizarListaPlayers()
    playersList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playersList, p.Name)
        end
    end
end
atualizarListaPlayers()

TabJogadores:Button({
    Title = "🔄 Atualizar Lista de Jogadores",
    Callback = function()
        atualizarListaPlayers()
    end,
})

-- TELEPORTAR COM DROPDOWN
local jogadorSelecionado = nil

TabJogadores:Dropdown({
    Title = "👥 Jogadores",
    Values = playersList,
    Multi = false,
    Default = nil,
    Callback = function(value)
        jogadorSelecionado = value
    end,
})

TabJogadores:Button({
    Title = "🚀 Teleportar até Jogador",
    Callback = function()
        if jogadorSelecionado then
            local target = Players:FindFirstChild(jogadorSelecionado)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end,
})

-- VISUAL - ESP COMPLETO
local ESPAtivo = false
local ESPObjetos = {}

local function criarText()
    local txt = Drawing.new("Text")
    txt.Size = 13
    txt.Center = true
    txt.Outline = true
    txt.Font = 2
    txt.Visible = false
    return txt
end

local function criarLinha()
    local linha = Drawing.new("Line")
    linha.Thickness = 2
    linha.Visible = false
    return linha
end

local function criarESPCompleto()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            ESPObjetos[p.Name] = {
                Nome = criarText(),
                Linha = criarLinha(),
            }
        end
    end
end

local function removerESP()
    for _, v in pairs(ESPObjetos) do
        if v.Nome then v.Nome:Remove() end
        if v.Linha then v.Linha:Remove() end
    end
    ESPObjetos = {}
end

local function atualizarESPVisual()
    if not ESPAtivo then return end
    local cam = Workspace.CurrentCamera
    for _, p in pairs(Players:GetPlayers()) do
        local esp = ESPObjetos[p.Name]
        if p ~= LocalPlayer and esp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if vis then
                local cor = Color3.fromHSV((tick() % 5) / 5, 1, 1)

                -- Nome RGB
                esp.Nome.Text = string.format("[%s] %s", p.Team and p.Team.Name or "No Team", p.Name)
                esp.Nome.Position = Vector2.new(pos.X, pos.Y - 25)
                esp.Nome.Color = cor
                esp.Nome.Visible = true

                -- Linha RGB
                esp.Linha.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                esp.Linha.To = Vector2.new(pos.X, pos.Y)
                esp.Linha.Color = cor
                esp.Linha.Visible = true
            else
                esp.Nome.Visible = false
                esp.Linha.Visible = false
            end
        elseif esp then
            esp.Nome.Visible = false
            esp.Linha.Visible = false
        end
    end
end

TabVisual:Toggle({
    Title = "👁 ESP COMPLETO",
    Default = false,
    Callback = function(v)
        ESPAtivo = v
        if v then
            criarESPCompleto()
        else
            removerESP()
        end
    end,
})

RunService.RenderStepped:Connect(function()
    if ESPAtivo then
        atualizarESPVisual()
    end
end)

-- AIMLOCK + AIMBOT
local aimFOV, teamCheck = 80, true
local aimlockAtivo, aimbotAtivo, mouseDown = false, false, false

local function getClosestTarget()
    local cam = Workspace.CurrentCamera
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if teamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
            local pos, onScreen = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if d < aimFOV and d < dist then
                    dist = d
                    closest = plr
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimlockAtivo or (aimbotAtivo and mouseDown) then
        local t = getClosestTarget()
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local cam = Workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position, t.Character.HumanoidRootPart.Position)
        end
    end
end)

if UIS.TouchEnabled then
    UIS.TouchStarted:Connect(function()
        if #UIS:GetTouches() >= 2 then mouseDown = true end
    end)
    UIS.TouchEnded:Connect(function()
        if #UIS:GetTouches() < 2 then mouseDown = false end
    end)
else
    UIS.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then mouseDown = true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton2 then mouseDown = false end
    end)
end

TabFerramentas:Toggle({
    Title = "🎯 Aimlock",
    Default = false,
    Callback = function(v) aimlockAtivo = v end,
})
TabFerramentas:Toggle({
    Title = "🎯 Aimbot (segurar)",
    Default = false,
    Callback = function(v) aimbotAtivo = v end,
})
TabFerramentas:Slider({
    Title = "Aim FOV",
    Min = 10,
    Max = 150,
    Default = aimFOV,
    Callback = function(v) aimFOV = v end,
})
TabFerramentas:Toggle({
    Title = "Team Check",
    Default = true,
    Callback = function(v) teamCheck = v end,
})

-- RADAR
local radarGui = Instance.new("ScreenGui", game.CoreGui)
radarGui.Name = "RadarDexter"
radarGui.ResetOnSpawn = false
local radarFrame = Instance.new("Frame", radarGui)
radarFrame.Size = UDim2.new(0, 140, 0, 140)
radarFrame.Position = UDim2.new(1, -160, 1, -160)
radarFrame.BackgroundColor3 = Color3.new(0,0,0)
radarFrame.BackgroundTransparency = 0.4
radarFrame.Visible = false

local radarAtivo, setas = false, {}

local function criarSeta()
    local arrow = Instance.new("Frame")
    arrow.Size = UDim2.new(0, 6, 0, 20)
    arrow.BackgroundColor3 = Color3.fromRGB(255,0,0)
    arrow.BorderSizePixel = 0
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Position = UDim2.new(0.5, 0, 0.5, 0)
    arrow.Rotation = 0
    arrow.Parent = radarFrame
    return arrow
end

RunService.RenderStepped:Connect(function()
    if not radarAtivo then return end
    for _, s in pairs(setas) do s:Destroy() end
    setas = {}
    local lpHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lpHRP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local offset = (p.Character.HumanoidRootPart.Position - lpHRP.Position)
            local angle = math.atan2(offset.X, offset.Z)
            local deg = -math.deg(angle)
            local seta = criarSeta()
            seta.Rotation = deg
            table.insert(setas, seta)
        end
    end
end)

TabFerramentas:Toggle({
    Title = "📡 Radar",
    Default = false,
    Callback = function(v)
        radarAtivo = v
        radarFrame.Visible = v
    end,
})

-- SHIFT LOCK CORRIGIDO
local shiftLockAtivo = false

local function ativarShiftLock()
    RunService:BindToRenderStep("DexterShiftLock", Enum.RenderPriority.Camera.Value + 1, function()
        local cam = Workspace.CurrentCamera
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            cam.CFrame = CFrame.new(cam.CFrame.Position, hrp.Position + hrp.CFrame.LookVector)
        end
    end)
end

local function desativarShiftLock()
    RunService:UnbindFromRenderStep("DexterShiftLock")
end

TabFerramentas:Toggle({
    Title = "🔒 Shift Lock",
    Default = false,
    Callback = function(v)
        shiftLockAtivo = v
        if v then ativarShiftLock() else desativarShiftLock() end
    end,
})

-- TROLLAGENS
TabTrollagens:Button({
    Title = "🎀 Plug Rosa",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetChildren()) do
                if p:IsA("BasePart") then
                    p.BrickColor = BrickColor.new("Hot pink")
                    p.Material = Enum.Material.Neon
                end
            end
            game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                Text = "DEIXA DE SER VIADO KKKKKKK",
                Color = Color3.fromRGB(255, 20, 147),
                Font = Enum.Font.SourceSansBold,
                FontSize = Enum.FontSize.Size24,
            })
        end
    end,
})

TabTrollagens:Button({
    Title = "💬 Fake Chat",
    Callback = function()
        local r = game:GetService("ReplicatedStorage")
        local chat = r:FindFirstChild("DefaultChatSystemChatEvents")
        if chat then
            local send = chat:FindFirstChild("SayMessageRequest")
            if send then send:FireServer("Dexter Hub ativado! 😎", "All") end
        end
    end,
})

-- ABA ADMIN
local comandoTexto = ""

local comandosDisponiveis = [[
Comandos disponíveis:
:kill PlayerName - Mata o jogador
:kick PlayerName - Expulsa o jogador
:freeze PlayerName - Congela o jogador
:unfreeze PlayerName - Descongela o jogador
:cmds - Mostra esta lista de comandos
]]

TabAdmin:Textbox({
    Title = "Digite o comando",
    Placeholder = "Ex: :kill PlayerName",
    Text = "",
    Callback = function(text)
        comandoTexto = text
    end,
})

TabAdmin:Button({
    Title = "Enviar Comando",
    Callback = function()
        if comandoTexto == "" then
            warn("Digite um comando para enviar.")
            return
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if not chatRemote then
            warn("DefaultChatSystemChatEvents não encontrado.")
            return
        end

        local SayMessageRequest = chatRemote:FindFirstChild("SayMessageRequest")
        if not SayMessageRequest then
            warn("SayMessageRequest não encontrado.")
            return
        end

        if comandoTexto == ":cmds" then
            print(comandosDisponiveis)
            for line in comandosDisponiveis:gmatch("[^\r\n]+") do
                SayMessageRequest:FireServer(line, "All")
                task.wait(0.3)
            end
        else
            SayMessageRequest:FireServer(comandoTexto, "All")
            print("Comando enviado: "..comandoTexto)
        end
    end,
})

-- RESTAURA APÓS MORTE
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    if superSpeedAtivo then atualizarWalkSpeed() end
    if ESPAtivo then
        for _, b in pairs(ESPObjetos) do
            if b.Nome then b.Nome:Remove() end
            if b.Linha then b.Linha:Remove() end
        end
        ESPObjetos = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                ESPObjetos[p.Name] = {
                    Nome = criarText(),
                    Linha = criarLinha(),
                }
            end
        end
    end
end)

print("✅ Dexter Hub carregado com sucesso!")
