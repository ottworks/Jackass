AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_serversidebodies.lua")
AddCSLuaFile("sh_bones.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("includes/modules/easings.lua")
AddCSLuaFile("sh_spawnmenu.lua")
AddCSLuaFile("sh_buyables.lua")

include("shared.lua")
include("sv_serversidebodies.lua")
include("sv_puppetmaster.lua")
include("sv_sql_database.lua")

resource.AddFile("sound/jackass/chaching.wav")
resource.AddFile("resource/321impact.ttf")
resource.AddFile("models/stairsupport_tall.mdl")
resource.AddFile("models/hanging_stair_128.mdl")
resource.AddFile("models/stunt_helmet.mdl")
resource.AddFile("models/freeman/camera.mdl")

local failed = false

function ExitRagdoll(ply, cmd)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	ply:GetRagdollEntity():SetRenderBones(false)
	timer.Simple(0.1, function()
		if IsValid(ply:GetRagdollEntity()) then
			local ragpos = ply:GetRagdollEntity():GetPos()
			local trace = {}
			local tr = {}
				tr.filter = {ply:GetRagdollEntity(), ply}
				tr.start = ragpos
				tr.endpos = ragpos
				tr.mins = Vector(-16, -16, 0)
				tr.maxs = Vector(16, 16, 72)
				tr.output = trace
				tr.mask = MASK_PLAYERSOLID
			for i = 1, 25 do
				util.TraceHull(tr)
				if trace.Hit then
					local rand = Vector(math.random(-48, 48), math.random(-48, 48), math.random(-48, 48))
					tr.start = ragpos + rand
					tr.endpos = ragpos + rand
				else
					break
				end
			end
			if trace.Hit then
				ply:Kill()
			end
			ply:SetPos(trace.HitPos)
			ply:SetVelocity(-ply:GetVelocity() + ply:GetRagdollEntity():GetVelocity())
			ply:GetRagdollEntity():Remove()
			ply:SetNoDraw(false)
		end
	end)
end
function EnterRagdoll(ply, cmd)
	net.Start("stunt_begin")
	net.Send(ply)
	ply:CreateRagdoll()
	--ply:SetPos(ply:GetPos() + Vector(0, 0, 10))
	timer.Simple(0, function()
		ply:SetMoveType(MOVETYPE_NONE)
		ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		ply:SetNoDraw(true)
	end)
	timer.Create("ragcreate", 0.05, 0, function()
		if IsValid(ply:GetRagdollEntity()) then
			ply:GetRagdollEntity():SetRenderBones(true)
			ply:GetRagdollEntity():SetNWInt("physcount", ply:GetRagdollEntity():GetPhysicsObjectCount())
			timer.Destroy("ragcreate")
		end
	end)
end
util.AddNetworkString("stunt_success")
util.AddNetworkString("stunt_failure")
util.AddNetworkString("stunt_begin")

function GM:PlayerLoadout(ply)
	ply:SetModel("models/player/Group02/male_02.mdl")
	--ply:GodEnable()
end
function GM:Move(ply, cmd)
	if cmd:KeyReleased(IN_JUMP) then
		if IsValid(ply:GetRagdollEntity()) then
			local profit = ply:GetRagdollEntity():GetNWInt("profits")
			ExitRagdoll(ply, cmd)
			net.Start("stunt_success")
			net.Send(ply)
			timer.Simple(0.4, function() ply:SetNWInt("money", ply:GetNWInt("money") + profit) end)
		elseif not ply:IsOnGround() then
			EnterRagdoll(ply, cmd)
		end
	end

	--[[if cmd:KeyPressed(IN_USE) then
		ply:SetMoveType(MOVETYPE_NOCLIP)
	end--]]

	if IsValid(ply:GetRagdollEntity()) then
		if ply:GetRagdollEntity().BoneDamage[10] >= ply:GetRagdollEntity():GetNWInt("BreakPoint") then
			ExitRagdoll(ply, cmd)
			if not failed then
				net.Start("stunt_failure")
				net.Send(ply)
				failed = true
				timer.Simple(0.1, function() failed = false end)
			end
		end
	end
end 
function GM:GetFallDamage(ply, speed)
	EnterRagdoll(ply)
end
function GM:PlayerShouldTakeDamage(ply, attacker)
	if not IsValid(ply:GetRagdollEntity()) then
		EnterRagdoll(ply)
	end
end
function GM:EntityTakeDamage(t, dinfo)
	if t:IsRagdoll() then
		if dinfo:IsExplosionDamage() then
			for bone = 0, t:GetPhysicsObjectCount() - 1 do
				t.BoneDamage[bone] = math.min(t.BoneDamage[bone] + dinfo:GetDamage(), t.BreakPoint)
				t:SetNWInt("BoneDamage" .. bone, t.BoneDamage[bone])
				t:SetNWInt("profits", math.floor(t:GetNWInt("profits") + math.min(dinfo:GetDamage(), (t.BreakPoint - t.BoneDamage[bone])) ^ 1.1))
			end
		end
	end
end

function count(o)
	local a = 0
	for _ in pairs(o) do a = a + 1 end 
	return a
end

function GM:SetupPlayerVisibility(ply, viewentity)
	if IsValid(ply:GetRagdollEntity()) then
		AddOriginToPVS(ply:GetRagdollEntity():GetPos())
	end
end

function playerphys(ply, data, collider)
	if data.HitEntity == ent then return end
	local a = (data.TheirOldVelocity - data.OurOldVelocity)
	local impact = (a * data.HitNormal):Distance(Vector())
	if impact > 300 then
		EnterRagdoll(ply)
	end
end

function GM:PlayerInitialSpawn(ply)
	ply:AddCallback("PhysicsCollide", playerphys)
end

local player = FindMetaTable("Player")
function player:GetShootPos()
	local pos = self:GetPos() + Vector(0, 0, 64)
	local ang = self:EyeAngles()
	local offset = pos + Angle(0, ang.y, ang.r):Forward() * 20 * math.max((math.abs(ang.p) - 30), 0) / 90 + Vector(0, 0, 12)
	local ragoffset = IsValid(self:GetRagdollEntity()) and self:GetRagdollEntity():GetBonePosition(6) + Vector(0, 0, 12)
	return ragoffset or offset
end
function player:EyePos()
	local pos = self:GetPos() + Vector(0, 0, 64) * self:GetModelScale()
	local ang = self:EyeAngles()
	local offset = pos + Angle(0, ang.y, ang.r):Forward() * 20 * math.max((math.abs(ang.p) - 30), 0) / 90 + Vector(0, 0, 12)
	local ragoffset = IsValid(self:GetRagdollEntity()) and self:GetRagdollEntity():GetBonePosition(6) + Vector(0, 0, 12)
	return ragoffset or offset
end
