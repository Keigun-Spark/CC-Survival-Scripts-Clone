local library = require("library")
local tArgs = {...}

function mineSquence(depth, start)
	for i=1, depth do
		library.move.down()
		if start - 2 == library.data.coords.y then
			if library.tools.findJunk("minecraft:gravel") then
				turtle.placeUp(library.tools.slot)
			end
		end
		library.dig.checkForOre(tostring("back_true"))
		local tbl = {turtle.inspectDown()}
		if tbl[2].name == "minecraft:bedrock" then
			term.clear()
			term.setCursorPos(1,1)
			print("Found bedrock at "..library.data.coords.y.." blocks deep,")
			print("returning to the surface!")
			if library.data.hasWireless then
				rednet.broadcast("Found bedrock at "..library.data.coords.y.." blocks deep,")
				rednet.broadcast("returning to the surface!")
			end
			local y = start - library.data.coords.y
			library.move.up(y)
			if library.tools.findJunk("minecraft:gravel") then
				turtle.placeDown(library.tools.slot)
				return
			end
		elseif start - depth == library.data.coords.y then
			local y = start - library.data.coords.y
			library.move.up(y)
			if library.tools.findJunk("minecraft:gravel") then
				turtle.placeDown(library.tools.slot)
				return
			end
		end
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define depth down! (Example: '10') [10 blocks down]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), start.y)
library.move.moveTo(start.x, start.y, start.z)
library.storage.drop(library.tools.maxSlots)
fs.delete("/.save")