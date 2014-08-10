-- Made by Slight
-- Fixed for Garry's Mod 13 by Blazeard/QuentinDylanP
-- Modified by Ott for use in his gamemode
local meta = FindMetaTable("Player")
if (!meta) then return end

local CreateRagdoll		= meta.CreateRagdoll
local GetRagdollEntity	= meta.GetRagdollEntity

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

	end

end

hook.Add("PlayerSpawn", "RemoveRagdollEntity", RemoveRagdollEntity)
hook.Add("PlayerDisconnected", "RemoveRagdollEntity", RemoveRagdollEntity)

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
	Ent.BoneDamage = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,}
	Ent.BoneDamage[0] = 0
	Ent.BreakPoint = 1000
	Ent:SetNWInt("BreakPoint", Ent.BreakPoint)

	function physics(ent, data, obj)
		if data.HitEntity == ent then return end
		local impact = (data.OurOldVelocity * data.HitNormal):Distance(Vector())
		impact = math.floor(impact)
		if impact > 100 then
			if string.sub(data.HitEntity:GetClass(), 1, 14) == "func_breakable" then
				--WINDOW BREAK
				
			end
		end
		if impact > 300 then
			local trace = {}
			trace.start = data.HitPos
			trace.endpos = data.HitPos + data.HitNormal * -5
			trace.ignoreworld = true
			local tr = util.TraceLine(trace)
			local bone = tr.PhysicsBone

			ent.BoneDamage[bone] = math.min(ent.BoneDamage[bone] + impact - 300, ent.BreakPoint)
			ent:SetNWInt("BoneDamage" .. bone, ent.BoneDamage[bone])
			ent:SetNWInt("profits", ent:GetNWInt("profits") + impact - 300)
		end
	end
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
end

function meta:GetRagdollEntity()
	return self:GetNetworkedEntity("m_hRagdollEntity")
end
