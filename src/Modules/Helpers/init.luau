local helpers = {}
local RoSe = require(script.Parent.RoSe)
function helpers:getSelectedInstances()
    local selection = game.Selection:Get()
    if #selection == 0 then
        warn("No instances selected")
        return
    end
    return selection
end


local HttpService = game:GetService("HttpService");

local buffer_tostring = buffer.tostring;
local buffer_fromstring = buffer.fromstring;

function helpers:compress(text : string) : string
    print("Compressing text of length " .. #text);
    local mode = "split";
    if #text < 1000000 then
        mode = "single";
    else
        mode = "split";
    end
    if mode == "split" then
        local chunks = {};
        local chunk_size = 1000000;
        for i = 1, #text, chunk_size do
            table.insert(chunks, HttpService:JSONEncode(buffer_fromstring(text:sub(i, i + chunk_size - 1))));
        end
        return table.concat(chunks, "__VVS__");
    else
        return HttpService:JSONEncode(buffer_fromstring(text));
    end
end

function helpers:decompress(text : string) : string
    local mode = "split";
    if text:find("__VVS__") == nil then
        mode = "single";
    else
        mode = "split";
    end
    if mode == "split" then
        local chunks = text:split("__VVS__");
        local decoded_chunks = {};
        for i, chunk in ipairs(chunks) do
            decoded_chunks[i] = buffer_tostring(HttpService:JSONDecode(chunk));
        end
        return table.concat(decoded_chunks);
    else
        return buffer_tostring(HttpService:JSONDecode(text));
    end
end

function helpers:bundle(data : {client : string, server : string, modules : {string}, assets : {string}}) : string
    local bundle = {
        client = data.client,
        server = data.server,
        modules = data.modules,
        assets = data.assets,
    }
    local blacklisted = {
        "Camera",
        "Humanoid",
        "HumanoidDescription",
        "ModuleScript",
        "Script",
        "LocalScript",
    }
    local masterFolder = Instance.new("Folder");
    masterFolder.Name = "Assets"
    for i, asset in ipairs(bundle.assets) do
        for _, blacklisted in ipairs(blacklisted) do
            if asset:IsA(blacklisted) then
                table.remove(bundle.assets, i);
                break
            end
        end
        local newAsset = asset:Clone();
        newAsset.Parent = masterFolder;
    end
    masterFolder = RoSe.serialize(masterFolder);

    return helpers:compress(HttpService:JSONEncode({
        client = bundle.client,
        server = bundle.server,
        modules = bundle.modules,
        assets = masterFolder,
    }));
end

function helpers:unpack(data : string) : {client : string, server : string, modules : {string}, assets : {string}}
    local bundle = HttpService:JSONDecode(helpers:decompress(data));
    local client = helpers:decompress(bundle.client);
    local server = helpers:decompress(bundle.server);
    local modules = {};
    for i, module in pairs(bundle.modules) do
        modules[i] = helpers:decompress(module);
    end
    local assets = RoSe.deserialize(bundle.assets);
    return {
        client = client,
        server = server,
        modules = modules,
        assets = assets,
    }
end

return helpers