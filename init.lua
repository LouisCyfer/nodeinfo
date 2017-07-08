local version = minetest.get_current_modname() .. " v0.5"

player_identifier_table = {}
local clearImg = "bg.png"
local cornerPos = {x=0.78,y=0.85}
local linesize = 18
local timer = 0
local cTime = "00:00:00"
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

--clock
-- minetest.register_globalstep(function(dtime)

function getTimeString()
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
	return timestring
end

function splittedString(inputStr, maxLineLen)

	local reString = ""

	if inputStr == nil or type(inputStr) ~= "string" then
		return "n/a"
	end

	local splitIndex = 0
	local strLen = string.len(inputStr)
	local maxLines = math.ceil(string.len(inputStr)/maxLineLen)	
	local thisline = ""
	
	for lineCount = 1, maxLines do

		if lineCount == maxLines then
			thisline = inputStr
		else
			splitIndex = string.find(inputStr, " ", maxLineLen - 5, maxLineLen)
	
			thisline = string.sub(inputStr, 0, splitIndex)
			thisline = thisline .. "\n"
			inputStr = string.sub(inputStr, splitIndex + 1)
		end

		reString = reString .. thisline
	end
	return reString
end

function fillImage(nodeName)

	if minetest.registered_items[nodeName] == nil then
		return clearImg
	end

	local tiles = minetest.registered_items[nodeName].inventory_image

	if string.len(tiles) > 0 then
		return tiles
	else
		tiles = minetest.registered_nodes[nodeName].tiles
		if tiles ~= nil and type(tiles[1]) == "string" then
			return minetest.registered_nodes[nodeName].tiles[1]
		else
			return clearImg
		end
	end
end

minetest.register_on_joinplayer(function(player)

	local pName = player:get_player_name()

	if player_identifier_table[pName] == nil then
		player_identifier_table[pName] = {}
	end

	player_identifier_table[pName].name = "air"

	if useDebug == true then
		player_identifier_table[pName].huddebug = player:hud_add({
			hud_elem_type = "text",
			position = {x=0,y=0},
			size = "",
			text = "DEBUG:",
			number = 0x00FF00,
			alignment = {x=1,y=1},
			offset = {x=0, y=0}
		})
	end

	player_identifier_table[pName].hud_bg = player:hud_add({
		hud_elem_type = "image",
		position = cornerPos,
		size = "",
		text = "bg.png",
		number = 20,
		alignment = {x=1,y=1},
		offset = {x=0, y=0},
		scale = {x=40,y=20}
	})

	player_identifier_table[pName].hud_image = player:hud_add({
		hud_elem_type = "statbar",
		position = cornerPos,
		size = {x=50,y=50},
		text = "bg.png",
		number = 2,
		offset = {x=linesize, y=25}
	})

	player_identifier_table[pName].hud_titlebar = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = "Block-Info:",
		number = 0x00FF00,
		alignment = {x=1,y=1},
		offset = {x=5, y=0}
	})

	player_identifier_table[pName].hud_title = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = "air",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=82, y=0}
	})

	player_identifier_table[pName].hud_modinfo = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=82, y=linesize*2}
	})

	player_identifier_table[pName].hud_description = player:hud_add({
		hud_elem_type = "text",
		position = cornerPos,
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=5, y=linesize*5}
	})

	player_identifier_table[pName].hudtext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.72,y=0.927},
		size = "",
		text = " ",
		number = 0xFFFFFF,
		alignment = {x=1,y=1},
		offset = {x=0, y=0}
	})

	player_identifier_table[pName].clocktext = player:hud_add({
		hud_elem_type = "text",
		position = {x=0.993,y=0.993},
		size = "",
		text = cTime,
		number = 0xFFFFFF,
		alignment = {x=-1,y=-1},
		offset = {x=0, y=0}
	})
end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 0.2 then

		cTime = getTimeString()
		if cTime == nil then
			cTime = "00:00:00"
		end
		timer = 0
	else
		return
	end

	for _,player in ipairs(minetest.get_connected_players()) do
		--Find some better way to do this
		local dbg = "n/a"

		local pName = player:get_player_name()
		player:hud_change(player_identifier_table[pName].clocktext, "text", cTime)

		local look
		local pos
		local distance
		local newdir
		local newlook

		local node = nil
		local oldnode
		local setNodeName = "air"

		local text_title = "air"
		local text_modInfo = ""
		local text_description = ""

		local setImg = clearImg
		local tiles

		oldnode = player_identifier_table[pName].name
		newdir   = {}
		newlook  = {}
		distance = 3
		look     = player:get_look_dir()
		pos      = player:getpos()
		pos.y = pos.y + 1.5

		local nodeInfos = ""
		local entityInfos = ""

		local foundEntity = {found=false, isPlayer=false, name=nil}

		-- get closest node/entity that is not air/water
		for i = 1, 4 do
			newlook.x = look.x*i
			newlook.y = look.y*i
			newlook.z = look.z*i
			
			newdir.x = (newlook.x) + pos.x
			newdir.y = (newlook.y) + pos.y
			newdir.z = (newlook.z) + pos.z
			
			node = minetest.get_node(newdir)
			local entList = minetest.get_objects_inside_radius(newdir, 0.5)
			foundEntity = {
				found = false,
				isPlayer = false,
				isMob = false,
				name = nil,
				amount = 1,
				hp = 0,
				health = 0,
				follow = {"n/a"},
				tamed = false
			}
			
			local _,object
			for _,object in ipairs(entList) do
				foundEntity.isPlayer = object:is_player()
				foundEntity.hp = object:get_hp()
				foundEntity.found = true

				if object:is_player() then
					foundEntity.name = object:get_player_name()
					break
				else
					if object:get_luaentity() then
						local ent = object:get_luaentity()
						if ent.name == "__builtin:item" then
							local entStr = string.split(ent.itemstring, " ")
							foundEntity.name = entStr[1]
					
							if #entStr > 1 then
								foundEntity.amount = entStr[2]
							end
							break
						else
							foundEntity.isMob = true
							foundEntity.name = ent.name
							if ent.follow then
								foundEntity.follow = ent.follow
							end
							if ent.tamed then
								foundEntity.tamed = ent.tamed
							end
							if ent.health then
								foundEntity.health = ent.health
							end
							break
						end
					end
				end
			end

			nodeInfos = nodeInfos .. tostring(i) .. "=" .. node.name .. "\n"
			entityInfos = entityInfos .. tostring(i) .. "\nfoundEntity:\n" .. dump(foundEntity) .. "\n---\n"

			if foundEntity.found == true then
				setNodeName = foundEntity.name
				break
			else
				if node.name ~= "air" and node.name ~= "ignore" then
					if node.name == "default:water_source" or node.name == "default:water_flowing" then
						if i == 2 then
							break
						end
					else
						break
					end
				end
			end
		end

		if node ~= nil and foundEntity.found == false then
			setNodeName = node.name
		end

		if node ~= nil and setNodeName ~= nil and setNodeName ~= "air" and node.name ~= "ignore" then

			setImg = player:hud_get(player_identifier_table[pName].hud_image)["text"]
			text_title = player:hud_get(player_identifier_table[pName].hud_title)["text"]
			text_modInfo = player:hud_get(player_identifier_table[pName].hud_modinfo)["text"]
			text_description = player:hud_get(player_identifier_table[pName].hud_description)["text"]

			if setNodeName ~= oldnode then
				player_identifier_table[pName].name = setNodeName

				setImg = fillImage(setNodeName)

				local reciepesTable = minetest.get_all_craft_recipes(setNodeName)
				local recAmount = 0

				if reciepesTable ~= nil then
					recAmount = #reciepesTable
				end

				player:hud_change(player_identifier_table[pName].hud_image, "text", setImg)

				local getStr = setNodeName

				if minetest.registered_items[setNodeName] ~= nil then
					getStr = minetest.registered_items[setNodeName].description
				end

				text_title = getStr
				text_description = " "

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

				text_description = splittedString(text_description, 50)

				if foundEntity.found == true then
					text_title = text_title .. " x" .. tostring(foundEntity.amount)

					if foundEntity.isMob == true then
						text_description = "HP: " .. tostring(foundEntity.health) .. "/" .. tostring(foundEntity.hp) .. " | "
						text_description = text_description .. "tamed: " .. tostring(foundEntity.tamed) .. "\n"

						local followStr= ""
						if type(foundEntity.follow) == "string" then
							followStr = foundEntity.follow
						else
							followStr = table.concat(foundEntity.follow, ", ")
						end

						text_description = text_description .. "follow: " .. splittedString(followStr, 50)
					end
				end

				text_title = text_title .. " | Reciepes: " .. tostring(recAmount)
			end
		end

		if minetest.registered_items[setNodeName] ~= nil and setNodeName ~= "air" then
			setMod = minetest.registered_items[setNodeName].mod_origin
			text_modInfo = "Mod: " .. setMod .. "\n --> " .. setNodeName
		end

		player_identifier_table[pName].name = setNodeName

		player:hud_change(player_identifier_table[pName].hud_image, "text", setImg)
		player:hud_change(player_identifier_table[pName].hud_title, "text", text_title)
		player:hud_change(player_identifier_table[pName].hud_modinfo, "text", text_modInfo)
		player:hud_change(player_identifier_table[pName].hud_description, "text", text_description)

		if useDebug == true then
			player:hud_change(player_identifier_table[pName].huddebug, "text", "DEBUG:\n" .. dbg)
		end
	end
end)

if minetest.settings:get("log_mods") then
	minetest.log("action", "[Mod] " .. versionStr .. " loaded")
end
