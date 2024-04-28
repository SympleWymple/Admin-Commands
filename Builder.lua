local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

return function(Settings)
	script.SystemPackages.Settings:Destroy() --> delete settings in package it was just a place holder
	Settings.Name = "Settings" -- get the new one and name it
	Settings.Parent = script.SystemPackages -- and put it back in our package folder

	warn("sz_Tolu's Admin; Preparing...")

	-- get folders, remote evnts, and tables
	local remotefolder = Instance.new("Folder")

	local isPlayerAddedFired = false --> check if the player added event was fired for the first player
	local remotes = {
		Function = Instance.new("RemoteFunction"),
		Event = Instance.new("RemoteEvent"),
		BindableEvent = Instance.new("BindableEvent")
	}
		
	-- global packages 
	local packages,systemPackages, permissionTable, disableTable, cachedData, sharedCommons, globalAdmins = {}, {}, {}, {}, {}, {}, {}
	-- change name of folder, add all related events and then put it in the garbage once done
	remotefolder.Name = "sz_Tolu Remotes"
	remotes.Function.Parent, remotes.Event.Parent, remotes.BindableEvent.Parent = remotefolder, remotefolder, remotefolder
	remotes.BindableEvent.Name = "BindableEvent"
	remotefolder.Parent = ReplicatedStorage
	remotefolder = nil

		
--> used to go through the rank permissions from highest to lowest do we this because we just inherit the commands from the admin ranks under Owner perms, 
		--instead of listing each admin rank for each indivudal admin rank
	local function buildTempPermissions(permissions, group, groupconfig)
		local temptable = {}
		if groupconfig["Inherits"] and permissions[groupconfig["Inherits"]] and permissions[groupconfig["Inherits"]]["Permissions"] then
			for _,perm in ipairs(permissions[groupconfig["Inherits"]]["Permissions"]) do
				table.insert(temptable, perm)
			end
			local inherited = buildTempPermissions(permissions, groupconfig["Inherits"], permissions[groupconfig["Inherits"]])
			if inherited ~= false then
				for _, perm in ipairs(inherited) do
					table.insert(temptable, perm)
				end
			end
			return temptable
		else
			return false
		end
	end


	--> this actuall build the table for each admin rank getting the info from the above function
	local function buildPermissionTables()
		local permissions = systemPackages.Settings["Settings"]["Permissions"]

		for i,v in pairs(permissions) do
			permissionTable[i] = {}

			if v["Permissions"] then
				for _,perm in ipairs(v["Permissions"]) do
					permissionTable[i][perm] = true
				end
			end

			if v["Inherits"] and permissions[v["Inherits"]] and permissions[v["Inherits"]]["Permissions"] then
				local inherited = buildTempPermissions(permissions, i, v)
				if inherited ~= false then
					for _,perm in ipairs(inherited) do
						permissionTable[i][perm] = true
					end
				end
			end
		end
	end

	-- Builds disable prefix table.
	local function buildDisableTables()
		local permissions = systemPackages.Settings["Settings"]["Permissions"]

		for i,v in pairs(permissions) do
			disableTable[i] = {}

			if v["DisallowPrefixes"] then
				for _,disallow in ipairs(v["DisallowPrefixes"]) do
					disableTable[i][disallow:lower()] = true
				end
			end
		end
	end

		---> this is used for checking the rank list permissions, for groups and players, also groups have two types of ways it can be set
		--> manually code each section (yes this could definately be improved and become more effecient
		--<  but to make sure there are no errors this way is fine
	local function buildAdminList()
		local settingsRequired = require(Settings)
		local ranks = settingsRequired["Settings"]["Ranks"]
		local OwnerUsers = ranks["Creators"]["Users"]
		local HeadAdminUsers = ranks["HeadAdmins"]["Users"]
		local Admins = ranks["Admins"]["Users"]
		local Moderators = ranks["Moderators"]["Users"]
		local Trainers = ranks["Trainers"]["Users"]

		for i, v in ipairs(OwnerUsers) do
			if v["Type"] == "Group" then
				local tableTemplate = {
					["Type"] = "Group";
					["ID"] = 0;
					["Rank"] = 0;
					["Name"] = "";
					["AdminRank"] = "Creator"
				}
				if string.match(v["Rank"], "/^[0-9]+$/") then
					tableTemplate["Rank"] = tonumber(v["Rank"])
				else
					local num1, num2 = string.split(v["Rank"], ":")[1],string.split(v["Rank"], ":")[2]
					tableTemplate["Rank"] = {tonumber(num1); tonumber(num2)}
				end
				tableTemplate["ID"] = v["ID"]

				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
			if v["Type"] == "Player" then
				local tableTemplate = {
					["Type"] = "Player";
					["ID"] = 0;
					["Name"] = "";
					["AdminRank"] = "Creator"
				}
				tableTemplate["ID"] = v["ID"]
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
		end

		for i, v in ipairs(HeadAdminUsers) do
			if v["Type"] == "Group" then
				local tableTemplate = {
					["Type"] = "Group";
					["ID"] = 0;
					["Rank"] = 0;
					["Name"] = "";
					["AdminRank"] = "HeadAdmin"
				}
				tableTemplate["ID"] = v["ID"]
				if string.match(v["Rank"], "/^[0-9]+$/") then
					tableTemplate["Rank"] = tonumber(v["Rank"])
				else
					local num1, num2 = string.split(v["Rank"], ":")[1],string.split(v["Rank"], ":")[2]
					tableTemplate["Rank"] = {tonumber(num1); tonumber(num2)}
				end
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
			if v["Type"] == "Player" then
				local tableTemplate = {
					["Type"] = "Player";
					["ID"] = 0;
					["Name"] = "";
					["AdminRank"] = "HeadAdmin"
				}
				tableTemplate["ID"] = v["ID"]
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
		end

		for i, v in ipairs(Admins) do
			if v["Type"] == "Group" then
				local tableTemplate = {
					["Type"] = "Group";
					["ID"] = 0;
					["Rank"] = 0;
					["Name"] = "";
					["AdminRank"] = "Admin"
				}
				tableTemplate["ID"] = v["ID"]
				if string.match(v["Rank"], "/^[0-9]+$/") then
					tableTemplate["Rank"] = tonumber(v["Rank"])
				else
					local num1, num2 = string.split(v["Rank"], ":")[1],string.split(v["Rank"], ":")[2]
					tableTemplate["Rank"] = {tonumber(num1); tonumber(num2)}
				end
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
			if v["Type"] == "Player" then
				local tableTemplate = {
					["Type"] = "Player";
					["ID"] = 0;
					["Name"] = "";
					["AdminRank"] = "Admin"
				}
				tableTemplate["ID"] = v["ID"]
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
		end

		for i, v in ipairs(Moderators) do
			if v["Type"] == "Group" then
				local tableTemplate = {
					["Type"] = "Group";
					["ID"] = 0;
					["Rank"] = 0;
					["Name"] = "";
					["AdminRank"] = "Moderator"
				}
				tableTemplate["ID"] = v["ID"]
				if string.match(v["Rank"], "/^[0-9]+$/") then
					tableTemplate["Rank"] = tonumber(v["Rank"])
				else
					local num1, num2 = string.split(v["Rank"], ":")[1],string.split(v["Rank"], ":")[2]
					tableTemplate["Rank"] = {tonumber(num1); tonumber(num2)}
				end
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
			if v["Type"] == "Player" then
				local tableTemplate = {
					["Type"] = "Player";
					["ID"] = 0;
					["Name"] = "";
					["AdminRank"] = "Moderator"
				}
				tableTemplate["ID"] = v["ID"]
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
		end

		for i, v in ipairs(Trainers) do
			if v["Type"] == "Group" then
				local tableTemplate = {
					["Type"] = "Group";
					["ID"] = 0;
					["Rank"] = 0;
					["Name"] = "";
					["AdminRank"] = "Trainers"
				}
				if string.match(v["Rank"], "/^[0-9]+$/") then
					tableTemplate["Rank"] = tonumber(v["Rank"])
				else
					local num1, num2 = string.split(v["Rank"], ":")[1],string.split(v["Rank"], ":")[2]
					tableTemplate["Rank"] = {tonumber(num1); tonumber(num2)}
				end
				tableTemplate["ID"] = v["ID"]

				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
			if v["Type"] == "Player" then
				local tableTemplate = {
					["Type"] = "Player";
					["ID"] = 0;
					["Name"] = "";
					["AdminRank"] = "Trainers"
				}
				tableTemplate["ID"] = v["ID"]
				tableTemplate["Name"] = v["Name"]
				table.insert(globalAdmins, tableTemplate)
			end
		end

		return true
	end

		--> this sets up all the server packages and runs them
	local function loadPackages()
		for _, package in pairs(script.SystemPackages:GetChildren()) do
			if package:IsA("ModuleScript") and package.Name ~= "Commands" then
				local name = package.Name
				package = require(package)
				systemPackages[name] = package
			end
			if package.Name == "Commands" then
				local name = package.Name
				package = require(package)
				systemPackages[name] = package
				package.remotes = remotes
				package.Init()
			end
		end

		buildPermissionTables()
		buildDisableTables()
		buildAdminList()

			--> just adding info into the api module which will be needed in other modules
		systemPackages.API.PermissionTable = permissionTable
		systemPackages.API.DisableTable = disableTable
		systemPackages.API.Settings = Settings
		systemPackages.API.Remotes = remotes
		systemPackages.API.globalAdmins = globalAdmins


		for i,v in pairs(systemPackages) do
			for index, value in pairs(systemPackages) do
				if systemPackages[index] ~= v and typeof(v) ~= "function" and i ~= "Settings" then
					v.Remotes = remotes
					v[index] = value
				end
			end
		end

-- this is used for setting up the command modules some modules have scripts under them which we dont want to run
		local allowedFolderNames = {"Character", "Messaging", "Moderation", "logs", "other", "Banning"}
		for _,v in pairs(script.Packages:GetDescendants()) do
			if v:IsA("ModuleScript") and v.Parent.ClassName ~= "ModuleScript" and table.find(allowedFolderNames, v.Parent.Name)   then
				local ok, response = pcall(function()
					local mod = require(v)
					mod.Services = systemPackages.Services
					mod.API = systemPackages.API
					mod.Settings = systemPackages.Settings
					mod.Remotes = remotes
					mod.Shared = sharedCommons
					mod.PackageId = v.Name
					mod.globalAdmins = globalAdmins
					mod.SetWaypoint = systemPackages.Waypoints
					mod.fetchLogs = script.waypointBindable
					if mod and mod.Name and mod.Description and mod.Location then
						packages[mod.Name] = mod
					end

					if not mod.Init then
						mod.Execute(nil, "firstrun")
					else
						mod.Init()
					end
				end)

				if not ok then
					error("\n\nOh snap! sz_Tolus' Admin encountered a fatal error while trying to compile commands in the runtime...\n\nAffected files: game." .. v:GetFullName() .. ".lua\nError message: " .. response .. "\n\n")
				end
			end
		end

		
	-- start running all the client scripts so we can add global variables to them
		for _,v in pairs(script.Library.UI.Client.Scripts:GetDescendants()) do
			if v:IsA("ModuleScript") then
				local ok, response = pcall(function()
					local mod = require(v)
					mod.Services = systemPackages.Services
					mod.API = systemPackages.API
					mod.Settings = systemPackages.Settings
					mod.Remotes = remotes
					mod.Shared = sharedCommons
					mod.fetchLogs = script.waypointBindable
				end)

				if not ok then
					error("\n\nOh snap! sz_Tolus' Admin encountered a fatal error while trying to compile Ui Frames in the runtime...\n\nAffected files: game." .. v:GetFullName() .. ".lua\nError message: " .. response .. "\n\n")
				end
			end
		end
	end

	loadPackages()

		--> sets up bindale function used for commands running successfuly
	script.waypointBindable.OnInvoke = function()
		return systemPackages.Waypoints.fetch()
	end

		-- used for private messaging
	remotes.Function.OnServerInvoke = function(Client, Type, Protocol, Attachment)
		if Type == "notifyCallback" then
			-- bindable was not the best choice I could have used for this oh well 
			local Event = script.Bindables:FindFirstChild(Protocol)
			if Event and Attachment then
				Event:Fire(Attachment or false)
				Event:Destroy()
			else
				return false
			end
		end
	end


		--> pretty self explantory sorts out all the client stuff adding it to player gui and running some scripts
	local function setupUIForPlayer(Client: Player)
		local UI = script.Library.UI.Client:Clone()
		UI.ResetOnSpawn = false
		UI.Scripts.Core.Disabled = false
		UI.Parent = Client:FindFirstChildOfClass("PlayerGui")
		isPlayerAddedFired = true

		local clientPackages = UI:WaitForChild("Client")
		local mod = require(clientPackages)
		mod.API = systemPackages.API
		mod.Remotes = remotes

		local mod2 = require(clientPackages["Logs"].handler)
		mod2.Remotes = remotes
		require(clientPackages).buildClientTable(Client)
	end

		-- this sends a message to player letting them know what to do once adming is fully setup for them
	local function lastCalledFunction(player: Player)
		local Api = systemPackages.API
		local getPlayerAdminRank = Api.getAdminLevel(player.UserId, player.Name)
		if getPlayerAdminRank ~= "None" then Api.Players.notify(player, "System", string.format("Welcome to HBA! \n say %q to view the list if commands",":cmds")) end
	end

	Players.PlayerAdded:Connect(function(Client)
		setupUIForPlayer(Client)
		lastCalledFunction(Client)
		remotes.BindableEvent:Fire(Client, script)
	end)

	-- just checking if is playeradded will work or not
	if not isPlayerAddedFired then
		for i,v in pairs(Players:GetPlayers()) do
			setupUIForPlayer(v)
			lastCalledFunction(v)
			remotes.BindableEvent:Fire(v, script)
		end
	end

	warn("sz_Tolu's Admin Loaded!")
end
