local addonName = ...;
local function OnUpdate(self, elapsed)
	if ( self.unit ) then
		local guid = UnitGUID(self.unit);
		
		if ( UnitExists(self.unit) and guid ~= self.guid ) then
			self:UpdateGUID(self.unit);
			self:Update();
		end
	end
end

local function OnShow(frame)
	frame:Update();
end

local function UpdateElementPositions(frame)
	ArenaLiveUnitFrames:SetFramePositions(frame);
end

function ALUF_TargetTargetFrame:Initialise()
		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "TargetTargetFrame", "target", "togglemenu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "TargetTargetFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "TargetTargetFrame");
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."Name"], "NameText");

		-- Update Constituent positions:
		self.UpdateElementPositions = UpdateElementPositions;
		self:UpdateElementPositions();
		
		-- Set OnUpdate script:
		self:SetScript("OnShow", OnShow);
		self:SetScript("OnUpdate", OnUpdate);
end

function ALUF_TargetTargetFrame:OnEnable()
	self:UpdateUnit("targettarget");
end

function ALUF_FocusTargetFrame:Initialise()
		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "FocusTargetFrame", "target", "togglemenu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, nil, nil, nil, nil, nil, nil, addonName, "FocusTargetFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "FocusTargetFrame");
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."Name"], "NameText");

		-- Update Constituent positions:
		self.UpdateElementPositions = UpdateElementPositions;
		self:UpdateElementPositions();
		
		-- Set OnUpdate script:
		self:SetScript("OnShow", OnShow);
		self:SetScript("OnUpdate", OnUpdate);
end

function ALUF_FocusTargetFrame:OnEnable()
	self:UpdateUnit("focus-target");
end