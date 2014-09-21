GM.Name = "Jackass"
GM.Author = "Ott, RzDat"
GM.Email = "N/A"
GM.Website = "https://github.com/DaaOtt/Jackass"

include("sh_bones.lua")
include("sh_buyables.lua")
include("sh_sounds.lua")
include("sh_multipliers.lua") 

function GM:Initialize()

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

function GM:PlayerFootstep(ply)
	return IsValid(ply:GetRagdollEntity())
end