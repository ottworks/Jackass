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

				print("Player " .. ply:GetName() .. " spawned prop " .. BUYABLES[i].model)

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

				timer.Create("DecayBase" .. prop:EntIndex(), 60 * 5, 1, function()
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
			elseif ACCESSORIES[i].type == "weapon" then
				ply:SetNWInt("money", ply:GetNWInt("money") - ACCESSORIES[i].price)
				ply:Give("ropegun")
			end
		end
	end
end)