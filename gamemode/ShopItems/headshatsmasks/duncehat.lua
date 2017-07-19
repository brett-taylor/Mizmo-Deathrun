ITEM.Name = 'Dunce Hat'
ITEM.Price = 200
ITEM.Model = 'models/duncehat/duncehat.mdl'
ITEM.Attachment = 'eyes'
ITEM.Buyable = true;

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	--model:SetModelScale(1.6, 0)
	ang:RotateAroundAxis(ang:Right(), 25)
	pos = pos + (ang:Forward() * -2.8) + (ang:Up() * 2.5)
	
	
	return model, pos, ang
end
