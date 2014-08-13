local model = ClientsideModel("models/stunt_helmet.mdl", RENDERGROUP_OPAQUE)
model:SetModelScale(0.9, 0)
local function drawhats()
	for k, v in pairs(player.GetAll()) do
		if v:GetNWString("Hat") == "Stunt Helmet" and not v:GetNoDraw() then
			local pos, ang = LocalToWorld(Vector(1, 0, 0), Angle(0, -90, -90), v:GetBonePosition(6))
			model:SetRenderOrigin( pos );
			model:SetRenderAngles( ang );
			model:SetupBones();
			model:DrawModel();
		end
	end
	model:SetRenderOrigin(Vector())
end
hook.Add("PostDrawTranslucentRenderables", "drawhats", drawhats)