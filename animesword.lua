--[[ Protected by Lua Guard ]]

-- ====================================================================
--                      1. IMPORTAÇÃO DE MÓDULOS
-- ====================================================================
local Fluent = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\103\105\116\104\117\098\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\114\101\108\101\097\115\101\115\047\108\097\116\101\115\116\047\100\111\119\110\108\111\097\100\047\109\097\105\110\046\108\117\097"))()
local SaveManager = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\109\097\115\116\101\114\047\065\100\100\111\110\115\047\083\097\118\101\077\097\110\097\103\101\114\046\108\117\097"))()
local InterfaceManager = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\109\097\115\116\101\114\047\065\100\100\111\110\115\047\073\110\116\101\114\102\097\099\101\077\097\110\097\103\101\114\046\108\117\097"))()


-- ====================================================================
--                      2. SERVIÇOS, PLAYERS & REMOTES
-- ====================================================================
local Players            = game:GetService("\080\108\097\121\101\114\115")
local ReplicatedStorage  = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
local RunService         = game:GetService("\082\117\110\083\101\114\118\105\099\101")
local MarketplaceService = game:GetService("\077\097\114\107\101\116\112\108\097\099\101\083\101\114\118\105\099\101")
local LocalPlayer        = Players.LocalPlayer

local Remotes            = ReplicatedStorage:WaitForChild("\082\101\109\111\116\101\115")
local SignalRemote       = Remotes:WaitForChild("\083\105\103\110\097\108")
local ClientFolder       = workspace:WaitForChild("\067\108\105\101\110\116")
local EnemiesFolder      = ClientFolder:WaitForChild("\069\110\101\109\105\101\115")
local WorldEnemies       = EnemiesFolder:WaitForChild("\087\111\114\108\100")
local GamemodesFolder    = ReplicatedStorage:WaitForChild("\071\097\109\101\109\111\100\101\115")


-- ====================================================================
--                      3. ESTADO GLOBAL / VARIÁVEIS
-- ====================================================================
local gameName = "\067\097\114\114\101\103\097\110\100\111\046\046\046"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local State = {
    -- Player Farm & Stats Settings
    AutoAttackTurbo        = false,
    AutoRankUp             = false,
    SelectedStat           = "\069\110\101\114\103\121",
    AutoUpgradeStat        = false,
    AutoClaimTimeRewards   = false,
    
    -- Craft Settings
    SelectedCraftIsland    = "\078\105\110\106\097\032\073\115\108\097\110\100",
    CraftShinyVersion      = false,
    AutoCraft              = false,

    -- Auto Farm World Settings
    SelectedWorldMobFolder = "\080\105\114\097\116\101\032\073\115\108\097\110\100",
    SelectedMobName        = nil,
    AutoFarmWorldMobs      = false,

    -- Stars & Gachas
    SelectedStar           = "\078\105\110\106\097\032\073\115\108\097\110\100",
    AutoOpenStar           = false,
    SelectedGacha          = "\067\108\097\110\115",
    AutoOpenGacha          = false,
    
    -- Gamemodes & Position Save
    SelectedGamemode       = "\084\114\105\097\108\032\069\097\115\121",
    AutoJoinGamemode       = false,
    AutoFarmGamemode       = false,
    AutoLeaveWave          = false,
    UseSavedPosition       = false,
    SavedCFrame            = nil,
    SavedIslandName        = "\078\101\110\104\117\109\097",
    TargetWaves            = {
        ["\084\114\105\097\108\032\069\097\115\121"]      = 10,
        ["\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101"] = 50,
        ["\078\097\109\101\107\032\073\110\118\097\115\105\111\110"]  = 15
    },
    
    FastDelay              = 0.05,
    GamemodeDelay          = 0.01,
    WorldFarmDelay         = 0.5
}

local StatsList = {
    "\069\110\101\114\103\121",
    "\067\111\105\110\115",
    "\068\097\109\097\103\101",
    "\076\117\099\107",
    "\069\120\112"
}

local CraftIslandList = {
    "\078\105\110\106\097\032\073\115\108\097\110\100\032\040\087\049\041",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100\032\040\087\050\041",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100\032\040\087\051\041",
    "\078\097\109\101\107\032\073\115\108\097\110\100\032\040\087\052\041"
}

local WorldFoldersList = {
    "\078\105\110\106\097\032\073\115\108\097\110\100",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100",
    "\078\097\109\101\107\032\073\115\108\097\110\100"
}

local GamemodeMobFolders = {
    ["\084\114\105\097\108\032\069\097\115\121"]      = "\084\114\105\097\108\069\097\115\121",
    ["\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101"] = "\073\110\102\105\110\105\116\101\067\097\115\116\108\101",
    ["\078\097\109\101\107\032\073\110\118\097\115\105\111\110"]  = "\078\097\109\101\107\032\073\110\118\097\115\105\111\110"
}

local StarList = {
    "\078\105\110\106\097\032\073\115\108\097\110\100\032\040\087\049\041",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100\032\040\087\050\041",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100\032\040\087\051\041",
    "\078\097\109\101\107\032\073\115\108\097\110\100\032\040\087\052\041"
}

local GachaList = {
    "\067\108\097\110\115\032\071\097\099\104\097\032\040\087\049\041",
    "\070\105\114\115\116\032\083\104\105\110\111\098\105\032\040\087\049\041",
    "\070\114\117\105\116\115\032\071\097\099\104\097\032\040\087\050\041",
    "\072\097\107\105\032\071\097\099\104\097\032\040\087\050\041",
    "\066\114\101\097\116\104\115\032\071\097\099\104\097\032\040\087\051\041",
    "\068\101\109\111\110\032\065\114\116\115\032\040\087\051\041",
    "\080\108\097\121\101\114\032\080\097\115\115\105\118\101\032\040\087\052\041",
    "\068\114\097\103\111\110\032\084\101\099\104\110\105\113\117\101\115\032\040\087\052\041",
    "\082\097\099\101\115\032\071\097\099\104\097\032\040\087\052\041"
}

local GamemodeList = {
    "\084\114\105\097\108\032\069\097\115\121\032\040\076\111\098\098\121\041",
    "\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101\032\040\087\051\041",
    "\078\097\109\101\107\032\073\110\118\097\115\105\111\110\032\040\087\052\041"
}


-- ====================================================================
--                      4. INTERFACE GRÁFICA (UI)
-- ====================================================================
local Window = Fluent:CreateWindow({
    Title       = "\084\104\101\032\067\114\111\119\110\032\073\110\099",
    SubTitle    = gameName,
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 520),
    Acrylic     = true,
    Theme       = "\068\097\114\107",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    AutoFarm  = Window:AddTab({ Title = "\065\117\116\111\032\070\097\114\109",   Icon = "\115\119\111\114\100" }),
    Player    = Window:AddTab({ Title = "\080\108\097\121\101\114\032\070\097\114\109", Icon = "\117\115\101\114" }),
    Gachas    = Window:AddTab({ Title = "\071\097\099\104\097\115\032\038\032\083\121\115\116\101\109\115", Icon = "\115\116\097\114" }),
    Gamemodes = Window:AddTab({ Title = "\071\097\109\101\109\111\100\101\115",        Icon = "\103\097\109\101\112\097\100" }),
    Settings  = Window:AddTab({ Title = "\083\101\116\116\105\110\103\115",         Icon = "\115\101\116\116\105\110\103\115" })
}


-- ====================================================================
--                  [FUNÇÕES AUXILIARES DE LEITURA E LOCALIZAÇÃO]
-- ====================================================================

local function GetMobRealName(mobModel)
    local head = mobModel:FindFirstChild("\072\101\097\100") or mobModel:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    
    if head and head:IsA("\066\097\115\101\080\097\114\116") then
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
    
    local humanoid = mobModel:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
    local rootPart = mobModel:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mobModel:FindFirstChild("\072\101\097\100") or mobModel.PrimaryPart
    
    if not humanoid or humanoid.Health <= 0 then return false end
    if not rootPart or not rootPart:IsA("\066\097\115\101\080\097\114\116") then return false end
    
    return true
end

-- Identifica a ilha atual aproximada com base na localização dos mobs mais próximos do jogador
local function GetCurrentIslandName()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    if not rootPart then return State.SelectedWorldMobFolder or "\068\101\115\099\111\110\104\101\099\105\100\097" end

    local closestIsland = State.SelectedWorldMobFolder or "\068\101\115\099\111\110\104\101\099\105\100\097"
    local shortestDist = math.huge

    for _, folderName in ipairs(WorldFoldersList) do
        local folder = WorldEnemies:FindFirstChild(folderName)
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local mobRoot = mob:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mob:FindFirstChild("\072\101\097\100")
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

local WorldFarmSection = Tabs.AutoFarm:AddSection("\087\111\114\108\100\032\069\110\101\109\105\101\115\032\065\117\116\111\032\070\097\114\109")

local WorldDropdown = WorldFarmSection:AddDropdown("\087\111\114\108\100\070\111\108\100\101\114\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\097\032\080\097\115\116\097\032\100\111\032\087\111\114\108\100",
    Description = "\069\115\099\111\108\104\097\032\100\101\032\113\117\097\108\032\105\108\104\097\032\100\101\115\101\106\097\032\098\117\115\099\097\114\032\111\115\032\109\111\098\115",
    Values      = WorldFoldersList,
    Multi       = false,
    Default     = "\080\105\114\097\116\101\032\073\115\108\097\110\100",
    Callback    = function(Value)
        State.SelectedWorldMobFolder = Value
    end
})

local EnemyDropdown = WorldFarmSection:AddDropdown("\069\110\101\109\121\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\111\032\073\110\105\109\105\103\111",
    Description = "\077\111\098\032\097\108\118\111\032\112\097\114\097\032\097\117\116\111\032\102\097\114\109",
    Values      = {"\078\101\110\104\117\109\032\077\097\112\112\101\100"},
    Multi       = false,
    Default     = nil,
    Callback    = function(Value)
        if Value then
            local CleanName = Value:gsub("\037\115\042\037\040\091\037\119\037\115\093\043\037\041", "")
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
                table.insert(FilteredList, mobRealName .. "\032\040" .. State.SelectedWorldMobFolder .. "\041")
            end
        end
    end

    if #FilteredList == 0 then
        table.insert(FilteredList, "\078\101\110\104\117\109\032\077\111\098\032\069\110\099\111\110\116\114\097\100\111")
    end

    EnemyDropdown:SetValues(FilteredList)
    EnemyDropdown:SetValue(FilteredList[1])
end

WorldFarmSection:AddButton({
    Title       = "\082\101\102\114\101\115\104\032\077\111\098\115",
    Description = "\065\116\117\097\108\105\122\097\032\097\032\108\105\115\116\097\032\100\101\032\105\110\105\109\105\103\111\115\032\100\097\032\105\108\104\097\032\115\101\108\101\099\105\111\110\097\100\097",
    Callback    = function()
        RefreshEnemyList()
    end
})

WorldFarmSection:AddToggle("\065\117\116\111\087\111\114\108\100\070\097\114\109\084\111\103\103\108\101", {
    Title       = "\065\116\105\118\097\114\032\065\117\116\111\032\070\097\114\109\032\087\111\114\108\100",
    Description = "\084\101\108\101\112\111\114\116\097\032\105\110\115\116\097\110\116\097\110\101\097\109\101\110\116\101\032\112\097\114\097\032\111\032\109\111\098\032\118\105\118\111\032\109\097\105\115\032\112\114\243\120\105\109\111\032\100\111\032\116\105\112\111\032\115\101\108\101\099\105\111\110\097\100\111",
    Default     = false,
    Callback    = function(Value)
        State.AutoFarmWorldMobs = Value
    end
})

local function GetTargetWorldMob()
    local targetFolder = WorldEnemies:FindFirstChild(State.SelectedWorldMobFolder)
    if not targetFolder or not State.SelectedMobName then return nil end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    if not rootPart then return nil end

    local closestMob = nil
    local shortestDistance = math.huge

    for _, mob in ipairs(targetFolder:GetChildren()) do
        if IsMobSpawnedAndAlive(mob) then
            local realName = GetMobRealName(mob)
            if realName:lower() == State.SelectedMobName:lower() then
                local mobRoot = mob:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mob:FindFirstChild("\072\101\097\100") or mob.PrimaryPart
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
                    local rootPart = character and character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
                    local mobRoot = targetMob:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or targetMob:FindFirstChild("\072\101\097\100") or targetMob.PrimaryPart

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

local PlayerSection = Tabs.Player:AddSection("\080\108\097\121\101\114\032\070\117\110\099\116\105\111\110\115")

PlayerSection:AddToggle("\065\117\116\111\065\116\116\097\099\107\084\117\114\098\111\084\111\103\103\108\101", {
    Title       = "\065\117\116\111\032\065\116\116\097\099\107\032\084\117\114\098\111",
    Description = "\068\105\115\112\097\114\097\032\111\032\114\101\109\111\116\101\032\100\101\032\097\116\097\113\117\101\032\097\032\099\097\100\097\032\048\046\048\053\115",
    Default     = false,
    Callback    = function(Value)
        State.AutoAttackTurbo = Value
    end
})

PlayerSection:AddToggle("\065\117\116\111\082\097\110\107\085\112\084\111\103\103\108\101", {
    Title       = "\065\117\116\111\032\082\097\110\107\032\085\112",
    Description = "\082\101\097\108\105\122\097\032\111\032\117\112\103\114\097\100\101\032\100\101\032\082\097\110\107\032\097\117\116\111\109\097\116\105\099\097\109\101\110\116\101",
    Default     = false,
    Callback    = function(Value)
        State.AutoRankUp = Value
    end
})

-- Seção: Stats Level Upgrades
local StatsSection = Tabs.Player:AddSection("\083\116\097\116\115\032\085\112\103\114\097\100\101\115")

StatsSection:AddDropdown("\083\116\097\116\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\111\032\065\116\114\105\098\117\116\111",
    Description = "\069\115\099\111\108\104\097\032\113\117\097\108\032\115\116\097\116\032\100\101\115\101\106\097\032\101\118\111\108\117\105\114",
    Values      = StatsList,
    Multi       = false,
    Default     = "\069\110\101\114\103\121",
    Callback    = function(Value)
        State.SelectedStat = Value
    end
})

StatsSection:AddToggle("\065\117\116\111\085\112\103\114\097\100\101\083\116\097\116\084\111\103\103\108\101", {
    Title       = "\065\116\105\118\097\114\032\065\117\116\111\032\085\112\103\114\097\100\101\032\083\116\097\116",
    Description = "\069\118\111\108\117\105\032\111\032\097\116\114\105\098\117\116\111\032\115\101\108\101\099\105\111\110\097\100\111\032\097\117\116\111\109\097\116\105\099\097\109\101\110\116\101",
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
                    "\071\101\110\101\114\097\108",
                    "\076\101\118\101\108\085\112\103\114\097\100\101\115",
                    "\085\112\103\114\097\100\101",
                    State.SelectedStat,
                    1
                )
            end)
        end
    end
end)

-- Loop Auto Attack Turbo (0.05s)
task.spawn(function()
    while true do
        task.wait(State.FastDelay)
        if State.AutoAttackTurbo then
            pcall(function()
                SignalRemote:FireServer("\071\101\110\101\114\097\108", "\065\116\116\097\099\107", "\067\108\105\099\107", {})
            end)
        end
    end
end)

-- Loop Auto Rank Up
task.spawn(function()
    while true do
        task.wait(0.5)
        if State.AutoRankUp then
          
