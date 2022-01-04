local tArgs = {...}

local api = {
	timeout = 5,
	d = 0,
	hasWireless = false,
	direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
	coords = {x = 0, y = 0,z = 0}
	maxSlots = 16,
	slot = 1,
}

local junkList = {
	"minecraft:dirt",
	"minecraft:gravel",
	"minecraft:cobblestone",
	"minecraft:cobbled_deepslate",
	"minecraft:tuff",
	"minecraft:andesite",
	"minecraft:diorite",
	"minecraft:granite",
}

local fuelList = {
	"minecraft:coal",
	"minecraft:coal_block",
	"minecraft:charcoal",
	"mekanism:block_charcoal",
	"minecraft:lava_bucket",
}

function api.copyTable(tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	end
	local rtbl = {}
	for k,v in pairs(tbl) do
		rtbl[k] = v
	end
	return rtbl
end

function api.saveData(dir, path, tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	elseif type(path) ~= "string" or type(dir) ~= "string" then
		error("The type of 'path' or 'dir' is not a string",2)
	end
	if not fs.exists(dir) then
		fs.makeDir(dir)
	end
	local f = fs.open(dir .. path, "w")
	f.write(textutils.serialize(tbl))
	f.close()
end

function api.loadData(dir, path)
	if type(path) ~= "string" or type(dir) ~= "string" then
		error("The type of 'path' or 'dir' is not a string",2)
	end
	if fs.exists(dir) then
		local tbl = {}
		local f = fs.open(dir .. path, "r")
		tbl = f.readAll()
		tbl = textutils.unserialize(tbl)
		f.close()
		return tbl
	end
	return false
end

function api.findItem(name)
	for i=1, api.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			if item == name then
				turtle.select(i)
				api.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function api.inventorySort()
	local inv = {}
	for i=1, api.maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, api.maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), api.maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
				if turtle.getItemSpace(i) == 0 then
					break
				end
				turtle.select(j)
				api.slot = j
				local count = turtle.getItemSpace(i)
				if count > inv[j].count then
					count = inv[j].count
				end
				turtle.transferTo(i, count)
				inv[i].count = inv[i].count + count
				inv[j].count = inv[j].count - count
				if inv[j].count <= 0 then
					inv[j] = nil
			end
			end
		end
		end
	end
	for i=1, api.maxSlots do
		if not inv[i] then
			for j=(i+1), api.maxSlots do
				if inv[j] then
				turtle.select(j)
				api.slot = j
				turtle.transferTo(i)
				inv[i] = api.copyTable(inv[j])
				inv[j] = nil
				break
				end
			end
		end
	end
	turtle.select(1)
	api.slot = 1
end


function api.place(blockName, direction)
	api.findItem(blockName)
	if direction == nil then
		turtle.place()
	elseif direction == "up" then
		turtle.placeUp()
	elseif direction == "down" then
		turtle.placeDown()
	end
end

function api.dig(direction)
	if direction == nil then
		turtle.dig()
		os.sleep(0.4)
	elseif direction == "up" then
		turtle.digUp()
		os.sleep(0.4)
	elseif direction == "down" then
		turtle.digDown()
		os.sleep(0.4)
	end
end

function api.dropJunk()
	for i=1, api.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value then
					isJunk = true
					break
				end
			end
			if isJunk then
				turtle.select(i)
				api.slot = tonumber(i)
				turtle.dropUp()
			end
		end
	end
	api.inventorySort()
end

function api.findJunk(exclude)
	if exclude == nil then
		exclude = "nothing"
	end
	for i=1, api.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value and item ~= exclude then
					isJunk = true
					break
				end
			end
			if isJunk then
				turtle.select(i)
				api.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function api.refuel()
	for index, value in ipairs(fuelList) do
		if api.findItem(tostring(value)) then
			while turtle.getItemCount(api.slot) >= 1 and turtle.getFuelLevel() < turtle.getFuelLimit() do
				turtle.refuel()
			end
			return true
		end
	end
	return false
end

function api.turnLeft()
	turtle.turnLeft()
	api.d = (api.d - 1) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.turnRight()
	turtle.turnRight()
	api.d = (api.d + 1) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.turnAround()
	turtle.turnRight()
	turtle.turnRight()
	api.d = (api.d + 2) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.face(direction)
	if type(direction) == "number" or "string" then
		if type(direction) == "string" then
			for k,v in pairs(api.direction) do
				if v == direction then
					direction = k
					break
				end
			end
		end
		if direction == (api.d + 2) % 4 then
			api.turnAround()
			return true
		elseif direction == (api.d - 1) % 4 then
			api.turnLeft()
			return true
		elseif direction == (api.d + 1) % 4 then
			api.turnRight()
			return true
		elseif direction == api.d then
			return true
		end
	end
	error("the type of 'direction' is not of type number, string or is invalid")
end

function api.forward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.backward(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.forward() do
			local inspect = {turtle.inspect()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				while turtle.detect() do
					api.dig()
				end
			else
				turtle.attack()
			end
		end
		if api.d == 0 then
			api.coords.z = api.coords.z - 1
		elseif api.d == 1 then
			api.coords.x = api.coords.x + 1
		elseif api.d == 2 then
			api.coords.z = api.coords.z + 1
		elseif api.d == 3 then
			api.coords.x = api.coords.x - 1
		end
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.left(times)
	api.turnLeft()
	api.forward(times)
	api.turnRight()
end

function api.right(times)
	api.turnRight()
	api.forward(times)
	api.turnLeft()
end

function api.backward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.forward(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		turtle.back()
		if api.d == 0 then
			api.coords.z = api.coords.z + 1
		elseif api.d == 1 then
			api.coords.x = api.coords.x - 1
		elseif api.d == 2 then
			api.coords.z = api.coords.z - 1
		elseif api.d == 3 then
			api.coords.x = api.coords.x + 1
		end
		api.saveData("/.save", "/position", api.coords)
	end
end

function api.up(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.down(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.up() do
			local inspect = {turtle.inspectUp()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				api.dig("up")
			else
				turtle.attackUp()
			end
		end
		api.coords.y = api.coords.y + 1
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.down(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.up(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.down() do
			local inspect = {turtle.inspectDown()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				api.dig("down")
			else
				turtle.attackDown()
			end
		end
		api.coords.y = api.coords.y - 1
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.moveTo(x, y, z)
	if x == "~" then
		x = api.coords.x
	end
	if y == "~" then
		y = api.coords.y
	end
	if z == "~" then
		z = api.coords.z
	end
	if y > api.coords.y then
		api.up(y - api.coords.y)
	end
	if x < api.coords.x then
		api.face(3)
		api.forward(api.coords.x - x)
	elseif x > api.coords.x then
		api.face(1)
		api.forward(x - api.coords.x)
	end
	if z < api.coords.z then
		api.face(0)
		api.forward(api.coords.z - z)
	elseif z > api.coords.z then
		api.face(2)
		api.forward(z - api.coords.z)
	end
	if y < api.coords.y then
		api.down(api.coords.y - y)
	end
end

local function mineSequence(steps, direction)
	for i=1, steps do
		if direction == "up" then
			while turtle.detectUp() do
				api.dig("up")
			end
			api.forward()
			api.up()
		elseif direction == "down" then
			while turtle.detectUp() do
				api.dig("up")
			end
			api.forward()
			api.down()
		end
	end
end

if type(tonumber(tArgs[1])) ~= "number" and type(tostring(tArgs[1])) ~= "string" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define step amount and direction! (Example: '10 up') [10 steps, upwards]")
end

local start = api.copyTable(api.coords)
api.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tostring(tArgs[2]))
fs.delete("/.save")