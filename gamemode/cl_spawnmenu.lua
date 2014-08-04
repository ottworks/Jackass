local spawnmenu = vgui.Create("DFrame")
spawnmenu:SetPos(ScrW() / 2 + 32, ScrH() / 2 - ScrH() / 3 - 32)
spawnmenu:SetSize(ScrW() / 3, ScrH() / 3)
spawnmenu:SetTitle("Spawnmenu")
spawnmenu:ShowCloseButton(true)
spawnmenu:SetVisible(false)

local function open()
	gui.EnableScreenClicker(true)
	spawnmenu:SetVisible(true)
end
hook.Add("OnSpawnMenuOpen", "open", open)
local function close()
	gui.EnableScreenClicker(false)
	if IsValid(spawnmenu) then
		spawnmenu:SetVisible(false)
	end 
end
hook.Add("OnSpawnMenuClose", "close", close)