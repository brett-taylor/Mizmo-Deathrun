ITEM.Name = 'Shadow Daggers' .. ' | ' .. 'Night'
ITEM.Price = 20000
ITEM.Model = 'models/weapons/w_csgo_push.mdl'
ITEM.Skin = 7
ITEM.WeaponClass = 'csgo_daggers_night'
ITEM.Buyable = false;

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