local function grabinput(ply, cmd)
	if not IsValid(ply:GetRagdollEntity()) or not ply:Alive() then return end
	if not IsValid(ply:GetRagdollEntity():GetPhysicsObject()) then return end

	local body = ply:GetRagdollEntity()
	local hips = body:GetPhysicsObjectNum(0)
	local gut = body:GetPhysicsObjectNum(1)
	local right_shoulder = body:GetPhysicsObjectNum(2)
	local left_shoulder = body:GetPhysicsObjectNum(3)
	local left_elbow = body:GetPhysicsObjectNum(4)
	local left_wrist = body:GetPhysicsObjectNum(5)
	local right_elbow = body:GetPhysicsObjectNum(6)
	local right_wrist = body:GetPhysicsObjectNum(7)
	local right_hip_joint = body:GetPhysicsObjectNum(8)
	local right_knee = body:GetPhysicsObjectNum(9)
	local head = body:GetPhysicsObjectNum(10)
	local left_hip_joint = body:GetPhysicsObjectNum(11)
	local left_knee = body:GetPhysicsObjectNum(12)
	local left_ankle = body:GetPhysicsObjectNum(13)
	local right_ankle = body:GetPhysicsObjectNum(14)

	if cmd:KeyDown(IN_DUCK) then
		left_hip_joint:AddAngleVelocity(Vector(0, 0, -100))
		right_hip_joint:AddAngleVelocity(Vector(0, 0, -100))

		left_knee:AddAngleVelocity(Vector(0, 0, 100))
		right_knee:AddAngleVelocity(Vector(0, 0, 100))

		gut:AddAngleVelocity(Vector(0, 0, 100))

		local handpos = (((left_knee:GetPos() + left_ankle:GetPos()) / 2 + left_knee:GetAngles():Right() * 5) - left_wrist:GetPos())
		handpos:Normalize()
		left_wrist:ApplyForceCenter(handpos * 100)
		local handpos = (((right_knee:GetPos() + right_ankle:GetPos()) / 2 + right_knee:GetAngles():Right() * 5) - right_wrist:GetPos())
		handpos:Normalize()
		right_wrist:ApplyForceCenter(handpos * 100)

		head:AddAngleVelocity(Vector(0, 0, 100))
	end

	if cmd:KeyDown(IN_SPEED) then
		for i = 1, body:GetPhysicsObjectCount()-1 do
			local bone = body:GetPhysicsObjectNum(i)
			local pos = -body:WorldToLocal(head:GetPos())
			
			pos = body:LocalToWorld(pos) - body:GetPos()
			pos:Normalize()
			bone:ApplyForceCenter(pos * 100)
		end
		local pos = body:WorldToLocal(head:GetPos()) * 2
		pos = body:LocalToWorld(pos) - body:GetPos()
		pos:Normalize()
		head:ApplyForceCenter(pos * 1500)
	end

	if (not cmd:KeyDown(IN_DUCK) and not cmd:KeyDown(IN_SPEED)) and body:GetVelocity():Distance(Vector()) > 500 then
		for i = 1, body:GetPhysicsObjectCount()-1 do
			local bone = body:GetPhysicsObjectNum(i)
			local pos = bone:GetPos() - body:GetPos()
			pos:Normalize()
			bone:ApplyForceCenter(pos * 200)
		end
		local pos = body:WorldToLocal(head:GetPos()) * 2
		pos = body:LocalToWorld(pos) - body:GetPos()
		pos:Normalize()
		head:ApplyForceCenter(pos * 100)
	end
	if cmd:KeyDown(IN_FORWARD) then
		gut:AddAngleVelocity(Vector(0, 0, 50))
	end
	if cmd:KeyDown(IN_BACK) then
		gut:AddAngleVelocity(Vector(0, 0, -50))
	end
	if cmd:KeyDown(IN_MOVELEFT) then
		gut:AddAngleVelocity(Vector(-50, 0, 0))
	end
	if cmd:KeyDown(IN_MOVERIGHT) then
		gut:AddAngleVelocity(Vector(50, 0, 0))
	end
end
hook.Add("Move", "puppetinput", grabinput)