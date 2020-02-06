--variables
local lolVersion = "10.3.1"
local scrVersion = "0.6.00"
local menuIcon = "http://ddragon.leagueoflegends.com/cdn/10.3.1/img/spell/SummonerFlash.png"

local bushPositionsSR = {
    Vector(2334, 53, 13524), Vector(1660, 53, 13012), Vector(1174, 53, 12320),
    Vector(2994, -70, 11006), Vector(2318, 53, 9726), Vector(816, 53, 8168), Vector(5012, 0, 8440),
    Vector(3386, 53, 7766), Vector(4820, 51, 7118), Vector(6546, 49, 4690), Vector(8606, 52, 4670),
    Vector(5634, 51, 3506), Vector(6884, 51, 3122), Vector(8096, 52, 3496), Vector(10400, 50, 3060),
    Vector(9228, 59, 2130), Vector(7780, 49, 814), Vector(12490, 54, 1510), Vector(13342, 51, 2484),
    Vector(11902, -67, 3932), Vector(9414, -71, 5676), Vector(8128, -71, 6302), Vector(8654, -71, 6630),
    Vector(6302, -68, 8134), Vector(6744, -71, 8528), Vector(5234, -71, 9104), Vector(7176, 53, 14118),
    Vector(5654, 53, 12762), Vector(4460, 57, 11794), Vector(6784, 54, 11454), Vector(7988, 56, 11784),
    Vector(9200, 53, 11428), Vector(8282, 50, 10250), Vector(6252, 54, 10246), Vector(9974, 52, 7888),
    Vector(9840, 21, 6476), Vector(11484, 52, 7132), Vector(12502, 52, 5196), Vector(14112, 52, 7002),
}

local bushPositionsTT = {
    Vector(4978, -106, 8835), Vector(7162, -111, 7937), Vector(8216, -111, 7915),
    Vector(10426, -106, 8797), Vector(9066, -99, 6927), Vector(8660, -102, 6897), Vector(6722, -102, 6903),
    Vector(6322, -98, 6951), Vector(5164, -110, 5653), Vector(7706, -98, 5579), Vector(10238, -110, 5653),
}

local bushPositionsHA = {
    Vector(4153, -178, 5177), Vector(5447, -178, 6327), Vector(5907, -178, 6459),
    Vector(6365, -178, 6959), Vector(6547, -178, 7393), Vector(7731, -178, 8623),
}

-- Main Menu
local Menu = MenuElement({type = MENU, id = "PMenuFH", name = "Flash Helper Gamsteron Edition"})
Menu:MenuElement({id = "Enabled", name = "Enabled", value = true})
Menu:MenuElement({id = "Extended", name = "Extend to maximum range", value = true})
---
Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "Flash", name = "Flash HotKey", key = string.byte("F")})
---
Menu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
Menu.Drawing:MenuElement({type = MENU, id = "Basic", name = "Basic"})
Menu.Drawing.Basic:MenuElement({id = "Flash", name = "Draw Flash Range", value = true})
Menu.Drawing.Basic:MenuElement({id = "Tran", name = "Alpha", value = 0.5, min = 0, max = 1, step = 0.01})
Menu.Drawing.Basic:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = true})
Menu.Drawing:MenuElement({type = MENU, id = "Bushes", name = "Bushes"})
Menu.Drawing.Bushes:MenuElement({id = "Bushes", name = "Draw Bushes", value = true})
Menu.Drawing.Bushes:MenuElement({id = "Alpha", name = "Alpha", value = 0.75, min = 0, max = 1, step = 0.01})
Menu.Drawing.Bushes:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = true})

--- GET FLASH
local flashSpell, flashHK = 0, 0
local function IsFlashReady()
    local has_flash = false
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
        flashSpell = SUMMONER_1
        flashHK = HK_SUMMONER_1
        has_flash = true
    end
    if myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
        flashSpell = SUMMONER_2
        flashHK = HK_SUMMONER_2
        has_flash = true
    end
    if (not has_flash) then
        return false
    end
    if (myHero:GetSpellData(flashSpell).currentCd > 0) then
        return false
    end
    if (Game.CanUseSpell(flashSpell) ~= 0) then
        return false
    end
    return true
end

Callback.Add("Load", function()
    --- PRINT
    print("Flash Helper Gamsteron Edition: " .. scrVersion .. " | Loaded | By: TheBob & Gamsteron")
    --- DRAW
    Callback.Add("Draw", function()
        local lineWidth = 1
        if myHero.dead then return end
        if Menu.Drawing.Basic.Flash:Value() then
            if Menu.Drawing.Basic.During:Value() and myHero:GetSpellData(flashSpell).currentCd ~= 0 then
                
            else
                Draw.Circle(myHero.pos, 405, 1, Draw.Color(Menu.Drawing.Basic.Tran:Value() * 255, 255, 255, 0))
            end
        end
        --Draw.Circle(myHero.pos,415,1,Draw.Color(Menu.Drawing.Tran:Value() * 255, 255, 255, 0))
        if Menu.Drawing.Bushes.Bushes:Value() then
            if Menu.Drawing.Bushes.During:Value() and myHero:GetSpellData(flashSpell).currentCd ~= 0 then
                
            else
                if Game.mapID == 11 then
                    for i = 1, 39, 1 do
                        if bushPositionsSR[i]:To2D().onScreen then
                            if bushPositionsSR[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
                                lineWidth = 3
                            else
                                lineWidth = 1
                            end
                            Draw.Circle(bushPositionsSR[i], 75, lineWidth, Draw.Color(Menu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
                        end
                    end
                end
                if Game.mapID == 10 then
                    for i = 1, 11, 1 do
                        if bushPositionsTT[i]:To2D().onScreen then
                            if bushPositionsTT[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
                                lineWidth = 3
                            else
                                lineWidth = 1
                            end
                            Draw.Circle(bushPositionsTT[i], 75, lineWidth, Draw.Color(Menu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
                        end
                    end
                end
                if Game.mapID == 12 then
                    for i = 1, 6, 1 do
                        if bushPositionsHA[i]:To2D().onScreen then
                            if bushPositionsHA[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
                                lineWidth = 3
                            else
                                lineWidth = 1
                            end
                            Draw.Circle(bushPositionsHA[i], 75, lineWidth, Draw.Color(Menu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
                        end
                    end
                end
            end
        end
    end)
    --- TICK
    Callback.Add("Tick", function()
        if not Menu.Enabled:Value() or not Menu.Key.Flash:Value() or myHero.dead then return end
        if IsFlashReady() then
            print("Flash Helper | Flashing!")
            local pos
            if (Menu.Extended:Value()) then
                pos = myHero.pos:Extended(mousePos, 800)
            end
            Control.Flash(flashHK, pos)
        end
    end)
end)
