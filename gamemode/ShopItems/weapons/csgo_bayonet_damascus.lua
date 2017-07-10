ITEM.Name = 'Bayonet Knife' .. ' | ' .. 'Damascus Steel'
ITEM.Price = 20000
ITEM.Model = 'models/weapons/w_csgo_bayonet.mdl'
ITEM.Skin = 4
ITEM.WeaponClass = 'csgo_bayonet_damascus'

function ITEM:OnEquip(ply)
	ply:Give(self.WeaponClass)
	ply:StripWeapon("weapon_crowbar");
end

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
	ply:Give("weapon_crowbar")
end

function ITEM:OnHolster(ply)
	ply:StripWeapon(self.WeaponClass)
	ply:Give("weapon_crowbar")
end