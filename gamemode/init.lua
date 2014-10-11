AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_serversidebodies.lua")
AddCSLuaFile("sh_bones.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("includes/modules/easings.lua")
AddCSLuaFile("cl_spawnmenu.lua")
AddCSLuaFile("sh_buyables.lua")
AddCSLuaFile("cl_hats.lua")
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("sh_multipliers.lua")

include("shared.lua")
include("sv_serversidebodies.lua")
include("sv_puppetmaster.lua")
include("sv_sql_database.lua")
include("sv_spawnmenu.lua")

resource.AddFile("sound/jackass/chaching.wav")
resource.AddFile("resource/fonts/321impact.ttf")
resource.AddFile("models/stairsupport_tall.mdl")
resource.AddFile("models/hanging_stair_128.mdl")
resource.AddFile("models/stunt_helmet.mdl")
resource.AddFile("models/freeman/camera.mdl")
resource.AddFile("materials/models/freeman/camera.mdl")
resource.AddFile("materials/models/player/items/demo/camera_diffuse.vtf")
resource.AddFile("materials/models/player/items/demo/camera_specular.vtf")
resource.AddFile("materials/models/player/items/demo/camera.vmt")
resource.AddFile("materials/models/player/items/demo/sunt_helmet_blue.vtf")

local failed = false

function ExitRagdoll(ply)
	hook.Call("JackassExitRagdoll", nil, ply)
	failed = false
	ply:DrawViewModel(true)
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
			timer.Destroy("ragupdate" .. ply:EntIndex())
		end
	end)
end
function EnterRagdoll(ply)
	hook.Call("JackassEnterRagdoll", nil, ply)
	ply:SetActiveWeapon(NULL)
	ply:DrawViewModel(false)
	net.Start("stunt_begin")
	net.Send(ply)
	ply:CreateRagdoll()
	timer.Simple(0, function()
		ply:SetMoveType(MOVETYPE_NONE)
		ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		ply:SetNoDraw(true)
	end)
end
util.AddNetworkString("stunt_success")
util.AddNetworkString("stunt_failure")
util.AddNetworkString("stunt_begin")

function GM:PlayerLoadout(ply)
	ply:SetModel("models/player/Group02/male_02.mdl")
	--ply:GodEnable()
end
hook.Add("JackassPlayerNeckBroken", "die", function(ply)
	print("function")
	ply:Kill()
	net.Start("stunt_failure")
	net.Send(ply)
end)
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
			if not failed then
				hook.Call("JackassPlayerNeckBroken", nil, ply)
				failed = true
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
				dmg = math.floor(dinfo:GetDamage())
				t.BoneDamage[bone] = math.min(t.BoneDamage[bone] + dmg, t.BreakPoint)
				t:SetNWInt("BoneDamage" .. bone, t.BoneDamage[bone])
				t:SetNWInt("profits", t:GetNWInt("profits") + dmg)
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

hook.Add("JackassEnterRagdoll", "UpdatePlayer", function(ply)
	timer.Create("ragcreate", 0.1, 0, function()
		if IsValid(ply:GetRagdollEntity()) then
			ply:GetRagdollEntity():SetRenderBones(true)
			ply:GetRagdollEntity():SetNWInt("physcount", ply:GetRagdollEntity():GetPhysicsObjectCount())
			timer.Create("ragupdate" .. ply:EntIndex(), 1, 0, function()
				if IsValid(ply:GetRagdollEntity()) then
					ply:SetMoveType(MOVETYPE_WALK)
					timer.Simple(0, function()
						if IsValid(ply:GetRagdollEntity()) then
							ply:SetPos(ply:GetRagdollEntity():GetPos())
							ply:SetMoveType(MOVETYPE_NONE)
						end
					end)
				end
			end)
			timer.Destroy("ragcreate")
		end
	end)
end)



if GetConVarNumber("js_antilag") == 1 then
	local time
	local count = 0
	hook.Add("Think", "cleanup", function()
		if time then
			if SysTime() - time > 0.03 * game.GetTimeScale() then
				count = count + 1
			else
				count = 0
			end
			if count > 3 then
				for k, v in pairs(ents.GetAll()) do if v:GetClass() == "prop_physics" then v:Remove() end end
				RunConsoleCommand("say", "Tick took too long to process! Cleaning up. (>0.03 seconds for 3 ticks)")
				count = 0
			end
		end
		time = SysTime()
	end)
end

if GetConVarNumber("js_allowcslua") == 1 then
	RunConsoleCommand("sv_allowcslua", "1")
end