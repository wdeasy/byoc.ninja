# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

group_list = [
	[103582791429524812,"quakecon","http://steamcommunity.com/groups/quakecon"],
	[103582791432330298,"Quakecon™","http://steamcommunity.com/groups/Quakecon-PeaceLoveRockets"],
	[103582791432341478,"Quakecon Forum Wh0r3s","http://steamcommunity.com/groups/wh0r3s"],
	[103582791434503100,"/r/Quakecon","http://steamcommunity.com/groups/rQuakecon"]
]

group_list.each do |groupid64, name, url|
	Group.create!(groupid64: groupid64, name: name, url: url)
end

game_list = [
	[251570,"7 Days to Die","7d2d"],
	[107410,"Arma 3","armedassault3"],
	[22350,"BRINK","brink"],
	[221100,"DayZ","dayz"],
	[50130,"Mafia II","m2mp"],
	[4920,"Natural Selection 2","ns2"],
	[252490,"Rust","rust"],
	[1250,"Killing Floor","killingfloor"],
	[10,"Counter-Strike","cs16"],
	[240,"Counter-Strike: Source","css"],
	[80,"Counter-Strike: Condition Zero","cscz"],
	[730,"Counter-Strike: Global Offensive","csgo"],
	[4000,"Garry's Mod","gmod"],
	[320,"Half-Life 2: Deathmatch","hl2dm"],
	[70,"Half-Life","hldm"],
	[500,"Left 4 Dead","l4d"],
	[550,"Left 4 Dead 2","l4d2"],
	[300,"Day of Defeat: Source","dods"],
	[20,"Team Fortress Classic","tfc"],
	[440,"Team Fortress 2","tf2"]
]

game_list.each do |gameid, gameextrainfo, protocol|
	Game.create!(gameid: gameid, gameextrainfo: gameextrainfo, protocol: protocol)
end

network_list = [
	["byoc","0.0.0.0","0.0.0.0"],
	["private","10.0.0.0","10.255.255.255"],
	["private","172.16.0.0","172.31.255.255"],
	["private","192.168.0.0","192.168.255.255"]
]

network_list.each do |network, min, max|
	Network.create!(network: network, min: min, max: max)
end

user_list = [[76561197967593490,"|PpP| Ray Arnold","http://steamcommunity.com/id/RayArnold","http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/cf/cf9ad90b7219559f4259a552072e790a98befbef.jpg",true]]

user_list.each do |steamid, personaname, profileurl, avatar, admin|
	User.create!(steamid: steamid, personaname: personaname, profileurl: profileurl, avatar: avatar, admin: admin)
end

protocol_list = [
	["7d2d","7 Days to Die"],
	["Soldat","Soldat"],
	["aa","America's Army"],
	["aa3"," America's Army 3 (> 3.2)"],
	["aa3pre32","America's Army 3 (< 3.2)"],
	["alienswarm","Alien Swarm"],
	["aoc","Age of Chivalry"],
	["armedassault","Armed Assault"],
	["armedassault2","Armed Assault 2"],
	["armedassault2oa","Armed Assault 2: Operation Arrowhead"],
	["bfv","Battlefield Vietnam"],
	["brink","Brink"],
	["cod","Call of Duty"],
	["cod2","Call of Duty 2"],
	["cod4","Call of Duty 4"],
	["codmw3","Call of Duty: Modern Warfare 3"],
	["coduo","Call of Duty: United Offensive"],
	["codwaw","Call of Duty: World at War"],
	["crysis","Crysis"],
	["crysis2","Crysis 2"],
	["crysiswars","Crysis Wars"],
	["cs16","Counter-Strike 1.6"],
	["cscz","Counter-Strike: Condition Zero"],
	["csgo","Counter-Strike: Global Offensive"],
	["css","Counter-Strike: Source"],
	["cube2","Cube 2: Sauerbraten"],
	["dayz","DayZ Standalone"],
	["dayzmod","DayZ Mod"],
	["dod","Day of Defeat"],
	["dods","Day of Defeat: Source"],
	["doom3","Doom 3"],
	["et","Wolfenstein Enemy Territory"],
	["etqw","Enemy Territory: Quake Wars"],
	["fear","F.E.A.R."],
	["ffe","Fortress Forever"],
	["ffow","Frontlines: Fuel of War"],
	["gamespy","Gamespy"],
	["gamespy2","Gamespy2"],
	["gamespy3","Gamespy3"],
	["gmod","Garry's Mod"],
	["gore","Gore"],
	["graw","Gserver Recon: Advanced Warfighter"],
	["graw2","Gserver Recon: Advanced Warfighter 2"],
	["hl2dm","Half Life 2: Deathmatch"],
	["hldm","Half Life: Deathmatch"],
	["homefront","Homefront"],
	["insurgency","Insurgency"],
	["jc2","Just Cause 2 Multiplayer"],
	["killingfloor","Killing Floor"],
	["l4d","Left 4 Dead"],
	["l4d2","Left 4 Dead 2"],
	["m2mp","Mafia 2 Multiplayer"],
	["minecraft","Minecraft"],
	["minequery","Minequery"],
	["mohaa","Medal of Honor: Allied Assault"],
	["mohsh","Medal of Honor: Spearhead"],
	["mohwf","Medal of Honor Warfighter"],
	["mta","Multi Theft Auto"],
	["mumble","Mumble"],
	["ns","Natural Selection"],
	["ns2","Natural Selection 2"],
	["quake2","Quake 2"],
	["quake3","Quake 3"],
	["quake4","Quake 4"],
	["redeclipse","Red Eclipse"],
	["redfaction","Red Faction"],
	["redorchestra","Red Orchestra: Ostfront 41-45"],
	["redorchestra2","Red Orchestra 2"],
	["rtcw","Return to Castle Wolfenstein"],
	["rust","Rust"],
	["samp","San Andreas Multiplayer"],
	["sof2","Soldier of Fortune 2"],
	["source","Source Server"],
	["stalker","S.T.A.L.K.E.R: Shadow of Chernobyl"],
	["starbound","Starbound"],
	["teamspeak2","Teamspeak 2"],
	["teamspeak3","Teamspeak 3"],
	["teeworlds","Teeworlds"],
	["terraria","Terraria"],
	["tf2","Team Fortress 2"],
	["tfc","Team Fortress Classic"],
	["tribes2","Tribes 2"],
	["ut","Unreal Tournament"],
	["ut2004","Unreal Tournament 2004"],
	["ut3","Unreal Tournament 3"],
	["ventrilo","Ventrilo"],
	["warsow","Warsow"],
	["zombiemaster","Zombie Master"],
	["zps","Zombie Panic Source"]
]

protocol_list.each do |protocol, name|
	Protocol.create!(protocol: protocol, name: name)
end

