local meta = FindMetaTable( "Player" )
if (!meta) then return end

local GetRagdollEntity = meta.GetRagdollEntity

function meta:GetRagdollEntity()
	return self:GetNetworkedEntity( "m_hRagdollEntity" )
end

