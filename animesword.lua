--[[ Protected by Lua Guard ]]

(function(...) 
-- ====================================================================
--                      0x1. IMPORTAÇÃO DE MÓDULOS
-- ====================================================================
local _IIllIlIllI = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\103\105\116\104\117\098\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\114\101\108\101\097\115\101\115\047\108\097\116\101\115\116\047\100\111\119\110\108\111\097\100\047\109\097\105\110\046\108\117\097"))()
local _IllllIIlll = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\109\097\115\116\101\114\047\065\100\100\111\110\115\047\083\097\118\101\077\097\110\097\103\101\114\046\108\117\097"))()
local _llIIIllIII = loadstring(game:HttpGet("\104\116\116\112\115\058\047\047\114\097\119\046\103\105\116\104\117\098\117\115\101\114\099\111\110\116\101\110\116\046\099\111\109\047\100\097\119\105\100\045\115\099\114\105\112\116\115\047\070\108\117\101\110\116\047\109\097\115\116\101\114\047\065\100\100\111\110\115\047\073\110\116\101\114\102\097\099\101\077\097\110\097\103\101\114\046\108\117\097"))()


-- ====================================================================
--                      0x2. SERVIÇOS, PLAYERS & REMOTES
-- ====================================================================
local Players            = game:GetService("\080\108\097\121\101\114\115")
local ReplicatedStorage  = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
local RunService         = game:GetService("\082\117\110\083\101\114\118\105\099\101")
local _IIIlIIllIl = game:GetService("\077\097\114\107\101\116\112\108\097\099\101\083\101\114\118\105\099\101")
local _IlIlIllIlI        = Players.LocalPlayer

local _lIIlIllIIl            = ReplicatedStorage:WaitForChild("\082\101\109\111\116\101\115", 0xA)
local _lIlIlIllII       = _lIIlIllIIl and _lIIlIllIIl:WaitForChild("\083\105\103\110\097\108", 0xA)
local _llIllIlIlI       = workspace:WaitForChild("\067\108\105\101\110\116", 0xA)
local _IlIlllIIII      = _llIllIlIlI and _llIllIlIlI:WaitForChild("\069\110\101\109\105\101\115", 0xA)
local _lIIlIIIIIl       = _IlIlllIIII and _IlIlllIIII:WaitForChild("\087\111\114\108\100", 0xA)
local _llIllllIII    = ReplicatedStorage:WaitForChild("\071\097\109\101\109\111\100\101\115", 0xA)


-- ====================================================================
--                      0x3. ESTADO GLOBAL / VARIÁVEIS
-- ====================================================================
local _lIIlIlIIIl = "\065\110\105\109\101\032\083\119\111\114\100\032\071\097\109\101"
pcall(function()
    _lIIlIlIIIl = _IIIlIIllIl:GetProductInfo(game.PlaceId).Name
end)

local _IIlIlllllI = {
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
        ["\084\114\105\097\108\032\069\097\115\121"]      = 0xA,
        ["\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101"] = 0x32,
        ["\078\097\109\101\107\032\073\110\118\097\115\105\111\110"]  = 0xF
    },
    
    FastDelay              = 0x0, -- Velocidade máxima
    GamemodeDelay          = 0.01,
    WorldFarmDelay         = 0.5
}

local _IlllllIIlI = {
    "\069\110\101\114\103\121",
    "\067\111\105\110\115",
    "\068\097\109\097\103\101",
    "\076\117\099\107",
    "\069\120\112"
}

local _lIIIlIIIll = {
    "\078\105\110\106\097\032\073\115\108\097\110\100\032\040\087\049\041",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100\032\040\087\050\041",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100\032\040\087\051\041",
    "\078\097\109\101\107\032\073\115\108\097\110\100\032\040\087\052\041"
}

local _lIlIIlIIII = {
    "\078\105\110\106\097\032\073\115\108\097\110\100",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100",
    "\078\097\109\101\107\032\073\115\108\097\110\100"
}

local _lIIIIlIllI = {
    ["\084\114\105\097\108\032\069\097\115\121"]      = "\084\114\105\097\108\069\097\115\121",
    ["\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101"] = "\073\110\102\105\110\105\116\101\067\097\115\116\108\101",
    ["\078\097\109\101\107\032\073\110\118\097\115\105\111\110"]  = "\078\097\109\101\107\032\073\110\118\097\115\105\111\110"
}

local _IIlIlllllI = {
    "\078\105\110\106\097\032\073\115\108\097\110\100\032\040\087\049\041",
    "\080\105\114\097\116\101\032\073\115\108\097\110\100\032\040\087\050\041",
    "\083\108\097\121\101\114\032\073\115\108\097\110\100\032\040\087\051\041",
    "\078\097\109\101\107\032\073\115\108\097\110\100\032\040\087\052\041"
}

local _IlllIlllIl = {
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

local _lIIlIIIIlI = {
    "\084\114\105\097\108\032\069\097\115\121\032\040\076\111\098\098\121\041",
    "\073\110\102\105\110\105\116\101\032\067\097\115\116\108\101\032\040\087\051\041",
    "\078\097\109\101\107\032\073\110\118\097\115\105\111\110\032\040\087\052\041"
}


-- ====================================================================
--                      0x4. INTERFACE GRÁFICA (UI)
-- ====================================================================
local _IIIlIIllII = _IIllIlIllI:CreateWindow({
    Title       = "\084\104\101\032\067\114\111\119\110\032\073\110\099",
    SubTitle    = _lIIlIlIIIl,
    TabWidth    = 0xA0,
    Size        = UDim2.fromOffset(0x244, 0x208),
    Acrylic     = true,
    Theme       = "\068\097\114\107",
    MinimizeKey = Enum.KeyCode.RightControl
})

local _lIlIIIIIIl = {
    AutoFarm  = _IIIlIIllII:AddTab({ Title = "\065\117\116\111\032\070\097\114\109",   Icon = "\115\119\111\114\100" }),
    Player    = _IIIlIIllII:AddTab({ Title = "\080\108\097\121\101\114\032\070\097\114\109", Icon = "\117\115\101\114" }),
    Gachas    = _IIIlIIllII:AddTab({ Title = "\071\097\099\104\097\115\032\038\032\083\121\115\116\101\109\115", Icon = "\115\116\097\114" }),
    Gamemodes = _IIIlIIllII:AddTab({ Title = "\071\097\109\101\109\111\100\101\115",        Icon = "\103\097\109\101\112\097\100" }),
    Settings  = _IIIlIIllII:AddTab({ Title = "\083\101\116\116\105\110\103\115",         Icon = "\115\101\116\116\105\110\103\115" })
}


-- ====================================================================
--                  [FUNÇÕES AUXILIARES DE LEITURA E LOCALIZAÇÃO]
-- ====================================================================

local function _IIlIllllII(mobModel)
    local _IlllIIIllI = mobModel:FindFirstChild("\072\101\097\100") or mobModel:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    
    if _IlllIIIllI and _IlllIIIllI:IsA("\066\097\115\101\080\097\114\116") then
        local _IlllIIlllI, _IIllIllllI = pcall(function()
            return _IlllIIIllI.AssemblyRootPart
        end)
        
        if _IlllIIlllI and _IIllIllllI then
            return _IIllIllllI.Name
        end
    end
    
    return mobModel.Name
end

local function _IlIIIlIIIl(mobModel)
    if not mobModel or not mobModel.Parent then return false end
    
    local _IIIIIIlIll = mobModel:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
    local _IIllIllllI = mobModel:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mobModel:FindFirstChild("\072\101\097\100") or mobModel.PrimaryPart
    
    if not _IIIIIIlIll or _IIIIIIlIll.Health <= 0x0 then return false end
    if not _IIllIllllI or not _IIllIllllI:IsA("\066\097\115\101\080\097\114\116") then return false end
    
    return true
end

local function _lIIlIlIIIl()
    local _IlIIIlllIl = _IlIlIllIlI.Character
    local _IIllIllllI = _IlIIIlllIl and _IlIIIlllIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    if not _IIllIllllI or not _lIIlIIIIIl then return _IIlIlllllI.SelectedWorldMobFolder or "\068\101\115\099\111\110\104\101\099\105\100\097" end

    local _IllllIlllI = _IIlIlllllI.SelectedWorldMobFolder or "\068\101\115\099\111\110\104\101\099\105\100\097"
    local _lIlIIllIlI = math.huge

    for _, folderName in ipairs(_lIlIIlIIII) do
        local _IlIIlIIlll = _lIIlIIIIIl:FindFirstChild(folderName)
        if _IlIIlIIlll then
            for _, mob in ipairs(_IlIIlIIlll:GetChildren()) do
                local _lllIIlllIl = mob:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mob:FindFirstChild("\072\101\097\100")
                if _lllIIlllIl then
                    local _IllIIllIll = (_lllIIlllIl.Position - _IIllIllllI.Position).Magnitude
                    if _IllIIllIll < _lIlIIllIlI then
                        _lIlIIllIlI = _IllIIllIll
                        _IllllIlllI = folderName
                    end
                end
            end
        end
    end

    return _IllllIlllI
end


-- ====================================================================
--                  [ABA 0x1: AUTO FARM - WORLD MOBS]
-- ====================================================================

local _lIlIIIlIll = _lIlIIIIIIl.AutoFarm:AddSection("\087\111\114\108\100\032\069\110\101\109\105\101\115\032\065\117\116\111\032\070\097\114\109")

local _IIlllIllll = _lIlIIIlIll:AddDropdown("\087\111\114\108\100\070\111\108\100\101\114\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\097\032\080\097\115\116\097\032\100\111\032\087\111\114\108\100",
    Description = "\069\115\099\111\108\104\097\032\100\101\032\113\117\097\108\032\105\108\104\097\032\100\101\115\101\106\097\032\098\117\115\099\097\114\032\111\115\032\109\111\098\115",
    Values      = _lIlIIlIIII,
    Multi       = false,
    Default     = "\080\105\114\097\116\101\032\073\115\108\097\110\100",
    Callback    = function(Value)
        _IIlIlllllI.SelectedWorldMobFolder = Value
    end
})

local _IIllllIIlI = _lIlIIIlIll:AddDropdown("\069\110\101\109\121\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\111\032\073\110\105\109\105\103\111",
    Description = "\077\111\098\032\097\108\118\111\032\112\097\114\097\032\097\117\116\111\032\102\097\114\109",
    Values      = {"\078\101\110\104\117\109\032\077\097\112\112\101\100"},
    Multi       = false,
    Default     = nil,
    Callback    = function(Value)
        if Value then
            local _lIllIIIllI = Value:gsub("\037\115\042\037\040\091\037\119\037\115\093\043\037\041", "")
            _IIlIlllllI.SelectedMobName = _lIllIIIllI
        end
    end
})

local function _IllIIIlIll()
    if not _lIIlIIIIIl then return end
    local _llllIIIIIl = _lIIlIIIIIl:FindFirstChild(_IIlIlllllI.SelectedWorldMobFolder)
    local _lllIIlIlll = {}
    local _IIIIIIIIlI = {}

    if _llllIIIIIl then
        for _, mob in ipairs(_llllIIIIIl:GetChildren()) do
            local _IlllllllII = _IIlIllllII(mob)

            if _IlllllllII and _IlllllllII ~= "" and not _lllIIlIlll[_IlllllllII] then
                _lllIIlIlll[_IlllllllII] = true
                table.insert(_IIIIIIIIlI, _IlllllllII .. "\032\040" .. _IIlIlllllI.SelectedWorldMobFolder .. "\041")
            end
        end
    end

    if #_IIIIIIIIlI == 0x0 then
        table.insert(_IIIIIIIIlI, "\078\101\110\104\117\109\032\077\111\098\032\069\110\099\111\110\116\114\097\100\111")
    end

    _IIllllIIlI:SetValues(_IIIIIIIIlI)
    _IIllllIIlI:SetValue(_IIIIIIIIlI[0x1])
end

_lIlIIIlIll:AddButton({
    Title       = "\082\101\102\114\101\115\104\032\077\111\098\115",
    Description = "\065\116\117\097\108\105\122\097\032\097\032\108\105\115\116\097\032\100\101\032\105\110\105\109\105\103\111\115\032\100\097\032\105\108\104\097\032\115\101\108\101\099\105\111\110\097\100\097",
    Callback    = function()
        _IllIIIlIll()
    end
})

_lIlIIIlIll:AddToggle("\065\117\116\111\087\111\114\108\100\070\097\114\109\084\111\103\103\108\101", {
    Title       = "\065\116\105\118\097\114\032\065\117\116\111\032\070\097\114\109\032\087\111\114\108\100",
    Description = "\084\101\108\101\112\111\114\116\097\032\105\110\115\116\097\110\116\097\110\101\097\109\101\110\116\101\032\112\097\114\097\032\111\032\109\111\098\032\118\105\118\111\032\109\097\105\115\032\112\114\243\120\105\109\111\032\100\111\032\116\105\112\111\032\115\101\108\101\099\105\111\110\097\100\111",
    Default     = false,
    Callback    = function(Value)
        _IIlIlllllI.AutoFarmWorldMobs = Value
    end
})

local function _IIIlIlIIll()
    if not _lIIlIIIIIl then return nil end
    local _IIlIlIllIl = _lIIlIIIIIl:FindFirstChild(_IIlIlllllI.SelectedWorldMobFolder)
    if not _IIlIlIllIl or not _IIlIlllllI.SelectedMobName then return nil end

    local _IlIIIlllIl = _IlIlIllIlI.Character
    local _IIllIllllI = _IlIIIlllIl and _IlIIIlllIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
    if not _IIllIllllI then return nil end

    local _IIlIlIlIII = nil
    local _IlIllllIII = math.huge

    for _, mob in ipairs(_IIlIlIllIl:GetChildren()) do
        if _IlIIIlIIIl(mob) then
            local _lIlllIlIII = _IIlIllllII(mob)
            if _lIlllIlIII:lower() == _IIlIlllllI.SelectedMobName:lower() then
                local _lllIIlllIl = mob:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or mob:FindFirstChild("\072\101\097\100") or mob.PrimaryPart
                if _lllIIlllIl then
                    local _IllIIllIll = (_lllIIlllIl.Position - _IIllIllllI.Position).Magnitude
                    if _IllIIllIll < _IlIllllIII then
                        _IlIllllIII = _IllIIllIll
                        _IIlIlIlIII = mob
                    end
                end
            end
        end
    end

    return _IIlIlIlIII
end

-- Loop Auto Farm World (0x0.5s)
task.spawn(function()
    while true do
        task.wait(_IIlIlllllI.WorldFarmDelay)
        if _IIlIlllllI.AutoFarmWorldMobs then
            pcall(function()
                local _lIllIIIIll = _IIIlIlIIll()
                if _lIllIIIIll and _IlIIIlIIIl(_lIllIIIIll) then
                    local _IlIIIlllIl = _IlIlIllIlI.Character
                    local _IIllIllllI = _IlIIIlllIl and _IlIIIlllIl:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
                    local _lllIIlllIl = _lIllIIIIll:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") or _lIllIIIIll:FindFirstChild("\072\101\097\100") or _lIllIIIIll.PrimaryPart

                    if _IIllIllllI and _lllIIlllIl then
                        _IIllIllllI.AssemblyLinearVelocity = Vector3.zero
                        _IIllIllllI.AssemblyAngularVelocity = Vector3.zero
                        _IIllIllllI.CFrame = _lllIIlllIl.CFrame * CFrame.new(0x0, 1.5, 1.8)
                    end
                end
            end)
        end
    end
end)


-- ====================================================================
--                  [ABA 0x2: PLAYER FARM & STATS]
-- ====================================================================

local _IllIlIlIll = _lIlIIIIIIl.Player:AddSection("\080\108\097\121\101\114\032\070\117\110\099\116\105\111\110\115")

_IllIlIlIll:AddToggle("\065\117\116\111\065\116\116\097\099\107\084\117\114\098\111\084\111\103\103\108\101", {
    Title       = "\065\117\116\111\032\065\116\116\097\099\107\032\084\117\114\098\111",
    Description = "\068\105\115\112\097\114\097\032\111\032\114\101\109\111\116\101\032\100\101\032\097\116\097\113\117\101\032\101\109\032\118\101\108\111\099\105\100\097\100\101\032\109\225\120\105\109\097\032\040\097\032\099\097\100\097\032\102\114\097\109\101\041",
    Default     = false,
    Callback    = function(Value)
        _IIlIlllllI.AutoAttackTurbo = Value
    end
})

_IllIlIlIll:AddToggle("\065\117\116\111\082\097\110\107\085\112\084\111\103\103\108\101", {
    Title       = "\065\117\116\111\032\082\097\110\107\032\085\112",
    Description = "\082\101\097\108\105\122\097\032\111\032\117\112\103\114\097\100\101\032\100\101\032\082\097\110\107\032\097\117\116\111\109\097\116\105\099\097\109\101\110\116\101",
    Default     = false,
    Callback    = function(Value)
        _IIlIlllllI.AutoRankUp = Value
    end
})

-- Seção: Stats Level Upgrades
local _IlIIlIIllI = _lIlIIIIIIl.Player:AddSection("\083\116\097\116\115\032\085\112\103\114\097\100\101\115")

_IlIIlIIllI:AddDropdown("\083\116\097\116\083\101\108\101\099\116\111\114", {
    Title       = "\083\101\108\101\099\105\111\110\101\032\111\032\065\116\114\105\098\117\116\111",
    Description = "\069\115\099\111\108\104\097\032\113\117\097\108\032\115\116\097\116\032\100\101\115\101\106\097\032\101\118\111\108\117\105\114",
    Values      = _IlllllIIlI,
    Multi       = false,
    Default     = "\069\110\101\114\103\121",
    Callback    = function(Value)
        _IIlIlllllI.SelectedStat = Value
    end
})

_IlIIlIIllI:AddToggle("\065\117\116\111\085\112\103\114\097\100\101\083\116\097\116\084\111\103\103\108\101", {
    Title       = "\065\116\105\118\097\114\032\065\117\116\111\032\085\112\103\114\097\100\101\032\083\116\097\116",
    Description = "\069\118\111\108\117\105\032\111\032\097\116\114\105\098\117\116\111\032\115\101\108\101\099\105\111\110\097\100\111\032\097\117\116\111\109\097\116\105\099\097\109\101\110\116\101",
    Default     = false,
    Callback    = function(Value)
        _IIlIlllllI.AutoUpgradeStat = Value
    end
})

-- Loop Auto Upgrade Stat
task.spawn(function()
    while true do
        task.wait(0.1)
        if _IIlIlllllI.AutoUpgradeStat and _IIlIlllllI.SelectedStat and _lIlIlIllII then
            pcall(function()
                _lIlIlIllII:FireServer(
                    "\071\101\110\101\114\097\108",
                    "\076\101\118\101\108\085\112\103\114\097\100\101\115",
                    "\085\112\103\114\097\100\101",
                    _IIlIlllllI.SelectedStat,
                    0x1
                )
         
