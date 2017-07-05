player_identifier_table = {}
local clearImg = "bg.png"
local cornerPos = {x=0.78,y=0.85}
local linesize = 18
local useDebug = false

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

	if useDebug == true then
		player_identifier_table[name].huddebug = player:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=0},
			size = "",
			text = "DEBUG:",
			number = 0x00FF00,
			alignment = {x=1,y=1},
			offset = {x=0, y=0}
		})
	end

	player_identifier_table[name].hud_bg = player:hud_add({
		hud_elem_type = "image",
		position = cornerPos,
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		offset = {x=0, y=0},
		scale = {x=40,y=20}
	})

	player_identifier_table[name].hud_image = player:hud_add({
		hud_elem_type = "statbar",
		position = cornerPos,
		size = {x=50,y=50},
		text = "bg.png",
		number = 2,
		offset = {x=linesize, y=25}
	})

	player_identifier_table[name].hud_titlebar = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = "Block-Info:",
		number = 0x00FF00,
		alignment = {x=1,y=1},
		offset = {x=5, y=0}
	})

	player_identifier_table[name].hud_title = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = "air",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=82, y=0}
	})

	player_identifier_table[name].hud_modinfo = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=82, y=linesize*2}
	})

	player_identifier_table[name].hud_description = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=5, y=linesize*5}
	})

	player_identifier_table[name].hudtext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.72,y=0.927},
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})

	player_identifier_table[name].clocktext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.993,y=0.993},
		size = "",
		text = "0:00:00",
		number = 0xFFFFFF,
		alignment = {x=-1,y=-1},
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
			local meta = minetest.get_meta({x=newdir.x,y=newdir.y,z=newdir.z})
			local metaTable = meta:to_table()

			if node.name ~= "air" and node.name ~= "ignore" then
				if node.name ~= oldnode then
					player_identifier_table[pName].name = node.name
					setImg = clearImg
					tiles = minetest.registered_items[node.name].inventory_image

					if string.len(tiles) > 0 then
						setImg = tiles
					else
						tiles = minetest.registered_nodes[node.name].tiles
						if tiles ~= nil and type(tiles[1]) == "string" then
							setImg = minetest.registered_nodes[node.name].tiles[1]
						end
					end

					local reciepesTable = minetest.get_all_craft_recipes(node.name)
					local dbg = "n/a"
					local recAmount = 0

					if reciepesTable ~= nil then
						recAmount = #reciepesTable
						-- dbg = "len=" .. tostring(recAmount) .. "\n" .. dump(reciepesTable)
						
					end

					-- dbg = dump(metaTable)
					-- player:hud_change(player_identifier_table[pName].huddebug, "text", "DEBUG:\n" .. dbg)

					player:hud_change(player_identifier_table[pName].hud_image, "text", setImg)

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

					local maxLineLen = 50
					local strLen = string.len(text_description)
					local maxLines = math.ceil(string.len(text_description)/maxLineLen)

					dbg = "strLen=" .. tostring(strLen) .. " | " .. tostring(maxLines)

					local thisline = ""
					local cuttedStr = text_description
					text_description = ""

					for lineCount = 1, maxLines do
						splitIndex = string.find(cuttedStr, " ", maxLineLen - 5, maxLineLen)
						thisline = string.sub(cuttedStr, 0, splitIndex)

						if useDebug == true then
							dbg = dbg .. "\n\nlineCount=" .. tostring(lineCount) .. " | splitIndex=" .. tostring(splitIndex) .. " | thisline=" .. thisline
						end

						if lineCount < maxLines then
							thisline = thisline .. "\n"
							cuttedStr = string.sub(cuttedStr, splitIndex + 1)
						end

						text_description = text_description .. thisline
					end

					

					-- if string.len(text_description) > 45 then
						-- splitIndex = string.find(text_description, " ", 45)
						-- text_description = string.sub(text_description, 0, splitIndex) .. "\n" .. string.sub(text_description, splitIndex + 1)
					-- end

					text_title = text_title .. " | Reciepes: " .. tostring(recAmount)
					player:hud_change(player_identifier_table[pName].hud_title, "text", text_title)
					player:hud_change(player_identifier_table[pName].hud_description, "text", text_description)
					player:hud_change(player_identifier_table[pName].hud_modinfo, "text", "Mod: " .. minetest.registered_nodes[node.name].mod_origin .. "\n --> " .. node.name)

					if useDebug == true then
						player:hud_change(player_identifier_table[pName].huddebug, "text", "DEBUG:\n" .. dbg)
					end
				end
				return
			end

			local entity
		end
		if player_identifier_table[pName].name ~= "air" then
			player:hud_change(player_identifier_table[pName].hud_image, "text", clearImg)

			player_identifier_table[pName].name = "air"
			player:hud_change(player_identifier_table[pName].hud_title, "text", "air")
			player:hud_change(player_identifier_table[pName].hud_description, "text", " ")
			player:hud_change(player_identifier_table[pName].hud_modinfo, "text", " ")
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
