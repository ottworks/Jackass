local model = ClientsideModel("models/stunt_helmet.mdl", RENDERGROUP_OPAQUE)
model:SetModelScale(0.9, 0)
local function drawhats()
	for k, v in pairs(player.GetAll()) do
		if v:GetNWString("Hat") == "Stunt Helmet" then
			local pos, ang = LocalToWorld(Vector(1, 0, 0), Angle(0, -90, -90), v:GetBonePosition(6))
			if v:GetNoDraw() and IsValid(v:GetRagdollEntity()) then
				pos, ang = LocalToWorld(Vector(1, 0, 0), Angle(0, -90, -90), v:GetRagdollEntity():GetBonePosition(6))
			end
			model:SetRenderOrigin( pos );
			model:SetRenderAngles( ang );
			model:SetupBones();
			model:DrawModel();
		end
	end
	model:SetRenderOrigin(Vector())
end
hook.Add("PostDrawTranslucentRenderables", "drawhats", drawhats)