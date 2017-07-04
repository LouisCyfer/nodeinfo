player_identifier_table = {}
local border_size = 0.2
local clearImg = "bg.png"

--[[
-- possibly necessary for future updates

local basic_machines_found = false

function applyModSupport()
	for i, name in ipairs(minetest.get_modnames()) do
		if name == "basic_machines" then
			basic_machines_found = true
		end
	end
end
applyModSupport()
--]]

minetest.register_on_joinplayer(function(player)

	local name = player:get_player_name()

	if player_identifier_table[name] == nil then
		player_identifier_table[name] = {}
	end

	player_identifier_table[name].name = "air"
--[[
	player_identifier_table[name].huddebug = player:hud_add({
		hud_elem_type = "text",
		position = {x=0,y=0},
		size = "",
		text = "DEBUG:",
		number = 0x00FF00,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})
--]]
	player_identifier_table[name].hudbackground = player:hud_add({
		hud_elem_type = "image",
		position = {x=0.65,y=0.92},
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		offset = {x=0, y=0},
		scale = {x=40.5,y=4.8 + border_size}
	})

	player_identifier_table[name].hudtitle = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.655,y=0.927},
		size = "",
		text = "Block-Info:",
		number = 0x00FF00,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})

	player_identifier_table[name].hudimage = player:hud_add({
		hud_elem_type = "image",
		position = {x=0.66,y=0.95},
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		scale = {x=2.5,y=2.5}
	})

	player_identifier_table[name].hudtext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.72,y=0.927},
		size = "",
		text = "",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})

	player_identifier_table[name].clocktext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.962,y=0.977},
		size = "",
		text = "0:00:00",
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
		local pName = player:get_player_name()
		local oldnode

		local text_title
		local text_description
		local setImg
		local tiles

		oldnode = player_identifier_table[pName].name
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
					player_identifier_table[pName].name = node.name
					setImg = clearImg

					if minetest.registered_nodes[node.name].tiles[1] and type(minetest.registered_nodes[node.name].tiles[1]) == "string" then
						setImg = minetest.registered_nodes[node.name].tiles[1]

						if minetest.registered_items[node.name].inventory_image then
							setImg = minetest.registered_items[node.name].tiles[1]
						end
					end

					player:hud_change(player_identifier_table[pName].hudimage, "text", setImg)

					local getStr = minetest.registered_nodes[node.name].description
					text_title = getStr

					local checkStr = " - "

					if string.find(getStr, checkStr) then
						text_title = string.split(getStr, checkStr)[1]
						text_description = string.split(getStr, checkStr)[2]
					end

					checkStr = ": "

					if string.find(getStr, checkStr) then
						text_title = string.split(getStr, checkStr)[1]
						text_description = string.split(getStr, checkStr)[2]
					end

					if text_description == nil then
						text_description = " "
					end

					local splitIndex = 0

					if string.len(text_description) > 60 then
						splitIndex = string.find(text_description, " ", 60)
						text_description = string.sub(text_description, 0, splitIndex) .. "\n" .. string.sub(text_description, splitIndex + 1)
					end

					text_title = text_title .. " (" .. node.name .. ") | Mod: " .. minetest.registered_nodes[node.name].mod_origin .. "\n\n"
					player:hud_change(player_identifier_table[pName].hudtext, "text", text_title .. text_description)
				end
				return
			end
		end
		if player_identifier_table[pName].name ~= "air" then
			player:hud_change(player_identifier_table[pName].hudimage, "text", clearImg)

			local node = "air"

			player_identifier_table[pName].name = node
			player:hud_change(player_identifier_table[pName].hudtext, "text", node)
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
