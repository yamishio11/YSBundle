local button = {}
button.Name = "Unpack"
button.Description = "Unpacks the selected instances"
button.RequiresSelection = false
local RoSe = require(script.Parent.Parent.Modules.RoSe)
local Helpers = require(script.Parent.Parent.Modules.Helpers)
function button:onClick()
	local decodedBundle
	local succ, err = pcall(function()
		decodedBundle = game:GetService("StudioService"):PromptImportFile({ "lua", "txt" }):GetBinaryContents()
	end)
	if not succ then
		warn("Failed to decode bundle: " .. err)
		return
	end
	if not decodedBundle then
		warn("Failed to decode bundle")
		return
	end

	local bundle = Helpers:unpack(decodedBundle)
	print(bundle)
	local mod = Instance.new("Folder")
	mod.Name = "YSBundle-" .. game:GetService("HttpService"):GenerateGUID(false):sub(0, 8)
	mod.Parent = game.ServerStorage
	local assetsFolder = Instance.new("Folder")
	assetsFolder.Name = "Assets"
	assetsFolder.Parent = mod
	local modulesFolder = Instance.new("Folder")
	modulesFolder.Name = "Modules"
	modulesFolder.Parent = mod
	local client = Instance.new("LocalScript")
	client.Name = "init.client"
	client.Source = bundle.client
	client.Parent = mod
	local server = Instance.new("Script")
	server.Name = "init.server"
	server.Source = bundle.server
	server.Parent = mod
	local assets = bundle.assets
	for _, asset in ipairs(assets:GetChildren()) do
		asset.Parent = assetsFolder
	end
	local modules = bundle.modules
	for name, module in pairs(modules) do
		local newModule = Instance.new("ModuleScript")
		newModule.Name = name
		newModule.Source = module
		newModule.Parent = modulesFolder
	end

	mod.Parent = workspace
end
return button
