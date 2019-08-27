--0.10

_G.SDK =
{
    Version = '0.10',
    Load = {},
    Draw = {},
    Tick = {},
    FastTick = {},
    WndMsg = {},
    DAMAGE_TYPE_PHYSICAL = 0,
    DAMAGE_TYPE_MAGICAL = 1,
    DAMAGE_TYPE_TRUE = 2,
    ORBWALKER_MODE_NONE = -1,
    ORBWALKER_MODE_COMBO = 0,
    ORBWALKER_MODE_HARASS = 1,
    ORBWALKER_MODE_LANECLEAR = 2,
    ORBWALKER_MODE_JUNGLECLEAR = 3,
    ORBWALKER_MODE_LASTHIT = 4,
    ORBWALKER_MODE_FLEE = 5,
}
--https://discord.gg/wXfvEKV
-- global to local
local myHero, os, math, Game, Vector, Control, Draw, table, pairs, GetTickCount = myHero, os, math, Game, Vector, Control, Draw, table, pairs, GetTickCount

-- local classes
local Color, Menu, Action, Object, Target, Orbwalker, Item, Buff, Damage, Cursor, Health, Math, Data, Spell, Attack

--OK
Color =
{
    LightGreen =
    Draw.Color(255, 144, 238, 144),
    
    OrangeRed =
    Draw.Color(255, 255, 69, 0),
    
    Black =
    Draw.Color(255, 0, 0, 0),
    
    Red =
    Draw.Color(255, 255, 0, 0),
    
    Yellow =
    Draw.Color(255, 255, 255, 0),
    
    DarkRed =
    Draw.Color(255, 204, 0, 0),
    
    AlmostLastHitable =
    Draw.Color(255, 239, 159, 55),
    
    LastHitable =
    Draw.Color(255, 255, 255, 255),
    
    Range =
    Draw.Color(150, 49, 210, 0),
    
    EnemyRange =
    Draw.Color(150, 255, 0, 0),
    
    Cursor =
    Draw.Color(255, 0, 255, 0),
}

--OK
Menu =
{
    Main =
    nil,
    
    Target =
    nil,
    
    Orbwalker =
    nil,
}

function Menu:Init
    ()
    self.Main = MenuElement({id = 'GamsteronProject', name = 'GSO Project', type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GOS-External/master/Icons/rsz_gsoorbwalker.png"})
    
    self.Target = self.Main:MenuElement({id = 'Target', name = 'Target Selector', type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GOS-External/master/Icons/ts.png"})
    self.Target:MenuElement({id = 'Priorities', name = 'Priorities', type = MENU})
    self.Target:MenuElement({id = 'SelectedTarget', name = 'Selected Target', value = true})
    self.Target:MenuElement({id = 'OnlySelectedTarget', name = 'Only Selected Target', value = false})
    self.Target:MenuElement({id = 'SortMode' .. myHero.charName, name = 'Sort Mode', value = 1, drop = {'Auto', 'Closest', 'Near Mouse', 'Lowest HP', 'Lowest MaxHP', 'Highest Priority', 'Most Stack', 'Most AD', 'Most AP', 'Less Cast', 'Less Attack'}})
    
    self.Orbwalker = self.Main:MenuElement({id = 'Orbwalker', name = 'Orbwalker', type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GOS-External/master/Icons/orb.png"})
    self.Orbwalker:MenuElement({id = 'Keys', name = 'Keys', type = MENU})
    self.Orbwalker.Keys:MenuElement({id = 'Combo', name = 'Combo Key', key = string.byte(' ')})
    self.Orbwalker.Keys:MenuElement({id = 'Harass', name = 'Harass Key', key = string.byte('C')})
    self.Orbwalker.Keys:MenuElement({id = 'LastHit', name = 'LastHit Key', key = string.byte('X')})
    self.Orbwalker.Keys:MenuElement({id = 'LaneClear', name = 'LaneClear Key', key = string.byte('V')})
    self.Orbwalker.Keys:MenuElement({id = 'Jungle', name = 'Jungle Key', key = string.byte('V')})
    self.Orbwalker.Keys:MenuElement({id = 'Flee', name = 'Flee Key', key = string.byte('A')})
    self.Orbwalker.Keys:MenuElement({id = 'HoldKey', name = 'Hold Key', key = string.byte('H'), tooltip = 'Should be same in game keybinds'})
    self.Orbwalker:MenuElement({id = 'General', name = 'General', type = MENU})
    self.Orbwalker.General:MenuElement({id = 'AttackTargetKeyUse', name = 'Attack Target Key Use', value = false})
    self.Orbwalker.General:MenuElement({id = 'AttackTKey', name = 'Attack Target Key', key = string.byte('U'), tooltip = 'You should bind this one in ingame settings'})
    self.Orbwalker.General:MenuElement({id = 'AttackResetting', name = 'Attack Resetting', value = true})
    self.Orbwalker.General:MenuElement({id = 'FastKiting', name = 'Fast Kiting', value = true})
    self.Orbwalker.General:MenuElement({id = 'LaneClearHeroes', name = 'LaneClear Heroes', value = true})
    self.Orbwalker.General:MenuElement({id = 'StickToTarget', name = 'Stick To Target: Only Melee', value = false})
    self.Orbwalker.General:MenuElement({id = 'SkipTargets', name = 'Move Around Targets', value = false})
    self.Orbwalker.General:MenuElement({id = 'MovementDelay', name = 'Movement Delay', value = 250, min = 150, max = 500, step = 50})
    self.Orbwalker.General:MenuElement({id = 'HoldRadius', name = 'Hold Radius', value = 0, min = 0, max = 250, step = 10})
    self.Orbwalker.General:MenuElement({id = 'ExtraWindUpTime', name = 'Extra WindUpTime', value = 0, min = -25, max = 75, step = 5})
    self.Orbwalker:MenuElement({id = 'RandomHumanizer', name = 'Random Humanizer', type = MENU})
    self.Orbwalker.RandomHumanizer:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
    self.Orbwalker.RandomHumanizer:MenuElement({id = 'Min', name = 'Min', value = 160, min = 150, max = 300, step = 10})
    self.Orbwalker.RandomHumanizer:MenuElement({id = 'Max', name = 'Max', value = 240, min = 150, max = 400, step = 10})
    self.Orbwalker:MenuElement({id = 'Farming', name = 'Farming Settings', type = MENU})
    self.Orbwalker.Farming:MenuElement({id = 'LastHitPriority', name = 'Priorize Last Hit over Harass', value = true})
    self.Orbwalker.Farming:MenuElement({id = 'PushPriority', name = 'Priorize Push over Freeze', value = true})
    self.Orbwalker.Farming:MenuElement({id = 'ExtraFarmDelay', name = 'ExtraFarmDelay', value = 0, min = -80, max = 80, step = 10})
    
    self.Main:MenuElement({id = 'Items', name = 'Items', type = MENU, leftIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/a/aa/Ace_in_the_Hole.png"})
    self.Main.Items:MenuElement({id = 'Qss', name = 'Qss', type = MENU})
    self.Main.Items.Qss:MenuElement({id = 'BuffTypes', name = 'Buff Types', type = MENU})
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Slow', name = 'Slow: nasus w', value = true})--SLOW = 10 -> nasus W, zilean E
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Stun', name = 'Stun: sona r', value = true})--STUN = 5
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Snare', name = 'Snare: xayah e', value = true})--SNARE = 11
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Supress', name = 'Supress: warwick r', value = true})--SUPRESS = 24
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Knockup', name = 'Knockup: yasuo q3', value = true})--KNOCKUP = 29
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Fear', name = 'Fear: fiddle q', value = true})--FEAR = 21 -> fiddle Q, ...
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Charm', name = 'Charm: ahri e', value = true})--CHARM = 22 -> ahri E, ...
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Taunt', name = 'Taunt: rammus e', value = true})--TAUNT = 8 -> rammus E, ...
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Knockback', name = 'Knockback: alistar w', value = true})--KNOCKBACK = 30 -> alistar W, lee sin R, ...
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Blind', name = 'Blind: teemo q', value = true})--BLIND = 25 -> teemo Q
    self.Main.Items.Qss.BuffTypes:MenuElement({id = 'Disarm', name = 'Disarm: lulu w', value = true})--DISARM = 31 -> Lulu W
    self.Main.Items.Qss:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
    self.Main.Items.Qss:MenuElement({id = 'Count', name = 'Enemies Count', value = 1, min = 0, max = 5, step = 1})
    self.Main.Items.Qss:MenuElement({id = 'Distance', name = 'Enemies Distance < X', value = 1200, min = 0, max = 1500, step = 50})
    self.Main.Items.Qss:MenuElement({id = 'Duration', name = 'Buff Duration > X', value = 500, min = 0, max = 1000, step = 50})
    self.Main.Items:MenuElement({id = 'Botrk', name = 'Botrk', type = MENU})
    self.Main.Items.Botrk:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
    self.Main.Items.Botrk:MenuElement({id = 'AntiMelee', name = 'Anti Melee', value = true})
    self.Main.Items.Botrk:MenuElement({id = 'HeroHealth', name = 'Hero Health % < X', value = 50, min = 0, max = 100, step = 1})
    self.Main.Items.Botrk:MenuElement({id = 'TargetDistance', name = 'Target Distance < X', value = 0, min = 0, max = 650, step = 10})
    self.Main.Items.Botrk:MenuElement({id = 'FleeRange', name = 'Flee Target Distance > X', value = 550, min = 300, max = 600, step = 10})
    self.Main.Items.Botrk:MenuElement({id = 'FleeHealth', name = 'Flee Target Health % < X', value = 50, min = 0, max = 100, step = 1})
    self.Main.Items:MenuElement({id = 'HexGun', name = 'Hex Gunblade', type = MENU})
    self.Main.Items.HexGun:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
    self.Main.Items.HexGun:MenuElement({id = 'AntiMelee', name = 'Anti Melee', value = true})
    self.Main.Items.HexGun:MenuElement({id = 'HeroHealth', name = 'Hero Health % < X', value = 50, min = 0, max = 100, step = 1})
    self.Main.Items.HexGun:MenuElement({id = 'TargetDistance', name = 'Target Distance < X', value = 300, min = 0, max = 700, step = 10})
    self.Main.Items.HexGun:MenuElement({id = 'FleeRange', name = 'Flee Target Distance > X', value = 550, min = 300, max = 600, step = 10})
    self.Main.Items.HexGun:MenuElement({id = 'FleeHealth', name = 'Flee Target Health % < X', value = 50, min = 0, max = 100, step = 1})
    
    self.Main:MenuElement({id = 'Drawings', name = 'Drawings', type = MENU, leftIcon = "https://raw.githubusercontent.com/gamsteron/GOS-External/master/Icons/circles.png"})
    self.Main.Drawings:MenuElement({id = 'Enabled', name = 'Enabled', value = true})
    self.Main.Drawings:MenuElement({id = 'Cursor', name = 'Cursor', value = true})
    self.Main.Drawings:MenuElement({id = 'Range', name = 'AutoAttack Range', value = true})
    self.Main.Drawings:MenuElement({id = 'EnemyRange', name = 'Enemy AutoAttack Range', value = true})
    self.Main.Drawings:MenuElement({id = 'HoldRadius', name = 'Hold Radius', value = false})
    self.Main.Drawings:MenuElement({id = 'LastHittableMinions', name = 'Last Hittable Minions', value = true})
    self.Main.Drawings:MenuElement({id = 'SelectedTarget', name = 'Selected Target', value = true})
    
    self.Main:MenuElement({name = '', type = _G.SPACE, id = 'GeneralSpace'})
    self.Main:MenuElement({id = 'Latency', name = 'Latency', value = 50, min = 0, max = 120, step = 1, callback = function(value) _G.LATENCY = value end})
    self.Main:MenuElement({id = 'CursorDelay', name = 'Cursor Delay', value = 30, min = 30, max = 50, step = 5})
    
    self.Main:MenuElement({name = '', type = _G.SPACE, id = 'VersionSpaceA'})
    self.Main:MenuElement({name = 'Version  ' .. SDK.Version, type = _G.SPACE, id = 'VersionSpaceB'})
    
    _G.LATENCY = self.Main.Latency:Value()
end

--OK
Action =
{
    Tasks =
    {
    },
}

function Action:Init
    ()
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Action:OnLoad
    ()
    
    table.insert(SDK.FastTick, function()
        for i, task in pairs(self.Tasks) do
            if os.clock() >= task[2] then
                if task[1]() or os.clock() >= task[3] then
                    table.remove(self.Tasks, i)
                end
            end
        end
    end)
end

function Action:Add
    (task, startTime, endTime)
    
    startTime = startTime or 0
    endTime = endTime or 10000
    table.insert(self.Tasks, {task, os.clock() + startTime, os.clock() + startTime + endTime})
end

--OK
Object =
{
    UndyingBuffs =
    {
        ['zhonyasringshield'] = true,
        ['kindredrnodeathbuff'] = true,
        ['ChronoShift'] = true,
        ['UndyingRage'] = true,
        ['JaxCounterStrike'] = true,
    },
    
    AllyBuildings =
    {
    },
    
    EnemyBuildings =
    {
    },
    
    AllyHeroesInGame =
    {
    },
    
    EnemyHeroesInGame =
    {
    },
    
    EnemyHeroCb =
    {
    },
    
    AllyHeroCb =
    {
    },
    
    IsKalista =
    myHero.charName == "Kalista",
    
    IsCaitlyn =
    myHero.charName == "Caitlyn",
    
    IsRiven =
    myHero.charName == "Riven",
    
    IsKindred =
    myHero.charName == "Kindred",
}

function Object:Init
    ()
    self:OnEnemyHeroLoad(function(args)
        if args.CharName == 'Kayle' then
            self.UndyingBuffs['JudicatorIntervention'] = true
            return
        end
        if args.CharName == 'Taric' then
            self.UndyingBuffs['TaricR'] = true
            return
        end
        if args.CharName == 'Kindred' then
            self.UndyingBuffs['kindredrnodeathbuff'] = true
            return
        end
        if args.CharName == 'Zilean' then
            self.UndyingBuffs['ChronoShift'] = true
            self.UndyingBuffs['chronorevive'] = true
            return
        end
        if args.CharName == 'Tryndamere' then
            self.UndyingBuffs['UndyingRage'] = true
            return
        end
        if args.CharName == 'Jax' then
            self.UndyingBuffs['JaxCounterStrike'] = true
            return
        end
        if args.CharName == 'Fiora' then
            self.UndyingBuffs['FioraW'] = true
            return
        end
        if args.CharName == 'Aatrox' then
            self.UndyingBuffs['aatroxpassivedeath'] = true
            return
        end
        if args.CharName == 'Vladimir' then
            self.UndyingBuffs['VladimirSanguinePool'] = true
            return
        end
        if args.CharName == 'KogMaw' then
            self.UndyingBuffs['KogMawIcathianSurprise'] = true
            return
        end
        if args.CharName == 'Karthus' then
            self.UndyingBuffs['KarthusDeathDefiedBuff'] = true
            return
        end
    end)
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Object:OnLoad
    ()
    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        if object and (object.type == Obj_AI_Barracks or object.type == Obj_AI_Nexus) then
            if object.isEnemy then
                table.insert(self.EnemyBuildings, object)
            elseif object.isAlly then
                table.insert(self.AllyBuildings, object)
            end
        end
    end
    Action:Add(function()
        local success = false
        for i = 1, Game.HeroCount() do
            local args = Data:GetHeroData(Game.Hero(i))
            if args.Valid and args.IsAlly and self.AllyHeroesInGame[args.NetworkID] == nil then
                self.AllyHeroesInGame[args.NetworkID] = true
                for j, func in pairs(self.AllyHeroCb) do
                    func(args)
                end
            end
            if args.Valid and args.IsEnemy and self.EnemyHeroesInGame[args.NetworkID] == nil then
                self.EnemyHeroesInGame[args.NetworkID] = true
                for j, func in pairs(self.EnemyHeroCb) do
                    func(args)
                end
                success = true
            end
        end
        return success
    end, 0, 100)
end

function Object:OnAllyHeroLoad
    (cb)
    table.insert(self.AllyHeroCb, cb)
end

function Object:OnEnemyHeroLoad
    (cb)
    table.insert(self.EnemyHeroCb, cb)
end

function Object:IsHeroImmortal
    (unit, jaxE)
    local hp
    hp = 100 * (unit.health / unit.maxHealth)
    self.UndyingBuffs['kindredrnodeathbuff'] = hp < 10
    self.UndyingBuffs['ChronoShift'] = hp < 15
    self.UndyingBuffs['chronorevive'] = hp < 15
    self.UndyingBuffs['UndyingRage'] = hp < 15
    self.UndyingBuffs['JaxCounterStrike'] = jaxE
    for buffName, isActive in pairs(self.UndyingBuffs) do
        if isActive and Buff:HasBuff(unit, buffName) then
            return true
        end
    end
    --[[ anivia passive, olaf R, ...
    if unit.isImmortal and not Buff:HasBuff(unit, 'willrevive') and not Buff:HasBuff(unit, 'zacrebirthready') then
        return true
    end--]]
    return false
end

function Object:IsValid
    (obj, type, visible, immortal, jaxE)
    if obj == nil then
        return false
    end
    local objID, objType
    objID = obj.networkID
    if objID == nil or objID <= 0 then
        return false
    end
    objType = obj.type
    if objType == nil or (type and type ~= objType) then
        return false
    end
    if (objType == Obj_AI_Hero or objType == Obj_AI_Minion or objType == Obj_AI_Turret) and not obj.valid then
        return false
    end
    if immortal then
        if objType == Obj_AI_Hero then
            if self:IsHeroImmortal(obj, jaxE) then
                return false
            end
        elseif obj.isImmortal then
            return false
        end
    end
    if (visible and not obj.visible) or obj.dead or not obj.isTargetable then
        return false
    end
    return true
end

function Object:GetObjectsFromTable
    (t, func)
    local result = {}
    for i, obj in pairs(t) do
        if func(obj) then
            table.insert(result, obj)
        end
    end
    return result
end

function Object:GetHeroes
    (range, bbox, visible, immortal, jaxE, func)
    local result = {}
    local a = self:GetEnemyHeroes(range, bbox, visible, immortal, jaxE, func)
    local b = self:GetAllyHeroes(range, bbox, visible, immortal, jaxE, func)
    for i = 1, #a do
        table.insert(result, a[i])
    end
    for i = 1, #b do
        table.insert(result, b[i])
    end
    return result
end

function Object:GetEnemyHeroes
    (range, bbox, visible, immortal, jaxE, func)
    local result = {}
    for i = 1, Game.HeroCount() do
        local obj = Game.Hero(i)
        if self:IsValid(obj, Obj_AI_Hero, visible, immortal, jaxE) and obj.isEnemy then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetAllyHeroes
    (range, bbox, visible, immortal, jaxE, func)
    local result = {}
    for i = 1, Game.HeroCount() do
        local obj = Game.Hero(i)
        if self:IsValid(obj, Obj_AI_Hero, visible, immortal, jaxE) and obj.isAlly then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    local a = self:GetEnemyMinions(range, bbox, visible, immortal, func)
    local b = self:GetAllyMinions(range, bbox, visible, immortal, func)
    for i = 1, #a do
        table.insert(result, a[i])
    end
    for i = 1, #b do
        table.insert(result, b[i])
    end
    return result
end

function Object:GetEnemyMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.MinionCount() do
        local obj = Game.Minion(i)
        if self:IsValid(obj, Obj_AI_Minion, visible, immortal) and obj.isEnemy and obj.team < 300 then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetAllyMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.MinionCount() do
        local obj = Game.Minion(i)
        if self:IsValid(obj, Obj_AI_Minion, visible, immortal) and obj.isAlly and obj.team < 300 then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetOtherMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    local a = self:GetOtherAllyMinions(range, bbox, visible, immortal, func)
    local b = self:GetOtherEnemyMinions(range, bbox, visible, immortal, func)
    for i = 1, #a do
        table.insert(result, a[i])
    end
    for i = 1, #b do
        table.insert(result, b[i])
    end
    return result
end

function Object:GetOtherAllyMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.WardCount() do
        local obj = Game.Ward(i)
        if self:IsValid(obj, nil, visible, immortal) and obj.isAlly then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetOtherEnemyMinions
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.WardCount() do
        local obj = Game.Ward(i)
        if self:IsValid(obj, nil, visible, immortal) and obj.isEnemy then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetMonsters
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.MinionCount() do
        local obj = Game.Minion(i)
        if self:IsValid(obj, Obj_AI_Minion, visible, immortal) and obj.team == 300 then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetTurrets
    (range, bbox, visible, immortal, func)
    local result = {}
    local a = self:GetEnemyTurrets(range, bbox, visible, immortal, func)
    local b = self:GetAllyTurrets(range, bbox, visible, immortal, func)
    for i = 1, #a do
        table.insert(result, a[i])
    end
    for i = 1, #b do
        table.insert(result, b[i])
    end
    return result
end

function Object:GetEnemyTurrets
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.TurretCount() do
        local obj = Game.Turret(i)
        if self:IsValid(obj, Obj_AI_Turret, visible, immortal) and obj.isEnemy then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetAllyTurrets
    (range, bbox, visible, immortal, func)
    local result = {}
    for i = 1, Game.TurretCount() do
        local obj = Game.Turret(i)
        if self:IsValid(obj, Obj_AI_Turret, visible, immortal) and obj.isAlly then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetEnemyBuildings
    (range, bbox, visible, immortal, func)
    local result = {}
    for i, obj in pairs(self.EnemyBuildings) do
        if self:IsValid(obj, nil, visible, immortal) then
            if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetAllyBuildings
    (range, bbox, visible, immortal, func)
    local result = {}
    for i, obj in pairs(self.AllyBuildings) do
        if self:IsValid(obj, nil, visible, immortal) then
            if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

function Object:GetAllStructures
    (range, bbox, visible, immortal, func)
    
    local result = {}
    for i, obj in pairs(self.AllyBuildings) do
        if self:IsValid(obj, nil, visible, immortal) then
            if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    for i, obj in pairs(self.EnemyBuildings) do
        if self:IsValid(obj, nil, visible, immortal) then
            if (not range or obj.distance < range + (bbox and Data:GetBuildingBBox(obj) or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    for i = 1, Game.TurretCount() do
        local obj = Game.Turret(i)
        if self:IsValid(obj, Obj_AI_Turret, visible, immortal) then
            if (not range or obj.distance < range + (bbox and obj.boundingRadius or 0)) and (not func or func(obj)) then
                table.insert(result, obj)
            end
        end
    end
    return result
end

--OK
Target =
{
    SelectionTick =
    0,
    
    Selected =
    nil,
    
    CurrentSort =
    nil,
    
    CurrentSortMode =
    0,
    
    CurrentDamage =
    nil,
    
    SORT_AUTO =
    1,
    
    SORT_CLOSEST =
    2,
    
    SORT_NEAR_MOUSE =
    3,
    
    SORT_LOWEST_HEALTH =
    4,
    
    SORT_LOWEST_MAX_HEALTH =
    5,
    
    SORT_HIGHEST_PRIORITY =
    6,
    
    SORT_MOST_STACK =
    7,
    
    SORT_MOST_AD =
    8,
    
    SORT_MOST_AP =
    9,
    
    SORT_LESS_CAST =
    10,
    
    SORT_LESS_ATTACK =
    11,
    
    ActiveStackBuffs =
    {
        'BraumMark',
    },
    
    StackBuffs =
    {
        ['Vayne'] = {'VayneSilverDebuff'},
        ['TahmKench'] = {'tahmkenchpdebuffcounter'},
        ['Kennen'] = {'kennenmarkofstorm'},
        ['Darius'] = {'DariusHemo'},
        ['Ekko'] = {'EkkoStacks'},
        ['Gnar'] = {'GnarWProc'},
        ['Kalista'] = {'KalistaExpungeMarker'},
        ['Kindred'] = {'KindredHitCharge', 'kindredecharge'},
        ['Tristana'] = {'tristanaecharge'},
        ['Twitch'] = {'TwitchDeadlyVenom'},
        ['Varus'] = {'VarusWDebuff'},
        ['Velkoz'] = {'VelkozResearchStack'},
        ['Vi'] = {'ViWProc'},
    },
}

function Target:Init
    ()
    self.MenuPriorities = Menu.Target.Priorities
    self.MenuDrawSelected = Menu.Main.Drawings.SelectedTarget
    self.MenuTableSortMode = Menu.Target['SortMode' .. myHero.charName]
    self.MenuCheckSelected = Menu.Target.SelectedTarget
    self.MenuCheckSelectedOnly = Menu.Target.OnlySelectedTarget
    
    Object:OnEnemyHeroLoad(function(args)
        local priority = Data:GetHeroPriority(args.CharName) or 1
        self.MenuPriorities:MenuElement({id = args.CharName, name = args.CharName, value = priority, min = 1, max = 5, step = 1})
    end)
    
    if self.StackBuffs[myHero.charName] then
        for i, buffName in pairs(self.StackBuffs[myHero.charName]) do
            table.insert(self.ActiveStackBuffs, buffName)
        end
    end
    
    self.SortModes =
    {
        [self.SORT_AUTO] = function(a, b)
            local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
            local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
            local aDef, bDef = 0, 0
            if self.CurrentDamage == Damage.DAMAGE_TYPE_MAGICAL then
                local magicPen, magicPenPercent = myHero.magicPen, myHero.magicPenPercent
                aDef = math.max(0, aMultiplier * (a.magicResist - magicPen) * magicPenPercent)
                bDef = math.max(0, bMultiplier * (b.magicResist - magicPen) * magicPenPercent)
            elseif self.CurrentDamage == Damage.DAMAGE_TYPE_PHYSICAL then
                local armorPen, bonusArmorPenPercent = myHero.armorPen, myHero.bonusArmorPenPercent
                aDef = math.max(0, aMultiplier * (a.armor - armorPen) * bonusArmorPenPercent)
                bDef = math.max(0, bMultiplier * (b.armor - armorPen) * bonusArmorPenPercent)
            end
            return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
        end,
        
        [self.SORT_CLOSEST] = function(a, b)
            return a.distance < b.distance
        end,
        
        [self.SORT_NEAR_MOUSE] = function(a, b)
            return a.pos:DistanceTo(Vector(mousePos)) < b.pos:DistanceTo(Vector(mousePos))
        end,
        
        [self.SORT_LOWEST_HEALTH] = function(a, b)
            return a.health < b.health
        end,
        
        [self.SORT_LOWEST_MAX_HEALTH] = function(a, b)
            return a.maxHealth < b.maxHealth
        end,
        
        [self.SORT_HIGHEST_PRIORITY] = function(a, b)
            return self:GetPriority(a) > self:GetPriority(b)
        end,
        
        [self.SORT_MOST_STACK] = function(a, b)
            local aMax = 0
            for i, buffName in pairs(self.ActiveStackBuffs) do
                local buff = Buff:GetBuff(a, buffName)
                if buff then
                    aMax = math.max(aMax, math.max(buff.Count, buff.Stacks))
                end
            end
            local bMax = 0
            for i, buffName in pairs(self.ActiveStackBuffs) do
                local buff = Buff:GetBuff(b, buffName)
                if buff then
                    bMax = math.max(bMax, math.max(buff.Count, buff.Stacks))
                end
            end
            return aMax > bMax
        end,
        
        [self.SORT_MOST_AD] = function(a, b)
            return a.totalDamage > b.totalDamage
        end,
        
        [self.SORT_MOST_AP] = function(a, b)
            return a.ap > b.ap
        end,
        
        [self.SORT_LESS_CAST] = function(a, b)
            local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
            local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
            local aDef, bDef = 0, 0
            local magicPen, magicPenPercent = myHero.magicPen, myHero.magicPenPercent
            aDef = math.max(0, aMultiplier * (a.magicResist - magicPen) * magicPenPercent)
            bDef = math.max(0, bMultiplier * (b.magicResist - magicPen) * magicPenPercent)
            return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
        end,
        
        [self.SORT_LESS_ATTACK] = function(a, b)
            local aMultiplier = 1.75 - self:GetPriority(a) * 0.15
            local bMultiplier = 1.75 - self:GetPriority(b) * 0.15
            local aDef, bDef = 0, 0
            local armorPen, bonusArmorPenPercent = myHero.armorPen, myHero.bonusArmorPenPercent
            aDef = math.max(0, aMultiplier * (a.armor - armorPen) * bonusArmorPenPercent)
            bDef = math.max(0, bMultiplier * (b.armor - armorPen) * bonusArmorPenPercent)
            return (a.health * aMultiplier * ((100 + aDef) / 100)) - a.ap - (a.totalDamage * a.attackSpeed * 2) < (b.health * bMultiplier * ((100 + bDef) / 100)) - b.ap - (b.totalDamage * b.attackSpeed * 2)
        end,
    }
    
    self.CurrentSortMode = self.MenuTableSortMode:Value()
    self.CurrentSort = self.SortModes[self.CurrentSortMode]
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Target:OnLoad
    ()
    table.insert(SDK.WndMsg, function(msg, wParam)
        if msg == WM_LBUTTONDOWN and self.MenuCheckSelected:Value() and GetTickCount() > self.SelectionTick + 100 then
            self.Selected = nil
            local num = 10000000
            local pos = Vector(mousePos)
            for i, unit in pairs(Object:GetEnemyHeroes(20000, false, true)) do
                if unit.pos:ToScreen().onScreen then
                    local distance = pos:DistanceTo(unit.pos)
                    if distance < 150 and distance < num then
                        self.Selected = unit
                        num = distance
                    end
                end
            end
            self.SelectionTick = GetTickCount()
        end
    end)
    
    table.insert(SDK.Draw, function()
        if self.MenuDrawSelected:Value() and Object:IsValid(self.Selected, Obj_AI_Hero, true) then
            Draw.Circle(self.Selected.pos, 150, 1, Color.DarkRed)
        end
    end)
    
    table.insert(SDK.Tick, function()
        local sortMode = self.MenuTableSortMode:Value()
        if sortMode ~= self.CurrentSortMode then
            self.CurrentSortMode = sortMode
            self.CurrentSort = self.SortModes[sortMode]
        end
    end)
end

function Target:GetTarget
    (a, dmgType, bbox, visible, immortal, jaxE, func)
    
    a = a or 20000
    dmgType = dmgType or 1
    self.CurrentDamage = dmgType
    visible = visible == nil and true or visible
    immortal = immortal == nil and true or immortal
    
    local only = self.MenuCheckSelectedOnly:Value()
    if self.MenuCheckSelected:Value() and Object:IsValid(self.Selected, Obj_AI_Hero, not only and visible, immortal, not only and jaxE) then
        if type(a) == 'number' then
            if self.Selected.distance < a + (bbox and self.Selected.boundingRadius or 0) then
                return self.Selected
            end
        else
            table.sort(a, function(i, j) return i.distance > j.distance end)
            if #a > 0 and self.Selected.distance <= a[1].distance then
                return self.Selected
            end
        end
        if only then
            return nil
        end
    end
    
    if type(a) == 'number' then
        a = Object:GetEnemyHeroes(a, bbox, visible, immortal, jaxE, func)
    end
    
    if self.CurrentSortMode == self.SORT_MOST_STACK then
        local stackA = Object:GetObjectsFromTable(a, function(unit)
            for i, buffName in pairs(self.ActiveStackBuffs) do
                if Buff:HasBuff(unit, buffName) then
                    return true
                end
            end
            return false
        end)
        local sortMode = (#stackA == 0 and self.SORT_AUTO or self.SORT_MOST_STACK)
        if sortMode == self.SORT_MOST_STACK then
            a = stackA
        end
        table.sort(a, self.SortModes[sortMode])
    else
        table.sort(a, self.CurrentSort)
    end
    
    return (#a == 0 and nil or a[1])
end

function Target:GetPriority
    (unit)
    local name = unit.charName
    if self.MenuPriorities[name] then
        return self.MenuPriorities[name]:Value()
    end
    if Data.HeroPriorities[name:lower()] then
        return Data.HeroPriorities[name:lower()]
    end
    return 1
end

function Target:GetKalistaTarget
    ()
    local range, radius, objects
    
    range = myHero.range - 35
    radius = myHero.boundingRadius
    
    objects = Object:GetEnemyMinions(range + radius, true, true, true)
    if #objects > 0 then
        return objects[1]
    end
    
    objects = Object:GetEnemyTurrets(range + radius, true, true, true)
    if #objects > 0 then
        return objects[1]
    end
    
    objects = Object:GetEnemyBuildings(range, true, true, true)
    if #objects > 0 then
        return objects[1]
    end
    
    return nil
end

function Target:GetComboTarget
    (dmgType)
    
    local t, range
    
    dmgType = dmgType or Damage.DAMAGE_TYPE_PHYSICAL
    range = myHero.range + myHero.boundingRadius - 35
    
    t = self:GetTarget(Object:GetEnemyHeroes(false, false, true, true, true, function(hero)
        if hero.distance < range + ((Object.IsCaitlyn and Buff:HasBuff(hero, 'caitlynyordletrapinternal')) and 600 or hero.boundingRadius) then
            return true
        end
        return false
    end), dmgType)
    
    if Object.IsKalista and t == nil then
        t = self:GetKalistaTarget()
    end
    
    return t
end

Orbwalker =
{
    CanHoldPosition = true,
    
    PostAttackTimer = 0,
    
    IsNone = true,
    ORBWALKER_MODE_NONE = SDK.ORBWALKER_MODE_NONE,
    ORBWALKER_MODE_COMBO = SDK.ORBWALKER_MODE_COMBO,
    ORBWALKER_MODE_HARASS = SDK.ORBWALKER_MODE_HARASS,
    ORBWALKER_MODE_LANECLEAR = SDK.ORBWALKER_MODE_LANECLEAR,
    ORBWALKER_MODE_JUNGLECLEAR = SDK.ORBWALKER_MODE_JUNGLECLEAR,
    ORBWALKER_MODE_LASTHIT = SDK.ORBWALKER_MODE_LASTHIT,
    ORBWALKER_MODE_FLEE = SDK.ORBWALKER_MODE_FLEE,
    
    OnPreAttackCb = {},
    OnPostAttackCb = {},
    OnPostAttackTickCb = {},
    OnAttackCb = {},
    OnMoveCb = {},
}

function Orbwalker:Init
    ()
    
    self.Menu = Menu.Orbwalker
    self.MenuDrawings = Menu.Main.Drawings
    self.HoldPositionButton = Menu.Orbwalker.Keys.HoldKey
    
    self.MenuKeys =
    {
        [self.ORBWALKER_MODE_COMBO] = {},
        [self.ORBWALKER_MODE_HARASS] = {},
        [self.ORBWALKER_MODE_LANECLEAR] = {},
        [self.ORBWALKER_MODE_JUNGLECLEAR] = {},
        [self.ORBWALKER_MODE_LASTHIT] = {},
        [self.ORBWALKER_MODE_FLEE] = {},
    }
    
    self.Modes =
    {
        [self.ORBWALKER_MODE_COMBO] = false,
        [self.ORBWALKER_MODE_HARASS] = false,
        [self.ORBWALKER_MODE_LANECLEAR] = false,
        [self.ORBWALKER_MODE_JUNGLECLEAR] = false,
        [self.ORBWALKER_MODE_LASTHIT] = false,
        [self.ORBWALKER_MODE_FLEE] = false,
    }
    
    self:RegisterMenuKey(self.ORBWALKER_MODE_COMBO, self.Menu.Keys.Combo)
    self:RegisterMenuKey(self.ORBWALKER_MODE_HARASS, self.Menu.Keys.Harass)
    self:RegisterMenuKey(self.ORBWALKER_MODE_LASTHIT, self.Menu.Keys.LastHit)
    self:RegisterMenuKey(self.ORBWALKER_MODE_LANECLEAR, self.Menu.Keys.LaneClear)
    self:RegisterMenuKey(self.ORBWALKER_MODE_JUNGLECLEAR, self.Menu.Keys.Jungle)
    self:RegisterMenuKey(self.ORBWALKER_MODE_FLEE, self.Menu.Keys.Flee)
    
    self.ForceMovement = nil
    self.ForceTarget = nil
    
    self.PostAttackBool = false
    self.AttackEnabled = true
    self.MovementEnabled = true
    self.CanAttackC = function() return true end
    self.CanMoveC = function() return true end
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Orbwalker:OnLoad
    ()
    
    table.insert(SDK.Draw, function()
        
        if self.MenuDrawings.Range:Value() then
            Draw.Circle(myHero.pos, Data:GetAutoAttackRange(myHero), 2, Color.Range)
        end
        
        if self.MenuDrawings.HoldRadius:Value() then
            Draw.Circle(myHero.pos, self.Menu.General.HoldRadius:Value(), 1, Color.LightGreen)
        end
        
        if self.MenuDrawings.EnemyRange:Value() then
            local t = Object:GetEnemyHeroes(false, false, true, false, false)
            for i = 1, #t do
                local enemy = t[i]
                local range = Data:GetAutoAttackRange(enemy, myHero)
                Draw.Circle(enemy.pos, range, 2, Math:IsInRange(enemy, myHero, range) and Color.EnemyRange or Color.Range)
            end
        end
    end)
    
    table.insert(SDK.FastTick, function()
        Attack:OnTick()
        
        self.IsNone = self:HasMode(self.ORBWALKER_MODE_NONE)
        self.Modes = self:GetModes()
        
        if Cursor.Step > 0 then
            return
        end
        
        if Data:Stop() then
            return
        end
        
        Health:OnTick()
        
        if self.IsNone then
            return
        end
        
        self:Orbwalk()
    end)
end

function Orbwalker:RegisterMenuKey
    (mode, key)
    --
    table.insert(self.MenuKeys[mode], key)
end

function Orbwalker:GetModes
    ()
    return {
        [self.ORBWALKER_MODE_COMBO] = self:HasMode(self.ORBWALKER_MODE_COMBO),
        [self.ORBWALKER_MODE_HARASS] = self:HasMode(self.ORBWALKER_MODE_HARASS),
        [self.ORBWALKER_MODE_LANECLEAR] = self:HasMode(self.ORBWALKER_MODE_LANECLEAR),
        [self.ORBWALKER_MODE_JUNGLECLEAR] = self:HasMode(self.ORBWALKER_MODE_JUNGLECLEAR),
        [self.ORBWALKER_MODE_LASTHIT] = self:HasMode(self.ORBWALKER_MODE_LASTHIT),
        [self.ORBWALKER_MODE_FLEE] = self:HasMode(self.ORBWALKER_MODE_FLEE),
    }
end

function Orbwalker:HasMode
    (mode)
    if mode == self.ORBWALKER_MODE_NONE then
        for _, value in pairs(self:GetModes()) do
            if value then
                return false
            end
        end
        return true
    end
    for i = 1, #self.MenuKeys[mode] do
        local key = self.MenuKeys[mode][i]
        if key:Value() then
            return true
        end
    end
    return false
end

function Orbwalker:OnPreAttack
    (func)
    table.insert(self.OnPreAttackCb, func)
end

function Orbwalker:OnPostAttack
    (func)
    table.insert(self.OnPostAttackCb, func)
end

function Orbwalker:OnPostAttackTick
    (func)
    table.insert(self.OnPostAttackTickCb, func)
end

function Orbwalker:OnAttack
    (func)
    table.insert(self.OnAttackCb, func)
end

function Orbwalker:OnPreMovement
    (func)
    table.insert(self.OnMoveCb, func)
end

function Orbwalker:CanAttackEvent
    (func)
    self.CanAttackC = func
end

function Orbwalker:CanMoveEvent
    (func)
    self.CanMoveC = func
end

function Orbwalker:__OnAutoAttackReset
    ()
    Attack.Reset = true
end

function Orbwalker:SetMovement
    (boolean)
    self.MovementEnabled = boolean
end

function Orbwalker:SetAttack
    (boolean)
    self.AttackEnabled = boolean
end

function Orbwalker:IsEnabled
    ()
    return true
end

function Orbwalker:IsAutoAttacking
    (unit)
    
    if unit == nil or unit.isMe then
        return Attack:IsActive()
    end
    
    return Game.Timer() < unit.attackData.endTime - unit.attackData.windDownTime
end

function Orbwalker:CanMove
    (unit)
    
    if unit == nil or unit.isMe then
        if not self.CanMoveC() then
            return false
        end
        if JustEvade or (ExtLibEvade and ExtLibEvade.Evading) then
            return false
        end
        if myHero.charName == 'Kalista' then
            return true
        end
        if not Data:HeroCanMove() then
            return false
        end
        return not Attack:IsActive()
    end
    
    local attackData = unit.attackData
    return Game.Timer() > attackData.endTime - attackData.windDownTime
end

function Orbwalker:CanAttack
    (unit)
    
    if unit == nil or unit.isMe then
        if not self.CanAttackC() then
            return false
        end
        if JustEvade or (ExtLibEvade and ExtLibEvade.Evading) then
            return false
        end
        if not Data:HeroCanAttack() then
            return false
        end
        return Attack:IsReady()
    end
    
    local attackData = unit.attackData
    return Game.Timer() > attackData.endTime
end

function Orbwalker:GetTarget
    ()
    
    if Object:IsValid(self.ForceTarget, Obj_AI_Hero, true, true, true) then
        return self.ForceTarget
    end
    
    if self.Modes[self.ORBWALKER_MODE_COMBO] then
        return Target:GetComboTarget()
    end
    
    if self.Modes[self.ORBWALKER_MODE_LASTHIT] then
        return Health:GetLastHitTarget()
    end
    
    if self.Modes[self.ORBWALKER_MODE_JUNGLECLEAR] then
        local jungle = Health:GetJungleTarget()
        if jungle ~= nil then
            return jungle
        end
    end
    
    if self.Modes[self.ORBWALKER_MODE_LANECLEAR] then
        return Health:GetLaneClearTarget()
    end
    
    if self.Modes[self.ORBWALKER_MODE_HARASS] then
        return Health:GetHarassTarget()
    end
    
    return nil
end

function Orbwalker:MeleeLogic
    ()
    local process, position, aarange, aatarget, aatarget150, mePos, hepos, distance, direction
    
    process = true
    position = nil
    aarange = myHero.range + myHero.boundingRadius - 35
    
    aatarget = Target:GetTarget(Object:GetEnemyHeroes(aarange, true, true, true, true), Damage.DAMAGE_TYPE_PHYSICAL)
    
    if aatarget == nil then
        return process, position
    end
    
    aatarget150 = Target:GetTarget(Object:GetEnemyHeroes(aarange + 150, true, true, true, true), Damage.DAMAGE_TYPE_PHYSICAL)
    
    if aatarget150 ~= nil then
        aatarget = aatarget150
    end
    
    distance = aatarget.distance
    if (distance < aatarget.boundingRadius + 30) then
        if self.CanHoldPosition then
            Control.Hold(self.HoldPositionButton:Key())
        end
        return false, nil
    end
    
    mePos = myHero.pos
    hepos = aatarget.pos
    direction = (hepos - mePos):Normalized()
    position = hepos + direction * 200
    
    local i = 0
    while (Cursor:IsCursorOnTarget(position)) do
        i = i + 50
        position = hepos + direction * i
    end
    
    return process, position
end

function Orbwalker:OnUnkillableMinion
    (cb)
    table.insert(Health.OnUnkillableMinionCallbacks, cb);
end

function Orbwalker:Attack
    (unit)
    
    if self.AttackEnabled and unit ~= nil and unit.pos ~= nil and unit.pos:ToScreen().onScreen and self:CanAttack() then
        local args = {Target = unit, Process = true}
        
        for i = 1, #self.OnPreAttackCb do
            self.OnPreAttackCb[i](args)
        end
        
        if args.Process then
            if args.Target and Control.Attack(args.Target) then
                Attack.Reset = false
                Attack.LocalStart = Game.Timer()
                self.PostAttackBool = true
            end
            return true
        end
    end
    
    return false
end

function Orbwalker:Move
    ()
    
    if self.MovementEnabled and self:CanMove() then
        if self.PostAttackBool then
            for i = 1, #self.OnPostAttackCb do
                self.OnPostAttackCb[i]()
            end
            self.PostAttackTimer = Game.Timer()
            self.PostAttackBool = false
        end
        
        if Game.Timer() < self.PostAttackTimer + 0.15 then
            for i = 1, #self.OnPostAttackTickCb do
                self.OnPostAttackTickCb[i]()
            end
        end
        
        local mePos = myHero.pos
        if Math:IsInRange(mePos, _G.mousePos, self.Menu.General.HoldRadius:Value()) then
            if self.CanHoldPosition then
                Control.Hold(self.HoldPositionButton:Key())
            end
            return
        end
        
        if GetTickCount() > Cursor.MoveTimer then
            local args = {Target = nil, Process = true}
            
            for i = 1, #self.OnMoveCb do
                self.OnMoveCb[i](args)
            end
            
            if not args.Process then
                return
            end
            
            if self.ForceMovement ~= nil then
                Control.Move(self.ForceMovement)
                return
            end
            
            if args.Target == nil then
                if self.Menu.General.StickToTarget:Value() and Data:IsMelee() and myHero.range < 450 then
                    local process, meleepos = self:MeleeLogic()
                    if not process then
                        return
                    end
                    Control.Move(meleepos)
                    return
                end
            else
                if args.Target.x then
                    args.Target = Vector(args.Target)
                elseif args.Target.pos then
                    args.Target = args.Target.pos
                end
                Control.Move(args.Target)
                return
            end
            
            local pos = Math:IsInRange(mePos, mousePos, 100) and mePos:Extend(mousePos, 100) or nil
            
            if self.Menu.General.SkipTargets:Value() then
                local i = 0
                local mPos = pos or mousePos
                local dir = (mPos - mePos):Normalized()
                
                while (Cursor:IsCursorOnTarget(mPos)) do
                    i = i + 50
                    mPos = mPos + dir * i
                    pos = mPos
                end
            end
            
            Control.Move(pos)
            
        end
    end
end

function Orbwalker:Orbwalk
    ()
    
    if not self:Attack(self:GetTarget()) then
        self:Move()
    end
end

--OK
Item =
{
    ItemSlots =
    {
        ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6, ITEM_7,
    },
    
    ItemKeys =
    {
        HK_ITEM_1, HK_ITEM_2, HK_ITEM_3, HK_ITEM_4, HK_ITEM_5, HK_ITEM_6, HK_ITEM_7
    },
    
    ItemBotrk =
    {
        3153, 3144, 3389,
    },
    
    ItemQss =
    {
        3139, 3140,
    },
    
    ItemGunblade = 3146,
    
    --[[
    ITEM_HYDRA =
    {
        ['tia'] = {name = 'Tiamat', id = 3077, range = 300},
        ['hyd'] = {name = 'Ravenous Hydra', id = 3074, range = 300},
        ['tit'] = {name = 'Titanic Hydra', id = 3748, range = 300},
    },
 
    ITEM_SKILLSHOT =
    {
        ['pro'] = {name = 'Hextech Protobelt-01', id = 3152, range = 800},
        ['glp'] = {name = 'Hextech GLP-800', id = 3030, range = 800},
    },]]
    
    CachedItems = {},
    
    Hotkey = nil,
}

function Item:Init
    ()
    self.MenuQss = Menu.Main.Items.Qss
    self.MenuQssBuffs = Menu.Main.Items.Qss.BuffTypes
    self.MenuBotrk = Menu.Main.Items.Botrk
    self.MenuGunblade = Menu.Main.Items.HexGun
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Item:OnLoad
    ()
    table.insert(SDK.Tick, function()
        if self:UseQss() then
            return
        end
        
        if Orbwalker.Modes[Orbwalker.ORBWALKER_MODE_COMBO] then
            if self:UseGunblade() then
                return
            end
            
            if self:UseBotrk() then
                return
            end
        end
    end)
    
    table.insert(SDK.Tick, function()
        self.CachedItems = {}
    end)
end

function Item:GetItemById
    (unit, id)
    local networkID = unit.networkID
    if self.CachedItems[networkID] == nil then
        local t = {}
        for i = 1, #self.ItemSlots do
            local slot = self.ItemSlots[i]
            local item = unit:GetItemData(slot)
            if item ~= nil and item.itemID ~= nil and item.itemID > 0 then
                t[item.itemID] = i
            end
        end
        self.CachedItems[networkID] = t
    end
    return self.CachedItems[networkID][id]
end

function Item:IsReady
    (unit, id)
    local item = self:GetItemById(unit, id)
    if item and myHero:GetSpellData(self.ItemSlots[item]).currentCd == 0 then
        self.Hotkey = self.ItemKeys[item]
        return true
    end
    return false
end

function Item:UseBotrk
    ()
    if not self.MenuBotrk.Enabled:Value() then
        return false
    end
    
    local botrkReady = false
    for _, id in pairs(self.ItemBotrk) do
        if self:IsReady(myHero, id) then
            botrkReady = true
            break
        end
    end
    
    if not botrkReady then
        return false
    end
    
    local bbox = myHero.boundingRadius
    local target = Target:GetTarget(550 - 35 + bbox, 0, true)
    
    if target == nil then
        return false
    end
    
    if target.distance < self.MenuBotrk.TargetDistance:Value() then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    if self.MenuBotrk.AntiMelee:Value() then
        local meleeHeroes = {}
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if Object:IsValid(hero, Obj_AI_Hero) and hero.isEnemy then
                local heroRange = hero.range
                if heroRange < 400 and hero.distance < heroRange + bbox + hero.boundingRadius then
                    table.insert(meleeHeroes, hero)
                end
            end
        end
        if #meleeHeroes > 0 then
            table.sort(meleeHeroes, function(a, b) return a.health + (a.totalDamage * 2) + (a.attackSpeed * 100) > b.health + (b.totalDamage * 2) + (b.attackSpeed * 100) end)
            Control.CastSpell(self.Hotkey, meleeHeroes[1])
            return true
        end
    end
    
    local myHeroHealth = 100 * (myHero.health / myHero.maxHealth)
    if myHeroHealth <= self.MenuBotrk.HeroHealth:Value() then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    if target.distance >= self.MenuBotrk.FleeRange:Value() and 100 * (target.health / target.maxHealth) <= self.MenuBotrk.FleeHealth:Value() and Math:IsFacing(myHero, target, 90) and not Math:IsFacing(target, myHero, 90) then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    return false
end

function Item:UseGunblade
    ()
    if not self.MenuGunblade.Enabled:Value() then
        return false
    end
    
    if not self:IsReady(myHero, self.ItemGunblade) then
        return false
    end
    
    local target = Target:GetTarget(700 - 35, 1, false)
    
    if target == nil then
        return false
    end
    
    if target.distance < self.MenuGunblade.TargetDistance:Value() then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    if self.MenuGunblade.AntiMelee:Value() then
        local meleeHeroes = {}
        local bbox = myHero.boundingRadius
        for i = 1, Game.HeroCount() do
            local hero = Game.Hero(i)
            if Object:IsValid(hero, Obj_AI_Hero) and hero.isEnemy then
                local heroRange = hero.range
                if heroRange < 400 and hero.distance < heroRange + bbox + hero.boundingRadius then
                    table.insert(meleeHeroes, hero)
                end
            end
        end
        if #meleeHeroes > 0 then
            table.sort(meleeHeroes, function(a, b) return a.health + (a.totalDamage * 2) + (a.attackSpeed * 100) > b.health + (b.totalDamage * 2) + (b.attackSpeed * 100) end)
            Control.CastSpell(self.Hotkey, meleeHeroes[1])
            return true
        end
    end
    
    local myHeroHealth = 100 * (myHero.health / myHero.maxHealth)
    if myHeroHealth <= self.MenuGunblade.HeroHealth:Value() then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    if target.distance >= self.MenuGunblade.FleeRange:Value() and 100 * (target.health / target.maxHealth) <= self.MenuGunblade.FleeHealth:Value() and Math:IsFacing(myHero, target, 90) and not Math:IsFacing(target, myHero, 90) then
        Control.CastSpell(self.Hotkey, target)
        return true
    end
    
    return false
end

function Item:UseQss
    ()
    if not self.MenuQss.Enabled:Value() then
        return false
    end
    
    local qssReady = false
    for _, id in pairs(self.ItemQss) do
        if self:IsReady(myHero, id) then
            qssReady = true
            break
        end
    end
    
    if not qssReady then
        return false
    end
    
    local enemiesCount = 0
    local menuDistance = self.MenuQss.Distance:Value()
    
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if Object:IsValid(hero, Obj_AI_Hero) and hero.isEnemy and hero.distance <= menuDistance then
            enemiesCount = enemiesCount + 1
        end
    end
    
    if enemiesCount < self.MenuQss.Count:Value() then
        return false
    end
    
    local menuDuration = self.MenuQss.Duration:Value() * 0.001
    
    local menuBuffs = {
        [5] = self.MenuQssBuffs.Stun:Value(),
        [11] = self.MenuQssBuffs.Snare:Value(),
        [24] = self.MenuQssBuffs.Supress:Value(),
        [29] = self.MenuQssBuffs.Knockup:Value(),
        [21] = self.MenuQssBuffs.Fear:Value(),
        [22] = self.MenuQssBuffs.Charm:Value(),
        [8] = self.MenuQssBuffs.Taunt:Value(),
        [30] = self.MenuQssBuffs.Knockback:Value(),
        [25] = self.MenuQssBuffs.Blind:Value(),
        [31] = self.MenuQssBuffs.Disarm:Value(),
        [10] = self.MenuQssBuffs.Slow:Value(),
    }
    
    for i = 0, myHero.buffCount do
        local buff = myHero:GetBuff(i)
        if buff and buff.count > 0 then
            local buffType = buff.type
            local buffDuration = buff.duration
            if buffType == 10 then
                if menuBuffs[buffType] and buffDuration >= 1 and myHero.ms <= 200 then
                    Control.CastSpell(self.Hotkey)
                    return true
                end
            elseif menuBuffs[buffType] and buffDuration >= menuDuration then
                Control.CastSpell(self.Hotkey)
                return true
            end
        end
    end
    
    return false
end

function Item:HasItem
    (unit, id)
    return self:GetItemById(unit, id) ~= nil
end

--OK
Buff =
{
    CachedBuffs =
    {},
}

function Buff:Init
    ()
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Buff:OnLoad
    ()
    
    table.insert(SDK.Tick, function()
        self.CachedBuffs = {}
    end)
end

function Buff:CreateBuffs
    (unit)
    
    local result = {}
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 then
            result[buff.name:lower()] =
            {
                Type = buff.type,
                StartTime = buff.startTime,
                ExpireTime = buff.expireTime,
                Duration = buff.duration,
                Stacks = buff.stacks,
                Count = buff.count,
            }
        end
    end
    return result
end

function Buff:GetBuffDuration
    (unit, name)
    
    name = name:lower()
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    if self.CachedBuffs[id][name] then
        return self.CachedBuffs[id][name].Duration
    end
    return 0
end

function Buff:GetBuff
    (unit, name)
    
    name = name:lower()
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    return self.CachedBuffs[id][name]
end

function Buff:HasBuffContainsName
    (unit, str)
    
    str = str:lower()
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    for name, buff in pairs(self.CachedBuffs[id]) do
        if name:find(str) then
            return true
        end
    end
    return false
end

function Buff:ContainsBuffs
    (unit, arr)
    
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    for i = 1, #arr do
        local name = arr[i]:lower()
        if self.CachedBuffs[id][name] then
            return true
        end
    end
    return false
end

function Buff:HasBuff
    (unit, name)
    
    name = name:lower()
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    if self.CachedBuffs[id][name] then
        return true
    end
    return false
end

function Buff:HasBuffTypes
    (unit, types)
    
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    for name, buff in pairs(self.CachedBuffs[id]) do
        if types[buff.Type] then
            return true
        end
    end
    return false
end

function Buff:GetBuffCount
    (unit, name)
    
    name = name:lower()
    local id = unit.networkID
    if self.CachedBuffs[id] == nil then self.CachedBuffs[id] = self:CreateBuffs(unit) end
    if self.CachedBuffs[id][name] then
        return self.CachedBuffs[id][name].Count
    end
    return 0
end

--OK
Damage =
{
    BaseTurrets =
    {
        ["SRUAP_Turret_Order3"] = true,
        ["SRUAP_Turret_Order4"] = true,
        ["SRUAP_Turret_Chaos3"] = true,
        ["SRUAP_Turret_Chaos4"] = true,
    },
    
    TurretToMinionPercent =
    {
        ["SRU_ChaosMinionMelee"] = 0.43,
        ["SRU_ChaosMinionRanged"] = 0.68,
        ["SRU_ChaosMinionSiege"] = 0.14,
        ["SRU_ChaosMinionSuper"] = 0.05,
        ["SRU_OrderMinionMelee"] = 0.43,
        ["SRU_OrderMinionRanged"] = 0.68,
        ["SRU_OrderMinionSiege"] = 0.14,
        ["SRU_OrderMinionSuper"] = 0.05,
        ["HA_ChaosMinionMelee"] = 0.43,
        ["HA_ChaosMinionRanged"] = 0.68,
        ["HA_ChaosMinionSiege"] = 0.14,
        ["HA_ChaosMinionSuper"] = 0.05,
        ["HA_OrderMinionMelee"] = 0.43,
        ["HA_OrderMinionRanged"] = 0.68,
        ["HA_OrderMinionSiege"] = 0.14,
        ["HA_OrderMinionSuper"] = 0.05,
    },
    
    DAMAGE_TYPE_PHYSICAL = SDK.DAMAGE_TYPE_PHYSICAL,
    DAMAGE_TYPE_MAGICAL = SDK.DAMAGE_TYPE_MAGICAL,
    DAMAGE_TYPE_TRUE = SDK.DAMAGE_TYPE_TRUE,
}

function Damage:Init()
    self.HeroStaticDamage =
    {
        ["Caitlyn"] = function(args)
            if Buff:HasBuff(args.From, "caitlynheadshot") then
                if args.TargetIsMinion then
                    args.RawPhysical = args.RawPhysical + args.From.totalDamage * 1.5
                else
                    --TODO
                end
            end
        end,
        ["Corki"] = function(args)
            args.RawTotal = args.RawTotal * 0.5
            args.RawMagical = args.RawTotal
        end,
        ["Diana"] = function(args)
            if Buff:GetBuffCount(args.From, "dianapassivemarker") == 2 then
                local level = args.From.levelData.lvl
                args.RawMagical = args.RawMagical + math.max(15 + 5 * level, -10 + 10 * level, -60 + 15 * level, -125 + 20 * level, -200 + 25 * level) + 0.8 * args.From.ap
            end
        end,
        ["Draven"] = function(args)
            if Buff:HasBuff(args.From, "DravenSpinningAttack") then
                local level = args.From:GetSpellData(_Q).level
                args.RawPhysical = args.RawPhysical + 25 + 5 * level + (0.55 + 0.1 * level) * args.From.bonusDamage
            end
        end,
        ["Graves"] = function(args)
            local t = {70, 71, 72, 74, 75, 76, 78, 80, 81, 83, 85, 87, 89, 91, 95, 96, 97, 100}
            args.RawTotal = args.RawTotal * t[math.max(math.min(args.From.levelData.lvl, 18), 1)] * 0.01
        end,
        ["Jinx"] = function(args)
            if Buff:HasBuff(args.From, "JinxQ") then
                args.RawPhysical = args.RawPhysical + args.From.totalDamage * 0.1
            end
        end,
        ["Kalista"] = function(args)
            args.RawPhysical = args.RawPhysical - args.From.totalDamage * 0.1
        end,
        ["Kayle"] = function(args)
            local level = args.From:GetSpellData(_E).level
            if level > 0 then
                if Buff:HasBuff(args.From, "JudicatorRighteousFury") then
                    args.RawMagical = args.RawMagical + 10 + 10 * level + 0.3 * args.From.ap
                else
                    args.RawMagical = args.RawMagical + 5 + 5 * level + 0.15 * args.From.ap
                end
            end
        end,
        ["Nasus"] = function(args)
            if Buff:HasBuff(args.From, "NasusQ") then
                args.RawPhysical = args.RawPhysical + math.max(Buff:GetBuffCount(args.From, "NasusQStacks"), 0) + 10 + 20 * args.From:GetSpellData(_Q).level
            end
        end,
        ["Thresh"] = function(args)
            local level = args.From:GetSpellData(_E).level
            if level > 0 then
                local damage = math.max(Buff:GetBuffCount(args.From, "threshpassivesouls"), 0) + (0.5 + 0.3 * level) * args.From.totalDamage
                if Buff:HasBuff(args.From, "threshqpassive4") then
                    damage = damage * 1
                elseif Buff:HasBuff(args.From, "threshqpassive3") then
                    damage = damage * 0.5
                elseif Buff:HasBuff(args.From, "threshqpassive2") then
                    damage = damage * 1 / 3
                else
                    damage = damage * 0.25
                end
                args.RawMagical = args.RawMagical + damage
            end
        end,
        ["TwistedFate"] = function(args)
            if Buff:HasBuff(args.From, "cardmasterstackparticle") then
                args.RawMagical = args.RawMagical + 30 + 25 * args.From:GetSpellData(_E).level + 0.5 * args.From.ap
            end
            if Buff:HasBuff(args.From, "BlueCardPreAttack") then
                args.DamageType = self.DAMAGE_TYPE_MAGICAL
                args.RawMagical = args.RawMagical + 20 + 20 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
            elseif Buff:HasBuff(args.From, "RedCardPreAttack") then
                args.DamageType = self.DAMAGE_TYPE_MAGICAL
                args.RawMagical = args.RawMagical + 15 + 15 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
            elseif Buff:HasBuff(args.From, "GoldCardPreAttack") then
                args.DamageType = self.DAMAGE_TYPE_MAGICAL
                args.RawMagical = args.RawMagical + 7.5 + 7.5 * args.From:GetSpellData(_W).level + 0.5 * args.From.ap
            end
        end,
        ["Varus"] = function(args)
            local level = args.From:GetSpellData(_W).level
            if level > 0 then
                args.RawMagical = args.RawMagical + 6 + 4 * level + 0.25 * args.From.ap
            end
        end,
        ["Viktor"] = function(args)
            if Buff:HasBuff(args.From, "ViktorPowerTransferReturn") then
                args.DamageType = self.DAMAGE_TYPE_MAGICAL
                args.RawMagical = args.RawMagical + 20 * args.From:GetSpellData(_Q).level + 0.5 * args.From.ap
            end
        end,
        ["Vayne"] = function(args)
            if Buff:HasBuff(args.From, "vaynetumblebonus") then
                args.RawPhysical = args.RawPhysical + (0.25 + 0.05 * args.From:GetSpellData(_Q).level) * args.From.totalDamage
            end
        end,
    }
    
    self.ItemStaticDamage =
    {
        [1043] = function(args)
            args.RawPhysical = args.RawPhysical + 15
        end,
        [2015] = function(args)
            if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                args.RawMagical = args.RawMagical + 40
            end
        end,
        [3057] = function(args)
            if Buff:HasBuff(args.From, "sheen") then
                args.RawPhysical = args.RawPhysical + 1 * args.From.baseDamage
            end
        end,
        [3078] = function(args)
            if Buff:HasBuff(args.From, "sheen") then
                args.RawPhysical = args.RawPhysical + 2 * args.From.baseDamage
            end
        end,
        [3085] = function(args)
            args.RawPhysical = args.RawPhysical + 15
        end,
        [3087] = function(args)
            if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                local t = {50, 50, 50, 50, 50, 56, 61, 67, 72, 77, 83, 88, 94, 99, 104, 110, 115, 120}
                args.RawMagical = args.RawMagical + (1 + (args.TargetIsMinion and 1.2 or 0)) * t[math.max(math.min(args.From.levelData.lvl, 18), 1)]
            end
        end,
        [3091] = function(args)
            args.RawMagical = args.RawMagical + 40
        end,
        [3094] = function(args)
            if Buff:GetBuffCount(args.From, "itemstatikshankcharge") == 100 then
                local t = {50, 50, 50, 50, 50, 58, 66, 75, 83, 92, 100, 109, 117, 126, 134, 143, 151, 160}
                args.RawMagical = args.RawMagical + t[math.max(math.min(args.From.levelData.lvl, 18), 1)]
            end
        end,
        [3100] = function(args)
            if Buff:HasBuff(args.From, "lichbane") then
                args.RawMagical = args.RawMagical + 0.75 * args.From.baseDamage + 0.5 * args.From.ap
            end
        end,
        [3115] = function(args)
            args.RawMagical = args.RawMagical + 15 + 0.15 * args.From.ap
        end,
        [3124] = function(args)
            args.CalculatedMagical = args.CalculatedMagical + 15
        end
    }
    
    self.HeroPassiveDamage =
    {
        ["Jhin"] = function(args)
            if Buff:HasBuff(args.From, "jhinpassiveattackbuff") then
                args.CriticalStrike = true
                args.RawPhysical = args.RawPhysical + math.min(0.25, 0.1 + 0.05 * math.ceil(args.From.levelData.lvl / 5)) * (args.Target.maxHealth - args.Target.health)
            end
        end,
        ["Lux"] = function(args)
            if Buff:HasBuff(args.Target, "LuxIlluminatingFraulein") then
                args.RawMagical = 20 + args.From.levelData.lvl * 10 + args.From.ap * 0.2
            end
        end,
        ["Orianna"] = function(args)
            local level = math.ceil(args.From.levelData.lvl / 3)
            args.RawMagical = args.RawMagical + 2 + 8 * level + 0.15 * args.From.ap
            if args.Target.handle == args.From.attackData.target then
                args.RawMagical = args.RawMagical + math.max(Buff:GetBuffCount(args.From, "orianapowerdaggerdisplay"), 0) * (0.4 + 1.6 * level + 0.03 * args.From.ap)
            end
        end,
        ["Quinn"] = function(args)
            if Buff:HasBuff(args.Target, "QuinnW") then
                local level = args.From.levelData.lvl
                args.RawPhysical = args.RawPhysical + 10 + level * 5 + (0.14 + 0.02 * level) * args.From.totalDamage
            end
        end,
        ["Vayne"] = function(args)
            if Buff:GetBuffCount(args.Target, "VayneSilveredDebuff") == 2 then
                local level = args.From:GetSpellData(_W).level
                args.CalculatedTrue = args.CalculatedTrue + math.max((0.045 + 0.015 * level) * args.Target.maxHealth, 20 + 20 * level)
            end
        end,
        ["Zed"] = function(args)
            if 100 * args.Target.health / args.Target.maxHealth <= 50 and not Buff:HasBuff(args.From, "zedpassivecd") then
                args.RawMagical = args.RawMagical + args.Target.maxHealth * (4 + 2 * math.ceil(args.From.levelData.lvl / 6)) * 0.01
            end
        end
    }
end

function Damage:IsBaseTurret
    (name)
    
    if self.BaseTurrets[name] then
        return true
    end
    return false
end

function Damage:SetHeroStaticDamage
    (args)
    
    local s = self.HeroStaticDamage[args.From.charName]
    if s then s(args) end
end

function Damage:SetItemStaticDamage
    (id, args)
    
    local s = self.ItemStaticDamage[id]
    if s then s(args) end
end

function Damage:SetHeroPassiveDamage
    (args)
    
    local s = self.HeroPassiveDamage[args.From.charName]
    if s then s(args) end
end

function Damage:CalculateDamage
    (from, target, damageType, rawDamage, isAbility, isAutoAttackOrTargetted)
    
    if from == nil or target == nil then
        return 0
    end
    if isAbility == nil then
        isAbility = true
    end
    if isAutoAttackOrTargetted == nil then
        isAutoAttackOrTargetted = false
    end
    local fromIsMinion = from.type == Obj_AI_Minion
    local targetIsMinion = target.type == Obj_AI_Minion
    local baseResistance = 0
    local bonusResistance = 0
    local penetrationFlat = 0
    local penetrationPercent = 0
    local bonusPenetrationPercent = 0
    if damageType == self.DAMAGE_TYPE_PHYSICAL then
        baseResistance = math.max(target.armor - target.bonusArmor, 0)
        bonusResistance = target.bonusArmor
        penetrationFlat = from.armorPen
        penetrationPercent = from.armorPenPercent
        bonusPenetrationPercent = from.bonusArmorPenPercent
        -- Minions return wrong percent values.
        if fromIsMinion then
            penetrationFlat = 0
            penetrationPercent = 0
            bonusPenetrationPercent = 0
        elseif from.type == Obj_AI_Turret then
            penetrationPercent = self:IsBaseTurret(from.charName) and 0.75 or 0.3
            penetrationFlat = 0
            bonusPenetrationPercent = 0
        end
    elseif damageType == self.DAMAGE_TYPE_MAGICAL then
        baseResistance = math.max(target.magicResist - target.bonusMagicResist, 0)
        bonusResistance = target.bonusMagicResist
        penetrationFlat = from.magicPen
        penetrationPercent = from.magicPenPercent
        bonusPenetrationPercent = 0
    elseif damageType == self.DAMAGE_TYPE_TRUE then
        return rawDamage
    end
    local resistance = baseResistance + bonusResistance
    if resistance > 0 then
        if penetrationPercent > 0 then
            baseResistance = baseResistance * penetrationPercent
            bonusResistance = bonusResistance * penetrationPercent
        end
        if bonusPenetrationPercent > 0 then
            bonusResistance = bonusResistance * bonusPenetrationPercent
        end
        resistance = baseResistance + bonusResistance
        resistance = resistance - penetrationFlat
    end
    local percentMod = 1
    -- Penetration cant reduce resistance below 0.
    if resistance >= 0 then
        percentMod = percentMod * (100 / (100 + resistance))
    else
        percentMod = percentMod * (2 - 100 / (100 - resistance))
    end
    local flatPassive = 0
    local percentPassive = 1
    if fromIsMinion and targetIsMinion then
        percentPassive = percentPassive * (1 + from.bonusDamagePercent)
    end
    local flatReceived = 0
    if not isAbility and targetIsMinion then
        flatReceived = flatReceived - target.flatDamageReduction
    end
    return math.max(percentPassive * percentMod * (rawDamage + flatPassive) + flatReceived, 0)
end

function Damage:GetStaticAutoAttackDamage
    (from, targetIsMinion)
    
    local args = {
        From = from,
        RawTotal = from.totalDamage,
        RawPhysical = 0,
        RawMagical = 0,
        CalculatedTrue = 0,
        CalculatedPhysical = 0,
        CalculatedMagical = 0,
        DamageType = self.DAMAGE_TYPE_PHYSICAL,
        TargetIsMinion = targetIsMinion
    }
    self:SetHeroStaticDamage(args)
    local HashSet = {}
    for i = 1, #Item.ItemSlots do
        local slot = Item.ItemSlots[i]
        local item = args.From:GetItemData(slot)
        if item ~= nil and item.itemID > 0 then
            if HashSet[item.itemID] == nil then
                self:SetItemStaticDamage(item.itemID, args)
                HashSet[item.itemID] = true
            end
        end
    end
    return args
end

function Damage:GetHeroAutoAttackDamage
    (from, target, static)
    
    local args = {
        From = from,
        Target = target,
        RawTotal = static.RawTotal,
        RawPhysical = static.RawPhysical,
        RawMagical = static.RawMagical,
        CalculatedTrue = static.CalculatedTrue,
        CalculatedPhysical = static.CalculatedPhysical,
        CalculatedMagical = static.CalculatedMagical,
        DamageType = static.DamageType,
        TargetIsMinion = target.type == Obj_AI_Minion,
        CriticalStrike = false,
    }
    if args.TargetIsMinion and args.Target.maxHealth <= 6 then
        return 1
    end
    self:SetHeroPassiveDamage(args)
    if args.DamageType == self.DAMAGE_TYPE_PHYSICAL then
        args.RawPhysical = args.RawPhysical + args.RawTotal
    elseif args.DamageType == self.DAMAGE_TYPE_MAGICAL then
        args.RawMagical = args.RawMagical + args.RawTotal
    elseif args.DamageType == self.DAMAGE_TYPE_TRUE then
        args.CalculatedTrue = args.CalculatedTrue + args.RawTotal
    end
    if args.RawPhysical > 0 then
        args.CalculatedPhysical = args.CalculatedPhysical + self:CalculateDamage(from, target, self.DAMAGE_TYPE_PHYSICAL, args.RawPhysical, false, args.DamageType == self.DAMAGE_TYPE_PHYSICAL)
    end
    if args.RawMagical > 0 then
        args.CalculatedMagical = args.CalculatedMagical + self:CalculateDamage(from, target, self.DAMAGE_TYPE_MAGICAL, args.RawMagical, false, args.DamageType == self.DAMAGE_TYPE_MAGICAL)
    end
    local percentMod = 1
    if args.From.critChance - 1 == 0 or args.CriticalStrike then
        percentMod = percentMod * self:GetCriticalStrikePercent(args.From)
    end
    return percentMod * args.CalculatedPhysical + args.CalculatedMagical + args.CalculatedTrue
end

function Damage:GetAutoAttackDamage
    (from, target, respectPassives)
    
    if respectPassives == nil then
        respectPassives = true
    end
    if from == nil or target == nil then
        return 0
    end
    local targetIsMinion = target.type == Obj_AI_Minion
    if respectPassives and from.type == Obj_AI_Hero then
        return self:GetHeroAutoAttackDamage(from, target, self:GetStaticAutoAttackDamage(from, targetIsMinion))
    end
    if targetIsMinion then
        if target.maxHealth <= 6 then
            return 1
        end
        if from.type == Obj_AI_Turret and not self:IsBaseTurret(from.charName) then
            local percentMod = self.TurretToMinionPercent[target.charName]
            if percentMod ~= nil then
                return target.maxHealth * percentMod
            end
        end
    end
    return self:CalculateDamage(from, target, self.DAMAGE_TYPE_PHYSICAL, from.totalDamage, false, true)
end

function Damage:GetCriticalStrikePercent
    (from)
    
    local baseCriticalDamage = 2
    local percentMod = 1
    local fixedMod = 0
    if from.charName == "Jhin" then
        percentMod = 0.75
    elseif from.charName == "XinZhao" then
        baseCriticalDamage = baseCriticalDamage - (0.875 - 0.125 * from:GetSpellData(_W).level)
    elseif from.charName == "Yasuo" then
        percentMod = 0.9
    end
    return baseCriticalDamage * percentMod
end

--OK
Cursor =
{
    Hold = nil,
    Step = 0,
    MoveTimer = 0,
    Flash = nil,
    WndChecked = false,
    EndTime = 0,
    Pos = nil,
    CastPos = nil,
    IsHero = false,
    Targets = {},
    TargetsBool = true,
    WParam = nil,
    Msg = nil,
}

function Cursor:Init
    ()
    
    self.MenuDelay = Menu.Main.CursorDelay
    self.MenuOrbwalker = Menu.Orbwalker.General
    self.MenuDrawCursor = Menu.Main.Drawings.Cursor
    self.MenuRandomHumanizer = Menu.Orbwalker.RandomHumanizer
    
    _G.Control.Hold = function(key)
        if (self.Step == 0) then
            self:New(key, nil, false)
            Orbwalker.CanHoldPosition = false
            self.MoveTimer = 0
            return true
        end
        self.Hold = {Key = key, Tick = GetTickCount()}
        return true
    end
    
    _G.Control.Flash = function(key, pos)
        if (self.Step == 0) then
            self:New(key, pos, false)
            return true
        end
        self.Flash = {Key = key, Pos = pos, Tick = GetTickCount()}
        return true
    end
    
    _G.Control.Attack = function(target)
        if (self.Step > 0) then
            return false
        end
        local key = self.MenuOrbwalker.AttackTargetKeyUse:Value() and self.MenuOrbwalker.AttackTKey:Key() or MOUSEEVENTF_RIGHTDOWN
        self:New(key, target, false)
        if (self.MenuOrbwalker.FastKiting:Value()) then
            self.MoveTimer = 0
        end
        return true
    end
    
    _G.Control.CastSpell = function(key, a, b, c)
        if (self.Step > 0) then
            return false
        end
        local pos = self:GetControlPos(a, b, c)
        self:New(key, pos, false)
        return true
    end
    
    _G.Control.Move = function(a, b, c)
        if (self.Step > 0 or GetTickCount() < self.MoveTimer) then
            return false
        end
        self:New(MOUSEEVENTF_RIGHTDOWN, self:GetControlPos(a, b, c), true)
        return true
    end
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Cursor:OnLoad
    ()
    
    table.insert(SDK.Tick, function()
        self.Targets = {}
        self.TargetsBool = true
    end)
    
    table.insert(SDK.FastTick, function()
        self:OnTick()
    end)
    
    table.insert(SDK.Draw, function()
        if self.MenuDrawCursor:Value() then
            Draw.Circle(mousePos, 150, 2, Color.Cursor)
        end
    end)
    
    table.insert(SDK.WndMsg, function(msg, wParam)
        self:WndMsg(msg, wParam)
    end)
end

function Cursor:New
    (key, castPos, isMove)
    
    self.Step = 1
    if key == MOUSEEVENTF_RIGHTDOWN then
        self.WParam = nil
        self.Msg = WM_RBUTTONUP
    else
        self.WParam = key
        self.Msg = nil
    end
    self.IsMove = isMove
    self.Pos = cursorPos
    self.WndChecked = false
    self.EndTime = GetTickCount() + 70 + self.MenuDelay:Value()
    self.IsHero = false
    self.CastPos = castPos
    if self.CastPos ~= nil then
        self:SetToCastPos()
        if self.CastPos.type == Obj_AI_Hero then
            self.IsHero = true
        end
    end
    self:KeyDown()
end

function Cursor:OnTick
    ()
    local step = self.Step
    
    if (step == 0) then
        if (self.Flash) then
            if GetTickCount() > self.Flash.Tick + 300 then
                print('FLASH TIMEOUT !')
            else
                self:New(self.Flash.Key, self.Flash.Pos, false)
            end
            self.Flash = nil
            return
        end
        
        if (self.Hold) then
            if GetTickCount() > self.Hold.Tick + 300 then
                print('HOLD TIMEOUT !')
            else
                self:New(self.Hold.Key, nil, false)
                Orbwalker.CanHoldPosition = false
                self.MoveTimer = 0
            end
            self.Hold = nil
            return
        end
    end
    
    if (step == 1) then
        self.Step = 2
        if self.CastPos == nil then
            self.Step = 0
        else
            self:SetToCastPos()
        end
        self:KeyUp()
        return
    end
    
    if (step == 2) then
        if (GetTickCount() > self.EndTime) then
            self.Step = 3
            self:SetToCursor()
        elseif self.CastPos ~= nil then
            self:SetToCastPos()
        end
        return
    end
    
    if (step == 3) then
        self:SetToCursor()
        return
    end
end

function Cursor:WndMsg
    (msg, wParam)
    
    if self.Step == 0 or self.WndChecked then
        return
    end
    
    if (self.Msg and msg == self.Msg) or (self.WParam and wParam == self.WParam) then
        self.EndTime = GetTickCount() + self.MenuDelay:Value()
        self.WndChecked = true
    end
end

function Cursor:IsCursorOnTarget
    (pos)
    
    pos = Vector(pos)
    if self.TargetsBool then
        for i = 1, Game.HeroCount() do
            local unit = Game.Hero(i)
            if unit and unit.valid and not unit.isAlly and unit.alive and unit.isTargetable and unit.visible and unit.distance < 2500 then
                table.insert(self.Targets, {unit.pos, unit.boundingRadius + 180})
            end
        end
        for i = 1, Game.MinionCount() do
            local unit = Game.Minion(i)
            if unit and unit.valid and not unit.isAlly and unit.alive and unit.isTargetable and unit.visible and unit.distance < 2500 then
                table.insert(self.Targets, {unit.pos, unit.boundingRadius + 120})
            end
        end
        for i = 1, Game.TurretCount() do
            local unit = Game.Turret(i)
            if unit and unit.valid and not unit.isAlly and unit.alive and unit.isTargetable and unit.visible and unit.distance < 2500 then
                table.insert(self.Targets, {unit.pos, unit.boundingRadius + 120})
            end
        end
        self.TargetsBool = false
    end
    for i = 1, #self.Targets do
        local item = self.Targets[i]
        if pos:DistanceTo(item[1]) < item[2] then
            return true
        end
    end
    return false
end

function Cursor:GetHumanizer
    ()
    
    if self.MenuRandomHumanizer.Enabled:Value() then
        local min = self.MenuRandomHumanizer.Min:Value()
        local max = self.MenuRandomHumanizer.Max:Value()
        return max <= min and min or math.random(min, max)
    end
    return self.MenuOrbwalker.MovementDelay:Value()
end

function Cursor:SetToCastPos
    ()
    
    local pos = self.CastPos.pos
    if pos then
        pos = pos:To2D()
    else
        pos = (self.CastPos.z ~= nil) and self.CastPos:To2D() or self.CastPos
    end
    Control.SetCursorPos(pos.x, pos.y)
end

function Cursor:SetToCursor
    ()
    
    Control.SetCursorPos(self.Pos.x, self.Pos.y)
    local dx = cursorPos.x - self.Pos.x
    local dy = cursorPos.y - self.Pos.y
    if (dx * dx + dy * dy < 15000) then
        self.Step = 0
    end
end

function Cursor:KeyDown
    ()
    
    if self.IsHero then
        Control.KeyDown(_G.HK_TCO)
    end
    
    if (self.Msg) then
        Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
        if self.IsMove then
            self.MoveTimer = GetTickCount() + self:GetHumanizer()
            Orbwalker.CanHoldPosition = true
        end
    else
        Control.KeyDown(self.WParam)
    end
end

function Cursor:KeyUp
    ()
    
    if (self.Msg) then
        Control.mouse_event(MOUSEEVENTF_RIGHTUP)
    else
        Control.KeyUp(self.WParam)
    end
    
    if self.IsHero then
        Control.KeyUp(_G.HK_TCO)
    end
end

function Cursor:GetControlPos
    (a, b, c)
    
    local pos
    if (a and b and c) then
        pos = Vector(a, b, c)
    elseif (a and b) then
        pos = {x = a, y = b}
    elseif (a) then
        pos = (a.pos ~= nil) and a or Vector(a)
    end
    return pos
end

--ok
Health =
{
}

--ok
function Health:Init
    ()
    self.ExtraFarmDelay = Menu.Orbwalker.Farming.ExtraFarmDelay
    self.MenuDrawings = Menu.Main.Drawings
    
    self.IsLastHitable = false
    self.ShouldRemoveObjects = false
    
    self.ShouldWaitTime = 0
    self.OnUnkillableC = {}
    
    self.HighestEndTime = {}
    self.ActiveAttacks = {}
    
    self.AllyTurret = nil
    self.AllyTurretHandle = nil
    self.StaticAutoAttackDamage = nil
    self.FarmMinions = {}
    self.Handles = {}
    self.AllyMinionsHandles = {}
    self.EnemyWardsInAttackRange = {}
    self.EnemyMinionsInAttackRange = {}
    self.JungleMinionsInAttackRange = {}
    self.EnemyStructuresInAttackRange = {}
    
    self.TargetsHealth = {}
    self.AttackersDamage = {}
    
    self.Spells = {}
    self.LastHitHandle = 0
    self.LaneClearHandle = 0
end

--ok
function Health:AddSpell
    (class)
    
    table.insert(self.Spells, class)
end

--ok
function Health:OnTick()
    local attackRange, structures, pos, speed, windup, time, anim
    
    -- RESET ALL
    if self.ShouldRemoveObjects then
        self.ShouldRemoveObjects = false
        
        self.AllyTurret = nil
        self.AllyTurretHandle = nil
        self.StaticAutoAttackDamage = nil
        
        for i = 1, #self.FarmMinions do
            table.remove(self.FarmMinions, i)
        end
        
        for i = 1, #self.EnemyWardsInAttackRange do
            table.remove(self.EnemyWardsInAttackRange, i)
        end
        
        for i = 1, #self.EnemyMinionsInAttackRange do
            table.remove(self.EnemyMinionsInAttackRange, i)
        end
        
        for i = 1, #self.JungleMinionsInAttackRange do
            table.remove(self.JungleMinionsInAttackRange, i)
        end
        
        for i = 1, #self.EnemyStructuresInAttackRange do
            table.remove(self.EnemyStructuresInAttackRange, i)
        end
        
        for k, v in pairs(self.AttackersDamage) do
            for k2, v2 in pairs(v) do
                self.AttackersDamage[k][k2] = nil
            end
            self.AttackersDamage[k] = nil
        end
        
        for k, v in pairs(self.AllyMinionsHandles) do
            self.AllyMinionsHandles[k] = nil
        end
        
        for k, v in pairs(self.TargetsHealth) do
            self.TargetsHealth[k] = nil
        end
        
        for k, v in pairs(self.Handles) do
            self.Handles[k] = nil
        end
    end
    
    -- SPELLS
    for i = 1, #self.Spells do
        self.Spells[i]:Reset()
    end
    
    if Orbwalker.Modes[Orbwalker.ORBWALKER_MODE_COMBO] then return end--or Orbwalker.IsNone
    
    self.IsLastHitable = false
    self.ShouldRemoveObjects = true
    self.StaticAutoAttackDamage = Damage:GetStaticAutoAttackDamage(myHero, true)
    
    -- SET OBJECTS
    attackRange = myHero.range + myHero.boundingRadius - 35
    
    for i = 1, Game.MinionCount() do
        local obj = Game.Minion(i)
        if Object:IsValid(obj, Obj_AI_Minion, true) and Math:IsInRange(myHero, obj, 2000) then
            local handle = obj.handle
            self.Handles[handle] = obj
            local team = obj.team
            if team == Data.AllyTeam then
                self.AllyMinionsHandles[handle] = obj
            elseif team == Data.EnemyTeam then
                if not obj.isImmortal and Math:IsInRange(myHero, obj, attackRange + obj.boundingRadius) then
                    table.insert(self.EnemyMinionsInAttackRange, obj)
                end
            elseif team == Data.JungleTeam then
                if not obj.isImmortal and Math:IsInRange(myHero, obj, attackRange + obj.boundingRadius) then
                    table.insert(self.JungleMinionsInAttackRange, obj)
                end
            end
        end
    end
    
    structures = Object:GetAllStructures(2000, false, true)
    
    for i = 1, #structures do
        local obj = structures[i]
        local objType = obj.type
        
        if objType == Obj_AI_Turret then
            self.Handles[obj.handle] = obj
            if obj.team == Data.AllyTeam then
                self.AllyTurret = obj
                self.AllyTurretHandle = obj.handle
            end
        end
        
        if obj.team == Data.EnemyTeam then
            local objRadius = 0
            
            if objType == Obj_AI_Barracks then
                objRadius = 270
            elseif objType == Obj_AI_Nexus then
                objRadius = 380
            elseif objType == Obj_AI_Turret then
                objRadius = obj.boundingRadius
            end
            
            if not obj.isImmortal and Math:IsInRange(myHero, obj, attackRange + objRadius) then
                table.insert(self.EnemyStructuresInAttackRange, obj)
            end
        end
    end
    
    for i = 1, Game.WardCount() do
        local obj = Game.Ward(i)
        if obj and obj.team == Data.EnemyTeam and obj.visible and obj.alive and Math:IsInRange(myHero, obj, attackRange + 35) then
            table.insert(self.EnemyWardsInAttackRange, obj)
        end
    end

    -- ON ATTACK
    local timer = Game.Timer()
    for handle, obj in pairs(self.Handles) do
        local s = obj.activeSpell
        if s and s.valid and s.isAutoAttack then
            if self.ActiveAttacks[handle] == nil then
                self.ActiveAttacks[handle] = {}
            end
            local endTime = s.endTime
            local speed = s.speed
            local animation = s.animation
            local windup = s.windup
            local target = s.target
            if endTime and self.ActiveAttacks[handle][endTime] == nil and speed and animation and windup and target and endTime > timer and math.abs(endTime - timer - animation) < 0.05 then
                self.ActiveAttacks[handle][endTime] =
                {
                    Speed = speed,
                    EndTime = endTime,
                    AnimationTime = animation,
                    WindUpTime = windup,
                    StartTime = endTime - animation,
                    Target = target,
                }
                for handle2, attacks in pairs(self.ActiveAttacks) do
                    for endTime2, attack in pairs(attacks) do
                        if endTime - endTime2 > 15 then
                            self.ActiveAttacks[handle][endTime2] = nil
                        end
                    end
                end
                local endTime2 = self.HighestEndTime[handle]
                if endTime2 ~= nil and endTime - endTime2 < animation - 0.1 then
                    self.ActiveAttacks[handle][endTime] = nil
                end
                self.HighestEndTime[handle] = endTime
            end
        end
    end
    
    -- RECALCULATE ATTACKS
    for handle, endTime in pairs(self.HighestEndTime) do
        if self.Handles[handle] == nil then
            self.HighestEndTime[handle] = nil
        end
    end
    for handle, attacks in pairs(self.ActiveAttacks) do
        if self.Handles[handle] == nil then
            for endTime, attack in pairs(attacks) do
                self.ActiveAttacks[handle][endTime] = nil
            end
            self.ActiveAttacks[handle] = nil
        end
    end
    
    -- SET FARM MINIONS
    pos = myHero.pos
    speed = Attack:GetProjectileSpeed()
    windup = Attack:GetWindup()
    time = windup - Data:GetLatency() - self.ExtraFarmDelay:Value() * 0.001
    anim = Attack:GetAnimation()
    for i = 1, #self.EnemyMinionsInAttackRange do
        local target = self.EnemyMinionsInAttackRange[i]
        table.insert(self.FarmMinions, self:SetLastHitable(target, anim, time + target.distance / speed, Damage:GetAutoAttackDamage(myHero, target, self.StaticAutoAttackDamage)))
    end
    
    -- SPELLS
    for i = 1, #self.Spells do
        self.Spells[i]:Tick()
    end
    
    -- DRAW
    if self.MenuDrawings.LastHittableMinions:Value() then
        for i = 1, #self.FarmMinions do
            local args = self.FarmMinions[i]
            local minion = args.Minion
            if Object:IsValid(minion, Obj_AI_Minion, true, true) then
                if args.LastHitable then
                    Draw.Circle(minion.pos, math.max(65, minion.boundingRadius), 2, Color.LastHitable)
                elseif args.AlmostLastHitable then
                    Draw.Circle(minion.pos, math.max(65, minion.boundingRadius), 2, Color.AlmostLastHitable)
                end
            end
        end
    end
end

--ok
function Health:GetPrediction
    (target, time)
    
    local timer, pos, team, handle, health, attackers
    timer = Game.Timer()
    pos = target.pos
    handle = target.handle
    if self.TargetsHealth[handle] == nil then
        self.TargetsHealth[handle] = target.health + Data:GetTotalShield(target)
    end
    health = self.TargetsHealth[handle]
    
    for attackerHandle, attacks in pairs(self.ActiveAttacks) do
        local attacker = self.Handles[attackerHandle]
        if attacker then
            local c = 0
            for endTime, attack in pairs(attacks) do
                if attack.Target == handle then

                    local speed, startT, flyT, endT, damage
                    speed = attack.Speed
                    startT = attack.StartTime
                    flyT = speed > 0 and Math:GetDistance(attacker.pos, pos) / speed or 0
                    endT = (startT + attack.WindUpTime + flyT) - timer
                    
                    if endT > 0 and endT < time then
                        c = c + 1
                        if self.AttackersDamage[attackerHandle] == nil then
                            self.AttackersDamage[attackerHandle] = {}
                        end
                        if self.AttackersDamage[attackerHandle][handle] == nil then
                            self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(attacker, target)
                        end
                        damage = self.AttackersDamage[attackerHandle][handle]
                        
                        health = health - damage
                    end
                end
            end
        end
    end
    
    return health
end

--ok
function Health:LocalGetPrediction
    (target, time)
    
    local timer, pos, team, handle, health, attackers, turretAttacked
    turretAttacked = false
    timer = Game.Timer()
    pos = target.pos
    handle = target.handle
    if self.TargetsHealth[handle] == nil then
        self.TargetsHealth[handle] = target.health + Data:GetTotalShield(target)
    end
    health = self.TargetsHealth[handle]
    
    local handles = {}

    for attackerHandle, attacks in pairs(self.ActiveAttacks) do
        local attacker = self.Handles[attackerHandle]
        if attacker then
            
            for endTime, attack in pairs(attacks) do
                if attack.Target == handle then
                    
                    local speed, startT, flyT, endT, damage
                    speed = attack.Speed
                    startT = attack.StartTime
                    flyT = speed > 0 and Math:GetDistance(attacker.pos, pos) / speed or 0
                    endT = (startT + attack.WindUpTime + flyT) - timer
                    
                    -- laneClear
                    if endT < 0 and timer - attack.EndTime < 1.25 then
                        endT = attack.WindUpTime + flyT
                        endT = timer > attack.EndTime and endT or endT + (attack.EndTime - timer)
                        startT = timer > attack.EndTime and timer or attack.EndTime
                    end
                    
                    if endT > 0 and endT < time then
                        
                        handles[attackerHandle] = true

                        -- damage
                        if self.AttackersDamage[attackerHandle] == nil then
                            self.AttackersDamage[attackerHandle] = {}
                        end
                        if self.AttackersDamage[attackerHandle][handle] == nil then
                            self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(attacker, target)
                        end
                        damage = self.AttackersDamage[attackerHandle][handle]
                        
                        -- laneClear
                        local c = 1
                        while (endT < time) do
                            if attackerHandle == self.AllyTurretHandle then
                                turretAttacked = true
                            else
                                health = health - damage
                            end
                            endT = (startT + attack.WindUpTime + flyT + c * attack.AnimationTime) - timer
                            c = c + 1
                            if c > 10 then
                                print("ERROR LANECLEAR!")
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- laneClear
    for attackerHandle, obj in pairs(self.AllyMinionsHandles) do

        if handles[attackerHandle] == nil then
            local aaData = obj.attackData
            local isMoving = obj.pathing.hasMovePath
            
            if aaData == nil or aaData.target == nil or self.Handles[aaData.target] == nil or isMoving or self.ActiveAttacks[attackerHandle] == nil then
                local distance = Math:GetDistance(obj.pos, pos)
                local range = Data:GetAutoAttackRange(obj, target)
                local extraRange = isMoving and 250 or 0
                
                if distance < range + extraRange then
                    local speed, flyT, endT, damage
                    
                    speed = aaData.projectileSpeed
                    distance = distance > range and range or distance
                    flyT = speed > 0 and distance / speed or 0
                    endT = aaData.windUpTime + flyT
                    
                    if endT < time then
                        if self.AttackersDamage[attackerHandle] == nil then
                            self.AttackersDamage[attackerHandle] = {}
                        end
                        if self.AttackersDamage[attackerHandle][handle] == nil then
                            self.AttackersDamage[attackerHandle][handle] = Damage:GetAutoAttackDamage(obj, target)
                        end
                        damage = self.AttackersDamage[attackerHandle][handle]
                        
                        local c = 1
                        while (endT < time) do
                            health = health - damage
                            endT = aaData.windUpTime + flyT + c * aaData.animationTime
                            c = c + 1
                            if c > 10 then
                                print("ERROR LANECLEAR!")
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    return health, turretAttacked
end

--ok
function Health:SetLastHitable
    (target, anim, time, damage)
    
    local timer, handle, currentHealth, health, lastHitable, almostLastHitable, almostalmost, unkillable
    
    timer = Game.Timer()
    handle = target.handle
    currentHealth = target.health + Data:GetTotalShield(target)
    self.TargetsHealth[handle] = currentHealth
    health = self:GetPrediction(target, time)
    
    lastHitable = false
    almostLastHitable = false
    almostalmost = false
    unkillable = false
    
    -- unkillable
    if health < 0 then
        unkillable = true
        for i = 1, #self.OnUnkillableC do
            self.OnUnkillableC[i](target)
        end
        return
        {
            LastHitable = lastHitable,
            Unkillable = unkillable,
            AlmostLastHitable = almostLastHitable,
            PredictedHP = health,
            Minion = target,
            AlmostAlmost = almostalmost,
            Time = time,
        }
    end
    
    -- lasthitable
    if health - damage < 0 then
        lastHitable = true
        self.IsLastHitable = true
        return
        {
            LastHitable = lastHitable,
            Unkillable = unkillable,
            AlmostLastHitable = almostLastHitable,
            PredictedHP = health,
            Minion = target,
            AlmostAlmost = almostalmost,
            Time = time,
        }
    end
    
    -- almost lasthitable
    local turretAttack, extraTime, almostHealth, almostAlmostHealth, turretAttacked
    turretAttack = self.AllyTurret ~= nil and self.AllyTurret.attackData or nil
    extraTime = (1.5 - anim) * 0.3
    extraTime = extraTime < 0 and 0 or extraTime
    almostHealth, turretAttacked = self:LocalGetPrediction(target, anim + time + extraTime)-- + 0.25
    if almostHealth < 0 then
        almostLastHitable = true
        self.ShouldWaitTime = GetTickCount()
    elseif almostHealth - damage < 0 then
        almostLastHitable = true
    elseif currentHealth ~= almostHealth then
        almostAlmostHealth, turretAttacked = self:LocalGetPrediction(target, 1.25 * anim + 1.25 * time + 0.5 + extraTime)
        if almostAlmostHealth - damage < 0 then
            almostalmost = true
        end
    end
    
    -- under turret, turret attackdata: 1.20048 0.16686 1200
    if turretAttacked or (turretAttack and turretAttack.target == handle) or (self.AllyTurret and (Data:IsInAutoAttackRange(self.AllyTurret, target) or Data:IsInAutoAttackRange2(self.AllyTurret, target))) then
        local nearTurret, isTurretTarget, maxHP, startTime, windUpTime, flyTime, turretDamage, turretHits
        
        nearTurret = true
        isTurretTarget = turretAttack.target == handle
        
        maxHP = target.maxHealth
        startTime = turretAttack.endTime - 1.20048
        windUpTime = 0.16686
        flyTime = Math:GetDistance(self.AllyTurret, target) / 1200
        turretDamage = Damage:GetAutoAttackDamage(self.AllyTurret, target)
        
        turretHits = 1
        while (maxHP > turretHits * turretDamage) do
            turretHits = turretHits + 1
            if turretHits > 10 then
                print("ERROR TURRETHITS")
                break
            end
        end
        turretHits = turretHits - 1
        
        return
        {
            LastHitable = lastHitable,
            Unkillable = unkillable,
            AlmostLastHitable = almostLastHitable,
            PredictedHP = health,
            Minion = target,
            AlmostAlmost = almostalmost,
            Time = time,
            -- turret
            NearTurret = nearTurret,
            IsTurretTarget = isTurretTarget,
            TurretHits = turretHits,
            TurretDamage = turretDamage,
            TurretFlyDelay = flyTime,
            TurretStart = startTime,
            TurretWindup = windUpTime,
        }
    end
    
    return
    {
        LastHitable = lastHitable,
        Unkillable = health < 0,
        AlmostLastHitable = almostLastHitable,
        PredictedHP = health,
        Minion = target,
        AlmostAlmost = almostalmost,
        Time = time,
    }
end

--ok
function Health:ShouldWait
    ()
    -- why this delay ? because decreasing minion's health after attack is delayed, attack dissapear earlier + connection latency
    return GetTickCount() < self.ShouldWaitTime + 250
end

--ok
function Health:GetJungleTarget
    ()
    
    if #self.JungleMinionsInAttackRange > 0 then
        table.sort(self.JungleMinionsInAttackRange, function(a, b) return a.maxHealth > b.maxHealth end);
        return self.JungleMinionsInAttackRange[1]
    end
    
    return #self.EnemyWardsInAttackRange > 0 and self.EnemyWardsInAttackRange[1] or nil
end

--ok
function Health:GetLastHitTarget
    ()
    
    local min = 10000000
    local result = nil
    for i = 1, #self.FarmMinions do
        local minion = self.FarmMinions[i]
        if Object:IsValid(minion.Minion, Obj_AI_Minion, true, true) and minion.LastHitable and minion.PredictedHP < min and Data:IsInAutoAttackRange(myHero, minion.Minion) then
            min = minion.PredictedHP
            result = minion.Minion
            self.LastHitHandle = result.handle
        end
    end
    
    return result
end

--ok
function Health:GetHarassTarget
    ()
    
    local LastHitPriority = Menu.Orbwalker.Farming.LastHitPriority:Value()
    local structure = #self.EnemyStructuresInAttackRange > 0 and self.EnemyStructuresInAttackRange[1] or nil
    
    if structure ~= nil then
        if not LastHitPriority then
            return structure
        end
        if self.IsLastHitable then
            return self:GetLastHitTarget()
        end
        if LastHitPriority and not self:ShouldWait() then
            return structure
        end
    else
        if not LastHitPriority then
            local hero = Target:GetComboTarget()
            if hero ~= nil then
                return hero
            end
        end
        if self.IsLastHitable then
            return self:GetLastHitTarget()
        end
        if LastHitPriority and not self:ShouldWait() then
            local hero = Target:GetComboTarget()
            if hero ~= nil then
                return hero
            end
        end
    end
end

function Health:GetLaneMinion
    ()
    
    local laneMinion = nil
    local num = 10000
    for i = 1, #self.FarmMinions do
        local minion = self.FarmMinions[i]
        if Data:IsInAutoAttackRange(myHero, minion.Minion) then
            if minion.PredictedHP < num and not minion.AlmostAlmost and not minion.AlmostLastHitable then--and (self.AllyTurret == nil or minion.CanUnderTurret) then
                num = minion.PredictedHP
                laneMinion = minion.Minion
            end
        end
    end
    
    --[[
 
        while (c >= 0) do
            if health2 - c * turretDamage - damage > 0 then
                if c == 1 or c > 2 then
                    success = true
                end
                break
            end
            c = c - 1
        end
 
        if turretAttacked then
            almostHealth = almostHealth - turretDamage
        end
 
        if almostLastHitable or almostalmost then
            if turretAttacked or isTurretTarget then
                if startTime + windUpTime + flyTime < timer then
                    if health - turretDamage < 0 then
                        print("unkillable")
                    else
 
                    end
                end
            else
 
            end
        end
 
 
        if turretAttacked and almostHealth - damage > 0 then
            success = true
        elseif 
            local turretAttack, startTime, windUpTime, flyTime, turretDamage
            if startTime + windUpTime + flyTime < timer then
 
            end
        end
        
        if not success and health - turretDamage < 0 and turretAttack.target ~= handle then
            if turretAttack.target == handle then
                if healthUnderTurret - damage < 0 and startTime + windUpTime + flyTime > timer then
                    success = true
                end
            else
                success = true
            end
        end]]
    --[[
            -- on last hit
            if lastHitable and healthUnderTurret - damage > 0 then
                almostLastHitable = false
                almostalmost = false
                self.ShouldWaitTime = 0
                lastHitable = false
                success = true
            end
            if not success and not lastHitable and (almostLastHitable or almostalmost) then
                
            end almostHealth - turretDamage < 0 and almostHealth - damage > 0 then
 
        if not success then
            success = almostHealth == currentHealth and healthUnderTurret - turretDamage < 0
        end
 
        if not success then
            success = currentHealth - almostHealth > 50 and almostHealth - turretDamage - damage > 0
        end
 
        if not success then
            if almostHealth == currentHealth then
                success = currentHealth - 2 * turretDamage < 0 and currentHealth - turretDamage - damage > 0
            end
        end]]
    
    -- or almostHealth - 2 * turretDamage > 0 or healthUnderTurret - turretDamage - damage > 0 then
    
    --local turretAttack = self.AllyTurret.attackData
    --if turretAttack.target == handle then
    --local endTime = (turretAttack.endTime - 1.20048) + 0.16686 + Math:GetDistance(self.AllyTurret, target) / 1200
    --[[
        if success then
            almostalmost = false
            almostLastHitable = false
            canUnderTurret = true
        end
    end
    
    if almostLastHitable then
        self.ShouldWaitTime = GetTickCount()
    end]]
    
    --[[
    LastHitable = lastHitable,
    Unkillable = unkillable,
    AlmostLastHitable = almostLastHitable,
    PredictedHP = health,
    Minion = target,
    AlmostAlmost = almostalmost,
    Time = time,
    -- turret
    NearTurret = nearTurret,
    IsTurretTarget = isTurretTarget,
    TurretHits = turretHits,
    TurretDamage = turretDamage,
    TurretFlyDelay = flyTime,
    TurretStart = startTime,
    TurretWindup = windUpTime,
]]
    
    -- 0. all based on turret target timers, health | hp - x * turretDamage > 0 - this delay - hero delay
    -- 1. hero attacks in turret hit delay | hp - heroDmg * x < 0
    
    --[[ get turret delay
        local turretDelay
        for i = 1, #self.FarmMinions do
            local minion = self.FarmMinions[i]
            if Data:IsInAutoAttackRange(myHero, minion.Minion) and minion.NearTurret then
 
                if minion.IsTurretTarget then
                    break
                end
            end
        end]]
    
    return laneMinion
end

--ok
function Health:GetLaneClearTarget
    ()
    
    local LastHitPriority = Menu.Orbwalker.Farming.LastHitPriority:Value()
    local LaneClearHeroes = Menu.Orbwalker.General.LaneClearHeroes:Value()
    local structure = #self.EnemyStructuresInAttackRange > 0 and self.EnemyStructuresInAttackRange[1] or nil
    local other = #self.EnemyWardsInAttackRange > 0 and self.EnemyWardsInAttackRange[1] or nil
    
    if structure ~= nil then
        if not LastHitPriority then
            return structure
        end
        if self.IsLastHitable then
            return self:GetLastHitTarget()
        end
        if other ~= nil then
            return other
        end
        if LastHitPriority and not self:ShouldWait() then
            return structure
        end
    else
        if not LastHitPriority and LaneClearHeroes then
            local hero = Target:GetComboTarget()
            if hero ~= nil then
                return hero
            end
        end
        if self.IsLastHitable then
            return self:GetLastHitTarget()
        end
        if self:ShouldWait() then
            return nil
        end
        if LastHitPriority and LaneClearHeroes then
            local hero = Target:GetComboTarget()
            if hero ~= nil then
                return hero
            end
        end
        
        -- lane minion
        local laneMinion = self:GetLaneMinion()
        if laneMinion ~= nil then
            self.LaneClearHandle = laneMinion.handle
            return laneMinion
        end
        
        -- ward
        if other ~= nil then
            return other
        end
    end
    return nil
end

--OK
Math =
{
}

function Math:PointOnSegment
    (p, p1, p2)
    
    local result =
    {
        IsOnSegment = false,
        PointSegment = nil,
        PointLine = nil,
        Point = 0,
    }
    local px, pz = p.x, (p.z or p.y)
    local ax, az = p1.x, (p1.z or p1.y)
    local bx, bz = p2.x, (p2.z or p2.y)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    result.PointLine = {x = ax + t * bxax, y = az + t * bzaz}
    if t < 0 then
        result.IsOnSegment = false
        result.PointSegment = p1
        result.Point = 1
    elseif t > 1 then
        result.IsOnSegment = false
        result.PointSegment = p2
        result.Point = 2
    else
        result.IsOnSegment = true
        result.PointSegment = result.PointLine
    end
    return result
end

function Math:RadianToDegree
    (angle)
    
    return angle * (180.0 / math.pi)
end

function Math:Polar
    (v1)
    
    local x = v1.x
    local z = v1.z or v1.y
    if x == 0 then
        if z > 0 then
            return 90
        end
        return z < 0 and 270 or 0
    end
    local theta = self:RadianToDegree(math.atan(z / x))
    if x < 0 then
        theta = theta + 180
    end
    if theta < 0 then
        theta = theta + 360
    end
    return theta
end

function Math:AngleBetween
    (vec1, vec2)
    
    local theta = self:Polar(vec1) - self:Polar(vec2)
    if theta < 0 then
        theta = theta + 360
    end
    if theta > 180 then
        theta = 360 - theta
    end
    return theta
end

function Math:EqualVector
    (vec1, vec2)
    
    local diffX = vec1.x - vec2.x
    local diffZ = (vec1.z or vec1.y) - (vec2.z or vec2.y)
    if diffX >= -10 and diffX <= 10 and diffZ >= -10 and diffZ <= 10 then
        return true
    end
    return false
end

function Math:Quad
    (a, b, c)
    
    local sol = nil
    if (math.abs(a) < 1e-6) then
        if (math.abs(b) < 1e-6) then
            if (math.abs(c) < 1e-6) then
                sol = {0, 0}
            end
        else
            sol = {-c / b, -c / b}
        end
    else
        local disc = b * b - 4 * a * c
        if (disc >= 0) then
            disc = math.sqrt(disc)
            local a = 2 * a
            sol = {(-b - disc) / a, (-b + disc) / a}
        end
    end
    return sol
end

function Math:Intercept
    (src, spos, epos, sspeed, tspeed)
    
    local dx = epos.x - spos.x
    local dz = epos.z - spos.z
    local magnitude = math.sqrt(dx * dx + dz * dz)
    local tx = spos.x - src.x
    local tz = spos.z - src.z
    local tvx = (dx / magnitude) * tspeed
    local tvz = (dz / magnitude) * tspeed
    
    local a = tvx * tvx + tvz * tvz - sspeed * sspeed
    local b = 2 * (tvx * tx + tvz * tz)
    local c = tx * tx + tz * tz
    
    local ts = self:Quad(a, b, c)
    
    local sol = nil
    if (ts) then
        local t0 = ts[1]
        local t1 = ts[2]
        local t = math.min(t0, t1)
        if (t < 0) then
            t = math.max(t0, t1)
        end
        if (t > 0) then
            sol = t
        end
    end
    
    return sol
end

function Math:IsInRange
    (v1, v2, range)
    
    v1 = v1.pos or v1
    v2 = v2.pos or v2
    local dx = v1.x - v2.x
    local dz = (v1.z or v1.y) - (v2.z or v2.y)
    if dx * dx + dz * dz <= range * range then
        return true
    end
    return false
end

function Math:GetDistanceSquared
    (v1, v2)
    
    v1 = v1.pos or v1
    v2 = v2.pos or v2
    local dx = v1.x - v2.x
    local dz = (v1.z or v1.y) - (v2.z or v2.y)
    return dx * dx + dz * dz
end

function Math:InsidePolygon
    (polygon, point)
    
    local result = false
    local j = #polygon
    point = point.pos or point
    local pointx = point.x
    local pointz = point.z or point.y
    for i = 1, #polygon do
        if (polygon[i].z < pointz and polygon[j].z >= pointz or polygon[j].z < pointz and polygon[i].z >= pointz) then
            if (polygon[i].x + (pointz - polygon[i].z) / (polygon[j].z - polygon[i].z) * (polygon[j].x - polygon[i].x) < pointx) then
                result = not result
            end
        end
        j = i
    end
    return result
end

function Math:GetDistance
    (v1, v2)
    
    v1 = v1.pos or v1
    v2 = v2.pos or v2
    local dx = v1.x - v2.x
    local dz = (v1.z or v1.y) - (v2.z or v2.y)
    return math.sqrt(dx * dx + dz * dz)
end

function Math:EqualDirection
    (vec1, vec2)
    
    return self:AngleBetween(vec1, vec2) <= 5
end

function Math:Normalized
    (vec1, vec2)
    
    local vec = {x = vec1.x - vec2.x, y = 0, z = (vec1.z or vec1.y) - (vec2.z or vec2.y)}
    local length = math.sqrt(vec.x * vec.x + vec.z * vec.z)
    if length > 0 then
        local inv = 1.0 / length
        return Vector(vec.x * inv, 0, vec.z * inv)
    end
    return Vector(0, 0, 0)
end

function Math:Extended
    (vec, dir, range)
    
    local vecz = vec.z or vec.y
    local dirz = dir.z or dir.y
    return Vector(vec.x + dir.x * range, 0, vecz + dirz * range)
end

function Math:IsFacing
    (source, target, angle)
    
    angle = angle or 90
    target = target.pos or Vector(target)
    if self:AngleBetween(source.dir, target - source.pos) < angle then
        return true
    end
    return false
end

function Math:IsBothFacing
    (source, target, angle)
    
    if self:IsFacing(source, target, angle) and self:IsFacing(target, source, angle) then
        return true
    end
    return false
end

function Math:ProjectOn
    (p, p1, p2)
    
    local isOnSegment, pointSegment, pointLine
    local px, pz = p.x, (p.z or p.y)
    local ax, az = p1.x, (p1.z or p1.y)
    local bx, bz = p2.x, (p2.z or p2.y)
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    local pointLine = {x = ax + t * bxax, y = az + t * bzaz}
    if t < 0 then
        isOnSegment = false
        pointSegment = p1
    elseif t > 1 then
        isOnSegment = false
        pointSegment = p2
    else
        isOnSegment = true
        pointSegment = pointLine
    end
    return isOnSegment, pointSegment, pointLine
end

Data =
{
    JungleTeam =
    300,
    
    AllyTeam =
    myHero.team,
    
    EnemyTeam =
    300 - myHero.team,
    
    HeroName =
    myHero.charName:lower(),
    
    ChannelingBuffs =
    {
        ['caitlyn'] = function()
            return Buff:HasBuff(myHero, 'CaitlynAceintheHole')
        end,
        ['fiddlesticks'] = function()
            return Buff:HasBuff(myHero, 'Drain') or Buff:HasBuff(myHero, 'Crowstorm')
        end,
        ['galio'] = function()
            return Buff:HasBuff(myHero, 'GalioIdolOfDurand')
        end,
        ['janna'] = function()
            return Buff:HasBuff(myHero, 'ReapTheWhirlwind')
        end,
        ['kaisa'] = function()
            return Buff:HasBuff(myHero, 'KaisaE')
        end,
        ['karthus'] = function()
            return Buff:HasBuff(myHero, 'karthusfallenonecastsound')
        end,
        ['katarina'] = function()
            return Buff:HasBuff(myHero, 'katarinarsound')
        end,
        ['lucian'] = function()
            return Buff:HasBuff(myHero, 'LucianR')
        end,
        ['malzahar'] = function()
            return Buff:HasBuff(myHero, 'alzaharnethergraspsound')
        end,
        ['masteryi'] = function()
            return Buff:HasBuff(myHero, 'Meditate')
        end,
        ['missfortune'] = function()
            return Buff:HasBuff(myHero, 'missfortunebulletsound')
        end,
        ['nunu'] = function()
            return Buff:HasBuff(myHero, 'AbsoluteZero')
        end,
        ['pantheon'] = function()
            return Buff:HasBuff(myHero, 'pantheonesound') or Buff:HasBuff(myHero, 'PantheonRJump')
        end,
        ['shen'] = function()
            return Buff:HasBuff(myHero, 'shenstandunitedlock')
        end,
        ['twistedfate'] = function()
            return Buff:HasBuff(myHero, 'Destiny')
        end,
        ['urgot'] = function()
            return Buff:HasBuff(myHero, 'UrgotSwap2')
        end,
        ['varus'] = function()
            return Buff:HasBuff(myHero, 'VarusQ')
        end,
        ['velkoz'] = function()
            return Buff:HasBuff(myHero, 'VelkozR')
        end,
        ['vi'] = function()
            return Buff:HasBuff(myHero, 'ViQ')
        end,
        ['vladimir'] = function()
            return Buff:HasBuff(myHero, 'VladimirE')
        end,
        ['warwick'] = function()
            return Buff:HasBuff(myHero, 'infiniteduresssound')
        end,
        ['xerath'] = function()
            return Buff:HasBuff(myHero, 'XerathArcanopulseChargeUp') or Buff:HasBuff(myHero, 'XerathLocusOfPower2')
        end,
    },
    
    SpecialWindup =
    {
        ['twistedfate'] = function()
            if Buff:HasBuff(myHero, 'BlueCardPreAttack') or Buff:HasBuff(myHero, 'RedCardPreAttack') or Buff:HasBuff(myHero, 'GoldCardPreAttack') then
                return 0.125
            end
            return nil
        end,
        ['jayce'] = function()
            if Buff:HasBuff(myHero, 'JayceHyperCharge') then
                return 0.125
            end
            return nil
        end
    },
    
    AllowMovement =
    {
        ['kaisa'] = function()
            return Buff:HasBuff(myHero, 'KaisaE')
        end,
        ['lucian'] = function()
            return Buff:HasBuff(myHero, 'LucianR')
        end,
        ['varus'] = function()
            return Buff:HasBuff(myHero, 'VarusQ')
        end,
        ['vi'] = function()
            return Buff:HasBuff(myHero, 'ViQ')
        end,
        ['vladimir'] = function()
            return Buff:HasBuff(myHero, 'VladimirE')
        end,
        ['xerath'] = function()
            return Buff:HasBuff(myHero, 'XerathArcanopulseChargeUp')
        end,
    },
    
    DisableAttackBuffs =
    {
        ['urgot'] = function()
            return Buff:HasBuff(myHero, 'UrgotW')
        end,
        ['darius'] = function()
            return Buff:HasBuff(myHero, 'dariusqcast')
        end,
        ['graves'] = function()
            if myHero.hudAmmo == 0 then
                return true
            end
            return false
        end,
        ['jhin'] = function()
            if Buff:HasBuff(myHero, 'JhinPassiveReload') then
                return true
            end
            if myHero.hudAmmo == 0 then
                return true
            end
            return false
        end,
    },
    
    SpecialMissileSpeeds =
    {
        ['caitlyn'] = function()
            if Buff:HasBuff(myHero, 'caitlynheadshot') then
                return 3000
            end
            return nil
        end,
        ['graves'] = function()
            return 3800
        end,
        ['illaoi'] = function()
            if Buff:HasBuff(myHero, 'IllaoiW') then
                return 1600
            end
            return nil
        end,
        ['jayce'] = function()
            if Buff:HasBuff(myHero, 'jaycestancegun') then
                return 2000
            end
            return nil
        end,
        ['jhin'] = function()
            if Buff:HasBuff(myHero, 'jhinpassiveattackbuff') then
                return 3000
            end
            return nil
        end,
        ['jinx'] = function()
            if Buff:HasBuff(myHero, 'JinxQ') then
                return 2000
            end
            return nil
        end,
        ['poppy'] = function()
            if Buff:HasBuff(myHero, 'poppypassivebuff') then
                return 1600
            end
            return nil
        end,
        ['twitch'] = function()
            if Buff:HasBuff(myHero, 'TwitchFullAutomatic') then
                return 4000
            end
            return nil
        end,
        ['kayle'] = function()
            if Buff:HasBuff(myHero, 'KayleE') then
                return 1750
            end
            return nil
        end,
    },
    
    --9.13.1
    HeroNames =
    {
        ['practicetool_targetdummy'] = true,
        ['aatrox'] = true,
        ['ahri'] = true,
        ['akali'] = true,
        ['alistar'] = true,
        ['amumu'] = true,
        ['anivia'] = true,
        ['annie'] = true,
        ['ashe'] = true,
        ['aurelionsol'] = true,
        ['azir'] = true,
        ['bard'] = true,
        ['blitzcrank'] = true,
        ['brand'] = true,
        ['braum'] = true,
        ['caitlyn'] = true,
        ['camille'] = true,
        ['cassiopeia'] = true,
        ['chogath'] = true,
        ['corki'] = true,
        ['darius'] = true,
        ['diana'] = true,
        ['draven'] = true,
        ['drmundo'] = true,
        ['ekko'] = true,
        ['elise'] = true,
        ['evelynn'] = true,
        ['ezreal'] = true,
        ['fiddlesticks'] = true,
        ['fiora'] = true,
        ['fizz'] = true,
        ['galio'] = true,
        ['gangplank'] = true,
        ['garen'] = true,
        ['gnar'] = true,
        ['gragas'] = true,
        ['graves'] = true,
        ['hecarim'] = true,
        ['heimerdinger'] = true,
        ['illaoi'] = true,
        ['irelia'] = true,
        ['ivern'] = true,
        ['janna'] = true,
        ['jarvaniv'] = true,
        ['jax'] = true,
        ['jayce'] = true,
        ['jhin'] = true,
        ['jinx'] = true,
        ['kaisa'] = true,
        ['kalista'] = true,
        ['karma'] = true,
        ['karthus'] = true,
        ['kassadin'] = true,
        ['katarina'] = true,
        ['kayle'] = true,
        ['kayn'] = true,
        ['kennen'] = true,
        ['khazix'] = true,
        ['kindred'] = true,
        ['kled'] = true,
        ['kogmaw'] = true,
        ['leblanc'] = true,
        ['leesin'] = true,
        ['leona'] = true,
        ['lissandra'] = true,
        ['lucian'] = true,
        ['lulu'] = true,
        ['lux'] = true,
        ['malphite'] = true,
        ['malzahar'] = true,
        ['maokai'] = true,
        ['masteryi'] = true,
        ['missfortune'] = true,
        ['monkeyking'] = true,
        ['mordekaiser'] = true,
        ['morgana'] = true,
        ['nami'] = true,
        ['nasus'] = true,
        ['nautilus'] = true,
        ['neeko'] = true,
        ['nidalee'] = true,
        ['nocturne'] = true,
        ['nunu'] = true,
        ['olaf'] = true,
        ['orianna'] = true,
        ['ornn'] = true,
        ['pantheon'] = true,
        ['poppy'] = true,
        ['pyke'] = true,
        ['qiyana'] = true,
        ['quinn'] = true,
        ['rakan'] = true,
        ['rammus'] = true,
        ['reksai'] = true,
        ['renekton'] = true,
        ['rengar'] = true,
        ['riven'] = true,
        ['rumble'] = true,
        ['ryze'] = true,
        ['sejuani'] = true,
        ['shaco'] = true,
        ['shen'] = true,
        ['shyvana'] = true,
        ['singed'] = true,
        ['sion'] = true,
        ['sivir'] = true,
        ['skarner'] = true,
        ['sona'] = true,
        ['soraka'] = true,
        ['swain'] = true,
        ['sylas'] = true,
        ['syndra'] = true,
        ['tahmkench'] = true,
        ['taliyah'] = true,
        ['talon'] = true,
        ['taric'] = true,
        ['teemo'] = true,
        ['thresh'] = true,
        ['tristana'] = true,
        ['trundle'] = true,
        ['tryndamere'] = true,
        ['twistedfate'] = true,
        ['twitch'] = true,
        ['udyr'] = true,
        ['urgot'] = true,
        ['varus'] = true,
        ['vayne'] = true,
        ['veigar'] = true,
        ['velkoz'] = true,
        ['vi'] = true,
        ['viktor'] = true,
        ['vladimir'] = true,
        ['volibear'] = true,
        ['warwick'] = true,
        ['xayah'] = true,
        ['xerath'] = true,
        ['xinzhao'] = true,
        ['yasuo'] = true,
        ['yorick'] = true,
        ['yuumi'] = true,
        ['zac'] = true,
        ['zed'] = true,
        ['ziggs'] = true,
        ['zilean'] = true,
        ['zoe'] = true,
        ['zyra'] = true,
    },
    
    --9.13.1
    HeroPriorities =
    {
        ['aatrox'] = 3,
        ['ahri'] = 4,
        ['akali'] = 4,
        ['alistar'] = 1,
        ['amumu'] = 1,
        ['anivia'] = 4,
        ['annie'] = 4,
        ['ashe'] = 5,
        ['aurelionsol'] = 4,
        ['azir'] = 4,
        ['bard'] = 3,
        ['blitzcrank'] = 1,
        ['brand'] = 4,
        ['braum'] = 1,
        ['caitlyn'] = 5,
        ['camille'] = 3,
        ['cassiopeia'] = 4,
        ['chogath'] = 1,
        ['corki'] = 5,
        ['darius'] = 2,
        ['diana'] = 4,
        ['draven'] = 5,
        ['drmundo'] = 1,
        ['ekko'] = 4,
        ['elise'] = 3,
        ['evelynn'] = 4,
        ['ezreal'] = 5,
        ['fiddlesticks'] = 3,
        ['fiora'] = 3,
        ['fizz'] = 4,
        ['galio'] = 1,
        ['gangplank'] = 4,
        ['garen'] = 1,
        ['gnar'] = 1,
        ['gragas'] = 2,
        ['graves'] = 4,
        ['hecarim'] = 2,
        ['heimerdinger'] = 3,
        ['illaoi'] = 3,
        ['irelia'] = 3,
        ['ivern'] = 1,
        ['janna'] = 2,
        ['jarvaniv'] = 3,
        ['jax'] = 3,
        ['jayce'] = 4,
        ['jhin'] = 5,
        ['jinx'] = 5,
        ['kaisa'] = 5,
        ['kalista'] = 5,
        ['karma'] = 4,
        ['karthus'] = 4,
        ['kassadin'] = 4,
        ['katarina'] = 4,
        ['kayle'] = 4,
        ['kayn'] = 4,
        ['kennen'] = 4,
        ['khazix'] = 4,
        ['kindred'] = 4,
        ['kled'] = 2,
        ['kogmaw'] = 5,
        ['leblanc'] = 4,
        ['leesin'] = 3,
        ['leona'] = 1,
        ['lissandra'] = 4,
        ['lucian'] = 5,
        ['lulu'] = 3,
        ['lux'] = 4,
        ['malphite'] = 1,
        ['malzahar'] = 3,
        ['maokai'] = 2,
        ['masteryi'] = 5,
        ['missfortune'] = 5,
        ['monkeyking'] = 3,
        ['mordekaiser'] = 4,
        ['morgana'] = 3,
        ['nami'] = 3,
        ['nasus'] = 2,
        ['nautilus'] = 1,
        ['neeko'] = 4,
        ['nidalee'] = 4,
        ['nocturne'] = 4,
        ['nunu'] = 2,
        ['olaf'] = 2,
        ['orianna'] = 4,
        ['ornn'] = 2,
        ['pantheon'] = 3,
        ['poppy'] = 2,
        ['pyke'] = 4,
        ['qiyana'] = 4,
        ['quinn'] = 5,
        ['rakan'] = 3,
        ['rammus'] = 1,
        ['reksai'] = 2,
        ['renekton'] = 2,
        ['rengar'] = 4,
        ['riven'] = 4,
        ['rumble'] = 4,
        ['ryze'] = 4,
        ['sejuani'] = 2,
        ['shaco'] = 4,
        ['shen'] = 1,
        ['shyvana'] = 2,
        ['singed'] = 1,
        ['sion'] = 1,
        ['sivir'] = 5,
        ['skarner'] = 2,
        ['sona'] = 3,
        ['soraka'] = 3,
        ['swain'] = 3,
        ['sylas'] = 4,
        ['syndra'] = 4,
        ['tahmkench'] = 1,
        ['taliyah'] = 4,
        ['talon'] = 4,
        ['taric'] = 1,
        ['teemo'] = 4,
        ['thresh'] = 1,
        ['tristana'] = 5,
        ['trundle'] = 2,
        ['tryndamere'] = 4,
        ['twistedfate'] = 4,
        ['twitch'] = 5,
        ['udyr'] = 2,
        ['urgot'] = 2,
        ['varus'] = 5,
        ['vayne'] = 5,
        ['veigar'] = 4,
        ['velkoz'] = 4,
        ['vi'] = 2,
        ['viktor'] = 4,
        ['vladimir'] = 3,
        ['volibear'] = 2,
        ['warwick'] = 2,
        ['xayah'] = 5,
        ['xerath'] = 4,
        ['xinzhao'] = 3,
        ['yasuo'] = 4,
        ['yorick'] = 2,
        ['yuumi'] = 3,
        ['zac'] = 1,
        ['zed'] = 4,
        ['ziggs'] = 4,
        ['zilean'] = 3,
        ['zoe'] = 4,
        ['zyra'] = 2,
    },
    
    -- 9.13.1
    HeroMelees =
    {
        ['aatrox'] = true,
        ['ahri'] = false,
        ['akali'] = true,
        ['alistar'] = true,
        ['amumu'] = true,
        ['anivia'] = false,
        ['annie'] = false,
        ['ashe'] = false,
        ['aurelionsol'] = false,
        ['azir'] = true,
        ['bard'] = false,
        ['blitzcrank'] = true,
        ['brand'] = false,
        ['braum'] = true,
        ['caitlyn'] = false,
        ['camille'] = true,
        ['cassiopeia'] = false,
        ['chogath'] = true,
        ['corki'] = false,
        ['darius'] = true,
        ['diana'] = true,
        ['draven'] = false,
        ['drmundo'] = true,
        ['ekko'] = true,
        ['elise'] = false,
        ['evelynn'] = true,
        ['ezreal'] = false,
        ['fiddlesticks'] = false,
        ['fiora'] = true,
        ['fizz'] = true,
        ['galio'] = true,
        ['gangplank'] = true,
        ['garen'] = true,
        ['gnar'] = false,
        ['gragas'] = true,
        ['graves'] = false,
        ['hecarim'] = true,
        ['heimerdinger'] = false,
        ['illaoi'] = true,
        ['irelia'] = true,
        ['ivern'] = true,
        ['janna'] = false,
        ['jarvaniv'] = true,
        ['jax'] = true,
        ['jayce'] = false,
        ['jhin'] = false,
        ['jinx'] = false,
        ['kaisa'] = false,
        ['kalista'] = false,
        ['karma'] = false,
        ['karthus'] = false,
        ['kassadin'] = true,
        ['katarina'] = true,
        ['kayle'] = false,
        ['kayn'] = true,
        ['kennen'] = false,
        ['khazix'] = true,
        ['kindred'] = false,
        ['kled'] = true,
        ['kogmaw'] = false,
        ['leblanc'] = false,
        ['leesin'] = true,
        ['leona'] = true,
        ['lissandra'] = false,
        ['lucian'] = false,
        ['lulu'] = false,
        ['lux'] = false,
        ['malphite'] = true,
        ['malzahar'] = false,
        ['maokai'] = true,
        ['masteryi'] = true,
        ['missfortune'] = false,
        ['monkeyking'] = true,
        ['mordekaiser'] = true,
        ['morgana'] = false,
        ['nami'] = false,
        ['nasus'] = true,
        ['nautilus'] = true,
        ['neeko'] = false,
        ['nidalee'] = false,
        ['nocturne'] = true,
        ['nunu'] = true,
        ['olaf'] = true,
        ['orianna'] = false,
        ['ornn'] = true,
        ['pantheon'] = true,
        ['poppy'] = true,
        ['pyke'] = true,
        ['qiyana'] = true,
        ['quinn'] = false,
        ['rakan'] = true,
        ['rammus'] = true,
        ['reksai'] = true,
        ['renekton'] = true,
        ['rengar'] = true,
        ['riven'] = true,
        ['rumble'] = true,
        ['ryze'] = false,
        ['sejuani'] = true,
        ['shaco'] = true,
        ['shen'] = true,
        ['shyvana'] = true,
        ['singed'] = true,
        ['sion'] = true,
        ['sivir'] = false,
        ['skarner'] = true,
        ['sona'] = false,
        ['soraka'] = false,
        ['swain'] = false,
        ['sylas'] = true,
        ['syndra'] = false,
        ['tahmkench'] = true,
        ['taliyah'] = false,
        ['talon'] = true,
        ['taric'] = true,
        ['teemo'] = false,
        ['thresh'] = true,
        ['tristana'] = false,
        ['trundle'] = true,
        ['tryndamere'] = true,
        ['twistedfate'] = false,
        ['twitch'] = false,
        ['udyr'] = true,
        ['urgot'] = true,
        ['varus'] = false,
        ['vayne'] = false,
        ['veigar'] = false,
        ['velkoz'] = false,
        ['vi'] = true,
        ['viktor'] = false,
        ['vladimir'] = false,
        ['volibear'] = true,
        ['warwick'] = true,
        ['xayah'] = false,
        ['xerath'] = false,
        ['xinzhao'] = true,
        ['yasuo'] = true,
        ['yorick'] = true,
        ['yuumi'] = false,
        ['zac'] = true,
        ['zed'] = true,
        ['ziggs'] = false,
        ['zilean'] = false,
        ['zoe'] = false,
        ['zyra'] = false,
    },
    
    HeroSpecialMelees =
    {
        ['elise'] = function()
            return myHero.range < 200
        end,
        ['gnar'] = function()
            return myHero.range < 200
        end,
        ['jayce'] = function()
            return myHero.range < 200
        end,
        ['kayle'] = function()
            return myHero.range < 200
        end,
        ['nidalee'] = function()
            return myHero.range < 200
        end,
    },
    
    IsAttackSpell =
    {
        ['CaitlynHeadshotMissile'] = true,
        ['GarenQAttack'] = true,
        ['KennenMegaProc'] = true,
        ['MordekaiserQAttack'] = true,
        ['MordekaiserQAttack1'] = true,
        ['MordekaiserQAttack2'] = true,
        ['QuinnWEnhanced'] = true,
        ['BlueCardPreAttack'] = true,
        ['RedCardPreAttack'] = true,
        ['GoldCardPreAttack'] = true,
        -- 9.9 patch
        ['RenektonSuperExecute'] = true,
        ['RenektonExecute'] = true,
        ['XinZhaoQThrust1'] = true,
        ['XinZhaoQThrust2'] = true,
        ['XinZhaoQThrust3'] = true,
        ['MasterYiDoubleStrike'] = true,
    },
    
    IsNotAttack =
    {
        ['GravesAutoAttackRecoil'] = true,
        ['LeonaShieldOfDaybreakAttack'] = true,
    },
    
    MinionRange =
    {
        ["SRU_ChaosMinionMelee"] = 110,
        ["SRU_ChaosMinionRanged"] = 550,
        ["SRU_ChaosMinionSiege"] = 300,
        ["SRU_ChaosMinionSuper"] = 170,
        ["SRU_OrderMinionMelee"] = 110,
        ["SRU_OrderMinionRanged"] = 550,
        ["SRU_OrderMinionSiege"] = 300,
        ["SRU_OrderMinionSuper"] = 170,
        ["HA_ChaosMinionMelee"] = 110,
        ["HA_ChaosMinionRanged"] = 550,
        ["HA_ChaosMinionSiege"] = 300,
        ["HA_ChaosMinionSuper"] = 170,
        ["HA_OrderMinionMelee"] = 110,
        ["HA_OrderMinionRanged"] = 550,
        ["HA_OrderMinionSiege"] = 300,
        ["HA_OrderMinionSuper"] = 170,
    },
    
    ExtraAttackRanges =
    {
        ["caitlyn"] = function(target)
            if target and Buff:HasBuff(target, "caitlynyordletrapinternal") then
                return 650
            end
            return 0
        end,
    },
    
    AttackResets =
    {
        ["blitzcrank"] = {Slot = _E, Key = HK_E},
        ["camille"] = {Slot = _Q, Key = HK_Q},
        ["chogath"] = {Slot = _E, Key = HK_E},
        ["darius"] = {Slot = _W, Key = HK_W},
        ["drmundo"] = {Slot = _E, Key = HK_E},
        ["elise"] = {Slot = _W, Key = HK_W, Name = "EliseSpiderW"},
        ["fiora"] = {Slot = _E, Key = HK_E},
        ["garen"] = {Slot = _Q, Key = HK_Q},
        ["graves"] = {Slot = _E, Key = HK_E, OnCast = true, CanCancel = true},
        ["kassadin"] = {Slot = _W, Key = HK_W},
        ["illaoi"] = {Slot = _W, Key = HK_W},
        ["jax"] = {Slot = _W, Key = HK_W},
        ["jayce"] = {Slot = _W, Key = HK_W, Name = "JayceHyperCharge"},
        ["kayle"] = {Slot = _E, Key = HK_E},
        ["katarina"] = {Slot = _E, Key = HK_E, CanCancel = true, OnCast = true},
        ["kindred"] = {Slot = _Q, Key = HK_Q},
        ["leona"] = {Slot = _Q, Key = HK_Q},
        ['lucian'] = {Slot = _E, Key = HK_E, Buff = 'LucianPassiveBuff', OnCast = true, CanCancel = true},
        ["masteryi"] = {Slot = _W, Key = HK_W},
        ["mordekaiser"] = {Slot = _Q, Key = HK_Q},
        ["nautilus"] = {Slot = _W, Key = HK_W},
        ["nidalee"] = {Slot = _Q, Key = HK_Q, Name = "Takedown"},
        ["nasus"] = {Slot = _Q, Key = HK_Q},
        ["reksai"] = {Slot = _Q, Key = HK_Q, Name = "RekSaiQ"},
        ["renekton"] = {Slot = _W, Key = HK_W},
        ["rengar"] = {Slot = _Q, Key = HK_Q},
        ["riven"] = {Slot = _Q, Key = HK_Q},
        -- RIVEN BUFFS ["riven"] = {'riventricleavesoundone', 'riventricleavesoundtwo', 'riventricleavesoundthree'},
        ["sejuani"] = {Slot = _E, Key = HK_E, ReadyCheck = true, ActiveCheck = true, SpellName = "SejuaniE2"},
        ["sivir"] = {Slot = _W, Key = HK_W},
        ["trundle"] = {Slot = _Q, Key = HK_Q},
        ["vayne"] = {Slot = _Q, Key = HK_Q, Buff = {'vaynetumblebonus'}, CanCancel = true},
        ["vi"] = {Slot = _E, Key = HK_E},
        ["volibear"] = {Slot = _Q, Key = HK_Q},
        ["monkeyking"] = {Slot = _Q, Key = HK_Q},
        ["xinzhao"] = {Slot = _Q, Key = HK_Q},
        ["yorick"] = {Slot = _Q, Key = HK_Q},
    },
}

function Data:Init
    ()
    self.IsChanneling = self.ChannelingBuffs[self.HeroName]
    self.CanDisableMove = self.AllowMovement[self.HeroName]
    self.CanDisableAttack = self.DisableAttackBuffs[self.HeroName]
    self.SpecialMissileSpeed = self.SpecialMissileSpeeds[self.HeroName]
    self.IsHeroMelee = self.HeroMelees[self.HeroName]
    self.IsHeroSpecialMelee = self.HeroSpecialMelees[self.HeroName]
    self.ExtraAttackRange = self.ExtraAttackRanges[self.HeroName]
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Data:OnLoad()
    self.AttackReset = self.AttackResets[self.HeroName]
    if self.AttackReset then
        self.AttackResetSuccess = false
        self.AttackResetSlot = self.AttackReset.Slot
        self.AttackResetBuff = self.AttackReset.Buff
        self.AttackResetOnCast = self.AttackReset.OnCast
        self.AttackResetCanCancel = self.AttackReset.CanCancel
        self.AttackResetTimer = 0
        self.AttackResetTimeout = 0
        local AttackResetKey = self.AttackReset.Key
        local AttackResetActiveSpell = self.AttackReset.ActiveCheck
        local AttackResetIsReady = self.AttackReset.ReadyCheck
        local AttackResetName = self.AttackReset.Name
        local AttackResetSpellName = self.AttackReset.SpellName
        local X, T = 0, 0
        if not self.AttackResetCanCancel then--and not Object.IsRiven then
            table.insert(SDK.WndMsg, function(msg, wParam)
                if not self.AttackResetSuccess and not Control.IsKeyDown(HK_LUS) and not Game.IsChatOpen() and wParam == AttackResetKey then
                    local checkNum = Object.IsRiven and 400 or 600
                    if GetTickCount() <= self.AttackResetTimer + checkNum then
                        return
                    end
                    if AttackResetIsReady and Game.CanUseSpell(self.AttackResetSlot) ~= 0 then
                        return
                    end
                    local spellData = myHero:GetSpellData(self.AttackResetSlot)
                    if (Object.IsRiven or spellData.mana <= myHero.mana) and spellData.currentCd == 0 and (not AttackResetName or spellData.name == AttackResetName) then
                        if AttackResetActiveSpell then
                            self.AttackResetTimer = GetTickCount()
                            local startTime = GetTickCount() + 400
                            Action:Add(function()
                                local s = myHero.activeSpell
                                if s and s.valid and s.name == AttackResetSpellName then
                                    self.AttackResetTimer = GetTickCount()
                                    self.AttackResetSuccess = true
                                    --print("Attack Reset ActiveSpell")
                                    --print(startTime - GetTickCount())
                                    return true
                                end
                                if GetTickCount() < startTime then
                                    return false
                                end
                                return true
                            end)
                            return
                        end
                        
                        self.AttackResetTimer = GetTickCount()
                        
                        if Object.IsKindred then
                            Orbwalker:SetMovement(false)
                            local setTime = GetTickCount() + 550
                            -- SET ATTACK
                            Action:Add(function()
                                if GetTickCount() < setTime then
                                    return false
                                end
                                --print("Move True Kindred")
                                Orbwalker:SetMovement(true)
                                return true
                            end)
                            return
                        end
                        
                        self.AttackResetSuccess = true
                        --print("Attack Reset")
                        
                        -- RIVEN
                        if Object.IsRiven then
                            X = X + 1
                            if X == 1 then
                                T = GetTickCount()
                            end
                            if X == 3 then
                                --print(GetTickCount() - T)
                            end
                            local isThree = Buff:HasBuff(myHero, 'riventricleavesoundtwo')
                            if isThree then
                                X = 0
                            end
                            local riven_start = GetTickCount() + 450 + (isThree and 100 or 0) - LATENCY
                            Action:Add(function()
                                if GetTickCount() < riven_start then
                                    if Cursor.Step == 0 then
                                        Cursor.MoveTimer = 0
                                        Control.Move()
                                    end
                                    return false
                                end
                                Orbwalker:SetAttack(true)
                                Attack.Reset = true
                                return true
                            end)
                            Orbwalker:SetAttack(false)
                            return
                        end
                    end
                end
            end)
        end
    end
end

function Data:IdEquals
    (a, b)
    if a == nil or b == nil then
        return false
    end
    return a.networkID == b.networkID
end

function Data:GetAutoAttackRange
    (from, target)
    local result = from.range
    local fromType = from.type
    if fromType == Obj_AI_Minion then
        local fromName = from.charName
        result = self.MinionRange[fromName] ~= nil and self.MinionRange[fromName] or 0
    elseif fromType == Obj_AI_Turret then
        result = 775
    end
    if target then
        local targetType = target.type
        if targetType == Obj_AI_Barracks then
            result = result + 270
        elseif targetType == Obj_AI_Nexus then
            result = result + 380
        else
            result = result + from.boundingRadius + target.boundingRadius
            if targetType == Obj_AI_Hero and self.ExtraAttackRange then
                result = result + self.ExtraAttackRange(target)
            end
        end
    else
        result = result + from.boundingRadius + 35
    end
    return result
end

function Data:IsInAutoAttackRange
    (from, target, extrarange)
    local range = extrarange or 0
    return Math:IsInRange(from.pos, target.pos, self:GetAutoAttackRange(from, target) + range)
end

function Data:IsInAutoAttackRange2
    (from, target, extrarange)
    local range = self:GetAutoAttackRange(from, target) + (extrarange or 0)
    if Math:IsInRange(from.pos, target.pos, range) and Math:IsInRange(from.pos, target.posTo, range) then
        return true
    end
    return false
end

function Data:CanResetAttack
    ()
    if self.AttackReset == nil then
        return false
    end
    
    if self.AttackResetCanCancel then
        if self.AttackResetOnCast then
            if self.AttackResetBuff == nil or Buff:HasBuff(myHero, self.AttackResetBuff) then
                local spellData = myHero:GetSpellData(self.AttackResetSlot)
                local startTime = spellData.castTime - spellData.cd
                if not self.AttackResetSuccess and Game.Timer() - startTime < 0.2 and GetTickCount() > self.AttackResetTimer + 1000 then
                    --print('Reset Cast, Buff')
                    self.AttackResetSuccess = true
                    self.AttackResetTimeout = GetTickCount()
                    self.AttackResetTimer = GetTickCount()
                    return true
                end
                if self.AttackResetSuccess and GetTickCount() > self.AttackResetTimeout + 200 then
                    --print('Reset Timeout')
                    self.AttackResetSuccess = false
                end
                return false
            end
        elseif Buff:ContainsBuffs(myHero, self.AttackResetBuff) then
            if not self.AttackResetSuccess then
                self.AttackResetSuccess = true
                --print('Reset Buff')
                return true
            end
            return false
        end
        if self.AttackResetSuccess then
            --print('Remove Reset')
            self.AttackResetSuccess = false
        end
        return false
    end
    
    if self.AttackResetSuccess then
        self.AttackResetSuccess = false
        --print("AA RESET STOP !")
        return true
    end
    
    return false
end

function Data:IsAttack
    (name)
    if self.IsAttackSpell[name] then
        return true
    end
    if self.IsNotAttack[name] then
        return false
    end
    return name:lower():find('attack')
end

function Data:GetLatency
    ()
    return LATENCY * 0.001
end

function Data:HeroCanMove
    ()
    if self.IsChanneling and self.IsChanneling() then
        if self.CanDisableMove == nil or (not self.CanDisableMove()) then
            return false
        end
    end
    return true
end

function Data:HeroCanAttack
    ()
    if self.IsChanneling and self.IsChanneling() then
        return false
    end
    if self.CanDisableAttack and self.CanDisableAttack() then
        return false
    end
    if Buff:HasBuffTypes(myHero, {[25] = true, [31] = true}) then
        return false
    end
    return true
end

function Data:IsMelee
    ()
    if self.IsHeroMelee or (self.IsHeroSpecialMelee and self.IsHeroSpecialMelee()) then
        return true
    end
    return false
end

function Data:GetHeroPriority
    (name)
    local p = self.HeroPriorities[name:lower()]
    return p and p or 5
end

function Data:GetHeroData
    (obj)
    if obj == nil then
        return {}
    end
    local id = obj.networkID
    if id == nil or id <= 0 then
        return {}
    end
    local name = obj.charName
    if name == nil or self.HeroNames[name:lower()] == nil then
        return {}
    end
    local team = obj.team
    local isEnemy = obj.isEnemy
    local isAlly = obj.isAlly
    if team == nil or team < 100 or team > 200 or isEnemy == nil or isAlly == nil or isEnemy == isAlly then
        return {}
    end
    return
    {
        Valid = true,
        IsEnemy = isEnemy,
        IsAlly = isAlly,
        NetworkID = id,
        CharName = name,
        Team = team,
    }
end

function Data:Join
    (t1, t2)
    
    local t = {}
    
    for i = 1, #t1 do
        table.insert(t, t1[i])
    end
    
    for i = 1, #t2 do
        table.insert(t, t2[i])
    end
    
    return t
end

function Data:IsUnit
    (unit)
    local type = unit.type
    if type == Obj_AI_Hero or type == Obj_AI_Minion or type == Obj_AI_Turret then
        return true
    end
    return false
end

function Data:GetTotalShield
    (obj)
    
    local shieldAd, shieldAp
    shieldAd = obj.shieldAD
    shieldAp = obj.shieldAP
    
    return (shieldAd and shieldAd or 0) + (shieldAp and shieldAp or 0)
end

function Data:TotalShieldHealth
    (target)
    
    local result = target.health + target.shieldAD + target.shieldAP
    --[[if target.charName == "Blitzcrank" then
            if not self:HasBuff(target, "manabarriercooldown") and not self:HasBuff(target, "manabarrier") then
                result = result + target.mana * 0.5
            end
        end--]]
    return result
end

function Data:GetBuildingBBox
    (unit)
    local type = unit.type
    if type == Obj_AI_Barracks then
        return 270
    end
    if type == Obj_AI_Nexus then
        return 380
    end
    return 0
end

function Data:IsAlly
    (unit)
    local team = unit.team
    if team == self.AllyTeam then
        return true
    end
    return false
end

function Data:IsEnemy
    (unit)
    local team = unit.team
    if team == self.EnemyTeam then
        return true
    end
    return false
end

function Data:IsJungle
    (unit)
    local team = unit.team
    if team == self.JungleTeam then
        return true
    end
    return false
end

function Data:IsOtherMinion
    (unit)
    if unit.maxHealth <= 6 then
        return true
    end
    return false
end

function Data:IsLaneMinion
    (unit)
    if not self:IsOtherMinion(unit) and not self:IsJungle(unit) then
        return true
    end
    return false
end

function Data:Stop
    ()
    
    return Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading) or JustEvade or (not Game.IsOnTop())
end

Spell =
{
}

function Spell:Init
    ()
    
    self.QTimer = 0
    self.WTimer = 0
    self.ETimer = 0
    self.RTimer = 0
    self.QkTimer = 0
    self.WkTimer = 0
    self.EkTimer = 0
    self.RkTimer = 0
    
    self.GameCanUseSpell = _G.Game.CanUseSpell
    _G.Game.CanUseSpell = function(spell)
        if self:IsReady(spell) then
            return 0
        end
        return 1
    end;
    
    table.insert(SDK.Load, function()
        self:OnLoad()
    end)
end

function Spell:OnLoad
    ()
    
    table.insert(SDK.WndMsg, function(msg, wParam)
        local timer = Game.Timer()
        
        if wParam == HK_Q then
            if timer > self.QkTimer + 0.33 and self.GameCanUseSpell(_Q) == 0 then
                self.QkTimer = timer
            end
            return
        end
        
        if wParam == HK_W then
            if timer > self.WkTimer + 0.33 and self.GameCanUseSpell(_W) == 0 then
                self.WkTimer = timer
            end
            return
        end
        
        if wParam == HK_E then
            if timer > self.EkTimer + 0.33 and self.GameCanUseSpell(_E) == 0 then
                self.EkTimer = timer
            end
            return
        end
        
        if wParam == HK_R then
            if timer > self.RkTimer + 0.33 and self.GameCanUseSpell(_R) == 0 then
                self.RkTimer = timer
            end
            return
        end
    end)
end

function Spell:IsReady
    (spell, delays)
    
    if Cursor.Step > 0 then
        return false
    end
    
    if delays ~= nil then
        local timer = Game.Timer()
        if timer < self.QTimer + delays.q or timer < self.QkTimer + delays.q then
            return false
        end
        if timer < self.WTimer + delays.w or timer < self.WkTimer + delays.w then
            return false
        end
        if timer < self.ETimer + delays.e or timer < self.EkTimer + delays.e then
            return false
        end
        if timer < self.RTimer + delays.r or timer < self.RkTimer + delays.r then
            return false
        end
    end
    
    if self.GameCanUseSpell(spell) ~= 0 then
        return false
    end
    
    return true
end

function Spell:GetLastSpellTimers
    ()
    
    return self.QTimer, self.QkTimer, self.WTimer, self.WkTimer, self.ETimer, self.EkTimer, self.RTimer, self.RkTimer
end

function Spell:CheckSpellDelays
    (delays)
    
    local timer = Game.Timer()
    if timer < self.QTimer + delays.q or timer < self.QkTimer + delays.q then
        return false
    end
    if timer < self.WTimer + delays.w or timer < self.WkTimer + delays.w then
        return false
    end
    if timer < self.ETimer + delays.e or timer < self.EkTimer + delays.e then
        return false
    end
    if timer < self.RTimer + delays.r or timer < self.RkTimer + delays.r then
        return false
    end
    return true
end

function Spell:CheckSpellDelays2
    (delays)
    
    local timer = Game.Timer()
    if timer < self.QTimer + delays[_Q] or timer < self.QkTimer + delays[_Q] then
        return false
    end
    if timer < self.WTimer + delays[_W] or timer < self.WkTimer + delays[_W] then
        return false
    end
    if timer < self.ETimer + delays[_E] or timer < self.EkTimer + delays[_E] then
        return false
    end
    if timer < self.RTimer + delays[_R] or timer < self.RkTimer + delays[_R] then
        return false
    end
    return true
end

function Spell:SpellClear
    (spell, spelldata, isReady, canLastHit, canLaneClear, getDrawMenu, getDamage)
    
    local c =
    {
        HK = 0,
        Radius = spelldata.Radius,
        Delay = spelldata.Delay,
        Speed = spelldata.Speed,
        Range = spelldata.Range,
        ShouldWaitTime = 0,
        IsLastHitable = false,
        LastHitHandle = 0,
        LaneClearHandle = 0,
        FarmMinions = {},
    }
    
    if spell == _Q then
        c.HK = HK_Q
    elseif spell == _W then
        c.HK = HK_W
    elseif spell == _E then
        c.HK = HK_E
    elseif spell == _R then
        c.HK = HK_R
    else
        print('SDK.Spell.SpellClear: error, spell must be _Q, _W, _E or _R')
        return
    end
    
    function c:GetLastHitTargets
        ()
        
        local result = {}
        
        for i, minion in pairs(self.FarmMinions) do
            if minion.LastHitable then
                local unit = minion.Minion
                if unit.handle ~= Health.LastHitHandle then
                    table.insert(result, unit)
                end
            end
        end
        
        return result
    end
    
    function c:GetLaneClearTargets
        ()
        
        local result = {}
        
        for i, minion in pairs(self.FarmMinions) do
            local unit = minion.Minion
            if unit.handle ~= Health.LaneClearHandle then
                table.insert(result, unit)
            end
        end
        
        return result
    end
    
    function c:ShouldWait
        ()
        
        return Game.Timer() <= self.ShouldWaitTime + 1
    end
    
    function c:SetLastHitable
        (target, time, damage)
        
        local hpPred = Health:GetPrediction(target, time)
        
        local lastHitable = false
        local almostLastHitable = false
        
        if hpPred - damage < 0 then
            lastHitable = true
            self.IsLastHitable = true
        elseif Health:GetPrediction(target, myHero:GetSpellData(spell).cd + (time * 3)) - damage < 0 then
            almostLastHitable = true
            self.ShouldWaitTime = Game.Timer()
        end
        
        return {LastHitable = lastHitable, Unkillable = hpPred < 0, Time = time, AlmostLastHitable = almostLastHitable, PredictedHP = hpPred, Minion = target}
    end
    
    function c:Reset()
        for i = 1, #self.FarmMinions do
            table.remove(self.FarmMinions, i)
        end
        self.IsLastHitable = false
        self.LastHitHandle = 0
        self.LaneClearHandle = 0
    end
    
    function c:Tick
        ()
        
        if Orbwalker:IsAutoAttacking() or not isReady() then
            return
        end
        
        local isLastHit = canLastHit() and (Orbwalker.Modes[Orbwalker.ORBWALKER_MODE_LASTHIT] or Orbwalker.Modes[Orbwalker.ORBWALKER_MODE_LANECLEAR])
        local isLaneClear = canLaneClear() and Orbwalker.Modes[Orbwalker.ORBWALKER_MODE_LANECLEAR]
        
        if not isLastHit and not isLaneClear then
            return
        end
        
        if Cursor.Step ~= 0 then
            return
        end
        
        if myHero:GetSpellData(spell).level == 0 then
            return
        end
        
        if myHero.mana < myHero:GetSpellData(spell).mana then
            return
        end
        
        if Game.CanUseSpell(spell) ~= 0 and myHero:GetSpellData(spell).currentCd > 0.5 then
            return
        end
        
        local targets = Object:GetEnemyMinions(self.Range - 35, false, true, true)
        for i = 1, #targets do
            local target = targets[i]
            table.insert(self.FarmMinions, self:SetLastHitable(target, self.Delay + target.distance / self.Speed + Data:GetLatency(), getDamage()))
        end
        
        if self.IsLastHitable and (isLastHit or isLaneClear) then
            local targets = self:GetLastHitTargets()
            for i = 1, #targets do
                local unit = targets[i]
                if unit.alive and unit:GetCollision(self.Radius + 35, self.Speed, self.Delay) == 1 then
                    if Control.CastSpell(self.HK, unit:GetPrediction(self.Speed, self.Delay)) then
                        self.LastHitHandle = unit.handle
                        Orbwalker:SetAttack(false)
                        Action:Add(function()
                            Orbwalker:SetAttack(true)
                        end, self.Delay + (unit.distance / self.Speed) + 0.05, 0)
                        break
                    end
                end
            end
        end
        
        if isLaneClear and self.LastHitHandle == 0 and not self:ShouldWait() then
            local targets = self:GetLaneClearTargets()
            for i = 1, #targets do
                local unit = targets[i]
                if unit.alive and unit:GetCollision(self.Radius + 35, self.Speed, self.Delay) == 1 then
                    if Control.CastSpell(self.HK, unit:GetPrediction(self.Speed, self.Delay)) then
                        self.LaneClearHandle = unit.handle
                    end
                end
            end
        end
        
        local lhmenu, lcmenu = getDrawMenu()
        if lhmenu.enabled:Value() or lcmenu.enabled:Value() then
            local targets = self.FarmMinions
            for i = 1, #targets do
                local minion = targets[i]
                if minion.LastHitable and lhmenu.enabled:Value() then
                    Draw.Circle(minion.Minion.pos, lhmenu.radius:Value(), lhmenu.width:Value(), lhmenu.color:Value())
                elseif minion.AlmostLastHitable and lcmenu.enabled:Value() then
                    Draw.Circle(minion.Minion.pos, lcmenu.radius:Value(), lcmenu.width:Value(), lcmenu.color:Value())
                end
            end
        end
    end
    
    Health:AddSpell(c)
end

--OK
Attack =
{
    TestDamage = false,
    
    TestCount = 0,
    TestStartTime = 0,
    
    SpecialWindup = Data.SpecialWindup[myHero.charName:lower()],
    
    HasLethalTempo = false,
    LethalTempoTimer = 0,
    
    AttackData =
    {
        windup = myHero.attackData.windUpTime,
        anim = myHero.attackData.animationTime,
        tickwindup = os.clock(),
        tickanim = os.clock(),
    },
    
    Reset = false,
    ServerStart = 0,
    CastEndTime = 1,
    LocalStart = 0,
    
    AttackWindup = 0,
    AttackAnimation = 0,
}

function Attack:OnTick
    ()
    
    --[[
        local s = ''
        for k,v in pairs(myHero:GetSpellData(_E)) do
            s = s .. k .. ': ' .. tostring(v) .. '\n'
        end
        Draw.Text(s, myHero.pos:To2D())
    ]]
    
    if Buff:HasBuffContainsName(myHero, 'lethaltempoemp') then
        self.HasLethalTempo = true
        self.LethalTempoTimer = GetTickCount()
    elseif GetTickCount() > self.LethalTempoTimer + 1000 then
        self.HasLethalTempo = false
    end
    
    if self.AttackData.windup ~= myHero.attackData.windUpTime then
        self.AttackData.tickwindup = os.clock() + 1
        self.AttackData.windup = myHero.attackData.windUpTime
    end
    
    if self.AttackData.anim ~= myHero.attackData.animationTime then
        self.AttackData.tickanim = os.clock() + 1
        self.AttackData.anim = myHero.attackData.animationTime
    end
    
    if Data:CanResetAttack() and Orbwalker.Menu.General.AttackResetting:Value() then
        self.Reset = true
    end
    
    local spell = myHero.activeSpell
    if spell and spell.valid and spell.target > 0 and spell.castEndTime > self.CastEndTime and Data:IsAttack(spell.name) then
        -- spell.isAutoAttack then  and Game.Timer() < self.LocalStart + 0.2
        
        for i = 1, #Orbwalker.OnAttackCb do
            Orbwalker.OnAttackCb[i]()
        end
        
        self.CastEndTime = spell.castEndTime
        self.AttackWindup = spell.windup
        self.ServerStart = self.CastEndTime - self.AttackWindup
        self.AttackAnimation = spell.animation
        
        if self.TestDamage then
            if self.TestCount == 0 then
                self.TestStartTime = Game.Timer()
            end
            self.TestCount = self.TestCount + 1
            if self.TestCount == 5 then
                print('5 attacks in time: ' .. tostring(Game.Timer() - self.TestStartTime) .. '[sec]')
                self.TestCount = 0
                self.TestStartTime = 0
            end
        end
    end
end

function Attack:GetWindup
    ()
    
    if self.SpecialWindup then
        local windup = self.SpecialWindup()
        if windup then
            return windup
        end
    end
    
    if self.HasLethalTempo then
        return myHero.attackData.windUpTime
    end
    
    if os.clock() < self.AttackData.tickwindup and myHero.attackSpeed * (1 / myHero.attackData.animationTime / myHero.attackSpeed) <= 2.5 then
        return myHero.attackData.windUpTime
    end
    
    return self.AttackWindup
end

function Attack:GetAnimation
    ()
    
    if math.abs(myHero.attackData.animationTime - self.AttackAnimation) > 0.25 then
        return myHero.attackData.animationTime
    end
    
    if self.HasLethalTempo then
        --print(myHero.attackData.animationTime .. ' ' .. self.AttackAnimation)
        --print(myHero.attackSpeed * (1 / myHero.attackData.animationTime / myHero.attackSpeed))
        return myHero.attackData.animationTime
    end
    
    if os.clock() < self.AttackData.tickanim and myHero.attackSpeed * (1 / myHero.attackData.animationTime / myHero.attackSpeed) <= 2.5 then
        return myHero.attackData.animationTime
    end
    
    return self.AttackAnimation
end

function Attack:GetProjectileSpeed
    ()
    
    -- MELEE
    if Data.IsHeroMelee or (Data.IsHeroSpecialMelee and Data.IsHeroSpecialMelee()) then
        return math.huge
    end
    
    -- SPECIAL
    if Data.SpecialMissileSpeed then
        local speed = Data.SpecialMissileSpeed()
        if speed then
            return speed
        end
    end
    
    -- ATTACK DATA
    local speed = myHero.attackData.projectileSpeed
    if speed > 0 then
        return speed
    end
    
    -- MELEE
    return math.huge
end

function Attack:IsReady
    ()
    
    if self.CastEndTime > self.LocalStart then
        if self.Reset or Game.Timer() >= self.ServerStart + self:GetAnimation() - Data:GetLatency() - 0.01 then
            return true
        end
        return false
    end
    
    if Game.Timer() < self.LocalStart + 0.2 then
        return false
    end
    
    return true
end

function Attack:IsActive
    ()
    
    if self.CastEndTime > self.LocalStart then
        if Game.Timer() >= self.ServerStart + self:GetWindup() - Data:GetLatency() + 0.025 + Orbwalker.Menu.General.ExtraWindUpTime:Value() * 0.001 then
            return false
        end
        return true
    end
    
    if Game.Timer() < self.LocalStart + 0.2 then
        return true
    end
    
    return false
end

function Attack:IsBefore
    (multipier)
    
    return Game.Timer() > self.LocalStart + multipier * self:GetAnimation()
end

--OK
Menu:Init()
Action:Init()
Object:Init()
Target:Init()
Orbwalker:Init()
Item:Init()
Buff:Init()
Damage:Init()
Cursor:Init()
Health:Init()
Data:Init()
Spell:Init()

_G.SDK.Color = Color
_G.SDK.Menu = Menu
_G.SDK.Action = Action
_G.SDK.ObjectManager = Object
_G.SDK.TargetSelector = Target
_G.SDK.Orbwalker = Orbwalker
_G.SDK.ItemManager = Item
_G.SDK.BuffManager = Buff
_G.SDK.Damage = Damage
_G.SDK.Cursor = Cursor
_G.SDK.HealthPrediction = Health
_G.SDK.Math = Math
_G.SDK.Data = Data
_G.SDK.Spell = Spell
_G.SDK.Attack = Attack

Callback.Add('Load', function()
    local sdk, drawEnabled
    
    sdk = _G.SDK
    drawEnabled = Menu.Main.Drawings.Enabled
    
    for k, v in pairs(sdk.Load) do v() end

    Callback.Add("Draw", function()
        for i = 1, #sdk.FastTick do sdk.FastTick[i]() end
        if not drawEnabled:Value() then return end
        for i = 1, #sdk.Draw do sdk.Draw[i]() end
    end)
    Callback.Add("Tick", function()
        for i = 1, #sdk.Tick do sdk.Tick[i]() end
    end)
    Callback.Add("WndMsg", function(msg, wParam)
        for i = 1, #sdk.WndMsg do sdk.WndMsg[i](msg, wParam) end
    end)
    
    -- Disabling GoS Orbwalker
    if _G.Orbwalker then
        _G.Orbwalker.Enabled:Value(false);
        _G.Orbwalker.Drawings.Enabled:Value(false);
    end
end)
