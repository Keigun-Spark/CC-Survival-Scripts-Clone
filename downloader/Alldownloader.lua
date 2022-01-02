function download(url)
	local content = http.get(url).readAll()
	local filename = url:match( "([^/]+)$" )
	if not content then
		error("Could not connect to website ", url)
	else
		print("Download finished from ", url)
		fs.delete(filename)
		file = fs.open(filename, "wb")
		file.write(content)
		file.close()
		if filename == "Alldownloader.lua" then
			fs.delete("startup/autoupdate.lua")
			fs.move(filename, "startup/autoupdate.lua")
			print("Installed autoupdate on every turtle startup!")
			os.sleep(1)
		end
		print("Downloaded and saved ", filename)
	end
end

print("Downloading APIs and programs!")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/Alldownloader.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/dataAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/toolsAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/moveAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/storageAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/digAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/stripTunnel.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/mineTunnel.lua")
print("API and program download finished.")