local data = require("dataAPI")
local tools = require("toolsAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local dig = require("digAPI")
local tArgs = {...}
local stack = {}

local inverter = {
	["forward"] = move.backward,
	["back"] = move.forward,
	["turnLeft"] = move.turnRight,
	["turnRight"] = move.turnLeft,
	["up"] = move.down,
	["down"] = move.up,
}

function stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

function mineSquence(Shaft_Amount, Shaft_Width, Shaft_Distance)
	for i=1, Shaft_Amount do
		for i=1, Shaft_Distance do
			move.forward()
			dig.checkForOre()
			turtle.digUp()
		end
		move.turnLeft()
		for i=1, Shaft_Width do
			move.forward()
			dig.checkForOre()
			turtle.digUp()
		end
		move.turnAround()
		move.forward(Shaft_Width)
		for i=1, Shaft_Width do
			move.forward()
			dig.checkForOre()
			turtle.digUp()
		end
		move.turnAround()
		move.forward(Shaft_Width)
		move.turnRight()
		end
		if data.loadData("/.save", "/chest")[1] == true then
			storage.emptyInv()
		elseif data.loadData("/.save", "/chest")[1] == false then
			storage.waitforemptyInv()
		end
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	error(("Usage: %s Define shaft amount, shaft width and shaft distance. (Example: '10 20 3' [10 deep, 20 to each side, and every 3 blocks]"):format(fs.getName(shell.getRunningProgram())))
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
storage.avoidChest()
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
move.moveTo(start.x, start.y, start.z)
storage.drop(data.coords)
fs.delete("/.save")