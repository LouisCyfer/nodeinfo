player_identifier_table = {}
local border_size = 0.2
local clearImg = "bg.png"

minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()

	if player_identifier_table[name] == nil then
		player_identifier_table[name] = {}
	end

	player_identifier_table[name].name = "air"

	player_identifier_table[name].clockbackground = player:hud_add({
		hud_elem_type = "image",
		position = {x=0.978,y=0.004},
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=0,y=1},
		offset = {x=0, y=0},
		scale = {x=4,y=1.2 + border_size}
	})

	player_identifier_table[name].clocktext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.978,y=0.0075},
		size = "",
		text = "0:00:00",
		number = 0xFFFFFF,
		alignment = {x=0,y=0},
		offset = {x=1, y=0}
	})

	player_identifier_table[name].hudbackground = player:hud_add({
		hud_elem_type = "image",
		position = {x=0.7,y=0.878},
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		offset = {x=0, y=0},
		scale = {x=25,y=4.8 + border_size}
	})

	player_identifier_table[name].hudtitle = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.705,y=0.885},
		size = "",
		text = "Block-Info:",
		number = 0x00FF00,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})

	player_identifier_table[name].hudimage = player:hud_add({
		hud_elem_type = "image",
		position = {x=0.705,y=0.905},
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		scale = {x=2.5,y=2.5}
	})

	player_identifier_table[name].hudtext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.75,y=0.885},
		size = "",
		text = "",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})
end)

--node info
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		--Find some better way to do this
		local look
		local pos
		local distance
		local newdir
		local newlook
		local name
		local oldnode

		local setText
		local tiles

		oldnode = player_identifier_table[player:get_player_name()].name
		name = player:get_player_name()
		newdir   = {}
		newlook  = {}
		distance = 3
		look     = player:get_look_dir()
		pos      = player:getpos()
		pos.y = pos.y + 1.5

		for i = 1,50 do
			i = i/10
			newlook.x = look.x*i
			newlook.y = look.y*i
			newlook.z = look.z*i
			
			newdir.x = (newlook.x) + pos.x
			newdir.y = (newlook.y) + pos.y
			newdir.z = (newlook.z) + pos.z
			
			local node = minetest.get_node({x=newdir.x,y=newdir.y,z=newdir.z})
			if node.name ~= "air" and node.name ~= "ignore" then
				if node.name ~= oldnode then

					local setImg = clearImg

					if minetest.registered_nodes[node.name].tiles ~= nil and type(minetest.registered_nodes[node.name].tiles[1]) == "string" then
						setImg = minetest.registered_nodes[node.name].tiles[1]
					end

					player:hud_change(player_identifier_table[name].hudimage, "text", setImg)

					setText = minetest.registered_nodes[node.name].description .. "\n\n" .. node.name

					player_identifier_table[player:get_player_name()].name = setText

					player:hud_change(player_identifier_table[name].hudtext, "text", setText)
				end
				return
			end
		end
		if player_identifier_table[player:get_player_name()].name ~= "Air" then
			player:hud_change(player_identifier_table[name].hudimage, "text", clearImg)

			local node = "air"

			player_identifier_table[player:get_player_name()].name = node
			player:hud_change(player_identifier_table[name].hudtext, "text", node)
		end
	end
end)

--clock
minetest.register_globalstep(function(dtime)
	local timeofday
	local name
	local twentyfour
	
	local minutes
	local hour
	
	local timestring
	local meridiem
	
	meridiem  = " AM"
	timeofday = minetest.get_timeofday()
	
	--convert 24000 minutes into 24 hours
	hour    = math.floor(((timeofday) % 24000)*24)
	minutes = math.floor(((math.floor(((timeofday) % 24000)*2400)-(hour*100))/50)*30)
	--don't do seconds for cpu sake
	
	--turn the raw time into easy to view 12 hour meridiem
	if hour >= 12 then
		meridiem = " PM"
	end
	if hour > 12 then
		hour = hour - 12
	end
	timestring = tostring(hour)
	if string.len(minutes) == 1 then
		timestring = timestring..":".."0"..minutes
	else
		timestring = timestring..":"..minutes
	end
	timestring = timestring..meridiem
	
	for _,player in ipairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		player:hud_change(player_identifier_table[name].clocktext, "text", timestring)
	end
end)
