
-- GLOBALS TO LOCALS -------------------------------------------------------------------------------------------------------------------------------------------

local Game = _G.Game
local Draw = _G.Draw
local myHero = _G.myHero
local Vector = _G.Vector
local Control = _G.Control
local MOUSEEVENTF_RIGHTDOWN = _G.MOUSEEVENTF_RIGHTDOWN
local MOUSEEVENTF_RIGHTUP = _G.MOUSEEVENTF_RIGHTUP

-- MENU --------------------------------------------------------------------------------------------------------------------------------------------------------

local MainMenu = MenuElement({name = "Gamsteron " .. myHero.charName, id = "gamsteron" .. myHero.charName, type = MENU})

local CursorMenu = MainMenu:MenuElement({name = "Cursor Pos", id = "cursor", type = MENU})
CursorMenu:MenuElement({name = "Enabled", id = "enabled", value = true})
CursorMenu:MenuElement({name = "Color", id = "color", color = Draw.Color(255, 0, 255, 0)})
CursorMenu:MenuElement({name = "Width", id = "width", value = 3, min = 1, max = 10})
CursorMenu:MenuElement({name = "Radius", id = "radius", value = 150, min = 1, max = 300})

local OrbwalkerMenu = MainMenu:MenuElement({name = "Orbwalker", id = "orb", type = MENU})
OrbwalkerMenu:MenuElement({name = "Latency", id = "latency", value = 50, min = 1, max = 120})
OrbwalkerMenu:MenuElement({name = "Player Attack Only Click", id = "aamoveclick", key = string.byte("U")})
OrbwalkerMenu:MenuElement({name = "Keys", id = "keys", type = MENU})
OrbwalkerMenu.keys:MenuElement({name = "Combo Key", id = "combo", key = string.byte(" ")})
OrbwalkerMenu.keys:MenuElement({name = "LastHit Key", id = "lasthit", key = string.byte("X")})
OrbwalkerMenu.keys:MenuElement({name = "Clear Key", id = "clear", key = string.byte("V")})
OrbwalkerMenu:MenuElement({name = "MyHero Attack Range", id = "me", type = MENU})
OrbwalkerMenu.me:MenuElement({name = "Enabled", id = "enabled", value = true})
OrbwalkerMenu.me:MenuElement({name = "Color", id = "color", color = Draw.Color(150, 49, 210, 0)})
OrbwalkerMenu.me:MenuElement({name = "Width", id = "width", value = 1, min = 1, max = 10})
OrbwalkerMenu:MenuElement({name = "Enemy Attack Range", id = "he", type = MENU})
OrbwalkerMenu.he:MenuElement({name = "Enabled", id = "enabled", value = true})
OrbwalkerMenu.he:MenuElement({name = "Color", id = "color", color = Draw.Color(150, 255, 0, 0)})
OrbwalkerMenu.he:MenuElement({name = "Width", id = "width", value = 1, min = 1, max = 10})

local ChampionMenu
if myHero.charName == "KogMaw" then
    ChampionMenu = MainMenu:MenuElement({name = myHero.charName, id = "champion", type = MENU})
    ChampionMenu:MenuElement({name = "W settings", id = "wset", type = MENU})
    ChampionMenu.wset:MenuElement({id = "combo", name = "Combo", value = true})
end

-- UTILS -------------------------------------------------------------------------------------------------------------------------------------------------------

local ImmortalBuffs = {
    ["zhonyasringshield"] = true,
    ["JudicatorIntervention"] = true,
    ["TaricR"] = true,
    ["kindredrnodeathbuff"] = true,
    ["ChronoShift"] = true,
    ["chronorevive"] = true,
    ["UndyingRage"] = true,
    ["JaxCounterStrike"] = true,
    ["FioraW"] = true,
    ["aatroxpassivedeath"] = true,
    ["VladimirSanguinePool"] = true,
    ["KogMawIcathianSurprise"] = true,
    ["KarthusDeathDefiedBuff"] = true
}

local function IsImmortal(unit, jaxE)
    local hp = 100 * (unit.health / unit.maxHealth)
    ImmortalBuffs["JaxCounterStrike"] = jaxE
    ImmortalBuffs["kindredrnodeathbuff"] = hp < 10
    ImmortalBuffs["UndyingRage"] = hp < 15
    ImmortalBuffs["ChronoShift"] = hp < 15
    ImmortalBuffs["chronorevive"] = hp < 15
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.count > 0 and ImmortalBuffs[buff.name] then
            return true
        end
    end
    return false
end

local function IsInRange(v1, v2, range)
    local dx = v1.x - v2.x
    local dy = (v1.z or v1.y) - (v2.z or v2.y)
    return dx * dx + dy * dy <= range * range
end

-- CURSOR ------------------------------------------------------------------------------------------------------------------------------------------------------

local CURSOR_READY = true
local CURSOR_POS = cursorPos
local CURSOR_WORK = nil
local CURSOR_SETTIME = 0

local function SetCursor(work)
    CURSOR_READY = false
    CURSOR_POS = cursorPos
    CURSOR_WORK = work
    CURSOR_SETTIME = Game.Timer() + 0.07
    CURSOR_WORK()
end

Callback.Add("Load", function()
    Callback.Add("Draw", function()
        if not CURSOR_READY then
            if CURSOR_WORK ~= nil then
                CURSOR_WORK()
                CURSOR_WORK = nil
            elseif Game.Timer() > CURSOR_SETTIME then
                Control.SetCursorPos(CURSOR_POS.x, CURSOR_POS.y)
                if IsInRange(CURSOR_POS, cursorPos, 120) then
                    CURSOR_READY = true
                end
            end
        end
        if CursorMenu.enabled:Value() then
            Draw.Circle(mousePos, CursorMenu.radius:Value(), CursorMenu.width:Value(), CursorMenu.color:Value())
        end
    end)
end)

-- ORBWALKER ---------------------------------------------------------------------------------------------------------------------------------------------------
local MOVE_TIMER = 0
local ATTACK_TIMER = 0
local ATTACK_ENDTIME = 0
local ATTACK_SERVER_START = 0
local ATTACK_IS_BLINDED = false

local function IsBeforeAttack(multipier)
    return Game.Timer() > ATTACK_TIMER + multipier * myHero.attackData.animationTime
end

local function PreAttack()
    return
end

local function Attack(unit)
    local attackKey = OrbwalkerMenu.aamoveclick:Key()
    local unitPos = Vector(unit.pos.x, unit.pos.y + 50, unit.pos.z):To2D()
    PreAttack()
    SetCursor(function()
        Control.SetCursorPos(unitPos.x, unitPos.y)
        Control.KeyDown(attackKey)
        Control.KeyUp(attackKey)
    end)
    MOVE_TIMER = 0
    ATTACK_TIMER = Game.Timer()
end

local function Move()
    Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
    Control.mouse_event(MOUSEEVENTF_RIGHTUP)
    MOVE_TIMER = Game.Timer() + 0.125
end

local function CanAttack()
    if ATTACK_IS_BLINDED then return false end
    
    if ATTACK_ENDTIME > ATTACK_TIMER then
        if Game.Timer() >= ATTACK_SERVER_START + myHero.attackData.animationTime - 0.05 - (OrbwalkerMenu.latency:Value() * 0.001) then
            return true
        end
        
        return false
    end
    
    if Game.Timer() < ATTACK_TIMER + 0.2 then
        return false
    end
    
    return true
end

local function CanMove()
    if myHero.pos:DistanceTo(mousePos) < 120 then
        return false
    end
    
    if ATTACK_ENDTIME > ATTACK_TIMER then
        if Game.Timer() >= ATTACK_SERVER_START + myHero.attackData.windUpTime - (OrbwalkerMenu.latency:Value() * 0.0005) then return true end
        return false
    end
    
    if Game.Timer() < ATTACK_TIMER + 0.2 then
        return false
    end
    
    return true
end

local function GetComboTarget()
    local enemylist = {}
    
    for i = 1, Game.HeroCount() do
        local enemy = Game.Hero(i)
        if enemy and enemy.team ~= myHero.team and enemy.valid and (not enemy.dead) and enemy.visible and enemy.isTargetable and (not IsImmortal(enemy, true)) and enemy.pos:DistanceTo(myHero.pos) < myHero.range + myHero.boundingRadius + enemy.boundingRadius - 35 then
            table.insert(enemylist, enemy)
        end
    end
    
    if #enemylist == 0 then return nil end
    
    table.sort(enemylist, function(a, b) return a.health - (a.totalDamage * 3) - (a.attackSpeed * 200) - (a.ap * 2) < b.health - (b.totalDamage * 3) - (b.attackSpeed * 200) - (b.ap * 2) end)
    
    return enemylist[1]
end

Callback.Add("Load", function()
    Callback.Add("Tick", function()
        local isblinded = false
        for i = 0, myHero.buffCount do
            local buff = myHero:GetBuff(i)
            if buff and buff.count > 0 and buff.name:lower() == "blindingdart" then
                isblinded = true
                break
            end
        end
        ATTACK_IS_BLINDED = isblinded
    end)
    
    Callback.Add("Draw", function()
        local spell = myHero.activeSpell
        if spell and spell.valid and (spell.castEndTime > ATTACK_ENDTIME) and (not myHero.isChanneling) then
            ATTACK_ENDTIME = spell.castEndTime
            ATTACK_SERVER_START = spell.startTime
        end
        if Game.IsChatOpen() or (ExtLibEvade and ExtLibEvade.Evading) or JustEvade or (not CURSOR_READY) or (not Game.IsOnTop()) then
            return
        end
        if OrbwalkerMenu.keys.combo:Value() then
            local target = GetComboTarget()
            if CanAttack() and target and target.pos:ToScreen().onScreen then
                Attack(target)
            elseif CanMove() and Game.Timer() > MOVE_TIMER then
                Move()
            end
        end
    end)
    
    Callback.Add("Draw", function()
        if OrbwalkerMenu.me.enabled:Value() and myHero.pos:ToScreen().onScreen then
            Draw.Circle(myHero.pos, myHero.range + myHero.boundingRadius + 35, OrbwalkerMenu.me.width:Value(), OrbwalkerMenu.me.color:Value())
        end
        if OrbwalkerMenu.he.enabled:Value() then
            for i = 1, Game.HeroCount() do
                local enemy = Game.Hero(i)
                if enemy and enemy.visible and enemy.team ~= myHero.team and enemy.valid and (not enemy.dead) then
                    Draw.Circle(enemy.pos, enemy.range + enemy.boundingRadius + myHero.boundingRadius, OrbwalkerMenu.he.width:Value(), OrbwalkerMenu.he.color:Value())
                end
            end
        end
    end)
end)

-- KOGMAW ------------------------------------------------------------------------------------------------------------------------------------------------------

if myHero.charName == "KogMaw" then
    local function CastW()
        if OrbwalkerMenu.keys.combo:Value() and ChampionMenu.wset.combo:Value() and Game.CanUseSpell(_W) == 0 then
            local isTarget = false
            for i = 1, Game.HeroCount() do
                local enemy = Game.Hero(i)
                if enemy and enemy.team ~= myHero.team and enemy.valid and (not enemy.dead) and enemy.visible and enemy.isTargetable and (not IsImmortal(enemy, true)) and enemy.pos:DistanceTo(myHero.pos) < 610 + (20 * myHero:GetSpellData(_W).level) + myHero.boundingRadius + enemy.boundingRadius - 35 then
                    isTarget = true
                    break
                end
            end
            if isTarget then
                Control.CastSpell(HK_W)
            end
        end
    end
    
    PreAttack = function() CastW() end
    
    Callback.Add("Load", function()
        Callback.Add("Tick", function()
            if CanMove() and IsBeforeAttack(0.55) then CastW() end
        end)
    end)
end
