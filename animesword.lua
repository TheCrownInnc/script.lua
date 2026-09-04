-- ====================================================================
--                      1. IMPORTAÇÃO DE MÓDULOS (WindUI)
-- ====================================================================
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- ====================================================================
--                      2. SERVIÇOS, PLAYERS & REMOTES
-- ====================================================================
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer        = Players.LocalPlayer

local Remotes            = ReplicatedStorage:WaitForChild("Remotes")
local SignalRemote       = Remotes:WaitForChild("Signal")
local ClientFolder       = workspace:WaitForChild("Client")
local EnemiesFolder      = ClientFolder:WaitForChild("Enemies")
local WorldEnemies       = EnemiesFolder:WaitForChild("World")

-- ====================================================================
--                      3. ESTADO GLOBAL / VARIÁVEIS
-- ====================================================================
local gameName = "Anime Sword"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local State = {
    AutoAttackTurbo        = false,
    AutoRankUp             = false,
    SelectedStat           = "Energy",
    AutoUpgradeStat        = false,
    AutoClaimTimeRewards   = false,
    
    SelectedCraftIsland    = "Ninja Island (W1)",
    CraftShinyVersion      = false,
    AutoCraft              = false,

    SelectedWorldMobFolder = "Pirate Island (W2)",
    SelectedMobName        = nil,
    AutoFarmWorldMobs      = false,

    SelectedStar           = "Ninja Island (W1)",
    AutoOpenStar           = false,
    SelectedGacha          = "Clans Gacha (W1)",
    AutoOpenGacha          = false,
    
    SelectedGamemode       = "Trial Easy",
    AutoJoinGamemode       = false,
    AutoFarmGamemode       = false,
    AutoLeaveWave          = false,
    UseSavedPosition       = false,
    SavedCFrame            = nil,
    SavedIslandName        = "Nenhuma",
    
    -- Inputs de Wave para cada Gamemode separadamente
    TargetWaveTrialEasy     = 10,
    TargetWaveInfiniteCastle= 50,
    TargetWaveNamekInvasion = 15
}

local StatsList = { "Energy", "Coins", "Damage", "Luck", "Exp" }
local CraftIslandList = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local WorldFoldersList = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local GamemodeMobFolders = {
    ["Trial Easy"]      = "TrialEasy",
    ["Infinite Castle"] = "InfiniteCastle",
    ["Namek Invasion"]  = "Namek Invasion"
}
local StarList = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local GachaList = {
    "Clans Gacha (W1)", "First Shinobi (W1)", "Fruits Gacha (W2)",
    "Haki Gacha (W2)", "Breaths Gacha (W3)", "Demon Arts (W3)",
    "Player Passive (W4)", "Dragon Techniques (W4)", "Races Gacha (W4)"
}
local GamemodeList = { "Trial Easy (Lobby)", "Infinite Castle (W3)", "Namek Invasion (W4)" }

-- ====================================================================
--                      4. CRIAÇÃO DA JANELA (WindUI)
-- ====================================================================
local Window = WindUI:CreateWindow({
    Title = "The Crown Inc",
    Icon = "crown",
    Author = gameName,
    Folder = "TheCrownIncConfig",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true
})

local Tabs = {
    AutoFarm  = Window:Tab({ Title = "Auto Farm",   Icon = "sword" }),
    Player    = Window:Tab({ Title = "Player Farm", Icon = "user" }),
    Gachas    = Window:Tab({ Title = "Gachas & Systems", Icon = "star" }),
    Gamemodes = Window:Tab({ Title = "Gamemodes",        Icon = "gamepad" })
}

-- ====================================================================
--                  [FUNÇÕES AUXILIARES]
-- ====================================================================
local function GetCleanFolder(name)
    return name:gsub("%s*%([%w%s]+%)", "")
end

local function GetMobRealName(mobModel)
    local head = mobModel:FindFirstChild("Head") or mobModel:FindFirstChild("HumanoidRootPart")
    if head and head:IsA("BasePart") then
        local success, rootPart = pcall(function() return head.AssemblyRootPart end)
        if success and rootPart then return rootPart.Name end
    end
    return mobModel.Name
end

local function IsMobSpawnedAndAlive(mobModel)
    if not mobModel or not mobModel.Parent then return false end
    local humanoid = mobModel:FindFirstChildOfClass("Humanoid")
    local rootPart = mobModel:FindFirstChild("HumanoidRootPart") or mobModel:FindFirstChild("Head") or mobModel.PrimaryPart
    if not humanoid or humanoid.Health <= 0 then return false end
    if not rootPart or not rootPart:IsA("BasePart") then return false end
    return true
end

local function GetCurrentIslandName()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return State.SelectedWorldMobFolder end

    local closestIsland = State.SelectedWorldMobFolder
    local shortestDist = math.huge

    for _, rawFolder in ipairs(WorldFoldersList) do
        local folderName = GetCleanFolder(rawFolder)
        local folder = WorldEnemies:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
                if mobRoot then
                    local dist = (mobRoot.Position - rootPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestIsland = rawFolder
                    end
                end
            end
        end
    end
    return closestIsland
end

-- ====================================================================
--                  [ABA 1: AUTO FARM - WORLD MOBS]
-- ====================================================================
Tabs.AutoFarm:Section({ Title = "World Enemies Auto Farm" })

Tabs.AutoFarm:Dropdown({
    Title       = "Selecione a Pasta do World",
    Desc        = "Escolha de qual ilha deseja buscar os mobs",
    Values      = WorldFoldersList,
    Value       = "Pirate Island (W2)",
    Callback    = function(Value)
        State.SelectedWorldMobFolder = Value
    end
})

local EnemyDropdown = Tabs.AutoFarm:Dropdown({
    Title       = "Selecione o Inimigo",
    Desc        = "Mob alvo para auto farm",
    Values      = {"Nenhum Mapped"},
    Value       = nil,
    Callback    = function(Value)
        if Value then
            local CleanName = Value:gsub("%s*%([%w%s]+%)", "")
            State.SelectedMobName = CleanName
        end
    end
})

local function RefreshEnemyList()
    local FolderName = GetCleanFolder(State.SelectedWorldMobFolder)
    local CurrentFolder = WorldEnemies:FindFirstChild(FolderName)
    local UniqueNames = {}
    local FilteredList = {}

    if CurrentFolder then
        for _, mob in ipairs(CurrentFolder:GetChildren()) do
            local mobRealName = GetMobRealName(mob)
            if mobRealName and mobRealName ~= "" and not UniqueNames[mobRealName] then
                UniqueNames[mobRealName] = true
                table.insert(FilteredList, mobRealName .. " (" .. State.SelectedWorldMobFolder .. ")")
            end
        end
    end

    if #FilteredList == 0 then table.insert(FilteredList, "Nenhum Mob Encontrado") end
    EnemyDropdown:Refresh(FilteredList)
    EnemyDropdown:Set(FilteredList[1])
end

Tabs.AutoFarm:Button({
    Title       = "Refresh Mobs",
    Desc        = "Atualiza a lista de inimigos da ilha selecionada",
    Callback    = function() RefreshEnemyList() end
})

Tabs.AutoFarm:Toggle({
    Title       = "Ativar Auto Farm World",
    Desc        = "Teleporta instantaneamente para o mob vivo mais próximo",
    Value       = false,
    Callback    = function(Value) State.AutoFarmWorldMobs = Value end
})

local function GetTargetWorldMob()
    local folderName = GetCleanFolder(State.SelectedWorldMobFolder)
    local targetFolder = WorldEnemies:FindFirstChild(folderName)
    if not targetFolder or not State.SelectedMobName then return nil end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestMob = nil
    local shortestDistance = math.huge

    for _, mob in ipairs(targetFolder:GetChildren()) do
        if IsMobSpawnedAndAlive(mob) then
            local realName = GetMobRealName(mob)
            if realName:lower() == State.SelectedMobName:lower() then
                local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head") or mob.PrimaryPart
                if mobRoot then
                    local dist = (mobRoot.Position - rootPart.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestMob = mob
                    end
                end
            end
        end
    end
    return closestMob
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoFarmWorldMobs then
            pcall(function()
                local targetMob = GetTargetWorldMob()
                if targetMob and IsMobSpawnedAndAlive(targetMob) then
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local mobRoot = targetMob:FindFirstChild("HumanoidRootPart") or targetMob:FindFirstChild("Head") or targetMob.PrimaryPart

                    if rootPart and mobRoot then
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                        rootPart.AssemblyAngularVelocity = Vector3.zero
                        rootPart.CFrame = mobRoot.CFrame * CFrame.new(0, 1.5, 1.8)
                    end
                end
            end)
        end
    end
end)
-- ====================================================================
--                  [ABA 2: PLAYER FARM & STATS]
-- ====================================================================
Tabs.Player:Section({ Title = "Player Functions" })

Tabs.Player:Toggle({
    Title       = "Auto Attack Turbo",
    Desc        = "Dispara o remote de ataque continuamente",
    Value       = false,
    Callback    = function(Value) State.AutoAttackTurbo = Value end
})

Tabs.Player:Toggle({
    Title       = "Auto Rank Up",
    Desc        = "Realiza o upgrade de Rank automaticamente",
    Value       = false,
    Callback    = function(Value) State.AutoRankUp = Value end
})

Tabs.Player:Section({ Title = "Stats Upgrades" })

Tabs.Player:Dropdown({
    Title       = "Selecione o Atributo",
    Desc        = "Escolha qual stat deseja evoluir",
    Values      = StatsList,
    Value       = "Energy",
    Callback    = function(Value) State.SelectedStat = Value end
})

Tabs.Player:Toggle({
    Title       = "Ativar Auto Upgrade Stat",
    Desc        = "Evolui o atributo selecionado automaticamente",
    Value       = false,
    Callback    = function(Value) State.AutoUpgradeStat = Value end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoUpgradeStat and State.SelectedStat then
            pcall(function()
                SignalRemote:FireServer("General", "LevelUpgrades", "Upgrade", State.SelectedStat, 1)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if State.AutoAttackTurbo then
            pcall(function() SignalRemote:FireServer("General", "Attack", "Click", {}) end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoRankUp then
            pcall(function() SignalRemote:FireServer("General", "RankUp", "Upgrade") end)
        end
    end
end)

Tabs.Player:Section({ Title = "Extra Functions" })

Tabs.Player:Toggle({
    Title       = "Auto Claim Time Rewards",
    Desc        = "Coleta automaticamente todas as recompensas por tempo",
    Value       = false,
    Callback    = function(Value) State.AutoClaimTimeRewards = Value end
})

Tabs.Player:Dropdown({
    Title       = "Selecione a Ilha do Craft",
    Desc        = "Escolha para qual ilha deseja fabricar",
    Values      = CraftIslandList,
    Value       = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedCraftIsland = Value end
})

Tabs.Player:Dropdown({
    Title       = "Tipo de Personagem",
    Desc        = "Escolha entre Normal (False) ou Shiny (True)",
    Values      = {"Normal (False)", "Shiny (True)"},
    Value       = "Normal (False)",
    Callback    = function(Value) State.CraftShinyVersion = (Value == "Shiny (True)") end
})

Tabs.Player:Toggle({
    Title       = "Auto Craft",
    Desc        = "Executa o craft repetidamente",
    Value       = false,
    Callback    = function(Value) State.AutoCraft = Value end
})

Tabs.Player:Button({
    Title       = "Redeem All Codes",
    Desc        = "Resgata o código 'Release'",
    Callback    = function()
        pcall(function() SignalRemote:FireServer("General", "Codes", "Claim", "Release") end)
    end
})

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoClaimTimeRewards then
            for rewardIndex = 1, 7 do
                pcall(function() SignalRemote:FireServer("General", "TimeRewards", "Claim", rewardIndex) end)
                task.wait(0.1)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoCraft and State.SelectedCraftIsland then
            pcall(function()
                SignalRemote:FireServer("General", "Craft", "Craft", GetCleanFolder(State.SelectedCraftIsland), State.CraftShinyVersion)
            end)
        end
    end
end)

-- ====================================================================
--                  [ABA 3: GACHAS & SYSTEMS]
-- ====================================================================
Tabs.Gachas:Section({ Title = "Auto Open Stars" })

Tabs.Gachas:Dropdown({
    Title       = "Selecione a Star",
    Values      = StarList,
    Value       = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedStar = Value end
})

Tabs.Gachas:Toggle({
    Title       = "Ativar Auto Open Star",
    Value       = false,
    Callback    = function(Value) State.AutoOpenStar = Value end
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if State.AutoOpenStar and State.SelectedStar then
            pcall(function()
                SignalRemote:FireServer("General", "Stars", "Multi", GetCleanFolder(State.SelectedStar))
            end)
        end
    end
end)

Tabs.Gachas:Section({ Title = "Gachas Open" })

Tabs.Gachas:Dropdown({
    Title       = "Selecione o Gacha",
    Values      = GachaList,
    Value       = "Clans Gacha (W1)",
    Callback    = function(Value) State.SelectedGacha = Value end
})

Tabs.Gachas:Toggle({
    Title       = "Ativar Auto Roll Gacha",
    Value       = false,
    Callback    = function(Value) State.AutoOpenGacha = Value end
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if State.AutoOpenGacha and State.SelectedGacha then
            pcall(function()
                local cleanGacha = GetCleanFolder(State.SelectedGacha):gsub("%s*Gacha", "")
                SignalRemote:FireServer("General", "Gacha", "Roll", cleanGacha, {})
            end)
        end
    end
end)

-- ====================================================================
--                  [ABA 4: GAMEMODES & SAVE POSITION]
-- ====================================================================
local function IsAnyGamemodeActive()
    for _, folderName in pairs(GamemodeMobFolders) do
        local folder = EnemiesFolder:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then return true end
            end
        end
    end
    return false
end

Tabs.Gamemodes:Section({ Title = "Gamemode & Status Information" })

local StatusParagraph = Tabs.Gamemodes:Paragraph({
    Title   = "Status Geral dos Gamemodes",
    Desc    = "Carregando informações..."
})

task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            local islandText = State.SavedIslandName or "Nenhuma"
            local cfText = "N/A"
            if State.SavedCFrame then
                local pos = State.SavedCFrame.Position
                cfText = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            end
            local activeText = IsAnyGamemodeActive() and "Em Partida (Ativo)" or "Lobby / Esperando"

            StatusParagraph:SetTitle("Status do Jogador / Gamemode")
            StatusParagraph:SetDesc(
                "• Estado Atual: " .. activeText .. "\n" ..
                "• Ilha Salva: " .. islandText .. "\n" ..
                "• Coordenadas Salvas: " .. cfText .. "\n" ..
                "• Target Wave (Trial): " .. tostring(State.TargetWaveTrialEasy) .. "\n" ..
                "• Target Wave (Castle): " .. tostring(State.TargetWaveInfiniteCastle) .. "\n" ..
                "• Target Wave (Namek): " .. tostring(State.TargetWaveNamekInvasion)
            )
        end)
    end
end)

Tabs.Gamemodes:Button({
    Title       = "Salvar Posição Atual",
    Desc        = "Salva a localização atual para retorno automático",
    Callback    = function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            State.SavedCFrame = rootPart.CFrame
            State.SavedIslandName = GetCurrentIslandName()
            WindUI:Notify({
                Title   = "Posição Salva",
                Content = "Localização gravada na ilha: " .. State.SavedIslandName,
                Duration = 3
            })
        end
    end
})

Tabs.Gamemodes:Toggle({
    Title       = "Retornar Para Posição Salva",
    Value       = false,
    Callback    = function(Value) State.UseSavedPosition = Value end
})

Tabs.Gamemodes:Section({ Title = "Configurações do Gamemode" })

Tabs.Gamemodes:Dropdown({
    Title       = "Selecione o Modo de Jogo",
    Values      = GamemodeList,
    Value       = "Trial Easy (Lobby)",
    Callback    = function(Value)
        State.SelectedGamemode = GetCleanFolder(Value)
    end
})

Tabs.Gamemodes:Input({
    Title       = "Wave Limite - Trial Easy",
    Value       = "10",
    Placeholder = "Digite a wave limite...",
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveTrialEasy = num end
    end
})

Tabs.Gamemodes:Input({
    Title       = "Wave Limite - Infinite Castle",
    Value       = "50",
    Placeholder = "Digite a wave limite...",
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveInfiniteCastle = num end
    end
})

Tabs.Gamemodes:Input({
    Title       = "Wave Limite - Namek Invasion",
    Value       = "15",
    Placeholder = "Digite a wave limite...",
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveNamekInvasion = num end
    end
})

Tabs.Gamemodes:Toggle({
    Title       = "Auto Join Gamemode",
    Value       = false,
    Callback    = function(Value) State.AutoJoinGamemode = Value end
})

Tabs.Gamemodes:Toggle({
    Title       = "Auto Farm Gamemode",
    Value       = false,
    Callback    = function(Value) State.AutoFarmGamemode = Value end
})

Tabs.Gamemodes:Toggle({
    Title       = "Auto Leave no Limite de Wave",
    Value       = false,
    Callback    = function(Value) State.AutoLeaveWave = Value end
})

local function GetTargetGamemodeMob()
    local folderName = GamemodeMobFolders[State.SelectedGamemode]
    if not folderName then return nil end

    local targetFolder = EnemiesFolder:FindFirstChild(folderName)
    if not targetFolder then return nil end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local closestMob = nil
    local shortestDist = math.huge

    for _, mob in ipairs(targetFolder:GetChildren()) do
        if IsMobSpawnedAndAlive(mob) then
            local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head") or mob.PrimaryPart
            if mobRoot then
                local dist = (mobRoot.Position - rootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestMob = mob
                end
            end
        end
    end
    return closestMob
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoFarmGamemode then
            pcall(function()
                local targetMob = GetTargetGamemodeMob()
                if targetMob and IsMobSpawnedAndAlive(targetMob) then
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local mobRoot = targetMob:FindFirstChild("HumanoidRootPart") or targetMob:FindFirstChild("Head") or targetMob.PrimaryPart

                    if rootPart and mobRoot then
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                        rootPart.AssemblyAngularVelocity = Vector3.zero
                        rootPart.CFrame = mobRoot.CFrame * CFrame.new(0, 1.5, 1.8)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoJoinGamemode and not IsAnyGamemodeActive() then
            pcall(function()
                SignalRemote:FireServer("General", "Gamemodes", "Join", State.SelectedGamemode)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoLeaveWave and IsAnyGamemodeActive() then
            pcall(function()
                local currentWave = 0
                local waveValue = workspace:FindFirstChild("CurrentWave") or ReplicatedStorage:FindFirstChild("CurrentWave")
                if waveValue then currentWave = waveValue.Value end

                local targetWave = 10
                if State.SelectedGamemode == "Trial Easy" then
                    targetWave = State.TargetWaveTrialEasy
                elseif State.SelectedGamemode == "Infinite Castle" then
                    targetWave = State.TargetWaveInfiniteCastle
                elseif State.SelectedGamemode == "Namek Invasion" then
                    targetWave = State.TargetWaveNamekInvasion
                end

                if currentWave >= targetWave then
                    SignalRemote:FireServer("General", "Gamemodes", "Leave")
                    if State.UseSavedPosition and State.SavedCFrame then
                        task.wait(1)
                        local char = LocalPlayer.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        if rootPart then rootPart.CFrame = State.SavedCFrame end
                    end
                end
            end)
        end
    end
end)

WindUI:Notify({
    Title    = "The Crown Inc",
    Content  = "Script carregado com sucesso!",
    Duration = 5
})
