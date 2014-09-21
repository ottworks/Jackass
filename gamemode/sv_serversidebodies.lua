-- Made by Slight
-- Fixed for Garry's Mod 13 by Blazeard/QuentinDylanP
-- Modified by Ott for use in his gamemode
local meta = FindMetaTable("Player")
if (!meta) then return end

local CreateRagdoll		= meta.CreateRagdoll
local GetRagdollEntity	= meta.GetRagdollEntity
local lasthit

// In this file we're adding functions to the player meta table.
// This means you'll be able to call functions here straight from the player object
// You can even override already existing functions.

local mp_keepragdolls = GetConVar("mp_keepragdolls")

local function PlayerDeath(ply, attacker, dmginfo)

	if (ply.m_hRagdollEntity && ply.m_hRagdollEntity:IsValid()) then

		ply:SpectateEntity(ply.m_hRagdollEntity)
		ply:Spectate(OBS_MODE_CHASE)

	end

end

hook.Add("PlayerDeath", "PlayerDeath", PlayerDeath)

local function RemoveRagdollEntity(ply)

	if (ply.m_hRagdollEntity && ply.m_hRagdollEntity:IsValid()) then

		ply.m_hRagdollEntity:Remove()
		ply.m_hRagdollEntity = nil
		timer.Destroy("muldecay" .. ply:EntIndex())
	end

end

hook.Add("PlayerSpawn", "RemoveRagdollEntity", RemoveRagdollEntity)
hook.Add("PlayerDisconnected", "RemoveRagdollEntity", RemoveRagdollEntity)


local function physics(ent, data, obj)
	if data.HitEntity == ent then return end
	local ply = ent:GetNWEntity("Player")
	local impact = ((data.OurOldVelocity - data.TheirOldVelocity) * data.HitNormal):Distance(Vector())
	if data.HitEntity ~= Entity(0) then
		local prophealth = data.HitEntity:GetMaxHealth()
		local id = data.HitEntity:EntIndex()
		timer.Simple(0, function()
			if not IsValid(data.HitEntity) then
				--Prop break
				if lasthit ~= id then
					ent:AddMultiplier(2, "Prop Broken")
					lasthit = id
					timer.Simple(0, function()
						lasthit = 0
					end)
				end
			end 
		end)
	end
	if impact > 100 then
		if string.sub(data.HitEntity:GetClass(), 1, 14) == "func_breakable" then
			--WINDOW BREAK
			ent:AddMultiplier(3, "Window Broken")
		end
	end
	if impact > 300 then
		impact = impact - 300
		local trace = {}
		trace.start = data.HitPos
		trace.endpos = data.HitPos + data.HitNormal * -5
		trace.ignoreworld = true
		local tr = util.TraceLine(trace)
		local bone = tr.PhysicsBone
		if bone == 10 and ent:GetNWEntity("Player"):GetNWString("Hat") == "Stunt Helmet" then
			impact = impact / 4
		end
		if ent.BoneDamage[bone] == ent.BreakPoint then return end
		ent.BoneDamage[bone] = math.min(ent.BoneDamage[bone] + impact, ent.BreakPoint)
		ent:SetNWInt("BoneDamage" .. bone, ent.BoneDamage[bone])

		impact = math.floor(impact * ent:GetNWInt("mul") or 1)
		local profit = math.floor(math.min(ent:GetNWInt("profits") + impact, 20000 + ent.random * 5000))
		if impact > ent.BreakPoint / 4 then
			if ent.CanSpeak then
				ent:EmitSound(randomsound(SOUNDS.male, bone), 100, 100 + math.random(-10, 10))
				ent.CanSpeak = false
				timer.Simple(5, function()
					ent.CanSpeak = true
				end)
			end
			ent:SetNWInt("profits", profit)
		end
	end
end

function meta:CreateRagdoll()
	local Ent = self:GetRagdollEntity()
	if (Ent && Ent:IsValid()) then Ent:Remove() end

	RemoveRagdollEntity(self)

	local Data = duplicator.CopyEntTable(self)

	Ent = ents.Create("prop_ragdoll")
		duplicator.DoGeneric(Ent, Data)
	Ent:Spawn()

	Ent.CanConstrain	= false
	Ent.CanTool			= false
	Ent.GravGunPunt		= false
	Ent.PhysgunDisabled	= false
	Ent.CanSpeak 		= true
	Ent.BoneDamage = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,}
	Ent.BoneDamage[0] = 0
	Ent.BreakPoint = 1000
	Ent.random = math.random()
	Ent.muls = {}
	Ent:SetNWInt("mul", 1)
	Ent:SetNWFloat("random", Ent.random)
	Ent:SetNWInt("BreakPoint", Ent.BreakPoint)
	Ent:SetNWEntity("Player", self)

	Ent:AddCallback("PhysicsCollide", physics)

	local Vel = self:GetVelocity()

	local iNumPhysObjects = Ent:GetPhysicsObjectCount()
	for Bone = 0, iNumPhysObjects-1 do

		local PhysObj = Ent:GetPhysicsObjectNum(Bone)
		if (PhysObj:IsValid()) then

			local Pos, Ang = self:GetBonePosition(Ent:TranslatePhysBoneToBone( Bone ))
			PhysObj:SetPos(Pos)
			PhysObj:AddVelocity(Vel)

		end

	end
	Ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local bones = Ent:GetPhysicsObjectCount()
    for i=1,bones-1 do -- There should be less than 128 bones for any ragdoll  
        -- This is the physics object of one of the ragdoll's bones  
        local bone = Ent:GetPhysicsObjectNum(i)  
        if IsValid(bone) then  
            -- This gets the position and angles of the entity bone corresponding to the above physics bone  
            local bonepos, boneang = self:GetBonePosition(Ent:TranslatePhysBoneToBone( i ))  
            -- All we need to do is set the bones position and angle  
            bone:SetPos(bonepos)  
            bone:SetAngles(boneang)            
        end  
    end  
	self:SetNetworkedEntity("m_hRagdollEntity", Ent)
	self.m_hRagdollEntity = Ent

	timer.Create("muldecay" .. self:EntIndex(), 2, 0, function()
		if Ent:GetNWInt("mul") > 1 then
			Ent:SetNWInt("mul", Ent:GetNWInt("mul") - 1)
		end
	end)
end

function meta:GetRagdollEntity()
	return self:GetNetworkedEntity("m_hRagdollEntity")
end
