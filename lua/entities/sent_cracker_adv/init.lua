AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

--util.AddNetworkString("sent_cracker_command")
CreateConVar("kcadv_hp",25,bit.band(FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY))
CreateConVar("kcadv_cracktime",15,bit.band(FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY))
function ENT:Initialize()
	self:SetModel( "models/weapons/w_c4.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:GetPhysicsObject():SetMass(1)
	self.hp = GetConVarNumber("kcadv_hp")
	self.timeToCrack = GetConVarNumber("kcadv_cracktime")
	self.cracking = true
	self.alive = true
	self.owner = nil
	self.target = nil
	self.beep = 0
	self.cracktime = CurTime()+self.timeToCrack
	self:SetUseType(SIMPLE_USE)
	self.crackchance = 1
end

function ENT:Use(act,call,use,val)
	if IsValid(act) and IsValid(self.owner) then
		if act==self.owner and self.hp > 0 then
			act:Give("weapon_keycrack_adv")
			self.target.ADV_CRACK = false
			self:Remove()
		end
	end
end

function ENT:Think()
	--nwvars
	self:SetNWBool("cracking",self.cracking)
	self:SetNWInt("cracktime",self.timeToCrack)
	self:SetNWFloat("progress",CurTime()-(self.cracktime-self.timeToCrack))
	if self.hp == nil then self.hp = 25 end
	if self.alive == false then return end
	if self.hp <= 0 or !IsValid(self.target) or !IsValid(self.owner) then
		self:GetPhysicsObject():Wake()
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.alive = false
		if IsValid(self.target) then
			self.target.ADV_CRACK = false
		end
		timer.Simple(2,function()
			sound.Play("weapons/stunstick/spark"..math.random(1,3)..".wav",self:GetPos(),85,100,1)
			local eft = EffectData()
			eft:SetOrigin(self:GetPos())
			util.Effect("ManhackSparks",eft)
			self:Remove()
		end)
	end
	if self.beep < CurTime() and self.cracking then
		self.beep = CurTime() + 0.8
		self:EmitSound("buttons/blip2.wav",90)
	end
	if self.cracktime < CurTime() then
		self.cracking = false
		if math.Rand(0,1)<self.crackchance then
			self.alive = false
			self.target:Process(true)
			local eft = EffectData()
			eft:SetOrigin(self:GetPos())
			util.Effect("ManhackSparks",eft)
			self:GetPhysicsObject():Wake()
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:EmitSound("buttons/combine_button1.wav",85)
			timer.Simple(5,function()
				if IsValid(self)==false then return end
				if self.owner:GetPos():Distance(self:GetPos())<400 then
					self.owner:Give("weapon_keycrack_adv")
					self:Remove()
				else
					timer.Simple(10,function()
						if IsValid(self)==false then return end
						self:Remove()
					end)
				end
			end)
		else
			self.target:Remove()
			self.hp = 0
			self.cracking = false
		end
	end
	local cr = self
	local ent = self.target
	cr:SetAngles(ent:GetAngles())
	cr:SetPos(ent:GetPos()+ent:GetForward()*1)
	local ang = cr:GetAngles()
	ang:RotateAroundAxis(cr:GetRight(),-90)
	ang:RotateAroundAxis(cr:GetForward(),180)
	cr:SetAngles(ang)


	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:OnTakeDamage(dmg)
	self.hp = self.hp - dmg:GetDamage()
end
