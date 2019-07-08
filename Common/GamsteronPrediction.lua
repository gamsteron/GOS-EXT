local SCRIPT_VERSION = '0.157'
--[=========================================================[
 
 
API:
 
 
    COLLISION_MINION (integer)
    COLLISION_ALLYHERO (integer)
    COLLISION_ENEMYHERO (integer)
    COLLISION_YASUOWALL (integer)
 
 
    HITCHANCE_IMPOSSIBLE (integer)
    HITCHANCE_COLLISION (integer)
    HITCHANCE_NORMAL (integer)
    HITCHANCE_HIGH (integer)
    HITCHANCE_IMMOBILE (integer)
 
 
    SPELLTYPE_LINE (integer)
    SPELLTYPE_CIRCLE (integer)
    SPELLTYPE_CONE (integer)
 
 
    GetGamsteronPrediction = function(unit (object), args (table), from (object))
 
        input args (table)
        {
            Delay (float (seconds)),
            Speed (integer),
            Radius (integer),
            Range (integer),
            Collision (boolean),
            Type (integer), [line] = 0, [circle = 1], [cone = 2]
            MaxCollision (integer),
            CollisionTypes (table {integer}), [minion = 0], [allyhero = 1], [enemyhero = 2], [yasuowall = 3]
            UseBoundingRadius (boolean)
        }
        return table
        {
            Hitchance (integer), [impossible = 0], [collision = 1], [normal = 2], [high = 3], [immobile = 4]
            CastPosition (Vector),
            UnitPosition (Vector),
            CollisionObjects (table {Object})
        }
 
 
    GetCollision = function(source (Object), castPos (Vector), predPos (Vector), speed (integer), delay (float (seconds)), radius (integer), collisionTypes (table), skipID (integer))
 
        input collisionTypes (table {integer}) [minion = 0], [allyhero = 1], [enemyhero = 2], [yasuowall = 3]
        return isWall (boolean), collisionObjects (table), collisionCount (integer)
 
 
    GetImmobileDuration = function(unit (object))
 
        return ImmobileDuration, SpellStartTime, AttackStartTime, KnockDuration
 
 
--]=========================================================]

-- RETURN IF LOADED
if (_G.GamsteronPredictionLoaded) then
    return
end
_G.GamsteronPredictionLoaded = true

do
    local function DownloadFile(url, path)
        DownloadFileAsync(url, path, function() end)
        local o = os.clock()
        while os.clock() < o + 1 do end
        while not FileExist(path) do end
    end

    local function Trim(s)
        local from = s:match"^%s*()"
        return from > #s and "" or s:match(".*%S", from)
    end

    local function ReadFile(path)
        local result = {}
        local file = io.open(path, "r")
        if file then
            for line in file:lines() do
                local str = Trim(line)
                if #str > 0 then
                    table.insert(result, str)
                end
            end
            file:close()
        end
        return result
    end

    local function AutoUpdate(args)
        DownloadFile(args.versionUrl, args.versionPath)
        local fileResult = ReadFile(args.versionPath)
        local newVersion = fileResult[1]
        if newVersion ~= args.version then
            DownloadFile(args.scriptUrl, args.scriptPath)
            return true, newVersion
        end
        return false, args.version
    end

    local scriptName = "GamsteronPrediction"
    local success, newVersion = AutoUpdate({
        version = SCRIPT_VERSION,
        scriptPath = COMMON_PATH .. scriptName .. ".lua",
        scriptUrl = "https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/" .. scriptName .. ".lua",
        versionPath = COMMON_PATH .. scriptName .. ".version",
        versionUrl = "https://raw.githubusercontent.com/gamsteron/GOS-EXT/master/Common/" .. scriptName .. ".version"
    })
    if (success) then
        print(scriptName .. " updated to version " .. newVersion .. ". Please Reload with 2x F6 !")
        return
    end
end

-- YASUO
local Yasuo =
{
    Wall = nil,
    Name = nil,
    Level = 0,
    CastTime = 0,
    StartPos = nil
}
local AddedToTick = false
local IsYasuo = false
Callback.Add("Tick", function()
    if AddedToTick then
        return
    end
    if _G.SDK ~= nil and _G.SDK.ObjectManager ~= nil then
        _G.SDK.ObjectManager:OnEnemyHeroLoad(function(args)
            if (args.CharName == "Yasuo" and args.IsEnemy) then
                IsYasuo = true
            end
        end)
        AddedToTick = true
    end
end)

-- MENU
local Menu = MenuElement({name = "Gamsteron Prediction", id = "GamsteronPrediction", type = _G.MENU})
Menu:MenuElement({name = "[*] Range:", type = _G.SPACE, id = "spacerange"})
local MENURANGE
Menu:MenuElement({id = "PredMaxRange", name = "Pred Max Range %", value = 100, min = 70, max = 100, step = 1, callback = function(value) MENURANGE = value * 0.01 end})
MENURANGE = Menu.PredMaxRange:Value() * 0.01
--Menu:MenuElement({name = "", type = _G.SPACE, id = "spacerangeend"})
Menu:MenuElement({name = "[*] Collision:", type = _G.SPACE, id = "spacecol"})
local MENURADIUS
Menu:MenuElement({id = "ExtraColRad", name = "Extra Collision Radius", value = 15, min = 0, max = 50, step = 5, callback = function(value) MENURADIUS = value end})
MENURADIUS = Menu.ExtraColRad:Value()
--Menu:MenuElement({name = "", type = _G.SPACE, id = "spacecolend"})
Menu:MenuElement({id = "spacehc", name = "[*] Hitchance:", type = _G.SPACE})
-- hitchance waypoint analysis:
Menu:MenuElement({name = "Waypoint Analysis", id = "wpanalyser", type = _G.MENU})
local MENUWPDUR
Menu.wpanalyser:MenuElement({id = "wpduration", name = "Analyse waypoints from last [x] ms", value = 400, min = 0, max = 1000, step = 50, callback = function(value) MENUWPDUR = value end})
MENUWPDUR = Menu.wpanalyser.wpduration:Value()
local MENUWPANGLE
Menu.wpanalyser:MenuElement({id = "wpangle", name = "Stop if angle between 2 waypoints > [x]", value = 20, min = 0, max = 90, step = 1, callback = function(value) MENUWPANGLE = value end})
MENUWPANGLE = Menu.wpanalyser.wpangle:Value()
-- unit pos direction check:
Menu:MenuElement({name = "Unit Position direction check", id = "dircheck", type = _G.MENU})
local MENUDIRCHECK
Menu.dircheck:MenuElement({id = "dirangl", name = "Stop if angle between dir (based on unit.pos)", value = 85, min = 0, max = 180, step = 1, callback = function(value) MENUDIRCHECK = value end})
Menu.dircheck:MenuElement({id = "spacediran", name = " and dir (based on pred) > [x]", type = _G.SPACE})
MENUDIRCHECK = Menu.dircheck.dirangl:Value()
-- hitchance high:
Menu:MenuElement({name = "Hitchance High", id = "hithigh", type = _G.MENU})
local MENUFACING, MENUWPCOUNT, MENUOPENP, MENUMOVELOW, MENUMOVEHIGH, MENULASTATTACK, MENULASTSPELL, MENUAFKHC
Menu.hithigh:MenuElement({id = "facin", name = "Facing/Fleeing target + dist to predpos < 400", value = false, callback = function(value) MENUFACING = value end})
MENUFACING = Menu.hithigh.facin:Value()
Menu.hithigh:MenuElement({id = "wpcount", name = ">2 waypoints in [x] ms < wp analysis time", value = true, callback = function(value) MENUWPCOUNT = value end})
MENUWPCOUNT = Menu.hithigh.wpcount:Value()
Menu.hithigh:MenuElement({id = "openpre", name = "Open Predict Hitchance and >0 waypoints ^", value = false, callback = function(value) MENUOPENP = value end})
MENUOPENP = Menu.hithigh.openpre:Value()
Menu.hithigh:MenuElement({id = "movelow", name = "last move time < 100ms", value = true, callback = function(value) MENUMOVELOW = value end})
MENUMOVELOW = Menu.hithigh.movelow:Value()
Menu.hithigh:MenuElement({id = "movehigh", name = "last move time > 750ms & wplenght > 500", value = true, callback = function(value) MENUMOVEHIGH = value end})
MENUMOVEHIGH = Menu.hithigh.movehigh:Value()
Menu.hithigh:MenuElement({id = "attacklow", name = "last attack time < 50ms", value = true, callback = function(value) MENULASTATTACK = value end})
MENULASTATTACK = Menu.hithigh.attacklow:Value()
Menu.hithigh:MenuElement({id = "spelllow", name = "last spell time < 50ms", value = true, callback = function(value) MENULASTSPELL = value end})
MENULASTSPELL = Menu.hithigh.spelllow:Value()
Menu.hithigh:MenuElement({id = "afkmode", name = "stopmove time > 2500ms", value = true, callback = function(value) MENUAFKHC = value end})
MENUAFKHC = Menu.hithigh.afkmode:Value()
--Menu:MenuElement({id = "spacehcend", name = "", type = _G.SPACE})
Menu:MenuElement({name = "[*] Version:", type = _G.SPACE, id = "spacever"})
Menu:MenuElement({name = tostring(SCRIPT_VERSION), type = _G.SPACE, id = "Version"})

_G.COLLISION_MINION = 0
_G.COLLISION_ALLYHERO = 1
_G.COLLISION_ENEMYHERO = 2
_G.COLLISION_YASUOWALL = 3

_G.HITCHANCE_IMPOSSIBLE = 0
_G.HITCHANCE_COLLISION = 1
_G.HITCHANCE_NORMAL = 2
_G.HITCHANCE_HIGH = 3
_G.HITCHANCE_IMMOBILE = 4

_G.SPELLTYPE_LINE = 0
_G.SPELLTYPE_CIRCLE = 1
_G.SPELLTYPE_CONE = 2

-- ATTACKS
local NoAutoAttacks =
{
    ["GravesAutoAttackRecoil"] = true,
    ["LeonaShieldOfDaybreakAttack"] = true
}
local SpecialAutoAttacks =
{
    ["CaitlynHeadshotMissile"] = true,
    ["GarenQAttack"] = true,
    ["KennenMegaProc"] = true,
    ["MordekaiserQAttack"] = true,
    ["MordekaiserQAttack1"] = true,
    ["MordekaiserQAttack2"] = true,
    ["QuinnWEnhanced"] = true,
    ["BlueCardPreAttack"] = true,
    ["RedCardPreAttack"] = true,
    ["GoldCardPreAttack"] = true,
    ["XenZhaoThrust"] = true,
    ["XenZhaoThrust2"] = true,
    ["XenZhaoThrust3"] = true
}

local function Num(x)
    return x
end

local function Bool(x)
    return x
end

--[=====[
Buff Types:
    INTERNAL = 0, AURA = 1, ENHANCER = 2, DEHANCER = 3, SPELLSHIELD = 4, STUN = 5, INVIS = 6, SILENCE = 7,
    TAUNT = 8, POLYMORPH = 9, SLOW = 10, SNARE = 11, DMG = 12, HEAL = 13, HASTE = 14, SPELLIMM = 15
    PHYSIMM = 16, INVULNERABLE = 17, SLEEP = 18, NEARSIGHT = 19, FRENZY = 20, FEAR = 21, CHARM = 22, POISON = 23
    SUPRESS = 24, BLIND = 25, COUNTER = 26, SHRED = 27, FLEE = 28, KNOCKUP = 29, KNOCKBACK = 30, DISARM = 31
--]=====]

-- IMMOBILE BUFF
local IMMOBILE_TYPES = {[5] = true, [8] = true, [11] = true, [21] = true, [22] = true, [24] = true, [29] = true}--[18] = true broken shiit
function GetImmobileDuration(unit)
    local SpellStartTime = 0
    local AttackStartTime = 0
    local ImmobileDuration = 0
    local KnockDuration = 0
    local path = unit.pathing
    if ((not path) or path.hasMovePath) then
        return ImmobileDuration, SpellStartTime, AttackStartTime, KnockDuration
    end
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if (buff) then
            local count = buff.count
            local duration = buff.duration
            local btype = buff.type
            if (count and duration and btype and count > 0 and duration > 0) then
                if (duration > ImmobileDuration and IMMOBILE_TYPES[btype]) then
                    ImmobileDuration = duration
                elseif (btype == 30) then
                    KnockDuration = duration
                end
            end
        end
    end
    local spell = unit.activeSpell
    if (spell and spell.valid) then
        local name = spell.name
        if (NoAutoAttacks[name] == nil and Bool(spell.isAutoAttack or name:lower():find("attack") or SpecialAutoAttacks[name])) then
            AttackStartTime = spell.startTime
        elseif (spell.windup > 0.2) then
            SpellStartTime = spell.startTime
        end
    end
    return ImmobileDuration, SpellStartTime, AttackStartTime, KnockDuration
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true
    end
    return false
end

local function IsAfk(unit)
    local spell = unit.activeSpell
    if (spell and spell.valid) then
        return false
    end
    return true
end

local function Get2D(p1)
    if (p1.pos) then
        p1 = p1.pos
    end
    local result = {x = 0, z = 0}
    if (p1.x) then
        result.x = p1.x
    end
    if (p1.z) then
        result.z = p1.z
    elseif (p1.y) then
        result.z = p1.y
    end
    return result
end

local function Get3D(p1)
    if (p1.pos) then
        p1 = p1.pos
    end
    return Vector(p1.x, 0, p1.z)
end

local function GetDistance(p1, p2)
    local dx = p2.x - p1.x
    local dz = p2.z - p1.z
    return math.sqrt(dx * dx + dz * dz)
end

local function IsInRange(p1, p2, range)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    if (dx * dx + dz * dz <= range * range) then
        return true
    end
    return false
end

local function VectorsEqual(p1, p2)
    if (GetDistance(p1, p2) < 5) then
        return true
    end
    return false
end

local function Normalized(p1, p2)
    local dx = p1.x - p2.x
    local dz = p1.z - p2.z
    local length = math.sqrt(dx * dx + dz * dz)
    local sol = nil
    if (length > 0) then
        local inv = 1.0 / length
        sol = {x = (dx * inv), z = (dz * inv)}
    end
    return sol
end

local function Extended(vec, dir, range)
    if (dir == nil) then
        return vec
    end
    return {x = vec.x + dir.x * range, z = vec.z + dir.z * range}
end

local function Perpendicular(dir)
    if (dir == nil) then
        return nil
    end
    return {x = -dir.z, z = dir.x}
end

local function Intersection(s1, e1, s2, e2)
    local IntersectionResult = {Intersects = false, Point = {x = 0, z = 0}}
    local deltaACz = s1.z - s2.z
    local deltaDCx = e2.x - s2.x
    local deltaACx = s1.x - s2.x
    local deltaDCz = e2.z - s2.z
    local deltaBAx = e1.x - s1.x
    local deltaBAz = e1.z - s1.z
    local denominator = deltaBAx * deltaDCz - deltaBAz * deltaDCx
    local numerator = deltaACz * deltaDCx - deltaACx * deltaDCz
    if (denominator == 0) then
        if (numerator == 0) then
            if s1.x >= s2.x and s1.x <= e2.x then
                return {Intersects = true, Point = s1}
            end
            if s2.x >= s1.x and s2.x <= e1.x then
                return {Intersects = true, Point = s2}
            end
            return IntersectionResult
        end
        return IntersectionResult
    end
    local r = numerator / denominator
    if (r < 0 or r > 1) then
        return IntersectionResult
    end
    local s = (deltaACz * deltaBAx - deltaACx * deltaBAz) / denominator
    if (s < 0 or s > 1) then
        return IntersectionResult
    end
    local point = {x = s1.x + r * deltaBAx, z = s1.z + r * deltaBAz}
    return {Intersects = true, Point = point}
end

local function ClosestPointOnLineSegment(p, p1, p2)
    local px = p.x
    local pz = p.z
    local ax = p1.x
    local az = p1.z
    local bx = p2.x
    local bz = p2.z
    local bxax = bx - ax
    local bzaz = bz - az
    local t = ((px - ax) * bxax + (pz - az) * bzaz) / (bxax * bxax + bzaz * bzaz)
    if (t < 0) then
        return p1, false
    end
    if (t > 1) then
        return p2, false
    end
    return {x = ax + t * bxax, z = az + t * bzaz}, true
end

local function quad(a, b, c)
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

local function intercept(src, spos, epos, sspeed, tspeed)
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
    
    local ts = quad(a, b, c)
    
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

local function Polar(p1)
    local x = p1.x
    local z = p1.z
    if (x == 0) then
        if (z > 0) then
            return 90
        end
        if (z < 0) then
            return 270
        end
        return 0
    end
    local theta = math.atan(z / x) * (180.0 / math.pi) --RadianToDegree
    if (x < 0) then
        theta = theta + 180
    end
    if (theta < 0) then
        theta = theta + 360
    end
    return theta
end

local function AngleBetween(p1, p2)
    if (p1 == nil or p2 == nil) then
        return nil
    end
    local theta = Polar(p1) - Polar(p2)
    if (theta < 0) then
        theta = theta + 360
    end
    if (theta > 180) then
        theta = 360 - theta
    end
    return theta
end

local function GetPathLenght(path)
    local result = 0
    for i = 1, #path - 1 do
        result = result + GetDistance(path[i], path[i + 1])
    end
    return result
end

local function CutPath(path, distance)
    if (distance <= 0) then
        return path
    end
    local result = {}
    for i = 1, #path - 1 do
        local dist = GetDistance(path[i], path[i + 1])
        if (dist > distance) then
            table.insert(result, Extended(path[i], Normalized(path[i + 1], path[i]), distance))
            for j = i + 1, #path do
                table.insert(result, path[j])
            end
            break
        end
        distance = distance - dist
    end
    if (#result > 0) then
        return result
    end
    return {path[#path]}
end

local function GetPath(unit, unitPath)
    local result = {}
    table.insert(result, Get2D(unit.pos))
    if (unitPath.isDashing) then
        table.insert(result, Get2D(unitPath.endPos))
    else
        for i = unitPath.pathIndex, unitPath.pathCount do
            table.insert(result, Get2D(unit:GetPath(i)))
        end
    end
    return result
end

-- GET HEROES
local function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if IsValid(hero) and hero.isEnemy then
            table.insert(_EnemyHeroes, hero)
        end
    end
    return _EnemyHeroes
end

local function GetAllyHeroes()
    local _AllyHeroes = {}
    for i = 1, Game.HeroCount() do
        local hero = Game.Hero(i)
        if IsValid(hero) and hero.isAlly then
            table.insert(_AllyHeroes, hero)
        end
    end
    return _AllyHeroes
end

-- ATTACKS
local _Attacks = {}
local function GetAttackData(unit)
    local id = unit.networkID
    if (_Attacks[id] == nil) then
        _Attacks[id] = {startTime = 0, animation = 0, windup = 0, castEndTime = 0, endTime = 0, isCloseToAttack = false}
    end
    if (unit.isEnemy and unit.attackSpeed > 1.5 and unit.range > 500) then
        local spell = unit.activeSpell
        if (spell and spell.valid) then
            if (spell.castEndTime > _Attacks[id].castEndTime) then
                local name = spell.name
                if (NoAutoAttacks[name] == nil and Bool(spell.isAutoAttack or name:lower():find("attack") or SpecialAutoAttacks[name])) then
                    _Attacks[id].startTime = spell.startTime
                    _Attacks[id].animation = spell.animation
                    _Attacks[id].windup = spell.windup
                    _Attacks[id].castEndTime = spell.castEndTime
                    _Attacks[id].endTime = spell.endTime
                end
            end
        end
        local isCloseToAttack = false
        if (GetDistance(Get2D(unit.pos), Get2D(myHero.pos)) < 1500) then
            if (Game.Timer() > _Attacks[id].startTime + (_Attacks[id].animation * 0.75) and Game.Timer() - _Attacks[id].startTime < _Attacks[id].animation * 1.5) then
                local unitPos = Get2D(unit.pos)
                for i, ally in pairs(GetAllyHeroes()) do
                    if (GetDistance(Get2D(ally.pos), unitPos) < unit.range + unit.boundingRadius) then
                        isCloseToAttack = true
                        break
                    end
                end
            end
        end
        _Attacks[id].isCloseToAttack = isCloseToAttack
    end
end

-- PREDICTED POSITION
local function GetDashingPrediction(from, speed, radius, delay, movespeed, dashSpeed, dashPath)
    from = Get2D(from)
    local predPos, castPos, timeToHit
    local delayPath = CutPath(dashPath, dashSpeed * delay)
    if (#delayPath == 1) then
        local startPos = dashPath[1]
        local endPos = dashPath[2]
        local dashTime = GetDistance(startPos, endPos) / dashSpeed
        local reactionTime = delay - dashTime
        if (speed == math.huge) then
            if (movespeed * reactionTime < radius - 25) then
                predPos = endPos
                timeToHit = delay
            end
        else
            local projTime = GetDistance(from, endPos) / speed
            -- NIE MA TU DELAYA NA LITOSC BOSKA -> to jest czas dolotu do endPos + roznica delay - dashTime (delay jest juz zawarty powyzej !!! - dodajemy juz delay !!!)
            reactionTime = reactionTime + projTime
            if (reactionTime * movespeed < radius - 25) then
                predPos = endPos
                timeToHit = delay + projTime
            end
        end
    else
        local startPos = delayPath[1]
        if (speed == math.huge) then
            predPos = startPos
            timeToHit = delay
        else
            local endPos = delayPath[2]
            local dashTime = GetDistance(startPos, endPos) / dashSpeed
            local t = intercept(from, startPos, endPos, speed, dashSpeed)
            if (t and t <= dashTime) then
                predPos = Extended(startPos, Normalized(endPos, startPos), t * dashSpeed)
                timeToHit = delay + t
            else
                local projTime = GetDistance(from, endPos) / speed
                -- NIE MA TU DELAYA NA LITOSC BOSKA -> tu odcinek jest dluzszy niz (delay * dashspeed) wiec delaya nie dodajemy bo go zawarlismy w powyzszych obliczeniach,
                -- spell zaczyna droge z delayem 0 (projTime) odejmujemy od tego pozostaly czas dolotu celu do endPos (od punktu przedluzenia o delay - wiec delay juz jest !!!)
                local reactionTime = projTime - dashTime
                if (movespeed * reactionTime < radius - 25) then
                    predPos = endPos
                    timeToHit = delay + projTime
                end
            end
        end
    end
    castPos = predPos
    return predPos, castPos, timeToHit
end

local function findAngle(p0, p1, p2)
    local b = math.pow(p1.x - p0.x, 2) + math.pow(p1.z - p0.z, 2)
    local a = math.pow(p1.x - p2.x, 2) + math.pow(p1.z - p2.z, 2)
    local c = math.pow(p2.x - p0.x, 2) + math.pow(p2.z - p0.z, 2)
    local angle = math.acos((a + b - c) / math.sqrt(4 * a * b)) * (180 / math.pi)
    if (angle > 90) then
        angle = 180 - angle
    end
    return angle
end

local function DrawLineRectangle(p1, p2, width, bold, color)
    local n1 = Perpendicular(Normalized(p1, p2))
    local x1 = Extended(p1, n1, width / 2)
    local x2 = Extended(x1, n1, -width)
    local x3 = Extended(p2, n1, width / 2)
    local x4 = Extended(x3, n1, -width)
    Draw.Line(Get3D(x1):To2D(), Get3D(x2):To2D(), bold, color)
    Draw.Line(Get3D(x3):To2D(), Get3D(x4):To2D(), bold, color)
    Draw.Line(Get3D(x1):To2D(), Get3D(x3):To2D(), bold, color)
    Draw.Line(Get3D(x2):To2D(), Get3D(x4):To2D(), bold, color)
end

local function GetPredictedPosition(from, delay, speed, radius, movespeed, stype, path)
    from = Get2D(from)
    local predpos, castpos, timetohit
    -- spell with only delay
    if (speed == math.huge) then
        timetohit = delay
        predpos = CutPath(path, movespeed * timetohit)[1]
        castpos = CutPath(path, movespeed * timetohit - radius * 0.9)[1]
    else
        -- spell with speed and delay
        local cancalc = true
        local timeelapsed = 0
        local source = from
        local delaypath = CutPath(path, movespeed * delay)
        for i = 1, #delaypath - 1 do
            local sP = delaypath[i]
            local eP = delaypath[i + 1]
            local it = intercept(source, sP, eP, speed, movespeed)
            if (it == nil or it <= 0) then
                cancalc = false
                break
            end
            local movetime = GetDistance(sP, eP) / movespeed
            if (movetime >= it) then
                predpos = Extended(sP, Normalized(eP, sP), it * movespeed)
                radius = math.min(radius, radius * GetDistance(from, predpos) / 750)
                radius = radius * 0.0111 * findAngle(predpos, path[1], from)
                castpos = CutPath(delaypath, movespeed * Num(timeelapsed + it) - radius)[1]
                cancalc = false
                break
            end
            -- last path
            if (i == #delaypath - 1) then
                predpos = eP
                castpos = predpos
                --castpos = CutPath(delaypath, movespeed * Num(timeelapsed + movetime + Num(it - movetime) - radiusdelay))[1]
                cancalc = false
                break
            end
            timeelapsed = timeelapsed + movetime
            source = Extended(source, Normalized(eP, source), speed * movetime)
        end
        if (cancalc and predpos == nil and #delaypath == 1) then
            predpos = path[#path]
            castpos = predpos
        end
        if (predpos ~= nil) then
            timetohit = delay + (GetDistance(from, predpos) / speed)
        end
    end
    -- return
    return predpos, castpos, timetohit
end

-- WAYPOINTS
local _Visible = {}
local _PosData = {}
local _PathBank = {}
local _Waypoints = {}
local function OnWaypoint(unit)
    GetAttackData(unit)
    local id = unit.networkID
    local unitPos = Get2D(unit.pos)
    if (_PosData[id] == nil) then
        _PosData[id] = {}
        _PosData[id].Pos = unitPos
    else
        local n = Normalized(unitPos, _PosData[id].Pos)
        if (n) then
            _PosData[id].Pos = unitPos
            _PosData[id].Dir = n
        end
    end
    if (_Visible[id] == nil) then
        _Visible[id] = {}
        _Visible[id].visible = false
    end
    if (_Visible[id].visible == false) then
        _Visible[id].visible = true
        _Visible[id].visibleTick = GetTickCount()
    end
    if (_PathBank[id] == nil) then
        _PathBank[id] = {}
    end
    if (_Waypoints[id] == nil) then
        _Waypoints[id] = {}
        _Waypoints[id].tick = 0
        _Waypoints[id].stoptick = 0
        _Waypoints[id].moving = false
        _Waypoints[id].pos = {x = 0, z = 0}
    end
    local unitPath = unit.pathing
    if (unitPath.hasMovePath) then
        local endPos = Get2D(unitPath.endPos)
        if (VectorsEqual(_Waypoints[id].pos, endPos) == false) then
            _Waypoints[id].pos = endPos
            _Waypoints[id].tick = GetTickCount()
            _Waypoints[id].moving = true
            table.insert(_PathBank[id], 1, {pos = endPos, tick = GetTickCount()})
            if (#_PathBank[id] > 10) then
                table.remove(_PathBank[id])
            end
        end
    else
        if (_Waypoints[id].moving) then
            _Waypoints[id].stoptick = GetTickCount()
            _Waypoints[id].moving = false
        end
    end
end

local function GetPathBank(bank, unitPos, time)
    local result = {}
    local currentTime = GetTickCount()
    for i = 1, #bank do
        local p = bank[i]
        local n = Normalized(unitPos, p.pos)
        if (n ~= nil and currentTime < p.tick + time) then
            table.insert(result, {i, n})
        end
    end
    return result
end

-- COLLISION
local function IsYasuoWall()
    if (IsYasuo == false or Yasuo.Wall == nil) then
        return false
    end
    if (Yasuo.Name == nil or Yasuo.Wall.name == nil or Yasuo.Name ~= Yasuo.Wall.name or Yasuo.StartPos == nil) then
        Yasuo.Wall = nil
        return false
    end
    return true
end

local function YasuoWallTick(unit)
    if (Game.Timer() > Yasuo.CastTime + 2) then
        local wallData = unit:GetSpellData(_W)
        if (wallData.currentCd > 0 and wallData.cd - wallData.currentCd < 1.5) then
            Yasuo.Wall = nil
            Yasuo.Name = nil
            Yasuo.StartPos = nil
            Yasuo.Level = wallData.level
            Yasuo.CastTime = wallData.castTime
            for i = 1, Game.ParticleCount() do
                local obj = Game.Particle(i)
                if (obj and obj.name and obj.pos) then
                    local name = obj.name:lower()
                    if (name:find("yasuo") and name:find("_w_") and name:find("windwall")) then
                        if (name:find("activate")) then
                            Yasuo.StartPos = Get2D(obj.pos)
                        else
                            Yasuo.Wall = obj
                            Yasuo.Name = obj.name
                            break
                        end
                    end
                end
            end
        end
    end
    if (Yasuo.Wall ~= nil) then
        if (Yasuo.Name == nil or Yasuo.Wall.name == nil or Yasuo.Name ~= Yasuo.Wall.name or Yasuo.StartPos == nil) then
            Yasuo.Wall = nil
        end
    end
end

function GetCollision(source, castPos, predPos, speed, delay, radius, collisionTypes, skipID)
    source = Get2D(source)
    castPos = Get2D(castPos)
    predPos = Get2D(predPos)
    local x = 0
    if (VectorsEqual(castPos, predPos) == false) then
        local pointLine, isOnSegment = ClosestPointOnLineSegment(predPos, source, castPos)
        local d1 = GetDistance(source, pointLine)
        local d2 = GetDistance(source, castPos)
        if (d1 > d2) then
            x = d1 - d2
        end
    end
    source = Extended(source, Normalized(source, castPos), 75)
    castPos = Extended(castPos, Normalized(castPos, source), 200 + x)
    
    local isWall, collisionObjects, collisionCount = false, {}, 0
    
    local objects = {}
    local checkYasuoWall = false
    for i, colType in pairs(collisionTypes) do
        if (colType == 0) then
            for k = 1, Game.MinionCount() do
                local unit = Game.Minion(k)
                if (IsValid(unit) and unit.isEnemy and GetDistance(source, Get2D(unit.pos)) < 2000) then
                    table.insert(objects, unit)
                end
            end
        elseif (colType == 1) then
            for k, unit in pairs(GetAllyHeroes()) do
                if (unit.networkID ~= skipID and GetDistance(source, Get2D(unit.pos)) < 2000) then
                    table.insert(objects, unit)
                end
            end
        elseif (colType == 2) then
            for k, unit in pairs(GetEnemyHeroes()) do
                if (unit.networkID ~= skipID and GetDistance(source, Get2D(unit.pos)) < 2000) then
                    table.insert(objects, unit)
                end
            end
        elseif (colType == 3) then
            checkYasuoWall = true
        end
    end
    
    for i, object in pairs(objects) do
        
        local isCol = false
        local path = object.pathing
        local objectPos = Get2D(object.pos)
        local pointLine, isOnSegment = ClosestPointOnLineSegment(objectPos, source, castPos)
        if (isOnSegment and IsInRange(objectPos, pointLine, radius + MENURADIUS + object.boundingRadius)) then
            isCol = true
            
        elseif (path and path.hasMovePath) then
            objectPos = Get2D(object:GetPrediction(speed, delay))
            pointLine, isOnSegment = ClosestPointOnLineSegment(objectPos, source, castPos)
            if isOnSegment and IsInRange(objectPos, pointLine, radius + MENURADIUS + object.boundingRadius) then
                isCol = true
            end
        end
        
        if (isCol) then
            table.insert(collisionObjects, object)
            collisionCount = collisionCount + 1
        end
    end
    
    if (checkYasuoWall and IsYasuoWall()) then
        local Pos = Get2D(Yasuo.Wall.pos)
        local ExtraWidth = 50 + MENURADIUS * 2
        local Width = ExtraWidth + 300 + 50 * Yasuo.Level
        local Direction = Perpendicular(Normalized(Pos, Yasuo.StartPos))
        local StartPos = Extended(Pos, Direction, Width / 2)
        local EndPos = Extended(StartPos, Direction, -Width)
        local IntersectionResult = Intersection(StartPos, EndPos, castPos, source)
        if (IntersectionResult.Intersects) then
            local t = Game.Timer() + delay + (GetDistance(IntersectionResult.Point, source) / speed)
            if t < Yasuo.CastTime + 4 then
                isWall = true
                collisionCount = collisionCount + 1
            end
        end
    end
    return isWall, collisionObjects, collisionCount
end

local function GetPrediction(unit, source, speed, radius, delay, stype)
    local predPos, castPos, timeToHit, SubRange
    local hitChance = 0
    OnWaypoint(unit)
    local id = unit.networkID
    local unitPath = unit.pathing
    if (unitPath.hasMovePath) then
        if (GetTickCount() > _Visible[id].visibleTick + 250) then
            if (unitPath.isDashing) then
                predPos, castPos, timeToHit = GetDashingPrediction(source, speed, radius, delay, unit.ms, unitPath.dashSpeed, GetPath(unit, unitPath))
                if (predPos ~= nil) then
                    hitChance = 4
                end
            elseif (not _Attacks[id].isCloseToAttack) then
                local currentPath = GetPath(unit, unitPath)
                predPos, castPos, timeToHit = GetPredictedPosition(source, delay, speed, radius, unit.ms, stype, currentPath)
                if (predPos ~= nil) then
                    SubRange = true
                    local randomDirectionSpam = false
                    unitPos = Get2D(unit.pos)
                    local nn = Normalized(unitPos, _PosData[id].Pos)
                    if (nn) then
                        _PosData[id].Pos = unitPos
                        _PosData[id].Dir = nn
                    end
                    local bank = GetPathBank(_PathBank[id], unitPos, MENUWPDUR)
                    for i, p1 in pairs(bank) do
                        for j, p2 in pairs(bank) do
                            if (p1[1] ~= p2[1] and AngleBetween(p1[2], p2[2]) > MENUWPANGLE) then
                                randomDirectionSpam = true
                                break
                            end
                        end
                    end
                    local badDirection = false
                    if (_PosData[id].Dir == nil) then
                        badDirection = true
                        --print("nil 1")
                    else
                        local n2 = Normalized(predPos, unitPos)
                        if (n2 == nil) then
                            badDirection = true
                            --print("nil 2")
                        else
                            local angle = AngleBetween(n2, _PosData[id].Dir)
                            if angle > MENUDIRCHECK then
                                badDirection = true
                                --print(angle .. " lol")
                            end
                        end
                    end
                    if (randomDirectionSpam == false and badDirection == false) then
                        local diff = GetTickCount() - _Waypoints[id].tick
                        local op = math.min(1, radius / unit.ms / timeToHit)
                        local dist = GetDistance(castPos, Get2D(unit.pos))
                        local pathLenght = GetPathLenght(currentPath)
                        if (pathLenght > 100) then
                            local isLowHc = false
                            local isHighHc = false
                            if (stype == 0) then
                                local n1 = Normalized(Get2D(source.pos), castPos)
                                local n2 = Normalized(unitPos, castPos)
                                if (n1 and n2) then
                                    local angle = AngleBetween(n1, n2)
                                    if (angle < 15 or angle > 180 - 15) then
                                        isHighHc = true
                                    elseif (angle > 75 and angle < 180 - 75) then
                                        isLowHc = true
                                    end
                                end
                            end
                            local distToSource = GetDistance(castPos, Get2D(source.pos))
                            if (pathLenght < Num(unit.ms * delay) - radius) then-- or isLowHc) then
                                hitChance = 2
                                --print("normal")
                            elseif (MENUOPENP and #bank > 0 and op > 0.6) then
                                hitChance = 3
                                --print("high: op")
                            elseif (MENUFACING and isHighHc and distToSource < 400) then
                                hitChance = 3
                                --print("high 1 angle < 15")
                            elseif (MENUWPCOUNT and #bank > 2) then
                                hitChance = 3
                                --print("high: bank > 2")
                            elseif (MENUMOVELOW and diff < 100) then
                                hitChance = 3
                                --print("high: < 100")
                            elseif (MENUMOVEHIGH and diff > 750 and pathLenght > 500) then
                                hitChance = 3
                                --print("high: > 750")
                            else
                                hitChance = 2
                                --print("normal2")
                            end
                        end
                    end
                end
            end
        end
    elseif (unit.visible and GetTickCount() > _Visible[id].visibleTick + 400) then
        local duration, SpellStartTime, AttackStartTime, knockduration = GetImmobileDuration(unit)
        if (duration > 0) then
            local predTime = delay
            if (speed ~= math.huge) then
                predTime = predTime + (GetDistance(Get2D(source.pos), Get2D(unit.pos)) / speed)
            end
            local reactiontime = predTime - duration
            if (duration >= predTime or reactiontime * unit.ms < radius - 25) then
                predPos = Get2D(unit.pos)
                castPos = predPos
                timeToHit = delay + (GetDistance(predPos, Get2D(source.pos)) / speed)
                hitChance = 4
            end
        elseif (knockduration == 0) then
            local stopTimer = GetTickCount() - _Waypoints[id].stoptick
            predPos = Get2D(unit.pos)
            castPos = predPos
            timeToHit = delay + (GetDistance(predPos, Get2D(source.pos)) / speed)
            if (AttackStartTime > 0 and Game.Timer() - AttackStartTime < 0.05) then
                hitChance = 2
                if (MENULASTATTACK) then
                    hitChance = 3
                end
            elseif (SpellStartTime > 0 and Game.Timer() - SpellStartTime < 0.05) then
                hitChance = 2
                if (MENULASTSPELL) then
                    hitChance = 3
                end
            elseif (MENUAFKHC and stopTimer > 1500) then
                hitChance = 3
            elseif (stopTimer > 1000) then
                hitChance = 2
            end
        end
    end
    return predPos, castPos, timeToHit, hitChance, SubRange
end

function GetGamsteronPrediction(unit, args, source)
    -- not valid
    if (IsValid(unit) == false) then
        return {Hitchance = 0}
    end
    -- pre pred unit data
    local prePosTo = Get2D(unit.posTo)
    local preVisible = unit.visible
    local prePath = unit.pathing
    if (prePath == nil or prePath.endPos == nil) then
        return {Hitchance = 0}
    end
    local preMovePath = prePath.hasMovePath
    local preIsdashing = prePath.isDashing
    local prePathCount = prePath.pathCount
    --[====[
    local prePosData = NewPosData[id]
    if (prePosData.Dir == nil) then
        return {Hitchance = 0}
    end
    --]====]
    -- input
    local inputCollision = false
    if (args.Collision ~= nil) then
        inputCollision = args.Collision
    end
    local inputMaxCollision = 0
    if (args.MaxCollision ~= nil) then
        inputMaxCollision = args.MaxCollision
    end
    local inputCollisionTypes = {0, 3}
    if (args.CollisionTypes ~= nil) then
        inputCollisionTypes = args.CollisionTypes
    end
    local latency = _G.LATENCY > 1 and _G.LATENCY * 0.001 or _G.LATENCY
    local inputDelay = 0.06 + latency
    if (args.Delay ~= nil) then
        inputDelay = inputDelay + args.Delay
    end
    local inputRadius = 1
    if (args.Radius ~= nil) then
        inputRadius = args.Radius
    end
    local inputRange = math.huge
    if (args.Range ~= nil) then
        inputRange = args.Range
    end
    local inputSpeed = math.huge
    if (args.Speed ~= nil) then
        inputSpeed = args.Speed
    end
    local inputType = 0
    if (args.Type ~= nil) then
        inputType = args.Type
    end
    local inputRealRadius = inputRadius
    if (args.UseBoundingRadius or inputType == 0) then
        inputRealRadius = inputRadius + unit.boundingRadius
    end
    -- output
    local predPos, castPos, timeToHit, hitChance, SubRange = GetPrediction(unit, source, inputSpeed, inputRealRadius, inputDelay, inputType)
    if (hitChance == 0) then
        return {Hitchance = 0}
    end
    -- check distance
    if inputRange ~= math.huge then
        if (SubRange) then
            inputRange = inputRange * MENURANGE
        end
        local mepos = Get2D(myHero.pos)
        local hepos = Get2D(unit.pos)
        if (hitChance >= 3 and IsInRange(mepos, hepos, inputRange + inputRealRadius) == false) then
            hitChance = 2
        end
        if (IsInRange(castPos, mepos, inputRange) == false) then
            return {Hitchance = 0}
        end
        local x = 0
        if (inputType == 1) then
            x = inputRadius
        end
        if (IsInRange(predPos, mepos, inputRange + x) == false) then
            return {Hitchance = 0}
        end
    end
    -- collision
    local colObjects = {}
    if (inputCollision) then
        local isWall, collisionObjects, collisionCount = GetCollision(source, castPos, predPos, inputSpeed, inputDelay, inputRadius, inputCollisionTypes, unit.networkID)
        if (isWall or collisionCount > inputMaxCollision) then
            hitChance = 1
            colObjects = collisionObjects
        end
    end
    -- post pred unit data
    local postPosTo = Get2D(unit.posTo)
    local postVisible = unit.visible
    local postPath = unit.pathing
    if (postPath == nil) then
        return {Hitchance = 0}
    end
    local postMovePath = postPath.hasMovePath
    local postIsdashing = postPath.isDashing
    local postPathCount = postPath.pathCount
    -- check pre post data
    if (VectorsEqual(prePosTo, postPosTo) == false or preVisible ~= postVisible or preMovePath ~= postMovePath or preIsdashing ~= postIsdashing or prePathCount ~= postPathCount) then
        return {Hitchance = 0}
    end
    --[============[
    if (preMovePath == true) then
        OnWaypoint(unit)
        local postPosData = NewPosData[unit.networkID]
        if prePosData.Dir.x ~= postPosData.Dir.x or prePosData.Dir.y ~= postPosData.Dir.y then
            return {Hitchance = 0}
        end
        local hepos = unit.pos hepos.y = 0
        local henext = unit:GetPath(postPath.pathIndex) henext.y = 0
        if AngleBetween(Normalized(henext, hepos), prePosData.Dir) > 10 then
            return {Hitchance = 0}
        end
    end
    --]============]
    -- linear castpos
    local castPos3D = Get3D(castPos)
    if (inputType == 0 and castPos3D:ToScreen().onScreen == false) then
        local mepos = Get2D(myHero.pos)
        castPos = Extended(mepos, Normalized(castPos, mepos), 600)
    end
    local pcast = Vector(castPos.x, unit.pos.y, castPos.z) --Get3D(castPos)
    local ppred = Vector(predPos.x, unit.pos.y, predPos.z) --Get3D(predPos)
    return {Hitchance = hitChance, CastPosition = pcast, UnitPosition = ppred, CollisionObjects = colObjects}
end

local _MissileSpeed = {}
Callback.Add("Load", function()
    Callback.Add("Draw", function()
        local currentHeroes = {}
        local YasuoChecked = false
        for i, unit in ipairs(GetEnemyHeroes()) do
            if (IsValid(unit)) then
                currentHeroes[unit.networkID] = true
                OnWaypoint(unit)
                if (IsYasuo and not YasuoChecked and unit.charName == "Yasuo") then
                    YasuoWallTick(unit)
                    YasuoChecked = true
                end
                --[================================================================================[
                for i = 1, Game.MinionCount() do
                    local unit = Game.Minion(i)
                    if (IsValid(unit) and unit.pos:DistanceTo(myHero.pos) < 500) then
                        if (unit.isEnemy and unit.pos:DistanceTo(myHero.pos) < 1200) then
                            local point, isSegment = ClosestPointOnLineSegment(Get2D(unit.pos), Get2D(mousePos), Get2D(myHero.pos))
                            local qwidth = tostring(80 + unit.boundingRadius)
                            local bbox = tostring(unit.boundingRadius)
                            --print(unit.pos:DistanceTo(myHero.pos))
                            print(GetDistance(point, Get2D(unit.pos)) .. " " .. qwidth .. " " .. bbox)
                        end
                    end
                end
                for i2 = 1, Game.MissileCount() do
                    local missile = Game.Missile(i2)
                    if missile then
                        local data = missile.missileData
                        if data then
                            if missile.pos:DistanceTo(myHero.pos) > 600 then
                                local name = data.name
                                local currentTick = GetTickCount()
                                local currentPos = Get2D(missile.pos)
                                if _MissileSpeed[name] == nil then
                                    _MissileSpeed[name] = {pos = currentPos, tick = currentTick}
                                end
                                local s = GetDistance(currentPos, _MissileSpeed[name].pos)
                                local t = Num(currentTick - _MissileSpeed[name].tick)
                                if s > 0 and t > 0 then
                                    print(s / t * 1000)
                                    _MissileSpeed[name].pos = currentPos
                                    _MissileSpeed[name].tick = currentTick
                                end
                            end
                            local str = ""
                            for k, l in pairs(data) do
                                str = str .. k .. ": " .. tostring(l) .. "\n"
                            end
                            Draw.Circle(Vector(missile.pos))
                            Draw.Text(str, myHero.pos:To2D())
                        end
                    end
                end
                if (unit.isEnemy and unit.pos:DistanceTo(myHero.pos) < 1200) then
                    for i3 = 0, unit.buffCount do
                        local buff = unit:GetBuff(i3)
                        if buff and buff.count > 0 and buff.duration > 0 then
                            local str = ""
                            for id, val in pairs(buff) do
                                str = str .. id .. ": " .. val .. "\n"
                            end
                            Draw.Text(str, 30, unit.pos:To2D())
                        end
                    end
                    local point, isSegment = ClosestPointOnLineSegment(Get2D(unit.pos), Get2D(mousePos), Get2D(myHero.pos))
                    local qwidth = tostring(80 + unit.boundingRadius)
                    local bbox = tostring(unit.boundingRadius)
                    print(unit.pos:DistanceTo(myHero.pos))
                    print(GetDistance(point, Get2D(unit.pos)) .. " " .. qwidth .. " " .. bbox)
                end
                if (unit.isEnemy and unit.pos:DistanceTo(myHero.pos) < 1000) then
                    print(unit.pos:DistanceTo(mousePos))
                end
                if (unit.isEnemy) then
                    local args = {Speed = 1000, Radius = 60, Delay = 0.25, Collision = true, Range = 1175, Type = 0}
                    local pred = GetGamsteronPrediction(unit, args, myHero)
                    if (pred.Hitchance > 0) then
                        Draw.Line(myHero.pos:To2D(), pred.CastPosition:To2D())
                    end
                end
                if (unit.isMe) then
                    local speed = 1000
                    local radius = 120
                    local delay = 0.25
                    local source = {x = 2756, z = 5352}
                    local predPos, castPos, timeToHit, hitChance = GetPrediction(unit, source, speed, radius, delay)
                    if (hitChance > 2) then
                        local p0 = Get3D(source)
                        local p1 = Get3D(predPos)
                        Draw.Line(p0:To2D(), p1:To2D())
                    end
                end
                --]================================================================================]
            end
        end
        for id, k in pairs(_PosData) do
            if (currentHeroes[id] == nil) then
                if (_Visible[id].visible == true) then
                    _Visible[id].visible = false
                    _Visible[id].invisibleTick = GetTickCount()
                end
            end
        end
    end)
end)

do
    local function LocalClass()
        local cls = {}
        cls.__index = cls
        return setmetatable(cls, {__call = function (c, ...)
            local instance = setmetatable({}, cls)
            if cls.__init then
                cls.__init(instance, ...)
            end
            return instance
        end})
    end

    local __GamsteronPrediction = LocalClass()

    function __GamsteronPrediction:__init()
    end

    function __GamsteronPrediction:GetPrediction(unit, args, source)
        return GetGamsteronPrediction(unit, args, source)
    end

    _G.GamsteronPrediction = __GamsteronPrediction()
end
