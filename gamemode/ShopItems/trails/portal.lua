ITEM.Name = 'Playing With Portals'
ITEM.Price = 1500
ITEM.Material = 'trails/portal.vmt'
ITEM.Desc = 'The cake is a lie.'
ITEM.Grade = 'Restricted'
ITEM.Buyable = true;

function ITEM:OnEquip(ply, modifications)
	ply.PortalTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
	SafeRemoveEntity(ply.PortalTrail)
end

function ITEM:Modify(modifications)
	PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
	SafeRemoveEntity(ply.PortalTrail)
	self:OnEquip(ply, modifications)
end