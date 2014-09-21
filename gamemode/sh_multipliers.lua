if SERVER then
	util.AddNetworkString("addmul")
end
if CLIENT then
	net.Receive("addmul", function()
		LocalPlayer():GetRagdollEntity().muls = LocalPlayer():GetRagdollEntity().muls or {}
		table.insert(LocalPlayer():GetRagdollEntity().muls, net.ReadString())
	end)
end

local meta = FindMetaTable("Entity")

function meta:AddMultiplier(mul, text)
	print(mul, text)
	if mul < 1 then
		mul = 1
	end
	self:SetNWInt("mul", self:GetNWInt("mul") + mul)
	if not CLIENT then
		net.Start("addmul")
			net.WriteString(text)
		net.Send(self:GetNWEntity("Player"))
	else
		self.muls = self.muls or {}
		table.insert(self.muls, text)
	end
end
