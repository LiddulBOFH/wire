local libs = {
	"datastream",
	"language",
	"http"
}

if VERSION < 150 then
	if not datastream then require("datastream") end
	function datastream.__prepareStream(streamID) end

	-- gmod 12 => use installed lib
	for _,libName in pairs(libs) do
		local lib12Name = libName.."12"

		local lib = _G[libName]
		_G[lib12Name] = lib
	end

	return
end
-- gmod 13 => use compatibility lib
for _,libName in pairs(libs) do
	local lib12Name = libName.."12"

	local lib = _G[libName]
	-- make copies of everything and override some of them
	_G[lib12Name] = lib and table.Copy(lib) or {}
end

function http12.Get(url, headers, callback)
	http.Fetch(url, callback, function() print("Err - http.Fetch") end)
end
if CLIENT then
	if VERSION >= 151 then
		_R.Panel.AddHeader = function() end
	end
end
if SERVER then
	resource.AddFile("materials/gui/silkicons/emoticon_smile.vtf")
	resource.AddFile("materials/gui/silkicons/newspaper.vtf")
	resource.AddFile("materials/gui/silkicons/wrench.vtf")
	resource.AddFile("materials/vgui/spawnmenu/save.vtf")
	
	function datastream12.__prepareStream(streamID)
		util.AddNetworkString("ds12_"..streamID)
	end

	function datastream12.Hook(streamID, callback)
		net.Receive("ds12_" .. streamID, function(len, ply)
			local tbl = net.ReadTable()
			callback(ply, streamID, "", glon.encode(tbl), tbl)
		end)
	end
	function datastream12.StreamToClients(player, streamID, data)
		net.Start("ds12_"..streamID)
			net.WriteTable(data)
		net.Send(player)
	end
else
	function datastream12.StreamToServer(streamID, data)
		net.Start("ds12_" .. streamID)
			net.WriteTable(data)
		net.SendToServer()
	end
	function datastream12.Hook(streamID, callback)
		net.Receive("ds12_"..streamID, function(len) callback( streamID, id, nil, net.ReadTable() ) end )
	end
	cam.StartMaterialOverride = render.MaterialOverride
	SetMaterialOverride = render.MaterialOverride
	local fontTable = 
	{
		font = "defaultbold",
		size = 12,
		weight = 700,
		antialias = true,
		additive = false,
	}
	surface.CreateFont("DefaultBold", fontTable)
end