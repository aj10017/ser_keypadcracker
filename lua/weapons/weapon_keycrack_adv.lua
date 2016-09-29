AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.Author = "Seris"
SWEP.Category = "Other"
SWEP.Purpose = "Crack Keypads without leaving yourself open to attack"
SWEP.Instructions = "Plant the cracker on a keypad and defend it!"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Slot = 4
SWEP.HoldType = "Pistol"

if CLIENT then
	SWEP.PrintName = "Advanced Keypad Cracker"
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.ViewModel = Model("models/weapons/v_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.Primary.Ammo = ""
SWEP.Secondary.Ammo = ""

SWEP.target = nil
SWEP.cracking = false

function SWEP:Reload()

end

function SWEP:SecondaryAttack()

end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() or IsValid(self.target) or self.cracking then return end
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local ent = nil
	if tr~=nil then if IsValid(tr.Entity) then ent = tr.Entity end end
	if IsValid(ent) then
		if (ent:GetClass()=="keypad" or ent:GetClass()=="keypad_wire") and self.Owner:EyePos():Distance(tr.HitPos)<100 then
			local cr = ents.Create("sent_cracker_adv")
			if IsValid(cr) and not ent.ADV_CRACK then
				cr:SetAngles(ent:GetAngles())
				cr:SetPos(ent:GetPos()+ent:GetForward()*1)
				cr:Spawn()
				local ang = cr:GetAngles()
				ang:RotateAroundAxis(cr:GetRight(),-90)
				ang:RotateAroundAxis(cr:GetForward(),180)
				cr:SetAngles(ang)
				cr:GetPhysicsObject():Sleep()
				cr:SetMoveType(MOVETYPE_NONE)
				cr.owner = self.Owner
				cr.target = ent
				--ent.ADV_CRACK = true
				self.Owner:StripWeapon("weapon_keycrack_adv")
			end
		end
	end
end

function SWEP:Think()

end
