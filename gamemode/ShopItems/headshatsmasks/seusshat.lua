ITEM.Name = 'Seuss Hat'
ITEM.Price = 200
ITEM.Model = 'models/gmod_tower/seusshat.mdl'
ITEM.Attachment = 'eyes'
ITEM.Buyable = true;

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	ang:RotateAroundAxis(ang:Right(), 15)
	pos = pos + (ang:Forward() * -3) + (ang:Up() * 2)
	
	return model, pos, ang
end
