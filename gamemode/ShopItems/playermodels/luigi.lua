ITEM.Name = 'Luigi'
ITEM.Price = 15000
ITEM.Model = 'models/sinful/luigib.mdl'
ITEM.Desc = "Mario's brother."
ITEM.Grade = 'Covert'
ITEM.Level = 55
ITEM.Buyable = true;

function ITEM:OnEquip(ply, modifications)
	if not ply._OldModel then
		ply._OldModel = ply:GetModel()
	end
	
	timer.Simple(1, function() ply:SetModel(self.Model) end)
end

function ITEM:OnHolster(ply)
	if ply._OldModel then
		ply:SetModel(ply._OldModel)
	end
end

function ITEM:PlayerSetModel(ply)
	ply:SetModel(self.Model)
end
