AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_serversidebodies.lua")
AddCSLuaFile("sh_bones.lua")

include("shared.lua")
include("sv_serversidebodies.lua")
include("sv_puppetmaster.lua")

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
			for i = 1, 20 do
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
	ply:CreateRagdoll()
	ply:SetMoveType(MOVETYPE_NONE)
	ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ply:SetNoDraw(true)
	timer.Create("ragcreate", 0.1, 0, function()
		if IsValid(ply:GetRagdollEntity()) then
			ply:GetRagdollEntity():SetRenderBones(true)
			timer.Destroy("ragcreate")
		end
	end)
end

function GM:PlayerLoadout(ply)
	ply:SetModel("models/player/Group02/male_02.mdl")
	ply:GodEnable()
end
function GM:Move(ply, cmd)
	if cmd:KeyReleased(IN_JUMP) then
		if IsValid(ply:GetRagdollEntity()) then
			ExitRagdoll(ply, cmd)
		elseif not ply:IsOnGround() then
			EnterRagdoll(ply, cmd)
		end
	end

	if cmd:KeyPressed(IN_USE) then
		ply:SetMoveType(MOVETYPE_NOCLIP)
	end

	if IsValid(ply:GetRagdollEntity()) then
		if ply:GetRagdollEntity().BoneDamage[10] > ply:GetRagdollEntity():GetNWInt("BreakPoint") then
			ExitRagdoll(ply, cmd)
		end
	end
end 
function GM:GetFallDamage(ply, speed)
	EnterRagdoll(ply)
end

