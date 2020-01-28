if myHero.charName ~= "Alistar" then return end

local LastW = 0
local Q,W,E,R,flashslot
local Scriptname,Version,Author,LVersion = "TRUSt in my Alistar","v2.2","TRUS & Gamsteron","9.9"

local function IsReady(spell)
	if ( myHero:GetSpellData(spell).level <= 0 ) then
		return false
	end
	if ( myHero:GetSpellData(spell).currentCd > 0 ) then
		return false
	end
	if ( myHero.mana < myHero:GetSpellData(spell).mana ) then
		return false
	end
	if ( Game.CanUseSpell(spell) ~= 0 ) then
		return false
	end
	return true
end

class "Alistar"

function Alistar:__init()
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	PrintChat(Scriptname.." "..Version.." - Loaded ! Author: " .. Author)
end

function Alistar:Tick()
	if myHero.dead then return end
	local combomodeactive = self.Menu.Combo.comboActive:Value()
	local harassactive = self.Menu.Harass.harassActive:Value()
	local flashcombo = self.Menu.FlashCombo.qFlash:Value()
	local protector = self.Menu.Protector.enabled:Value()
	flashslot = self:getFlash()
	if ( flashcombo and IsReady(_Q) and IsReady(flashslot) and self:CastQFlash() ) then
		return
	end
	if protector and IsReady(_W) then
		for i, hero in pairs(self:GetEnemyHeroes()) do 
			if hero.pathing.hasMovePath and hero.pathing.isDashing and hero.pathing.dashSpeed>500 then 
				for i, allyHero in pairs(self:GetAllyHeroes()) do 
					if self.Menu.Protector["RU"..allyHero.charName] and self.Menu.Protector["RU"..allyHero.charName]:Value() then 
						if allyHero.pos:DistanceTo( Vector( hero.pathing.endPos ) ) < 100 and allyHero.distance < W.Range then
							Control.CastSpell(HK_W,hero)
							return
						end
					end
				end
			end
		end
	end
	if combomodeactive then
		if ( self.Menu.Combo.comboUseW:Value() and IsReady(_Q) and IsReady(_W) and self:CastW() ) then
			LastW = GetTickCount()
			--print("WQ Combo")
		elseif ( self.Menu.Combo.comboUseQ:Value() and IsReady(_Q) and self:CastQ() ) then
			--print("Q Combo")
		end
		if ( self.Menu.Combo.comboUseE:Value() and IsReady(_E) and self:CastE() ) then
			--print("E Combo")
		end
	elseif harassactive then
		if self.Menu.Harass.harassUseQ:Value() and IsReady(_Q) and self:CastQ() then
			--print("Q Harass")
		end
	end
end

function Alistar:Draw()
	if myHero.dead then return end
	if ( GetTickCount() < LastW + 2000 and self.Menu.Combo.comboActive:Value() and self.Menu.Combo.comboUseQ:Value() and IsReady(_Q) and (myHero.pathing.isDashing or not IsReady(_W)) ) then
		Control.CastSpell(HK_Q)
		--print("Q Combo After W")
	end
	if self.Menu.DrawMenu.DrawQ:Value() then
		Draw.Circle(myHero.pos, Q.Range, 3, self.Menu.DrawMenu.QRangeC:Value())
	end
	if self.Menu.DrawMenu.DrawW:Value() then
		Draw.Circle(myHero.pos, W.Range, 3, self.Menu.DrawMenu.WRangeC:Value())
	end
end

function Alistar:LoadSpells()
	Q = {Range = 365, Delay = 0.25}
	W = {Range = 650}
	E = {Range = 350}
end

function Alistar:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "TRUStinymyAlistar", name = Scriptname})

	--[[FlashCombos]]
	self.Menu:MenuElement({type = MENU, id = "FlashCombo", name = "FlashCombo Settings"})
	for i, hero in pairs(self:GetEnemyHeroes()) do
		self.Menu.FlashCombo:MenuElement({id = "RU"..hero.charName, name = "Use FlashQ only on: "..hero.charName, value = true})
	end
	
	self.Menu.FlashCombo:MenuElement({id = "qFlash", name = "qFlash key", key = string.byte("G")})
	
	--[[Protector]]
	self.Menu:MenuElement({type = MENU, id = "Protector", name = "Protect from dashes"})
	self.Menu.Protector:MenuElement({id = "enabled", name = "Enabled", value = true})
	for i, hero in pairs(self:GetAllyHeroes()) do
		self.Menu.Protector:MenuElement({id = "RU"..hero.charName, name = "Protect from dashes: "..hero.charName, value = true})
	end
	
	--[[Combo]]
	self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
	self.Menu.Combo:MenuElement({id = "comboUseQ", name = "Use Q", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseW", name = "Use W", value = true})
	self.Menu.Combo:MenuElement({id = "comboUseE", name = "Use E", value = true})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	
	--[[Harass]]
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
	self.Menu.Harass:MenuElement({id = "harassUseQ", name = "Use Q", value = true})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})
	
	self.Menu:MenuElement({type = MENU, id = "DrawMenu", name = "Draw Settings"})
	self.Menu.DrawMenu:MenuElement({id = "DrawQ", name = "Draw Q Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "QRangeC", name = "Q Range color", color = Draw.Color(0xBF3F3FFF)})
	self.Menu.DrawMenu:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
	self.Menu.DrawMenu:MenuElement({id = "WRangeC", name = "W Range color", color = Draw.Color(0xBFBF3FFF)})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions and so", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 50, min = 0, max = 200, step = 5, identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. "" .. (TPred and " TPred" or "")})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end

function Alistar:GetEnemyHeroes()
	local EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isEnemy and Hero.isTargetable then
			table.insert(EnemyHeroes, Hero)
		end
	end
	return EnemyHeroes
end

function Alistar:GetAllyHeroes()
	local AllyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero and Hero.valid and Hero.alive and Hero.visible and Hero.isAlly then
			table.insert(AllyHeroes, Hero)
		end
	end
	return AllyHeroes
end

function Alistar:getFlash()
	for i = 1, 5 do
		if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
			return SUMMONER_1
		end
		if myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
			return SUMMONER_2
		end
	end
	return 0
end

function Alistar:IsValidTarget(unit, range, checkTeam, from)
	local range = range == nil and math.huge or range
	if unit == nil or not unit.valid or not unit.visible or unit.dead or not unit.isTargetable or (checkTeam and unit.isAlly) then
		return false
	end
	if myHero.pos:DistanceTo(unit.pos) > range then return false end 
	return true 
end

function Alistar:CastQFlash(target)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	for i, hero in pairs(self:GetEnemyHeroes()) do 
		if self:IsValidTarget(hero,Q.Range+350) and self.Menu.FlashCombo["RU"..hero.charName] and self.Menu.FlashCombo["RU"..hero.charName]:Value() then
			--print("Q FLASH")
			Control.CastSpell(HK_Q)
			Control.CastSpell(flashslot == SUMMONER_1 and HK_SUMMONER_1 or HK_SUMMONER_2,hero)
			return true
		end
	end
	return false
end

function Alistar:CastQ(target)
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = target or (_G.SDK and _G.SDK.TargetSelector:GetTarget(Q.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(Q.Range,"AP"))
	if target then
		local temppred = target:GetPrediction(math.huge,0.25)
		if temppred:DistanceTo(myHero.pos) < Q.Range then 
			Control.CastSpell(HK_Q)
			return true
		end
	end
	return false
end

function Alistar:CastW()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(W.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(W.Range,"AP"))
	if target and target.distance > Q.Range then
		Control.CastSpell(HK_W, target)
		return true
	end
	return false
end

function Alistar:CastE()
	if (not _G.SDK and not _G.GOS and not _G.EOW) then return end
	local target = (_G.SDK and _G.SDK.TargetSelector:GetTarget(E.Range, _G.SDK.DAMAGE_TYPE_MAGICAL)) or (_G.GOS and _G.GOS:GetTarget(E.Range,"AP"))
	if target then
		Control.CastSpell(HK_E)
		return true
	end
	return false
end

function OnLoad()
	Alistar()
end
