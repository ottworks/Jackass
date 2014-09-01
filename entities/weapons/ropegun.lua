SWEP.PrintName			= "Rope Gun"
SWEP.Author			= "Ott"
SWEP.Instructions		= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot			= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

local ShootSound = Sound("Metal.SawbladeStick")
local stage = 0
local ent, bone, pos
function SWEP:PrimaryAttack()
	self:EmitSound(ShootSound)
	if not SERVER then return end
	local tr = self.Owner:GetEyeTrace()
	if IsValid(tr.Entity) then
		if ( SERVER and not util.IsValidPhysicsObject( tr.Entity, tr.PhysicsBone ) ) then return false end
		stage = stage + 1
		if stage == 1 then
			ent = tr.Entity
			bone = tr.PhysicsBone
			pos = ent:WorldToLocal(tr.HitPos)
		else
			constraint.Rope(ent, tr.Entity, bone, tr.PhysicsBone, pos, tr.Entity:WorldToLocal(tr.HitPos), tr.HitPos:Distance(ent:LocalToWorld(pos)), 10, 0, 2, "cable/rope", false)
			stage = 0
		end
	end
end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
	self.Owner:DrawViewModel(false)
end