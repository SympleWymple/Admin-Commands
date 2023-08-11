-- defo not the best way to code this
local getAdminScripts = script.Parent.Parent.Packages
local allowedFolderNames = {"Character", "Messaging", "Moderation", "logs", "other", "Banning"}
local ValidMeAlias = {"bring", "to", "fly", "unfly", "rhats", "rtools", "re", "pm", "kill", "view", "unview", "kick", "age", "ref"}
local module = {}

local function checkValidCommand(command: string, commandTable : {table}): boolean
	for _, v in pairs(commandTable) do
		local alllowerCase = tostring(string.lower(v))
		if alllowerCase == string.lower(command) then
			return true
		else
			continue
		end
	end
	return false
end

local function runCommand(name, client, command, Type, Name, Value)
	for _, v in pairs(getAdminScripts:GetDescendants()) do
		if v:IsA("ModuleScript") and v.Parent:IsA("Folder") and table.find(allowedFolderNames, v.Parent.Name) then
			local commandLower = string.lower(name)
			if tostring(string.lower(v.Name)) == tostring(commandLower) then
				module = require(v)
				if module.Execute(client, Type, Name, Value) == true then
					module.SetWaypoint.new(client, commandLower, Value)
				end
			end
		end
	end
end             


function changeTableIntoString(seperator: {[string]: string}, list: {}, collection: number, listlength: number):  string
	return table.concat(list, seperator, collection, listlength)
end

module.Init = function()
	module.remotes.BindableEvent.Event:Connect(function(client, location)
		if location ~= script.Parent.Parent then return end

		local ClientPackage = require(client:FindFirstChildOfClass("PlayerGui").Client.Client)	
		local ClientAllowedCommands = ClientPackage.AllowedCommands
		local  CleintAdminRank = ClientPackage.Adminrank

		local Settings = module.Settings["Settings"]
		local Prefix = Settings["Prefix"]

		client.Chatted:Connect(function(message)
			if CleintAdminRank == "None" then return end
			local messagePrefix = string.sub(message, 1, 1)
			if message == nil then return end
			local MessageCommand = string.split(message, messagePrefix)[2]
			local commandlist = string.split(MessageCommand, Settings["SplitKey"])

			local command = commandlist[1]
			local argument = nil
			local value = nil

			if messagePrefix == Prefix then
				-- if message has to 2 splits that means its a command|playerName/Aliases
				if #commandlist == 2 then 
					argument = commandlist[2]
					-- if message has to 3 or more splits that means its a command|playerName/Aliases|message
				elseif #commandlist >= 3 then 
					argument = commandlist[2] 
					value = changeTableIntoString(" ", commandlist, 3, #commandlist)
					-- if value is only one we assume they want to do a command on themselves
				else
					if table.find(ValidMeAlias, string.lower(command)) then
						argument = "Me"
					end
				end
				if checkValidCommand(command, ClientAllowedCommands) and checkValidCommand(command, module.Settings["Settings"].AllCommands)  then
					runCommand(command, client, command, "command", argument, value)
				else
					return false
				end
			end
		end)	
	end)
end

return module
