-- ====================================================================
--                      1. IMPORTAÇÃO DE MÓDULOS
-- ====================================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


-- ====================================================================
--                      2. SERVIÇOS, PLAYERS & REMOTES
-- ====================================================================
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer        = Players.LocalPlayer

local Remotes            = ReplicatedStorage:WaitForChild("Remotes")
local SignalRemote       = Remotes:WaitForChild("Signal")
local ClientFolder       = workspace:WaitForChild("Client")
local EnemiesFolder      = ClientFolder:WaitForChild("Enemies")
local WorldEnemies       = EnemiesFolder:WaitForChild("World")
local GamemodesFolder    = ReplicatedStorage:WaitForChild("Gamemodes")


-- ====================================================================
--                      3. ESTADO GLOBAL / VARIÁVEIS
-- ====================================================================
local gameName = "Carregando..."
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local State = {
    -- Player Farm & Stats Settings
    AutoAttackTurbo        = false,
    AutoRankUp             = false,
    SelectedStat           = "Energy",
    AutoUpgradeStat        = false,
    AutoClaimTimeRewards   = false,
    
    -- Craft Settings
    SelectedCraftIsland    = "Ninja Island",
    CraftShinyVersion      = false,
    AutoCraft              = false,

    -- Auto Farm World Settings
    SelectedWorldMobFolder = "Pirate Island",
    SelectedMobName        = nil,
    AutoFarmWorldMobs      = false,

    -- Stars & Gachas
    SelectedStar           = "Ninja Island",
    AutoOpenStar           = false,
    SelectedGacha          = "Clans",
    AutoOpenGacha          = false,
    
    -- Gamemodes & Position Save
    SelectedGamemode       = "Trial Easy",
    AutoJoinGamemode       = false,
    AutoFarmGamemode       = false,
    AutoLeaveWave          = false,
    UseSavedPosition       = false,
    SavedCFrame            = nil,
    SavedIslandName        = "Nenhuma",
    TargetWaves            = {
        ["Trial Easy"]      = 10,
        ["Infinite Castle"] = 50,
        ["Namek Invasion"]  = 15
    },
    
    FastDelay              = 0, -- Ajustado para velocidade máxima
    GamemodeDelay          = 0.01,
    WorldFarmDelay         = 0.5
}

local StatsList = {
    "Energy",
    "Coins",
    "Damage",
    "Luck",
    "Exp"
}

local CraftIslandList = {
    "Ninja Island (W1)",
    "Pirate Island (W2)",
    "Slayer Island (W3)",
    "Namek Island (W4)"
}

local WorldFoldersList = {
    "Ninja Island",
    "Pirate Island",
    "Slayer Island",
    "Namek Island"
}

local GamemodeMobFolders = {
    ["Trial Easy"]      = "TrialEasy",
    ["Infinite Castle"] = "InfiniteCastle",
    ["Namek Invasion"]  = "Namek Invasion"
}

local StarList = {
    "Ninja Island (W1)",
    "Pirate Island (W2)",
    "Slayer Island (W3)",
    "Namek Island (W4)"
}

local GachaList = {
    "Clans Gacha (W1)",
    "First Shinobi (W1)",
    "Fruits Gacha (W2)",
    "Haki Gacha (W2)",
    "Breaths Gacha (W3)",
    "Demon Arts (W3)",
    "Player Passive (W4)",
    "Dragon Techniques (W4)",
    "Races Gacha (W4)"
}

local GamemodeList = {
    "Trial Easy (Lobby)",
    "Infinite Castle (W3)",
    "Namek Invasion (W4)"
}


-- ====================================================================
--                      4. INTERFACE GRÁFICA (UI)
-- ====================================================================
local Window = Fluent:CreateWindow({
    Title       = "The Crown Inc",
    SubTitle    = gameName,
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 520),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    AutoFarm  = Window:AddTab({ Title = "Auto Farm",   Icon = "sword" }),
    Player    = Window:AddTab({ Title = "Player Farm", Icon = "user" }),
    Gachas    = Window:AddTab({ Title = "Gachas & Systems", Icon = "star" }),
    Gamemodes = Window:AddTab({ Title = "Gamemodes",        Icon = "gamepad" }),
    Settings  = Window:AddTab({ Title = "Settings",         Icon = "settings" })
}


-- ====================================================================
--                  [FUNÇÕES AUXILIARES DE LEITURA E LOCALIZAÇÃO]
-- ====================================================================

local function GetMobRealName(mobModel)
    local head = mobModel:FindFirstChild("Head") or mobModel:FindFirstChild("HumanoidRootPart")
    
    if head and head:IsA("BasePart") then
        local success, rootPart = pcall(function()
            return head.AssemblyRootPart
        end)
        
        if success and rootPart then
            return rootPart.Name
        end
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

-- Identifica a ilha atual aproximada com base na localização dos mobs mais próximos do jogador
local function GetCurrentIslandName()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return State.SelectedWorldMobFolder or "Desconhecida" end

    local closestIsland = State.SelectedWorldMobFolder or "Desconhecida"
    local shortestDist = math.huge

    for _, folderName in ipairs(WorldFoldersList) do
        local folder = WorldEnemies:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head")
                if mobRoot then
                    local dist = (mobRoot.Position - rootPart.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestIsland = folderName
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

local WorldFarmSection = Tabs.AutoFarm:AddSection("World Enemies Auto Farm")

local WorldDropdown = WorldFarmSection:AddDropdown("WorldFolderSelector", {
    Title       = "Selecione a Pasta do World",
    Description = "Escolha de qual ilha deseja buscar os mobs",
    Values      = WorldFoldersList,
    Multi       = false,
    Default     = "Pirate Island",
    Callback    = function(Value)
        State.SelectedWorldMobFolder = Value
    end
})

local EnemyDropdown = WorldFarmSection:AddDropdown("EnemySelector", {
    Title       = "Selecione o Inimigo",
    Description = "Mob alvo para auto farm",
    Values      = {"Nenhum Mapped"},
    Multi       = false,
    Default     = nil,
    Callback    = function(Value)
        if Value then
            local CleanName = Value:gsub("%s*%([%w%s]+%)", "")
            State.SelectedMobName = CleanName
        end
    end
})

local function RefreshEnemyList()
    local CurrentFolder = WorldEnemies:FindFirstChild(State.SelectedWorldMobFolder)
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

    if #FilteredList == 0 then
        table.insert(FilteredList, "Nenhum Mob Encontrado")
    end

    EnemyDropdown:SetValues(FilteredList)
    EnemyDropdown:SetValue(FilteredList[1])
end

WorldFarmSection:AddButton({
    Title       = "Refresh Mobs",
    Description = "Atualiza a lista de inimigos da ilha selecionada",
    Callback    = function()
        RefreshEnemyList()
    end
})

WorldFarmSection:AddToggle("AutoWorldFarmToggle", {
    Title       = "Ativar Auto Farm World",
    Description = "Teleporta instantaneamente para o mob vivo mais próximo do tipo selecionado",
    Default     = false,
    Callback    = function(Value)
        State.AutoFarmWorldMobs = Value
    end
})

local function GetTargetWorldMob()
    local targetFolder = WorldEnemies:FindFirstChild(State.SelectedWorldMobFolder)
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

-- Loop Auto Farm World (0.5s)
task.spawn(function()
    while true do
        task.wait(State.WorldFarmDelay)
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

local PlayerSection = Tabs.Player:AddSection("Player Functions")

PlayerSection:AddToggle("AutoAttackTurboToggle", {
    Title       = "Auto Attack Turbo",
    Description = "Dispara o remote de ataque em velocidade máxima (a cada frame)",
    Default     = false,
    Callback    = function(Value)
        State.AutoAttackTurbo = Value
    end
})

PlayerSection:AddToggle("AutoRankUpToggle", {
    Title       = "Auto Rank Up",
    Description = "Realiza o upgrade de Rank automaticamente",
    Default     = false,
    Callback    = function(Value)
        State.AutoRankUp = Value
    end
})

-- Seção: Stats Level Upgrades
local StatsSection = Tabs.Player:AddSection("Stats Upgrades")

StatsSection:AddDropdown("StatSelector", {
    Title       = "Selecione o Atributo",
    Description = "Escolha qual stat deseja evoluir",
    Values      = StatsList,
    Multi       = false,
    Default     = "Energy",
    Callback    = function(Value)
        State.SelectedStat = Value
    end
})

StatsSection:AddToggle("AutoUpgradeStatToggle", {
    Title       = "Ativar Auto Upgrade Stat",
    Description = "Evolui o atributo selecionado automaticamente",
    Default     = false,
    Callback    = function(Value)
        State.AutoUpgradeStat = Value
    end
})

-- Loop Auto Upgrade Stat
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoUpgradeStat and State.SelectedStat then
            pcall(function()
                SignalRemote:FireServer(
                    "General",
                    "LevelUpgrades",
                    "Upgrade",
                    State.SelectedStat,
                    1
                )
            end)
        end
    end
end)

-- Loop Auto Attack Turbo (Velocidade Máxima via Heartbeat / Frame)
RunService.Heartbeat:Connect(function()
    if State.AutoAttackTurbo then
        pcall(function()
            SignalRemote:FireServer("General", "Attack", "Click", {})
        end)
    end
end)

-- Loop Auto Rank Up
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoRankUp then
            pcall(function()
                SignalRemote:FireServer("General", "RankUp", "Upgrade")
            end)
        end
    end
end)

-- Seção Extra Functions (Craft, Rewards & Codes)
local ExtraSection = Tabs.Player:AddSection("Extra Functions")

ExtraSection:AddToggle("AutoClaimTimeRewardsToggle", {
    Title       = "Auto Claim Time Rewards",
    Description = "Coleta automaticamente todas as recompensas por tempo",
    Default     = false,
    Callback    = function(Value)
        State.AutoClaimTimeRewards = Value
    end
})

ExtraSection:AddDropdown("CraftIslandSelector", {
    Title       = "Selecione a Ilha do Craft",
    Description = "Escolha para qual ilha deseja fabricar",
    Values      = CraftIslandList,
    Multi       = false,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value)
        State.SelectedCraftIsland = Value:gsub("%s*%([%w%s]+%)", "")
    end
})

ExtraSection:AddDropdown("CraftTypeSelector", {
    Title       = "Tipo de Personagem",
    Description = "Escolha entre Normal (False) ou Shiny (True)",
    Values      = {"Normal (False)", "Shiny (True)"},
    Multi       = false,
    Default     = "Normal (False)",
    Callback    = function(Value)
        State.CraftShinyVersion = (Value == "Shiny (True)")
    end
})

ExtraSection:AddToggle("AutoCraftToggle", {
    Title       = "Auto Craft",
    Description = "Executa o craft repetidamente no parâmetro selecionado",
    Default     = false,
    Callback    = function(Value)
        State.AutoCraft = Value
    end
})

ExtraSection:AddButton({
    Title       = "Redeem All Codes",
    Description = "Resgata o código 'Release'",
    Callback    = function()
        pcall(function()
            SignalRemote:FireServer("General", "Codes", "Claim", "Release")
        end)
    end
})

-- Loop Auto Claim Time Rewards
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoClaimTimeRewards then
            for rewardIndex = 1, 7 do
                pcall(function()
                    SignalRemote:FireServer("General", "TimeRewards", "Claim", rewardIndex)
                end)
                task.wait(0.1)
            end
        end
    end
end)

-- Loop Auto Craft
task.spawn(function()
    while true do
        task.wait(0.2)
        if State.AutoCraft and State.SelectedCraftIsland then
            pcall(function()
                SignalRemote:FireServer(
                    "General",
                    "Craft",
                    "Craft",
                    State.SelectedCraftIsland,
                    State.CraftShinyVersion
                )
            end)
        end
    end
end)


-- ====================================================================
--                  [ABA 3: GACHAS & SYSTEMS]
-- ====================================================================

local StarSection = Tabs.Gachas:AddSection("Auto Open Stars")

StarSection:AddDropdown("StarSelector", {
    Title       = "Selecione a Star",
    Description = "Escolha qual ilha deseja abrir",
    Values      = StarList,
    Multi       = false,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value)
        State.SelectedStar = Value:gsub("%s*%([%w%s]+%)", "")
    end
})

StarSection:AddToggle("AutoStarToggle", {
    Title       = "Ativar Auto Open Star",
    Description = "Dispara o remote automaticamente",
    Default     = false,
    Callback    = function(Value)
        State.AutoOpenStar = Value
    end
})

task.spawn(function()
    while true do
        task.wait(State.FastDelay)
        if State.AutoOpenStar and State.SelectedStar then
            pcall(function()
                SignalRemote:FireServer("General", "Stars", "Multi", State.SelectedStar)
            end)
        end
    end
end)

local GachaSection = Tabs.Gachas:AddSection("Gachas Open")

GachaSection:AddDropdown("GachaSelector", {
    Title       = "Selecione o Gacha",
    Description = "Escolha qual gacha deseja girar",
    Values      = GachaList,
    Multi       = false,
    Default     = "Clans Gacha (W1)",
    Callback    = function(Value)
        local CleanedName = Value:gsub("%s*Gacha", ""):gsub("%s*%([%w%s]+%)", "")
        State.SelectedGacha = CleanedName
    end
})

GachaSection:AddToggle("AutoGachaToggle", {
    Title       = "Ativar Auto Roll Gacha",
    Description = "Gira o gacha selecionado automaticamente",
    Default     = false,
    Callback    = function(Value)
        State.AutoOpenGacha = Value
    end
})

task.spawn(function()
    while true do
        task.wait(State.FastDelay)
        if State.AutoOpenGacha and State.SelectedGacha then
            pcall(function()
                SignalRemote:FireServer("General", "Gacha", "Roll", State.SelectedGacha, {})
            end)
        end
    end
end)


-- ====================================================================
--                  [ABA 4: GAMEMODES]
-- ====================================================================

local function IsAnyGamemodeActive()
    for _, folderName in pairs(GamemodeMobFolders) do
        local folder = EnemiesFolder:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local hum = mob:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    return true
                end
            end
        end
    end
    return false
end

local SavePosSection = Tabs.Gamemodes:AddSection("Gamemode & Status Information")

local StatusParagraph = SavePosSection:AddParagraph({
    Title   = "Status Geral dos Gamemodes",
    Content = "Carregando informações..."
})

-- Loop para atualizar o Paragraph em tempo real
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

            local wav
