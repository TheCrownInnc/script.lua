-- ====================================================================
--                      1. IMPORTAÇÃO DE MÓDULOS (Fluent)
-- ====================================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
--                      4. INTERFACE GRÁFICA (Fluent UI)
-- ====================================================================
local Window = Fluent:CreateWindow({
    Title       = "The Crown Inc",
    SubTitle    = gameName,
    TabWidth    = 140,
    Size        = UDim2.fromOffset(500, 380),
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
--                  [FUNÇÕES AUXILIARES DE LEITURA]
-- ====================================================================
local function GetCleanFolder(name)
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
    if not mobModel or not mobModel.Parent then return false end
    local humanoid = mobModel:FindFirstChildOfClass("Humanoid")
    local rootPart = GetMobRootPart(mobModel)
    if humanoid and humanoid.Health <= 0 then return false end
    if not rootPart or not rootPart:IsA("BasePart") then return false end
    return true
end

-- ====================================================================
--                  [ABA 1: AUTO FARM - WORLD MOBS]
-- ====================================================================
local WorldFarmSection = Tabs.AutoFarm:AddSection("World Enemies Auto Farm")

local EnemyDropdown

local function RefreshEnemyList()
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

    if #FilteredList == 0 then 
        table.insert(FilteredList, "Nenhum Mob Encontrado")
        State.SelectedMobName = nil
    else
        State.SelectedMobName = FilteredList[1]
    end

    if EnemyDropdown then
        EnemyDropdown:SetValues(FilteredList)
        if FilteredList[1] then
            EnemyDropdown:SetValue(FilteredList[1])
        end
    end
end

WorldFarmSection:AddDropdown("WorldFolderSelector", {
    Title       = "Selecione a Pasta do World",
    Description = "Escolha de qual ilha deseja buscar os mobs",
    Values      = WorldFoldersList,
    Multi       = false,
    Default     = "Pirate Island (W2)",
    Callback    = function(Value)
        State.SelectedWorldMobFolder = Value
        RefreshEnemyList()
    end
})

EnemyDropdown = WorldFarmSection:AddDropdown("EnemySelector", {
    Title       = "Selecione o Inimigo",
    Description = "Mob alvo para auto farm",
    Values      = {"Nenhum Mob Encontrado"},
    Multi       = false,
    Default     = nil,
    Callback    = function(Value)
        if Value and Value ~= "Nenhum Mob Encontrado" then
            State.SelectedMobName = Value
        end
    end
})

WorldFarmSection:AddButton({
    Title       = "Refresh Mobs",
    Description = "Atualiza a lista de inimigos da ilha selecionada",
    Callback    = function() RefreshEnemyList() end
})

WorldFarmSection:AddToggle("AutoWorldFarmToggle", {
    Title       = "Ativar Auto Farm World",
    Description = "Teleporta por todos os mobs do assembly selecionado",
    Default     = false,
    Callback    = function(Value) State.AutoFarmWorldMobs = Value end
})

-- ====================================================================
--        [VARREDURA TOTAL DE MOBS DO ASSEMBLY (FILA DE PRIORIDADE)]
-- ====================================================================
local CurrentTargetIndex = 1
local TargetStuckTimer = 0
local LastTargetMob = nil

local function GetAllMobsWithAssembly()
    local folderName = GetCleanFolder(State.SelectedWorldMobFolder)
    local targetFolder = WorldEnemies:FindFirstChild(folderName)
    local matchedMobs = {}

    if not targetFolder or not State.SelectedMobName then return matchedMobs end

    local targetAssemblyLower = State.SelectedMobName:lower()

    for _, mob in ipairs(targetFolder:GetChildren()) do
        if IsMobSpawnedAndAlive(mob) then
            local mobAssembly = GetMobAssembly(mob)
            if mobAssembly and mobAssembly:lower() == targetAssemblyLower then
                table.insert(matchedMobs, mob)
            end
        end
    end

    return matchedMobs
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if State.AutoFarmWorldMobs then
            pcall(function()
                local matchedMobs = GetAllMobsWithAssembly()

                if #matchedMobs > 0 then
                    -- Garante que o índice não estoure a tabela atual
                    if CurrentTargetIndex > #matchedMobs then
                        CurrentTargetIndex = 1
                    end

                    local currentMob = matchedMobs[CurrentTargetIndex]

                    -- Se o mob atual for válido e estiver vivo
                    if currentMob and IsMobSpawnedAndAlive(currentMob) then
                        local character = LocalPlayer.Character
                        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                        local mobRoot = GetMobRootPart(currentMob)

                        if rootPart and mobRoot then
                            rootPart.AssemblyLinearVelocity = Vector3.zero
                            rootPart.AssemblyAngularVelocity = Vector3.zero
                            rootPart.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, 1.5, 2))
                        end

                        -- Temporizador de Segurança (se o mob não morrer em 1.2s, passa para o próximo ID)
                        if currentMob == LastTargetMob then
                            TargetStuckTimer = TargetStuckTimer + 0.05
                            if TargetStuckTimer >= 1.2 then
                                CurrentTargetIndex = CurrentTargetIndex + 1
                                TargetStuckTimer = 0
                            end
                        else
                            LastTargetMob = currentMob
                            TargetStuckTimer = 0
                        end
                    else
                        -- Se o mob morreu/sumiu, avança para o próximo mob com o mesmo Assembly
                        CurrentTargetIndex = CurrentTargetIndex + 1
                        TargetStuckTimer = 0
                    end
                else
                    CurrentTargetIndex = 1
                    LastTargetMob = nil
                    TargetStuckTimer = 0
                end
            end)
        else
            CurrentTargetIndex = 1
            LastTargetMob = nil
            TargetStuckTimer = 0
        end
    end
end)

task.defer(function()
    task.wait(1)
    RefreshEnemyList()
end)
-- ====================================================================
--                  [ABA 2: PLAYER FARM & STATS]
-- ====================================================================
local PlayerSection = Tabs.Player:AddSection("Player Functions")

PlayerSection:AddToggle("AutoAttackTurboToggle", {
    Title       = "Auto Attack Turbo",
    Description = "Dispara o remote de ataque continuamente",
    Default     = false,
    Callback    = function(Value) State.AutoAttackTurbo = Value end
})

PlayerSection:AddToggle("AutoRankUpToggle", {
    Title       = "Auto Rank Up",
    Description = "Realiza o upgrade de Rank automaticamente",
    Default     = false,
    Callback    = function(Value) State.AutoRankUp = Value end
})

local StatsSection = Tabs.Player:AddSection("Stats Upgrades")

StatsSection:AddDropdown("StatSelector", {
    Title       = "Selecione o Atributo",
    Description = "Escolha qual stat deseja evoluir",
    Values      = StatsList,
    Multi       = false,
    Default     = "Energy",
    Callback    = function(Value) State.SelectedStat = Value end
})

StatsSection:AddToggle("AutoUpgradeStatToggle", {
    Title       = "Ativar Auto Upgrade Stat",
    Description = "Evolui o atributo selecionado automaticamente",
    Default     = false,
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

local ExtraSection = Tabs.Player:AddSection("Extra Functions")

ExtraSection:AddToggle("AutoClaimTimeRewardsToggle", {
    Title       = "Auto Claim Time Rewards",
    Description = "Coleta automaticamente todas as recompensas por tempo",
    Default     = false,
    Callback    = function(Value) State.AutoClaimTimeRewards = Value end
})

ExtraSection:AddDropdown("CraftIslandSelector", {
    Title       = "Selecione a Ilha do Craft",
    Description = "Escolha para qual ilha deseja fabricar",
    Values      = CraftIslandList,
    Multi       = false,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedCraftIsland = Value end
})

ExtraSection:AddDropdown("CraftTypeSelector", {
    Title       = "Tipo de Personagem",
    Description = "Escolha entre Normal (False) ou Shiny (True)",
    Values      = {"Normal (False)", "Shiny (True)"},
    Multi       = false,
    Default     = "Normal (False)",
    Callback    = function(Value) State.CraftShinyVersion = (Value == "Shiny (True)") end
})

ExtraSection:AddToggle("AutoCraftToggle", {
    Title       = "Auto Craft",
    Description = "Executa o craft repetidamente",
    Default     = false,
    Callback    = function(Value) State.AutoCraft = Value end
})

ExtraSection:AddButton({
    Title       = "Redeem All Codes",
    Description = "Resgata o código 'Release'",
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
local StarSection = Tabs.Gachas:AddSection("Auto Open Stars")

StarSection:AddDropdown("StarSelector", {
    Title       = "Selecione a Star",
    Values      = StarList,
    Multi       = false,
    Default     = "Ninja Island (W1)",
    Callback    = function(Value) State.SelectedStar = Value end
})

StarSection:AddToggle("AutoStarToggle", {
    Title       = "Ativar Auto Open Star",
    Default     = false,
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

local GachaSection = Tabs.Gachas:AddSection("Gachas Open")

GachaSection:AddDropdown("GachaSelector", {
    Title       = "Selecione o Gacha",
    Values      = GachaList,
    Multi       = false,
    Default     = "Clans Gacha (W1)",
    Callback    = function(Value) State.SelectedGacha = Value end
})

GachaSection:AddToggle("AutoGachaToggle", {
    Title       = "Ativar Auto Roll Gacha",
    Default     = false,
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
                local mobRoot = GetMobRootPart(mob)
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

local SavePosSection = Tabs.Gamemodes:AddSection("Gamemode & Status Information")

local StatusParagraph = SavePosSection:AddParagraph({
    Title   = "Status Geral dos Gamemodes",
    Content = "Carregando informações..."
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

SavePosSection:AddButton({
    Title       = "Salvar Posição Atual",
    Description = "Salva a localização atual para retorno automático",
    Callback    = function()
        local char = LocalPlayer.Character
        local rootPart = char and char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            State.SavedCFrame = rootPart.CFrame
            State.SavedIslandName = GetCurrentIslandName()
            Fluent:Notify({
                Title   = "Posição Salva",
                Content = "Localização gravada na ilha: " .. State.SavedIslandName,
                Duration = 3
            })
        end
    end
})

SavePosSection:AddToggle("UseSavedPosToggle", {
    Title       = "Retornar Para Posição Salva",
    Default     = false,
    Callback    = function(Value) State.UseSavedPosition = Value end
})

local GamemodeConfigSection = Tabs.Gamemodes:AddSection("Configurações do Gamemode")

GamemodeConfigSection:AddDropdown("GamemodeSelector", {
    Title       = "Selecione o Modo de Jogo",
    Values      = GamemodeList,
    Multi       = false,
    Default     = "Trial Easy (Lobby)",
    Callback    = function(Value)
        State.SelectedGamemode = GetCleanFolder(Value)
    end
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

-- SECTION SEPARADA EXCLUSIVAMENTE PARA INPUTS DAS WAVES
local WaveInputsSection = Tabs.Gamemodes:AddSection("Configuração de Waves (Limites)")

WaveInputsSection:AddInput("TargetWaveTrialInput", {
    Title       = "Wave Limite - Trial Easy",
    Default     = "10",
    Placeholder = "Digite a wave limite...",
    Numeric     = true,
    Finished    = true,
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveTrialEasy = num end
    end
})

WaveInputsSection:AddInput("TargetWaveCastleInput", {
    Title       = "Wave Limite - Infinite Castle",
    Default     = "50",
    Placeholder = "Digite a wave limite...",
    Numeric     = true,
    Finished    = true,
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveInfiniteCastle = num end
    end
})

WaveInputsSection:AddInput("TargetWaveNamekInput", {
    Title       = "Wave Limite - Namek Invasion",
    Default     = "15",
    Placeholder = "Digite a wave limite...",
    Numeric     = true,
    Finished    = true,
    Callback    = function(Value)
        local num = tonumber(Value)
        if num then State.TargetWaveNamekInvasion = num end
    end
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
            local mobRoot = GetMobRootPart(mob)
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
        task.wait(0.05)
        if State.AutoFarmGamemode then
            pcall(function()
                local targetMob = GetTargetGamemodeMob()
                if targetMob and IsMobSpawnedAndAlive(targetMob) then
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local mobRoot = GetMobRootPart(targetMob)

                    if rootPart and mobRoot then
                        rootPart.AssemblyLinearVelocity = Vector3.zero
                        rootPart.AssemblyAngularVelocity = Vector3.zero
                        rootPart.CFrame = CFrame.new(mobRoot.Position + Vector3.new(0, 1.5, 2))
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

-- ====================================================================
--                  [ABA 5: CONFIGURAÇÕES & ADICIONAIS]
-- ====================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("TheCrownIncScript")
SaveManager:SetFolder("TheCrownIncScript/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title    = "The Crown Inc",
    Content  = "Script carregado com sucesso!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
