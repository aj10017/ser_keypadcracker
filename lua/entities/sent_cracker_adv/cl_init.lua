include('shared.lua')
surface.CreateFont( "crackbar", {
		font = "courier new",
		size = 48,
		weight = 500,
		antialias = true,
		additive = false,
		shadow = false,
		outline = false,
		blursize = 0,
		scanlines = 0,
})
surface.CreateFont( "crackbar_small", {
		font = "courier new",
		size = 24,
		weight = 500,
		antialias = true,
		additive = false,
		shadow = false,
		outline = false,
		blursize = 0,
		scanlines = 0,
})
surface.CreateFont( "crackbar_tiny", {
		font = "courier new",
		size = 12,
		weight = 500,
		antialias = true,
		additive = false,
		shadow = false,
		outline = false,
		blursize = 0,
		scanlines = 0,
})
hook.Remove("PostDrawOpaqueRenderables","turrets")
hook.Add("PostDrawOpaqueRenderables","turrets",function(n,n2)
	for k, v in pairs(ents.FindByClass("sent_cracker_adv")) do
		if v:GetPos():Distance(LocalPlayer():GetPos())<500 then
			local ang = v:GetAngles()
			ang:RotateAroundAxis(v:GetForward(),0)
			ang:RotateAroundAxis(v:GetUp(),-90)
			cam.Start3D()
			cam.Start3D2D(v:GetPos()+v:GetUp()*4.5+v:GetForward()*3+v:GetRight()*-4,ang,0.02)
			draw.RoundedBox(0,0,0,480,240,Color(15,15,15,math.Rand(180,200)))
			if v:GetNWFloat("cracking",false)==true then
				draw.DrawText("<CRACKING>","crackbar",0,0,Color(255,255,255,255))
				draw.RoundedBox(0,10,60,460,170,Color(15,15,15,200))
				draw.DrawText("<PROGRESS>","crackbar_small",20,70,Color(255,255,255,255))
				local progress = (v:GetNWFloat("progress",0)/v:GetNWInt("cracktime",1))
				draw.DrawText(math.Round(progress*100).."%","crackbar_small",400,70,Color(255,255,255,255))
				draw.RoundedBox(0,160,75,200*progress,15,Color(0,255,0,150))
				--print((v:GetNWFloat("progress",0)))
				if v.crack == nil then v.crack = {} end
				for a, b in pairs(v.crack) do
					draw.DrawText(b,"crackbar_tiny",25,80+(a*10),Color(0,255,0,255))
				end
			else
				draw.DrawText("<CRACK COMPLETE>","crackbar",0,0,Color(255,255,255,255))
			end
			cam.End3D2D()
			cam.End3D()
		end
	end
end)

function ENT:Initialize()
	self:SetModel( "models/weapons/w_c4.mdl" )
	self:SetNoDraw(false)
	self:SetRenderMode(0)
	self:CreateCLModel()
	self.crack = {}
end

function ENT:Think()
	self:DrawModel()
	if not IsValid(self.clmodel) then self:CreateCLModel() end
	self.clmodel:SetPos(self:GetPos())
	self.clmodel:SetAngles(self:GetAngles())

	--print(CurTime()% 0.5)
	if CurTime() % 0.1  > 0.09 then
		table.insert(self.crack,self:randomstring())
	end
	if #self.crack > 13 then table.remove(self.crack,1) end
end

function ENT:randomstring()
	local txt = ""
	for i = 1,80 do
		txt = txt .. string.char(math.random(33,127))
	end
	return txt
end

function ENT:Draw()

end

function ENT:OnRemove()
	self.clmodel:Remove()

end

function ENT:CreateCLModel()

	self.clmodel = ClientsideModel("models/weapons/w_c4.mdl",RENDERGROUP_BOTH) or self.clmodel

end
