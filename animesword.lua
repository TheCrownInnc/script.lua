-- ====================================================================
--                  1. CARREGAMENTO SEGURO DA INTERFACE
-- ====================================================================
local Success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not Success or not Fluent then
    warn("[The Crown Inc] Falha ao carregar a Fluent UI Library.")
    return
end

local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ====================================================================
--                  2. SERVIÇOS, PLAYERS & VARIÁVEIS
-- ====================================================================
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer        = Players.LocalPlayer

local Remotes            = ReplicatedStorage:WaitForChild("Remotes", 10)
local SignalRemote       = Remotes and Remotes:WaitForChild("Signal", 10)
local ClientFolder       = workspace:WaitForChild("Client", 10)
local EnemiesFolder      = ClientFolder and ClientFolder:WaitForChild("Enemies", 10)
local WorldEnemies       = EnemiesFolder and EnemiesFolder:WaitForChild("World", 10)

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
    PriorityMobName        = "Nenhum",
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
    
    TargetWaveTrialEasy     = 10,
    TargetWaveInfiniteCastle= 50,
    TargetWaveNamekInvasion = 15
}

local StatsList          = { "Energy", "Coins", "Damage", "Luck", "Exp" }
local CraftIslandList    = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local WorldFoldersList   = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local StarList           = { "Ninja Island (W1)", "Pirate Island (W2)", "Slayer Island (W3)", "Namek Island (W4)" }
local GamemodeList       = { "Trial Easy (Lobby)", "Infinite Castle (W3)", "Namek Invasion (W4)" }
local GachaList          = {
    "Clans Gacha (W1)", "First Shinobi (W1)", "Fruits Gacha (W2)",
    "Haki Gacha (W2)", "Breaths Gacha (W3)", "Demon Arts (W3)",
    "Player Passive (W4)", "Dragon Techniques (W4)", "Races Gacha (W4)"
}
local GamemodeMobFolders = {
    ["Trial Easy"]      = "TrialEasy",
    ["Infinite Castle"] = "InfiniteCastle",
    ["Namek Invasion"]  = "Namek Invasion"
}

-- ====================================================================
--                  3. CRIAÇÃO DA JANELA UI
-- ====================================================================
local Window = Fluent:CreateWindow({
    Title       = "The Crown Inc",
    SubTitle    = gameName,
    TabWidth    = 140,
    Size        = UDim2.fromOffset(530, 390),
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
--                  4. FUNÇÕES AUXILIARES DE CHECAGEM
-- ====================================================================
local function GetCleanFolder(name)
    if not name then return "" end
    return name:gsub("%s*%([%w%s]+%)", "")
end

local function GetMobAssembly(mobModel)
    if not mobModel then return nil end
    local head = mobModel:FindFirstChild("Head") or mobModel:FindFirstChild("HumanoidRootPart")
    if head and head:IsA("BasePart") then
        local success, rootPart = pcall(function() return head.AssemblyRootPart end)
        if success and rootPart then return rootPart.Name end
    end
    return mobModel.Name
end

local function GetMobRootPart(mobModel)
    if not mobModel then return nil end
    return mobModel:FindFirstChild("HumanoidRootPart") 
        or mobModel:FindFirstChild("Head") 
        or mobModel.PrimaryPart 
        or mobModel:FindFirstChildWhichIsA("BasePart")
end

local function IsMobSpawnedAndAlive(mobModel)
    if not mobModel or not mobModel.Parent or not mobModel:IsDescendantOf(workspace) then return false end
    local humanoid = mobModel:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    local rootPart = GetMobRootPart(mobModel)
    if not rootPart or not rootPart:IsA("BasePart") then return false end
    return true
end

-- ====================================================================
--                  5. CONTROLES DA UI E LÓGICA
-- ====================================================================

-- ABA 1: AUTO FARM
local WorldFarmSection = Tabs.AutoFarm:AddSection("World Enemies Auto Farm")

local EnemyDropdown, PriorityDropdown

local function RefreshEnemyList()
    if not WorldEnemies then return end
    local FolderName = GetCleanFolder(State.SelectedWorldMobFolder)
    local CurrentFolder = WorldEnemies:FindFirstChild(FolderName)
    local UniqueAssemblies = {}
    local FilteredList = {}

    if CurrentFolder then
        for _, mob in ipairs(CurrentFolder:GetChildren()) do
            local assemblyName = GetMobAssembly(mob)
            if assemblyName and assemblyName ~= "" and not UniqueAssemblies[assemblyName] then
                UniqueAssemblies[assemblyName] = true
                table.insert(FilteredList, assemblyName)
            end
        end
    end

    local PriorityList = {"Nenhum"}

    if #FilteredList == 0 then 
        table.insert(FilteredList, "Nenhum Mob Encontrado")
        State.SelectedMobName = nil
    else
        State.SelectedMobName = FilteredList[1]
        for _, name in ipairs(FilteredList) do table.insert(PriorityList, name) end
    end

    if EnemyDropdown then
        EnemyDropdown:SetValues(FilteredList)
        if FilteredList[1] then EnemyDropdown:SetValue(FilteredList[1]) end
    end

    if PriorityDropdown then
        PriorityDropdown:SetValues(PriorityList)
        PriorityDropdown:SetValue("Nenhum")
        State.PriorityMobName = "Nenhum"
    end
end

WorldFarmSection:AddDropdown("WorldFolderSelector", {
    Title       = "Selecione a Pasta do World",
    Values      = WorldFoldersList,
    Default     = "Pirate Island (W2)",
    Callback    = function(Value)
        State.SelectedWorldMobFolder = Value
        RefreshEnemyList()
    end
})

EnemyDropdown = WorldFarmSection:AddDropdown("EnemySelector", {
    Title       = "Selecione o Inimigo Principal",
    Values      = {"Nenhum Mob Encontrado"},
    Default     = nil,
    Callback    = function(Value)
        if Value and Value ~= "Nenhum Mob Encontrado" then State.SelectedMobName = Value end
    end
})

PriorityDropdown = WorldFarmSection:AddDropdown("PriorityEnemySelector", {
    Title       = "Selecione o Mob Prioritário",
    Values      = {"Nenhum"},
    Default     = "Nenhum",
    Callback    = function(Value) State.PriorityMobName = Value or "Nenhum" end
})

WorldFarmSection:AddButton({
    Title       = "Refresh Mobs",
    Callback    = function() RefreshEnemyList() end
})

WorldFarmSection:AddToggle("AutoWorldFarmToggle", {
    Title       = "Ativar Auto Farm World (Troca 1.0s)",
    Default     = false,
    Callback    = function(Value) State.AutoFarmWorldMobs = Value end
})

-- ABA 2: PLAYER FARM & STATS
local PlayerSection = Tabs.Player:AddSection("Player Functions")

PlayerSection:AddToggle("AutoAttackTurboToggle", {
    Title       = "Auto Attack Turbo",
    Default     = false,
    Callback    = function(Value) State.AutoAttackTurbo = Value end
})

PlayerSection:AddToggle("AutoRankUpToggle", {
    Title       = "Auto Rank Up",
    Default     = false,
    Callback    = function(Value) State.AutoRankUp = Value end
})

local StatsSection = Tabs.Player:AddSection("Stats Upgrades")

StatsSection:AddDropdown("StatSelector", {
    Title       = "Selecione o Atributo",
    Values      = StatsList,
    Default     = "Energy",
    Callback    = function(Value) State.SelectedStat = Value end
})

StatsSection:AddToggle("AutoUpgradeStatToggle", {
    Title       = "Ativar Auto Upgrade Stat",
    Default     = false,
    Callback    = function(Value) State.AutoUpgradeStat = Value end
})

local ExtraSection = Tabs.Player:AddSection("Extra Functions")

ExtraSection:AddToggle("AutoClaimTimeRewardsToggle", {
    Title       = "Auto Claim Time Rewards",
    Default     = false,
    Callback    = function(Value) State.AutoClaimTimeRewards = Value end
})

ExtraSection:AddDropdown("CraftIslandSelector", {
    Title       = "Ilha do Craft",
    Values      = CraftIslandList,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedCraftIsland = Value end
})

ExtraSection:AddDropdown("CraftTypeSelector", {
    Title       = "Tipo de Personagem",
    Values      = {"Normal (False)", "Shiny (True)"},
    Default     = "Normal (False)",
    Callback    = function(Value) State.CraftShinyVersion = (Value == "Shiny (True)") end
})

ExtraSection:AddToggle("AutoCraftToggle", {
    Title       = "Auto Craft",
    Default     = false,
    Callback    = function(Value) State.AutoCraft = Value end
})

ExtraSection:AddButton({
    Title       = "Redeem All Codes",
    Callback    = function()
        if SignalRemote then SignalRemote:FireServer("General", "Codes", "Claim", "Release") end
    end
})

-- ABA 3: GACHAS & STARS
local StarSection = Tabs.Gachas:AddSection("Auto Open Stars")
StarSection:AddDropdown("StarSelector", {
    Title       = "Selecione a Star",
    Values      = StarList,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedStar = Value end
})
StarSection:AddToggle("AutoStarToggle", {
    Title       = "Ativar Auto Open Star",
    Default     = false,
    Callback    = function(Value) State.AutoOpenStar = Value end
})

local GachaSection = Tabs.Gachas:AddSection("Gachas Open")
GachaSection:AddDropdown("GachaSelector", {
    Title       = "Selecione o Gacha",
    Values      = GachaList,
    Default     = "Clans Gacha (W1)",
    Callback    = function(Value) State.SelectedGacha = Value end
})
GachaSection:AddToggle("AutoGachaToggle", {
    Title       = "Ativar Auto Roll Gacha",
    Default     = false,
    Callback    = function(Value) State.AutoOpenGacha = Value end
})

-- ABA 4: GAMEMODES & CONFIGS DE WAVE
local SavePosSection = Tabs.Gamemodes:AddSection("Informações & Posição")

SavePosSection:AddButton({
    Title       = "Salvar Posição Atual",
    Callback    = function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            State.SavedCFrame = rootPart.CFrame
            Fluent:Notify({ Title = "Sucesso", Content = "Posição salva!", Duration = 3 })
        end
    end
})

SavePosSection:AddToggle("UseSavedPosToggle", {
    Title       = "Retornar Para Posição Salva",
    Default     = false,
    Callback    = function(Value) State.UseSavedPosition = Value end
})

local GamemodeConfigSection = Tabs.Gamemodes:AddSection("Controle Gamemode")

GamemodeConfigSection:AddDropdown("GamemodeSelector", {
    Title       = "Selecione o Modo",
    Values      = GamemodeList,
    Default     = "Trial Easy (Lobby)",
    Callback    = function(Value) State.SelectedGamemode = GetCleanFolder(Value) end
})

GamemodeConfigSection:AddToggle("AutoJoinGamemodeToggle", {
    Title       = "Auto Join Gamemode",
    Default     = false,
    Callback    = function(Value) State.AutoJoinGamemode = Value end
})

GamemodeConfigSection:AddToggle("AutoFarmGamemodeToggle", {
    Title       = "Auto Farm Gamemode",
    Default     = false,
    Callback    = function(Value) State.AutoFarmGamemode = Value end
})

GamemodeConfigSection:AddToggle("AutoLeaveWaveToggle", {
    Title       = "Auto Leave no Limite de Wave",
    Default     = false,
    Callback    = function(Value) State.AutoLeaveWave = Value end
})

local WaveInputsSection = Tabs.Gamemodes:AddSection("Limites de Wave")

WaveInputsSection:AddInput("TargetWaveTrialInput", {
    Title       = "Wave Limite - Trial Easy",
    Default     = "10",
    Numeric     = true,
    Finished    = true,
    Callback    = function(v) State.TargetWaveTrialEasy = tonumber(v) or 10 end
})

WaveInputsSection:AddInput("TargetWaveCastleInput", {
    Title       = "Wave Limite - Infinite Castle",
    Default     = "50",
    Numeric     = true,
    Finished    = true,
    Callback    = function(v) State.TargetWaveInfiniteCastle = tonumber(v) or 50 end
})

WaveInputsSection:AddInput("TargetWaveNamekInput", {
    Title       = "Wave Limite - Namek Invasion",
    Default     = "15",
    Numeric     = true,
    Finished    = true,
    Callback    = function(v) State.TargetWaveNamekInvasion = tonumber(v) or 15 end
})

-- ====================================================================
--                  6. LOOPS DE EXECUÇÃO
-- ====================================================================

-- FARM WORLD ENEMIES ( prioritário + 1.0s rotação )
local CurrentTargetIndex, LastTargetMob, TargetTimeCounter = 1, nil, 0

local function GetValidMobs()
    if not WorldEnemies then return {} end
    local folderName = GetCleanFolder(State.SelectedWorldMobFolder)
    local targetFolder = WorldEnemies:FindFirstChild(folderName)
    local list = {}

    if not targetFolder then return list end

    if State.PriorityMobName and State.PriorityMobName ~= "Nenhum" then
        local priorityLower = State.PriorityMobName:lower()
        for _, mob in ipairs(targetFolder:GetChildren()) do
            if IsMobSpawnedAndAlive(mob) then
                local assembly = GetMobAssembly(mob)
                if assembly and assembly:lower() == priorityLower then
                    table.insert(list, mob)
                end
            end
        end
    end

    if #list == 0 and State.SelectedMobName then
        local targetLower = State.SelectedMobName:lower()
        for _, mob in ipairs(targetFolder:GetChildren()) do
            if IsMobSpawnedAndAlive(mob) then
                local assembly = GetMobAssembly(mob)
                if assembly and assembly:lower() == targetLower then
                    table.insert(list, mob)
                end
            end
        end
    end

    return list
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if State.AutoFarmWorldMobs then
            pcall(function()
                local mobs = GetValidMobs()
                if #mobs > 0 then
                    if CurrentTargetIndex > #mobs then CurrentTargetIndex = 1 end
                    local currentMob = mobs[CurrentTargetIndex]

                    if currentMob and IsMobSpawnedAndAlive(currentMob) then
                        local char = LocalPlayer.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        local mobRoot = GetMobRootPart(currentMob)

                        if rootPart and mobRoot then
                            rootPart.AssemblyLinearVelocity = Vector3.zero
                            rootPart.AssemblyAngularVelocity = Vector3.zero
                            rootPart.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, 1.5, 2))
                        end

                        if currentMob == LastTargetMob then
                            TargetTimeCounter = TargetTimeCounter + 0.05
                            if TargetTimeCounter >= 1.0 then 
                                CurrentTargetIndex = CurrentTargetIndex + 1
                                TargetTimeCounter = 0
                            end
                        else
                            LastTargetMob = currentMob
                            TargetTimeCounter = 0
                        end
                    else
                        CurrentTargetIndex = CurrentTargetIndex + 1
                        TargetTimeCounter = 0
                    end
                else
                    CurrentTargetIndex = 1
                    LastTargetMob = nil
                    TargetTimeCounter = 0
                end
            end)
        end
    end
end)

-- ATAQUE & ACTIONS TURBO
task.spawn(function()
    while true do
        task.wait(0.01)
        if State.AutoAttackTurbo and SignalRemote then
            pcall(function() SignalRemote:FireServer("General", "Attack", "Click", {}) end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoUpgradeStat and State.SelectedStat and SignalRemote then
            pcall(function() SignalRemote:FireServer("General", "LevelUpgrades", "Upgrade", State.SelectedStat, 1) end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if State.AutoOpenStar and State.SelectedStar and SignalRemote then
            pcall(function() SignalRemote:FireServer("General", "Stars", "Multi", GetCleanFolder(State.SelectedStar)) end)
        end
        if State.AutoOpenGacha and State.SelectedGacha and SignalRemote then
            pcall(function() 
                local cleanGacha = GetCleanFolder(State.SelectedGacha):gsub("%s*Gacha", "")
                SignalRemote:FireServer("General", "Gacha", "Roll", cleanGacha, {})
            end)
        end
    end
end)

-- CONFIGURAÇÕES DE INTERFACE DO FLUENT
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

task.defer(function()
    task.wait(1)
    RefreshEnemyList()
end)

Fluent:Notify({ Title = "The Crown Inc", Content = "Script carregado sem erros!", Duration = 5 })
-- ====================================================================
--            7. LOOPS DE EXECUÇÃO - PARTE 2 (SISTEMAS E GAMEMODES)
-- ====================================================================

-- --------------------------------------------------------------------
-- AUTO RANK UP & TIME REWARDS & CRAFT
-- --------------------------------------------------------------------

-- Loop do Auto Rank Up
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoRankUp and SignalRemote then
            pcall(function()
                SignalRemote:FireServer("General", "Ranks", "RankUp", {})
            end)
        end
    end
end)

-- Loop do Auto Claim Time Rewards (Recompensas por Tempo)
task.spawn(function()
    while true do
        task.wait(5)
        if State.AutoClaimTimeRewards and SignalRemote then
            pcall(function()
                for i = 1, 12 do
                    SignalRemote:FireServer("General", "TimeGifts", "Claim", i)
                    task.wait(0.1)
                end
            end)
        end
    end
end)

-- Loop do Auto Craft (Fundir Personagens)
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoCraft and State.SelectedCraftIsland and SignalRemote then
            pcall(function()
                local cleanIsland = GetCleanFolder(State.SelectedCraftIsland)
                SignalRemote:FireServer("General", "Craft", "CraftAll", cleanIsland, State.CraftShinyVersion)
            end)
        end
    end
end)

-- --------------------------------------------------------------------
-- SISTEMA DE GAMEMODES (Trial Easy, Infinite Castle, Namek Invasion)
-- --------------------------------------------------------------------

-- Auto Join Gamemode
task.spawn(function()
    while true do
        task.wait(2)
        if State.AutoJoinGamemode and State.SelectedGamemode and SignalRemote then
            pcall(function()
                -- Verifica se o jogador já não está dentro de um modo de jogo ativo
                local currentGamemodeFolder = EnemiesFolder and EnemiesFolder:FindFirstChild("Gamemode")
                local isInGamemode = currentGamemodeFolder and #currentGamemodeFolder:GetChildren() > 0

                if not isInGamemode then
                    SignalRemote:FireServer("General", "Gamemodes", "Join", State.SelectedGamemode)
                end
            end)
        end
    end
end)

-- Auto Farm Gamemode Mobs (Encontra e elimina mobs em modos de jogo)
task.spawn(function()
    while true do
        task.wait(0.05)
        if State.AutoFarmGamemode then
            pcall(function()
                local gamemodeEnemiesFolder = EnemiesFolder and EnemiesFolder:FindFirstChild("Gamemode")
                if gamemodeEnemiesFolder then
                    local activeGamemodeName = GamemodeMobFolders[State.SelectedGamemode] or State.SelectedGamemode
                    local targetFolder = gamemodeEnemiesFolder:FindFirstChild(activeGamemodeName) or gamemodeEnemiesFolder

                    local validMobs = {}
                    for _, mob in ipairs(targetFolder:GetChildren()) do
                        if IsMobSpawnedAndAlive(mob) then
                            table.insert(validMobs, mob)
                        end
                    end

                    if #validMobs > 0 then
                        local currentMob = validMobs[1]
                        local char = LocalPlayer.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        local mobRoot = GetMobRootPart(currentMob)

                        if rootPart and mobRoot then
                            rootPart.AssemblyLinearVelocity = Vector3.zero
                            rootPart.AssemblyAngularVelocity = Vector3.zero
                            rootPart.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, 1.5, 2))
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Leave Gamemode por Wave Limite
task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoLeaveWave and SignalRemote then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if not playerGui then return end

                -- Tenta ler a wave atual a partir do HUD/UI do Gamemode
                local currentWave = 0
                local waveGui = playerGui:FindFirstChild("GamemodeHUD") or playerGui:FindFirstChild("WaveHUD")
                
                if waveGui then
                    local waveTextLabel = waveGui:FindFirstChild("WaveText", true) or waveGui:FindFirstChild("Wave", true)
                    if waveTextLabel and waveTextLabel:IsA("TextLabel") then
                        currentWave = tonumber(waveTextLabel.Text:match("%d+")) or 0
                    end
                end

                -- Define o limite baseado no Gamemode Selecionado
                local targetLimit = 999
                if State.SelectedGamemode == "Trial Easy" then
                    targetLimit = State.TargetWaveTrialEasy
                elseif State.SelectedGamemode == "Infinite Castle" then
                    targetLimit = State.TargetWaveInfiniteCastle
                elseif State.SelectedGamemode == "Namek Invasion" then
                    targetLimit = State.TargetWaveNamekInvasion
                end

                -- Se atingir a wave configurada, envia o sinal de saída
                if currentWave >= targetLimit and currentWave > 0 then
                    SignalRemote:FireServer("General", "Gamemodes", "Leave", {})
                    
                    -- Se a opção de retornar à posição salvação estiver ativa
                    if State.UseSavedPosition and State.SavedCFrame then
                        task.wait(1.5)
                        local char = LocalPlayer.Character
                        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            rootPart.CFrame = State.SavedCFrame
                        end
                    end
                end
            end)
        end
    end
end)

-- Notificação de finalização
Fluent:Notify({ 
    Title = "The Crown Inc", 
    Content = "Parte 2 carregada com sucesso!", 
    Duration = 4 
})
