local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

return function(Settings)
	script.SystemPackages.Settings:Destroy()
	Settings.Name = "Settings"
	Settings.Parent = script.SystemPackages

	warn("sz_Tolu's Admin; Preparing...")

	local remotefolder = Instance.new("Folder")

	local isPlayerAddedFired = false
	local remotes = {
		Function = Instance.new("RemoteFunction"),
		Event = Instance.new("RemoteEvent"),
		BindableEvent = Instance.new("BindableEvent")
	}

	local packages,systemPackages, permissionTable, disableTable, cachedData, sharedCommons, globalAdmins = {}, {}, {}, {}, {}, {}, {}

	remotefolder.Name = "sz_Tolu Remotes"
	remotes.Function.Parent, remotes.Event.Parent, remotes.BindableEvent.Parent = remotefolder, remotefolder, remotefolder
	remotes.BindableEvent.Name = "BindableEvent"
	remotefolder.Parent = ReplicatedStorage
	remotefolder = nil

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

	script.waypointBindable.OnInvoke = function()
		return systemPackages.Waypoints.fetch()
	end

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
