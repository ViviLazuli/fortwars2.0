GM.Name     = "FortWars 13"
GM.Author   = "Red - Continuation from the work of g33k & Darkspider"
GM.Email    = ""
GM.Website  = "" 

DeriveGamemode( "base" )
AddCSLuaFile("classes/sh_classes.lua")
include("classes/sh_classes.lua")

----------------------------------------------------------
--CONFIGURABLE STUFF, EDIT THIS TO HOW YOU WANT IT
----------------------------------------------------------

//canJoinTeam = true --if set to true, players will be presented with a team menu upon joining the server and will have to pick their team
DEFBUILD_TIMER = 10 * 60 --the time in seconds that build mode lasts
DEFDM_TIMER = 12 * 60 --the time in seconds that deathmatch lasts
DEFAULT_BALL_TIME = 60 --the time in seconds that a team needs to hold the ball
BASE_ENERGY_REGEN = 1

NEO_JUMP_COST = 60
PRED_DRAIN_RATE = 15
SORCERER_MANA_COST = 100
ADVANCER_MANA_COST = 50
ASSASSIN_MANA_COST = 100

KILL_MONEY = 25

PREM_WIN_MULTIPLIER = 1.25
PLAT_WIN_MULTIPLIER = 1.5

PREM_KILL_BONUS = 10
PLAT_KILL_BONUS = 20

PREM_BALL_BONUS = 1
PLAT_BALL_BONUS = 2

ASSIST_MONEY = KILL_MONEY*(2/5)
WIN_MONEY = 1000
BALL_MONEY = 5
MAX_PROPS = 150
ENDGAME_TIME = 30
LOSE_SONG = "darkland/fortwars/wintest.mp3"
WIN_SONG = "darkland/fortwars/win9.mp3"
RESPAWN_TIME = 3 --time in seconds you must wait before respawning
VOTE_THRESH = 0.6
VOTE_DELAY = 150
VOTE_WARNING = 10
EVEN_TEAMS = true --if true, teams must still be even to change teams.
ROUNDOVER = false

--      Development shit      --
PRINT_QUERIES_IN_CONSOLE = false

----------------------------------------------------------------------
--DO NOT EDIT BELOW THIS, UNLESS YOU KNOW WHAT YOU ARE DOING
----------------------------------------------------------------------


function GM:PlayerBindPress(ply, bind, pressed)
	//if string.find(bind, "phys_swap") then 
	if bind == "phys_swap" then 
		if ply:GetNWBool("carrying") == true then
			return true
		elseif ply:GetNWBool("carrying") == false then
			return false			
		else return false end	
	end
end

function GM:ShouldCollide( ent1, ent2 )

	-- If players are about to collide with each other, then they won't collide.
	if ( IsValid( ent1 ) and IsValid( ent2 ) and (ent1:GetClass() == "swatnade" or ent1:GetClass() == "ball") and ent2:IsPlayer() ) then
		if ent1.LastHolder == ent2 then return false end
	end
	-- We must call this because anything else should return true.
	return true

end

numBuilds = 0
DM_MODE = false
BUILD_TIMER = DEFBUILD_TIMER
DM_TIMER = DEFDM_TIMER
TEAM_BLUE = 1
TEAM_RED = 2
TEAM_YELLOW = 3
TEAM_GREEN = 4

team.SetUp(TEAM_BLUE, "Blue Team", Color(20,0,240,255))
team.SetUp(TEAM_RED, "Red Team", Color(255,0,0,255))
team.SetUp(TEAM_YELLOW, "Yellow Team", Color(220,220,0,255))
team.SetUp(TEAM_GREEN, "Green Team", Color(0,255,0,255))

nextsec = 0
teamtime = {}

Skills = {}
Skills["speed_limit"] = { 
	NAME = "Speed", 
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = 0, [1] = 10, [2] = 20, [3] = 30, [4] = 40, [5] = 50, },
	DESCRIPTION = "This upgrade will increase your speed by 10 units per second to a maximum of 50 units per second.", 
}

Skills["health_limit"] = {
	NAME = "Health",
	COST = {[0] = 0, [1] = 6000, [2] = 12000, [3] = 18000, [4] = 24000, [5] = 30000, },
	LEVEL = {[0] = 0, [1] = 10, [2] = 20, [3] = 30, [4] = 40, [5] = 50, },
	DESCRIPTION = "This upgrade will give you 10 health points for each upgrade to a maximum of 50 health.",
}

Skills["energy_limit"] = {
	NAME = "Max Energy",
	COST = {[0] = 0, [1] = 6000, [2] = 12000, [3] = 18000, [4] = 24000, [5] = 30000, },
	LEVEL = {[0] = 0, [1] = 5, [2] = 10, [3] = 15, [4] = 20, [5] = 25, },
	DESCRIPTION = "This upgrade will increase your maximum energy by 5 energy points up to a maximum of 25 points.",
}

Skills["energy_regen"] = {
	NAME = "Energy Regen",
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = BASE_ENERGY_REGEN, [1] = 1.1, [2] = 1.2, [3] = 1.3, [4] = 1.4, [5] = 1.5, },
	DESCRIPTION = "This upgrade will increase your energy regeneration by 1 energy point per second to a maximum of +5",
}

Skills["fall_damage_resistance"] = {
	NAME = "Fall Damage",
	COST = {[0] = 0, [1] = 5000, [2] = 10000, [3] = 15000, [4] = 20000, [5] = 25000, },
	LEVEL = {[0] = 5, [1] = 6, [2] = 7, [3] = 8, [4] = 9, [5] = 10, },
	DESCRIPTION = "This upgrade will reduce your fall damage",
}

buyableProps = {}
buyableProps[1] = 
{
  MODEL = Model("models/props_farm/stairs_wood001a.mdl"),
  NAME = "Stairs",
  PRICE = 40, 
  COST = 35000, 
  HEALTH = 1000, 
  FILENAME = "stairs"
}
buyableProps[2] = 
{
  MODEL = Model("models/props_trainyard/awning001.mdl"),
  NAME = "Awning",
  PRICE = 100, 
  COST = 60000, 
  HEALTH = 1200, 
  FILENAME = "awning"
}

PropList = {}
PropList[1] = {
	MODEL = "models/props_junk/wood_crate001a.mdl",
	NAME = "Wooden crate",
	PRICE = 5,
	HEALTH = 500
}
PropList[2] = {
	MODEL = "models/props_junk/wood_crate002a.mdl",
	NAME = "Large wooden crate",
	PRICE = 10,
	HEALTH = 500
}
PropList[3] = {
	MODEL = "models/props_junk/wood_pallet001a.mdl",
	NAME = "Wooden pallet",
	PRICE = 15,
	HEALTH = 700
}
PropList[4] = {
	MODEL = "models/props_wasteland/wood_fence01a.mdl",
	NAME = "Wooden fence",
	PRICE = 40,
	HEALTH = 800
}
PropList[5] = {
	MODEL = "models/props_wasteland/wood_fence02a.mdl",
	NAME = "Slim wooden fence",
	PRICE = 30,
	HEALTH = 900
}
PropList[6] = {
	MODEL = "models/props_pipes/concrete_pipe001a.mdl",
	NAME = "Concrete Pipe",
	PRICE = 50,
	HEALTH = 1000
}
PropList[7] = {
	MODEL = "models/props_docks/dock01_pole01a_128.mdl",
	NAME = "Wooden pole",
	PRICE = 30,
	HEALTH = 800
}
/*
PropList[8] = {
	MODEL = "models/props_wasteland/prison_celldoor001a.mdl",
	NAME = "Slim metal bars",
	PRICE = 35,
	HEALTH = 700
}

PropList[9] = {
	MODEL = "models/props_wasteland/prison_slidingdoor001a.mdl",
	NAME = "Metal bars",
	PRICE = 40,
	HEALTH = 800
}

--Buyable props

PropList[100] = {
	MODEL = "models/props_trainyard/awning001.mdl",
	NAME = "Awning",
	PRICE = 100,
	HEALTH = 1200
}
PropList[101] = {
	MODEL = "models/props_farm/stairs_wood001a.mdl",
	NAME = "Stairs",
	PRICE = 45,
	HEALTH = 800
}

PropList[102] = {
	MODEL = "models/props_phx/construct/metal_plate2x2.mdl",
	NAME = "Steel plates",
	PRICE = 125,
	HEALTH = 1750
}

PropList[103] = {
	MODEL = "models/props_phx/construct/glass/glass_plate1x2.mdl",
	NAME = "Glass plate",
	PRICE = 40,
	HEALTH = 700
}
*/
for i,v in pairs(PropList) do
	Model(v.MODEL)
end

EndGameStats = {}
EndGameStats[1] = {
	Text = function(pl,data) return pl:Name().." is the Sadist, with "..data.." Kills!" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w:Frags()})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[2] = {
	Text = function(pl,data) return pl:Name().." is the MoneyMaker, earning a total of $"..data end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.MoneyEarned})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[3] = {
	Text = function(pl,data) return pl:Name().." is the BaseBuilder, wasting $"..data.." in props" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.ProppedMoney})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[4] = {
	Text = function(pl,data) return pl:Name().." isn't afraid of anything, with "..data.." deaths" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w:Deaths()})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[5] = {
	Text = function(pl,data) return pl:Name().." is the Homewrecker, doing a total of "..math.floor(data).." building damage" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.BuildingDamage})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[6] = {
	Text = function(pl,data) return pl:Name().." is a bit shy, with only  "..data.." kills" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w:Frags()})
		end
		table.sort(t,function(a,b) return a[2] < b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[7] = {
	Text = function(pl,data) return pl:Name().." is emo with "..data.." suicides" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.Suicides})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[8] = {
	Text = function(pl,data) return pl:Name().." is the Headhunter with "..data.." headshots" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.Headshots})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[9] = {
	Text = function(pl,data) return pl:Name().." is taking the game seriously, earning "..data.." achievements" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.TeirProgressEarned})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[10] = {
	Text = function(pl,data) return pl:Name().." is a Ball Whore, holding the ball for "..data.." seconds" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.BallSecs})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}
EndGameStats[11] = {
	Text = function(pl,data) if !IsValid(pl) then return "Nobody is impatient, because nobody voteskipped!" end return pl:Name().." is impatient, being the first voteskipper this round" end,
	Grabber = function(pl)
		for q,w in pairs(player.GetAll()) do
			if w.firstSkipper then
				return w
			end
		end
	end
}
EndGameStats[12] = {
	Text = function(pl,data) return pl:Name().." likes to spam chat, with a total of "..data.." messages" end,
	Grabber = function(pl)
		local t = {}
		for q,w in pairs(player.GetAll()) do
			table.insert(t,{w,w.Messages})
		end
		table.sort(t,function(a,b) return a[2] > b[2] end)
		
		return t[1][1],t[1][2]
	end
}


------------
--Maplist
------------
local list = file.Find("addons/fw_content/maps/*.bsp", "GAME") /** Change *.lua to what file format you want to loadfor example .mdl **/

mapList = {}
for k,v in pairs(list) do
    table.insert(mapList, {string.sub(v, 1, -5)})
end

for i,v in pairs(mapList) do
	mapList[i].votes = 0
end

utSounds = {}
utSounds.killingSprees = {}
utSounds.multiKills = {}

utSounds.killingSprees[3] = {}
utSounds.killingSprees[5] = {}
utSounds.killingSprees[8] = {}
utSounds.killingSprees[12] = {}
utSounds.killingSprees[17] = {}
utSounds.killingSprees[25] = {}

utSounds.multiKills[2] = {}
utSounds.multiKills[3] = {}
utSounds.multiKills[4] = {}
utSounds.multiKills[5] = {}
utSounds.multiKills[6] = {}

--killingSprees
utSounds.killingSprees[3].SOUND = "darkland/fortwars/killingspree.wav"
utSounds.killingSprees[3].DESC = "is on a killing spree"

utSounds.killingSprees[5].SOUND = "darkland/fortwars/rampage.wav"
utSounds.killingSprees[5].DESC = "is on a rampage"

utSounds.killingSprees[8].SOUND = "darkland/fortwars/dominating.wav"
utSounds.killingSprees[8].DESC = "is DOMINATING!"

utSounds.killingSprees[12].SOUND = "darkland/fortwars/unstoppable.wav"
utSounds.killingSprees[12].DESC = "is UNSTOPPABLE!"

utSounds.killingSprees[17].SOUND = "darkland/fortwars/wickedsick.wav"
utSounds.killingSprees[17].DESC = "is WICKEDSICK!"

utSounds.killingSprees[25].SOUND = "darkland/fortwars/godlike.wav"
utSounds.killingSprees[25].DESC = "is GODLIKE!"

--multiKills
utSounds.multiKills[2].SOUND = "darkland/fortwars/multikill.wav"
utSounds.multiKills[2].DESC = "got a multikill"

utSounds.multiKills[3].SOUND = "darkland/fortwars/ultrakill.wav"
utSounds.multiKills[3].DESC = "got an ultrakill"

utSounds.multiKills[4].SOUND = "darkland/fortwars/monsterkill.wav"
utSounds.multiKills[4].DESC = "got a monsterkill"

utSounds.multiKills[5].SOUND = "darkland/fortwars/ludricouskill.wav"
utSounds.multiKills[5].DESC = "got a ludricouskill"

utSounds.multiKills[6].SOUND = "darkland/fortwars/holyshit.wav"
utSounds.multiKills[6].DESC = "HOLY SHIT!"