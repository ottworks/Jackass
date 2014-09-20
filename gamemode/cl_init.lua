include("shared.lua")
include("cl_serversidebodies.lua")
include("cl_hud.lua")
include("cl_hats.lua")
include("cl_spawnmenu.lua")

local prevang

function GM:CalcView(ply, pos, ang, fov, nearz, farz)
	local offset = pos + Angle(0, ang.y, ang.r):Forward() * 20 * math.max((math.abs(ang.p) - 30), 0) / 90 + Vector(0, 0, 12)
	local ragoffset = IsValid(ply:GetRagdollEntity()) and ply:GetRagdollEntity():GetBonePosition(6) + Vector(0, 0, 12)
	local view = {angles = ang}
	local tr = {}
		if IsValid(ply:GetRagdollEntity()) then
			offset = ragoffset
			tr.filter = ply:GetRagdollEntity()
			tr.start = offset
			tr.endpos = offset - ang:Forward() * ((90 - fov) * 2.33 + 100)
		elseif ply:Alive() then
			tr.start = offset
			tr.endpos = offset - ang:Forward() * ((90 - fov) * 2.33 + 100)
		end
		tr.mask = MASK_BLOCKLOS
		tr.mins = Vector(-nearz*2, -nearz*2, -nearz*2)
		tr.maxs = Vector(nearz*2, nearz*2, nearz*2)
	local trace = util.TraceHull(tr)
	if trace.Hit then
		view.origin = trace.HitPos
	else
		view.origin = offset - ang:Forward() * ((90 - fov) * 2.33 + 100)
	end
	if not IsValid(ply:GetRagdollEntity()) then
		view.drawviewer = true
	else
		local _, ang = ply:GetRagdollEntity():GetBonePosition(6) --head ang
		ang = LerpAngle(0.9, ang, Angle(0, 0, 0))
		prevang = prevang or ang
		ang = LerpAngle(0.1, prevang, ang)
		ang1 = Angle()
		ang1:Set(ang)
		ang1:RotateAroundAxis(ang:Up(), view.angles.y)
		ang1.y = 0
		ang1.p = 0
		view.angles = view.angles + ang1

		prevang = ang
	end
	return view
end

function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HideHud", hidehud)
