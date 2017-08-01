local version = minetest.get_current_modname() .. " v0.6.1"

player_identifier_table = {}
local clearImg = "bg.png"
local cornerPos = {x=0.77,y=0.825}
local linesize = 18
local timer = 0
local cTime = "00:00:00"
local useDebug = false

local foundMods = {
	basic_machines = false,
	pipeworks = false,
	drawers = false,
	mobs = false
}

function applyModSupport()
	for i, name in ipairs(minetest.get_modnames()) do
		if name == "basic_machines" then foundMods.basic_machines = true
		elseif name == "pipeworks" then foundMods.pipeworks = true
		elseif name == "drawers" then foundMods.drawers = true
		elseif name == "mobs" then foundMods.mobs = true
		end
	end
end
applyModSupport()

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

function splittedString(inputStr)

	local reString = ""
	local maxLineLen = 55

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
			local tmpIndex = string.find(string.reverse(string.sub(inputStr, 0, maxLineLen)), " ")
			-- dbg = "tmpIndex=" .. tostring(tmpIndex)

			splitIndex = string.find(inputStr, " ", maxLineLen - tmpIndex, maxLineLen)
	
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
		return minetest.inventorycube(clearImg, clearImg, clearImg)
	end

	local tiles = minetest.registered_items[nodeName].inventory_image

	if type(tiles) == "string" then
		if string.len(tiles) > 0 then
			return tiles
		else
			if minetest.registered_nodes[nodeName].tiles then
				tiles = minetest.registered_nodes[nodeName].tiles
				-- minetest.log("action", "DEBUG: " .. dump(tiles))

				local maxTiles = #tiles

				local cubeTiles = {
					tile1 = clearImg,
					tile2 = clearImg,
					tile3 = clearImg
				}

				if type(tiles[maxTiles]) == "table" then
					if minetest.registered_nodes[nodeName].tiles[1].name then
						local justTile = minetest.registered_nodes[nodeName].tiles[1].name
						tiles = { justTile }
						cubeTiles.tile2 = justTile
						cubeTiles.tile3 = justTile
					end

					cubeTiles.tile1 = tiles[1]

					if tiles[maxTiles].name then
						cubeTiles.tile2 = tiles[maxTiles].name
						cubeTiles.tile3 = cubeTiles.tile2
					end

					return minetest.inventorycube(cubeTiles.tile1, cubeTiles.tile2, cubeTiles.tile3)

				elseif type(tiles[maxTiles]) == "string" then
					cubeTiles.tile1 = tiles[maxTiles]
					cubeTiles.tile2 = tiles[maxTiles]
					cubeTiles.tile3 = tiles[maxTiles]

					if maxTiles > 1 then
						cubeTiles.tile1 = tiles[1]
						cubeTiles.tile3 = tiles[maxTiles-1]
					end
					
					if nodeName == "bones:bones" then
						cubeTiles.tile1 = tiles[1]
						cubeTiles.tile2 = tiles[maxTiles]
						cubeTiles.tile3 = tiles[3]
					end

					if foundMods.basic_machines == true and minetest.registered_items[nodeName].mod_origin == "basic_machines" then
						cubeTiles.tile1 = tiles[1]
						cubeTiles.tile2 = tiles[3]
						cubeTiles.tile3 = tiles[3]
					end

					return minetest.inventorycube(cubeTiles.tile1, cubeTiles.tile2, cubeTiles.tile3)
				else return tiles[maxTiles] end
			else return minetest.inventorycube(clearImg, clearImg, clearImg)
			end
		end
	else
		return minetest.inventorycube(clearImg, clearImg, clearImg)
	end
end

minetest.register_on_joinplayer(function(player)

	local pName = player:get_player_name()

	if player_identifier_table[pName] == nil then
		player_identifier_table[pName] = {}
	end

	player_identifier_table[pName].name = "air"
	player_identifier_table[pName].amount = 1

	if useDebug == true then
		player_identifier_table[pName].dbg = "n/a"
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

	if timer >= 0.1 then

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

		local pName = player:get_player_name()
		player:hud_change(player_identifier_table[pName].clocktext, "text", cTime)

		if useDebug == true then local dbg = player_identifier_table[pName].dbg end

		local look
		local pos
		local distance
		local newdir
		local newlook

		local node = nil
		local oldnode
		local oldamount
		local setNodeName = "air"

		local text_title = "air"
		local text_modInfo = ""
		local text_description = ""

		local setImg = minetest.inventorycube(clearImg, clearImg, clearImg)
		local tiles

		oldnode = player_identifier_table[pName].name
		oldamount = player_identifier_table[pName].amount

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
				texture = setImg,
				found = false,
				entity = nil,
				isPlayer = false,
				isMob = false,
				name = nil,
				orgName = "",
				amount = 1,
				maxAmount = 1,
				hp = 0,
				health = 0,
				follow = {"n/a"},
				owner = "n/a",
				tamed = false,
				protected = false
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
						foundEntity.entity = ent

						if ent.name == "__builtin:item" then
							local entStr = string.split(ent.itemstring, " ")
							foundEntity.name = entStr[1]
							if #entStr > 1 then
								foundEntity.amount = entStr[2]
								foundEntity.maxAmount = foundEntity.amount
							end
							break
						elseif ent.name == "drawers:visual" and foundMods.drawers == true then
							foundEntity.texture = ent.texture
							foundEntity.orgName = ent.name

							if ent.itemName ~= nil then
								foundEntity.name = ent.itemName
								foundEntity.amount = ent.count
								foundEntity.maxAmount = ent.maxCount
							end

							if foundEntity.name == "" then foundEntity.name = ent.name end

							break
						else
							if foundMods.mobs == true then
								foundEntity.isMob = true
								foundEntity.name = ent.name
								if ent.follow then foundEntity.follow = ent.follow end
								if ent.owner then foundEntity.owner = ent.owner end
								if ent.tamed then foundEntity.tamed = ent.tamed end
								if ent.protected then foundEntity.protected = ent.protected end
								if ent.health then foundEntity.health = ent.health end
								break
							end
						end
					end
				end
			end

			nodeInfos = nodeInfos .. tostring(i) .. "=" .. node.name .. "\n"
			entityInfos = entityInfos .. tostring(i) .. "\nfoundEntity:\n" .. dump(foundEntity) .. "\n---\n"
			-- dbg = entityInfos

			if foundEntity.found == true then setNodeName = foundEntity.name break
			else
				if node.name ~= "air" and node.name ~= "ignore" then
					if node.name == "default:water_source" or node.name == "default:water_flowing" then
						if i == 2 then break end
					else break end
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

			if setNodeName ~= oldnode or foundEntity.amount ~= oldamount then
				player_identifier_table[pName].name = setNodeName
				player_identifier_table[pName].amount = foundEntity.amount

				if foundEntity.found == true then setImg = foundEntity.texture
				else
					local tmpImg = fillImage(setNodeName)
					setImg = tmpImg

					-- if tmpImg then setImg = tmpImg end
				end

				player:hud_change(player_identifier_table[pName].hud_image, "text", setImg)

				local reciepesTable = minetest.get_all_craft_recipes(setNodeName)
				local recAmount = 0

				if reciepesTable ~= nil then recAmount = #reciepesTable end

				local getStr = setNodeName

				if useDebug == true then
					-- dbg = dbg .. "\n\nfoundEntity=\n" .. dump(foundEntity) .. "\n"
					dbg = dump(minetest.registered_entities[foundEntity.orgName])
					dbg = "setNodeName=" .. setNodeName .. "\n\n" .. dbg
				end

				if minetest.registered_items[setNodeName] ~= nil then
					getStr = minetest.registered_items[setNodeName].description
					if minetest.registered_items[setNodeName].tiles then
						local maxTiles = #minetest.registered_items[setNodeName].tiles
						if useDebug == true then
							dbg = dbg .. "\n" .. " tiles " .. maxTiles .. " (" .. type(minetest.registered_items[setNodeName].tiles[maxTiles]) .. "):\n" .. dump(minetest.registered_items[setNodeName].tiles)
						end
					end
				end

				text_title = getStr
				text_description = " "

				local checkStr = " "

				if foundMods.pipeworks == true then
					checkStr = " {"
					if string.find(getStr, checkStr) then
						getStr = string.split(getStr, checkStr)[1]
						-- text_title = string.split(getStr, checkStr)[1]
						-- text_description = string.split(getStr, checkStr)[2]
					end
				end

				if foundMods.basic_machines == true then
					checkStr = " - "

					if string.find(getStr, checkStr) then
						text_title = string.split(getStr, checkStr)[1]
						text_description = string.split(getStr, checkStr)[2]
					end
				end

				checkStr = ": "

				if string.find(getStr, checkStr) then
					text_title = string.split(getStr, checkStr)[1]
					text_description = string.split(getStr, checkStr)[2]
				end

				text_description = splittedString(text_description)

				if foundEntity.found == true then
					text_title = text_title .. " x" .. tostring(foundEntity.amount)

					if foundEntity.isMob == true then
						text_description = "HP: " .. tostring(foundEntity.health) .. "/" .. tostring(foundEntity.hp)
						text_description = text_description .. " | tamed: " .. tostring(foundEntity.tamed)  .. " | protected: " .. tostring(foundEntity.protected) .. "\n"
						text_description = text_description .. "Owner: " .. foundEntity.owner .. "\n"

						local followStr= ""
						if type(foundEntity.follow) == "string" then
							followStr = foundEntity.follow
						else
							followStr = table.concat(foundEntity.follow, ", ")
						end

						text_description = text_description .. "follow: " .. splittedString(followStr)

					elseif foundEntity.orgName == "drawers:visual" and foundMods.drawers == true then
						local getPercent = math.floor(((foundEntity.amount / foundEntity.maxAmount) * 100) + 0.5)

						text_description = "[drawer-info] " .. foundEntity.amount .. "/" .. foundEntity.maxAmount .. " (" .. getPercent .. "% filled)" .. "\n\n" .. text_description
					end
					-- dbg = dbg .. "\nfoundEntity:\n" .. dump(foundEntity.entity)
				end
				-- dbg = dbg .. "\nfoundEntity:\n" .. dump(foundEntity)

				text_title = text_title .. " | Reciepes: " .. tostring(recAmount)
			end
		end

		if setNodeName ~= "air"then
			local setMod = "n/a"

			if minetest.registered_items[setNodeName] ~= nil then
				setMod = minetest.registered_items[setNodeName].mod_origin
			elseif minetest.registered_entities[setNodeName] ~= nil then

				if foundMods.drawers == true and setNodeName == "drawers:visual" then
					setMod = minetest.registered_entities[setNodeName].mod_origin
				end
			end

			text_modInfo = "Mod: " .. setMod .. "\n --> " .. setNodeName
		end

		player_identifier_table[pName].name = setNodeName

		player:hud_change(player_identifier_table[pName].hud_image, "text", setImg)
		player:hud_change(player_identifier_table[pName].hud_title, "text", text_title)
		player:hud_change(player_identifier_table[pName].hud_modinfo, "text", text_modInfo)
		player:hud_change(player_identifier_table[pName].hud_description, "text", text_description)
		
		if useDebug == true then
			player_identifier_table[pName].dbg = dbg
			player:hud_change(player_identifier_table[pName].huddebug, "text", "DEBUG:\n" .. dbg)
		end
	end
end)

if minetest.settings:get("log_mods") then
	minetest.log("action", "[Mod] " .. version .. " loaded")
end
