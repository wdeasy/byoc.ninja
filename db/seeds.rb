# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

group_list = [
	[103582791429524812,"quakecon","https://steamcommunity.com/groups/quakecon"],
	[103582791432330298,"Quakecon™","https://steamcommunity.com/groups/Quakecon-PeaceLoveRockets"],
	[103582791432341478,"Quakecon Forum Wh0r3s","https://steamcommunity.com/groups/wh0r3s"],
	[103582791434503100,"/r/Quakecon","https://steamcommunity.com/groups/rQuakecon"]
]

group_list.each do |steamid, name, url|
	Group.create!(steamid: steamid, name: name, url: url)
end

network_list = [
	[0,"0.0.0.0/0"],
	[1,"10.0.0.0/8"],
	[1,"172.16.0.0/12"],
	[1,"192.168.0.0/16"],
	[2,"255.255.255.255/32"]
]

network_list.each do |name, cidr|
	Network.create!(name: name, cidr: cidr)
end

user_list = [[76561197967593490,"|PpP| Ray Arnold","https://steamcommunity.com/id/RayArnold","https://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/cf/cf9ad90b7219559f4259a552072e790a98befbef.jpg",true]]

user_list.each do |steamid, name, url, avatar, admin|
	User.create!(steamid: steamid, name: name, url: url, avatar: avatar, admin: admin)
end

message_list = [["Click <a href=https://byoc.ninja/seat class=\"alert-link\">HERE</a> to link your BYOC seat to your steam account!","success",false]]

message_list.each do |message, message_type, show|
	Message.create!(message: message, message_type: message_type, show: show)
end

Game.create!(appid: 0, name: "NO GAME DATA FOUND")
