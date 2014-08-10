if SERVER then
	util.AddNetworkString("getbuyables")
	util.AddNetworkString("buy")
	util.AddNetworkString("getaccessories")
	util.AddNetworkString("buy2")
	net.Receive("getbuyables", function(len, ply)
		net.Start("getbuyables")
			net.WriteTable(BUYABLES)
		net.Send(ply)
	end)
	net.Receive("getaccessories", function(len, ply)
		net.Start("getaccessories")
			net.WriteTable(ACCESSORIES)
		net.Send(ply)
	end)
	net.Receive("buy", function(len, ply)
		local i = net.ReadUInt(16)
		local t = net.ReadUInt(4)
		if tonumber(ply:GetNWInt("money")) > BUYABLES[i].price then
			if t == 0 then
				ply:SetNWInt("money", ply:GetNWInt("money") - BUYABLES[i].price)
				if BUYABLES[i].type == "prop_physics" then
					local prop = ents.Create(BUYABLES[i].type)
					local tr = ply:GetEyeTrace()
					prop:SetPos(tr.HitPos)
					prop:SetModel(BUYABLES[i].model)
					prop:Spawn()
					prop:Activate()

					local offset = BUYABLES[i].offset or Angle()
					prop:SetAngles(Angle(offset.p, ply:EyeAngles().y + offset.y + 180, offset.r))
					-- Taken from Sandbox
					-- Attempt to move the object so it sits flush
					-- We could do a TraceEntity instead of doing all 
					-- of this - but it feels off after the old way

					local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	-- Find a point that is definitely out of the object in the direction of the floor
						vFlushPoint = prop:NearestPoint( vFlushPoint )			-- Find the nearest point inside the object to that point
						vFlushPoint = prop:GetPos() - vFlushPoint				-- Get the difference
						vFlushPoint = tr.HitPos + vFlushPoint					-- Add it to our target pos
					prop:SetPos(vFlushPoint)
					
					

					if IsValid(prop:GetPhysicsObject()) and BUYABLES[i].material then
						prop:GetPhysicsObject():SetMaterial(BUYABLES[i].material)
					end

					timer.Simple(60 * 5, function()
						if IsValid(prop) then
							local i = 1
							timer.Create("Decay" .. prop:EntIndex(), 1, 5, function()
								if IsValid(prop) then
									prop:SetRenderMode(RENDERGROUP_TRANSLUCENT)
									prop:SetColor(Color(255, 255, 255, 255 - i * 50))
									i = i + 1
									if i == 4 then
										prop:Remove()
									end
								end
							end)
						end
					end)
				end
			elseif t == 1 then
				if ACCESSORIES[i].type == "hat" then
					if ply:GetNWString("Hat") ~= ACCESSORIES[i].nick then
						ply:SetNWInt("money", ply:GetNWInt("money") - ACCESSORIES[i].price)
						ply:SetNWString("Hat", ACCESSORIES[i].nick)
					end
				end
			end
		end
	end)
end


if CLIENT then
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
					local nick = string.reverse(string.sub(rev, 1, s - 1))
				else nick = ACCESSORIES[i].nick end
				local but = vgui.Create( "SpawnIcon" )
				but:SetSize(64, 64)
				but:SetModel(mdl)
				but:SetToolTip("$" .. ACCESSORIES[i].price .. ": " .. nick)
				but.DoClick = function()
					net.Start("buy")
						net.WriteUInt(i, 16)
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
end