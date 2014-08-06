if SERVER then
	BUYABLES = {
		{
			type = "prop",
			model = "models/props_borealis/bluebarrel001.mdl",
			price = 200
		},
	}

	util.AddNetworkString("getbuyables")
	util.AddNetworkString("buy")
	net.Receive("getbuyables", function(len, ply)
		net.Start("getbuyables")
			net.WriteTable(BUYABLES)
		net.Send(ply)
	end)
	net.Receive("buy", function(len, ply)
		
	end)

end


if CLIENT then

	net.Receive("getbuyables", function()
		BUYABLES = net.ReadTable() or {}
		if grid then
			grid = vgui.Create("DGrid", scroller)
			grid:SetCols(10)
			grid:SetColWide(64)
			grid:SetRowHeight(64)
		end
	end)
	BUYABLES = BUYABLES or {}
	local spawnmenu = vgui.Create("DFrame")
	spawnmenu:SetPos(ScrW() / 2 + 32, ScrH() / 2 - ScrH() / 3 - 32)
	spawnmenu:SetSize(math.floor(ScrW() / 3 / 64) * 64 + 25, math.floor(ScrH() / 3 / 64) * 64 - 30)
	spawnmenu:SetTitle("Spawnmenu")
	spawnmenu:ShowCloseButton(false)
	spawnmenu:SetVisible(false)
	local scroller = vgui.Create("DScrollPanel", spawnmenu)
	scroller:SetSize(math.floor(ScrW() / 3 / 64) * 64 + 15, math.floor(ScrH() / 3 / 64) * 64 - 64)
	scroller:SetPos(5, 29)
	local grid = vgui.Create("DGrid", scroller)
	grid:SetCols(10)
	grid:SetColWide(64)
	grid:SetRowHeight(64)
	--grid:SetPos(5, 29)
	net.Start("getbuyables")
	net.SendToServer()
	local function open()
		gui.EnableScreenClicker(true)
		spawnmenu:SetVisible(true)
		net.Start("getbuyables")
		net.SendToServer()
		grid = vgui.Create("DGrid", scroller)
		grid:SetCols(10)
		grid:SetColWide(64)
		grid:SetRowHeight(64)
		for i = 1, #BUYABLES do
			local but = vgui.Create( "SpawnIcon" )
			but:SetSize(64, 64)
			but:SetModel(BUYABLES[i].model)
			but.DoClick = function()
				net.Start("buy")
					net.WriteUInt(i, 16)
				net.SendToServer()
			end
			grid:AddItem( but )
		end
	end
	hook.Add("OnSpawnMenuOpen", "open", open)
	local function close()
		gui.EnableScreenClicker(false)
		if IsValid(spawnmenu) then
			spawnmenu:SetVisible(false)
		end 
	end
	hook.Add("OnSpawnMenuClose", "close", close)
end