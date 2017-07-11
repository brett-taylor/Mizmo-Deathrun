local PANEL = {}

function PANEL:Init()
	self.Background = vgui.Create("DMizmoFrame");
	self.Background:SetText("Menu");
	self.Background:ShouldShowCloseButton(true);
	self.Background:SetOnClose(function()
		self:Remove(); 
		EscapeMenu.Panel = nil;
	end);

	self:InvalidateLayout();
end

function PANEL:InvalidateLayout()
	if (self.Background ~= nil) then
		self.Background:SetSize(300, 170);
		self.Background:Center();
		self.Background:InvalidateLayout();
	end
end

function PANEL:Remove()
	self.Background:Remove();
end

vgui.Register("DMizmoMainMenu", PANEL);