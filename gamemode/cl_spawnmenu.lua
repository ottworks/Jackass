BUYABLES = BUYABLES or {}
ACCESSORIES = ACCESSORIES or {}
local spawnmenu = vgui.Create("DPropertySheet")
spawnmenu:SetPos(ScrW() / 2 + 32, ScrH() / 2 - ScrH() / 3 - 32)
spawnmenu:SetSize(math.floor(ScrW() / 3 / 64) * 64 + 25, math.floor(ScrH() / 3 / 64) * 64 - 30)
spawnmenu:SetVisible(false)
--Props
	local scroller = vgui.Create("DScrollPanel")
	scroller:SetSize(math.floor(ScrW() / 3 / 64) * 64 + 15, math.floor(ScrH() / 3 / 64) * 64 - 64)
	scroller:SetPos(5, 29)
	local grid = vgui.Create("DGrid", scroller)
	grid:SetCols(math.floor(ScrW() / 3 / 64))
	grid:SetColWide(64)
	grid:SetRowHeight(64)
	local function open()
		gui.EnableScreenClicker(true)
		spawnmenu:SetVisible(true)
		if grid then
			grid:Remove()
		end
		grid = vgui.Create("DGrid", scroller)
		grid:SetCols(math.floor(ScrW() / 3 / 64))
		grid:SetColWide(64)
		grid:SetRowHeight(64)
		for i = 1, #BUYABLES do
			local mdl = BUYABLES[i].model
			local rev = string.reverse(string.sub(mdl, 1, -5))
			local s = string.find(rev, "/")
			local nick = string.reverse(string.sub(rev, 1, s - 1))
			local but = vgui.Create( "SpawnIcon" )
			but:SetSize(64, 64)
			but:SetModel(mdl)
			but:SetToolTip("$" .. BUYABLES[i].price .. ": " .. nick)
			but.DoClick = function()
				net.Start("buy")
					net.WriteUInt(i, 16)
					net.WriteUInt(0, 4)
				net.SendToServer()
			end
			grid:AddItem( but )
		end
	end
	spawnmenu:AddSheet("Props", scroller)
--Accessories
	local scroller2 = vgui.Create("DScrollPanel")
	scroller2:SetSize(math.floor(ScrW() / 3 / 64) * 64 + 15, math.floor(ScrH() / 3 / 64) * 64 - 64)
	scroller2:SetPos(5, 29)
	local grid2 = vgui.Create("DGrid", scroller2)
	grid2:SetCols(math.floor(ScrW() / 3 / 64))
	grid2:SetColWide(64)
	grid2:SetRowHeight(64)
	local function open2()
		if grid2 then
			grid2:Remove()
		end
		grid2 = vgui.Create("DGrid", scroller2)
		grid2:SetCols(math.floor(ScrW() / 3 / 64))
		grid2:SetColWide(64)
		grid2:SetRowHeight(64)
		for i = 1, #ACCESSORIES do
			local nick
			if not ACCESSORIES[i].nick then
				local mdl = ACCESSORIES[i].model
				local rev = string.reverse(string.sub(mdl, 1, -5))
				local s = string.find(rev, "/")
				nick = string.reverse(string.sub(rev, 1, s - 1))
			else nick = ACCESSORIES[i].nick end
			local but = vgui.Create( "SpawnIcon" )
			but:SetSize(64, 64)
			but:SetModel(mdl)
			but:SetToolTip("$" .. ACCESSORIES[i].price .. ": " .. nick)
			but.DoClick = function()
				net.Start("buy")
					net.WriteUInt(i, 16)
					net.WriteUInt(1, 4)
				net.SendToServer()
			end
			grid2:AddItem( but )
		end
	end
	spawnmenu:AddSheet("Accessories", scroller2)

hook.Add("OnSpawnMenuOpen", "open", function()
	open()
	open2()
end)
local function close()
	gui.EnableScreenClicker(false)
	if IsValid(spawnmenu) then
		spawnmenu:SetVisible(false)
	end 
end
hook.Add("OnSpawnMenuClose", "close", close)
