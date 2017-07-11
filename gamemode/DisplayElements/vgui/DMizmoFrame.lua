local PANEL = {};

function PANEL:Init()
	self.titlePanel = vgui.Create("DPanel", self);
	self.titlePanel.Paint = function(self, w, h)
		surface.SetDrawColor(Colours.Gold);
		surface.DrawRect(0, 0, w, h - 15);

		surface.SetDrawColor(ColorAlpha(Colours.Grey, 255));
		surface.DrawRect(15, h - 15, w - 30, 15);

		local leftArrow =
		{
			{ x = 0, y = h - 15 },
			{ x = 15, y = h - 15 },
			{ x = 15, y = h }
		}
		surface.SetDrawColor(Colours.GoldDark);
		surface.DrawPoly(leftArrow);

		local rightArrow =
		{
			{ x = w, y = h - 15 },
			{ x = w - 15, y = h - 15 },
			{ x = w - 15, y = h }
		}
		surface.SetDrawColor(Colours.GoldDark);
		surface.DrawPoly(rightArrow);
	end

	self.container = vgui.Create("DPanel", self);
	self.container.Paint = function(self, w, h)		
		surface.SetDrawColor(Colours.Grey);
		surface.DrawRect(0, 0, w, h);
	end

	self.title = vgui.Create("DLabel", self.titlePanel);
	self.title:SetFont("MizmoGaming-Pointshop-Title");
	self.title:SetColor(Colours.Grey);

	self.showTheCloseButton = false;

	self:MakePopup();
end

function PANEL:InvalidateLayout()
	self:Center();

	if (self.titlePanel ~= nil) then
		self.titlePanel:SetSize(self.titlePanel:GetParent():GetWide(), 55);
		self.titlePanel:SetPos(0, 0);
	end

	if (self.container ~= nil) then
		self.container:SetSize(self.titlePanel:GetParent():GetWide() - 30, self.titlePanel:GetParent():GetTall() - 55);
		self.container:SetPos(15, 55);
	end

	if (self.title ~= nil) then
		self.title:SetContentAlignment(8);
		self.title:Dock(FILL);
		self.title:DockMargin(0, 5, 0, 5);
	end

	if (self.showTheCloseButton == true && self.closeButton == nil) then
		self:CreateCloseButton();
	end

	if (self.showTheCloseButton == false && self.closeButton ~= nil) then
		self.closeButton:Remove();
	end

	if (self.closeButton ~= nil) then
		self.closeButton:SetSize(25, 25);
		self.closeButton:SetPos(self.closeButton:GetParent():GetWide() - 40, 7);
	end
end

function PANEL:SetOnClose(f)
	self.OnCloseFunction = f;
end

function PANEL:SetText(text)
	if (self.title ~= nil) then
		self.title:SetText(text);
	end
end

function PANEL:CreateCloseButton()
	self.closeButton = vgui.Create("DButton", self.titlePanel);
	self.closeButton:SetText("X");
	self.closeButton:SetTextColor(Colours.Grey);
	self.closeButton.Paint = function(self, w, h)
		surface.SetDrawColor(Colours.Grey);
		surface.DrawRect(0, 0, w, h);

		surface.SetDrawColor(Colours.Gold);
		surface.DrawRect(2, 2, w - 4, h - 4);
	end
	self.closeButton.DoClick = function()
		if (self.OnCloseFunction ~= nil) then
			self.OnCloseFunction();
		end
	end
end

function PANEL:ShouldShowCloseButton(b)
	self.showTheCloseButton = b;
end

vgui.Register("DMizmoFrame", PANEL)
