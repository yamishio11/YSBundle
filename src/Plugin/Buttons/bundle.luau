local button = {}
button.Name = "Pack"
button.Description = "Bundles the selected instances"
local RoSe = require(script.Parent.Parent.Modules.RoSe)
local Helpers = require(script.Parent.Parent.Modules.Helpers)
local ScriptEditorService = game:GetService('ScriptEditorService')

function button:onClick(selection)
    if #selection == 1 then
        if selection[1]:IsA("Folder") then
            selection = selection[1]
            local folders = {
                "Assets",
                "Modules"
            }
            for _, folder in ipairs(folders) do
                if not selection:FindFirstChild(folder) then
                    warn("Missing " .. folder .. " folder")
                    return
                end
            end
            local mainClient = selection:FindFirstChild("init.client")
            if not mainClient then
                warn("Missing init.client file")
                return
            end
            local mainServer = selection:FindFirstChild("init.server")
            if not mainServer then
                warn("Missing init.server file")
                return
            end
            local assets = selection.Assets:GetChildren()
            local modules = selection.Modules:GetChildren()
            local client = Helpers:compress(mainClient.Source)
            local server = Helpers:compress(mainServer.Source)

            local cmodules = {}
            for _, module in ipairs(modules) do
                if module:IsA("ModuleScript") then
                    cmodules[module.Name] = Helpers:compress(module.Source)
                end
            end

            local cassets = {}
            for _, asset in ipairs(assets) do
                table.insert(cassets, asset)
            end

            local bundle = Helpers:bundle({
                client = client,
                server = server,
                modules = cmodules,
                assets = cassets,
            })
            print(bundle)
            local succ,err = pcall(function()
                local ns = Instance.new("Script")
                local fileName = string.format("YSBundle-%s", game:GetService("HttpService"):GenerateGUID(false):sub(0, 8))
                ns.Name = fileName
                -- ns.Source = bundle
                ScriptEditorService:UpdateSourceAsync(ns, function()
                    return bundle
                end)
                ns.Parent = workspace
                local Selection = game:GetService("Selection")
                Selection:Set({ns})
                _G["ysp"]:PromptSaveSelection(fileName)
                game:GetService("Debris"):AddItem(ns, 0)
            end)
            if not succ then
                warn("Failed to export to file because " .. err)
                warn("This is probably because filesize issue, just ignore it")
            end
        else
            warn("First instance must be a folder")
            return
        end
    else
        warn("too many instances selected")
        return
    end
end
return button
