local api = require("customAPI")
local tArgs = {...}
local stack = {}

local inverter = {
	["forward"] = api.backward,
	["back"] = api.forward,
	["turnLeft"] = api.turnRight,
	["turnRight"] = api.turnLeft,
	["up"] = api.down,
	["down"] = api.up,
}

local converter = {
	["forward"] = api.forward,
	["back"] = api.backward,
	["turnLeft"] = api.turnLeft,
	["turnRight"] = api.turnRight,
	["up"] = api.up,
	["down"] = api.down,
}

local oreList = {
	"minecraft:iron_ore",
	"minecraft:coal_ore",
	"minecraft:gold_ore",
	"minecraft:diamond_ore",
	"minecraft:emerald_ore",
	"minecraft:copper_ore",
	"minecraft:lapis_ore",
	"minecraft:redstone_ore",
	"minecraft:deepslate_iron_ore",
	"minecraft:deepslate_coal_ore",
	"minecraft:deepslate_gold_ore",
	"minecraft:deepslate_diamond_ore",
	"minecraft:deepslate_emerald_ore",
	"minecraft:deepslate_copper_ore",
	"minecraft:deepslate_lapis_ore",
	"minecraft:deepslate_redstone_ore",
	"minecraft:nether_gold_ore",
	"minecraft:nether_quartz_ore",
}

function stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

function checkFallTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table",2)
	end
	if tbl[1] == true then
		for k,v in pairs(fallList) do
			if tbl[2].name == fallList[k] then
			return true
		end
	end
		return false
	else
		return false
	end
end

function checkOreTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table",2)
	end
	if tbl[1] == true then
		for k,v in pairs(oreList) do
			if tbl[2].name == oreList[k] then
				return true
			end
		end
		return false
	else
		return false
	end
end

function veinMine(lastFunc)
	if type(lastFunc) == "function" or "string" then
		if type(lastFunc) == "function" then
			for k,v in pairs(converter) do
				if v == lastFunc then
					table.insert(stack, k)
					break
				end
			end
		end
		if checkOreTable({turtle.inspectUp()}) then
			api.up()
			return veinMine(api.up)
		elseif checkOreTable({turtle.inspectDown()}) then
			api.down()
			return veinMine(api.down)
		end
		for i=1, 4 do
			if checkOreTable({turtle.inspect()}) then
				if i == 1 then
					api.forward()
					return veinMine(api.forward)
				elseif i == 2 then
					return veinMine(api.turnLeft)
				elseif i == 3 then
					table.insert(stack, "turnLeft")
					return veinMine(api.turnLeft)
				elseif i == 4 then
					return veinMine(api.turnRight)
				end
			end
			api.turnLeft()
		end
		if stack[#stack] == "turnLeft" then
			if stack[#stack] == stack[#stack-1] then
				stackPop()
				stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return veinMine(lastFunc)
				end
				return
			else
				stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return veinMine(lastFunc)
				end
				return
			end
		else
			stackPop()
			lastFunc = stack[#stack]
			if #stack > 0 then
				return veinMine(lastFunc)
			end
			return
		end
	else
		error("'lastFunc' is not of type function or string", 2)
	end
end

function checkForOre()
	if checkOreTable({turtle.inspectUp()}) then
		api.up()
		veinMine(api.up)
	end
	if checkOreTable({turtle.inspectDown()}) then
		api.down()
		veinMine(api.down)
	end
	api.turnLeft()
	if checkOreTable({turtle.inspect()}) then
		api.forward()
		veinMine(api.forward)
	end
	api.turnAround()
	if checkOreTable({turtle.inspect()}) then
		api.forward()
		veinMine(api.forward)
	end
		api.turnLeft()
end

function mineSquence()
	local Shaft_Amount = tonumber(arg[1])
	local Shaft_Widht = tonumber(arg[2])
	local Shaft_Distance = tonumber(arg[3])
	local move = 0
	for i=1, Shaft_Amount do
		for i=1, Shaft_Distance do
			api.forward()
			print("fwd")
			checkForOre()
			turtle.digUp()
			move = move + 1
			if turtle.getItemDetail(16).name == "minecraft:torch" and move == 10 then
				turtle.select(16)
				turtle.placeUp()
				turtle.select(1)
				move = 0
			end
		end
		api.turnLeft()
		print("left")
		for i=1, Shaft_Widht do
			api.forward()
			print("fwd")
			checkForOre()
			turtle.digUp()
			move = move + 1
			if turtle.getItemDetail(16).name == "minecraft:torch" and move == 10 then
				turtle.select(16)
				turtle.placeUp()
				turtle.select(1)
				move = 0
			end
		end
		api.turnAround()
		print("around")
		api.forward(Shaft_Widht)
		print("fwdfull")
		for i=1, Shaft_Widht do
			api.forward()
			print("fwd")
			checkForOre()
			turtle.digUp()
			move = move + 1
			if turtle.getItemDetail(16).name == "minecraft:torch" and move == 10 then
				turtle.select(16)
				turtle.placeUp()
				turtle.select(1)
				move = 0
			end
		end
		api.turnAround()
		print("around")
		api.forward(Shaft_Widht)
		print("fwdfull")
		api.turnRight()
		print("right")
		if api.loadData("/.save", "/chest")[1] == true then
			api.emptyInv()
		elseif api.loadData("/.save", "/chest")[1] == false then
			api.waitforemptyInv()
		end
	end
	if checkOreTable({turtle.inspect()}) then
		api.forward()
		veinMine(api.forward)
	end
end

local start = api.copyTable(api.coords)
api.saveData("/.save", "/start_pos", start)
api.avoidChest()
mineSquence(tArgs[1], tArgs[2], tArgs[3])
api.moveTo(start.x, start.y, start.z)
api.drop(api.maxSlots)
fs.delete("/.save")