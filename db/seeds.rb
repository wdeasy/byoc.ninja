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

