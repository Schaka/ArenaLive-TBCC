--[[
    ArenaLive [Spectator] is an user interface for spectated arena 
	wargames in World of Warcraft.
    Copyright (C) 2015  Harald Böhm <harald@boehm.agency>
	Further contributors: Jochen Taeschner and Romina Schmidt.
	
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
	ADDITIONAL PERMISSION UNDER GNU GPL VERSION 3 SECTION 7:
	As a special exception, the copyright holder of this add-on gives you
	permission to link this add-on with independent proprietary software,
	regardless of the license terms of the independent proprietary software.
]]

-- Addon Name and localisation table:
local FORCED_ALPHA = true
local NAMEPLATE_SIZE = 0.9
local NAMEPLATE_TARGET_SIZE = 1.0
local TESTMODE = false

if (FORCED_ALPHA == true) then
    SetCVar("nameplateNotSelectedAlpha", 1)
end

-- Addon Name and localisation table:
local addonName, L = ...;

local ArenaLiveNamePlatesFrame = CreateFrame("Frame", "ArenaLiveNamePlates3", UIParent)
ArenaLiveNamePlatesFrame.defaults = {
	["FirstLogin"] = true,
	["Cooldown"] =	{
		["ShowText"] = true,
		["StaticSize"] = false,
		["TextSize"] = 8,
	},
	["CCIndicator"] =	{
		["Priorities"] = {
			["crowdControl"] = 9,
			["stun"] = 8,
			["silence"] = 7,
			["defCD"] = 6,
			["offCD"] = 5,
			["root"] = 4,
			["disarm"] = 3,
			["usefulDebuffs"] = 2,
			["usefulBuffs"] = 1,
		},
	},
	["NamePlate"] = {
		["CCIndicator"] = {
			["Enabled"] = true,
		},
		["HealthBar"] = {
			["ColourMode"] = "class",
			["ShowHealPrediction"] = true,
			["ShowAbsorb"] = true,
		},
	},
};

local ArenaLiveNamePlates = ArenaLive:ConstructAddon(ArenaLiveNamePlatesFrame, addonName, false, ArenaLiveNamePlatesFrame.defaults, false, "ALNP_Database")


local function isInPvP()

	if TESTMODE then
		return true
	end	

	local inInstance, gameType = IsInInstance()
	local isInPvPZone = gameType == "pvp" or gameType == "arena"
	local inPvPMode = false -- FIXME: check if pvp status active (in certain zones?)
	return isInPvPZone or ( inPvPMode and not IsResting())
end

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
local NamePlate = ArenaLive:ConstructHandler("NamePlate", true, true);
local CCIndicator = ArenaLive:GetHandler("CCIndicator");
local HealthBar = ArenaLive:GetHandler("HealthBar");
local NameText = ArenaLive:GetHandler("NameText");
local playerExistState = {};


-- Register for needed events:
NamePlate:RegisterEvent("PLAYER_ENTERING_WORLD");
NamePlate:RegisterEvent("PLAYER_TARGET_CHANGED");
NamePlate:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED");
NamePlate:RegisterEvent("UNIT_AURA");
NamePlate:RegisterEvent("UNIT_NAME_UPDATE");
NamePlate:RegisterEvent("UNIT_PET");
NamePlate:RegisterEvent("UNIT_HEALTH");
NamePlate:RegisterEvent("UNIT_HEAL_PREDICTION");
NamePlate:RegisterEvent("NAME_PLATE_CREATED");
NamePlate:RegisterEvent("NAME_PLATE_UNIT_ADDED");
NamePlate:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
NamePlate:RegisterEvent("ADDON_LOADED");

-- Set Attributes:
NamePlate.unitNameCache = {};
NamePlate.namePlates = {};

-- Create NamePlate Class:
local NamePlateClass = {};

--[[
*****************************************
*** PRIVATE HOOK FUNCTIONS START HERE ***
*****************************************
]]--
local function NamePlateHealthBar_OnValueChanged(healthBar)
	local blizzPlate = healthBar:GetParent():GetParent():GetParent();
	local namePlate = NamePlate.namePlates[blizzPlate];
	if ( namePlate.enabled ) then
		namePlate:UpdateHealthBar();
	end
end

local function NamePlateCastBar_OnValueChanged(castBar)
	local blizzPlate = castBar:GetParent():GetParent();
	local namePlate = NamePlate.namePlates[blizzPlate];
	if ( namePlate.enabled ) then
		namePlate:UpdateCastBar();
	end
end



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function NamePlate:ConstructObject(namePlate, addonName, frameGroup)
	local prefix = namePlate:GetName();
	namePlate.addon = addonName;
	namePlate.group = frameGroup;
	
	-- Copy Class Methods:
	ArenaLive:CopyClassMethods(NamePlateClass, namePlate);	
	
	-- Construct CC Indicator:
	namePlate.CCIndicator = _G[prefix.."CCIndicator"];
	CCIndicator:ConstructObject(_G[prefix.."CCIndicator"], _G[prefix.."CCIndicatorTexture"], _G[prefix.."CCIndicatorCooldown"], addonName);
	
	-- Construct HealthBar:
	HealthBar:ConstructObject(_G[prefix.."HealthBar"], _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, frameGroup);
	
	-- Set reference where needed:
	namePlate.nameText = _G[prefix.."NameText"];
	namePlate.healerIcon = _G[prefix.."HealerIcon"];
	namePlate.border = _G[prefix.."Border"];
	
	
	namePlate:SetScript("OnShow", namePlate.OnShow);
	
	-- Enable or disable name plate according to spectator state:
    namePlate:Enable();

end

function NamePlate:Enable()
	self:Show();
	for blizzPlate, namePlate in pairs(self.namePlates) do
		namePlate:Enable();
	end
	self.enabled = true;
end

function NamePlate:Disable()
	self:Hide();
	for blizzPlate, namePlate in pairs(self.namePlates) do
		namePlate:Disable();
	end
	
	self.enabled = false;
end

function NamePlate:GetReactionType(r, g, b)
	-- I use 0.9 instead of 1, because getter functions
	-- most of the time return not 1, but 0,998 etc.
	if ( r > 0.9 and g > 0.9 and b == 0 ) then
		return "Neutral";
	elseif ( r > 0.9 and g == 0 and b == 0 ) then
		return "Hostile";
	elseif ( g > 0.9 and r == 0 and b == 0 ) then
		return "PvP-Friendly";
	elseif ( b > 0.9 and r == 0 and g == 0 ) then
		return "Friendly";
	else
		return "Hostile-Player" -- Only hostile/neutral players can have class colours.
	end
end

function NamePlate:SetBlizzPlateStructure(blizzPlate)

    if not blizzPlate.UnitFrame or blizzPlate.hooked then return end

    blizzPlate.hooked = true

	-- Get castbar and healthbar of a nameplate:
	local healthBar = blizzPlate.UnitFrame.healthBar;
	local castBar = blizzPlate.UnitFrame.castBar

	-- Secure hook scripts:
	healthBar:HookScript("OnValueChanged", NamePlateHealthBar_OnValueChanged);
	healthBar:HookScript("OnMinMaxChanged", NamePlateHealthBar_OnValueChanged);
	castBar:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged);
	castBar:HookScript("OnMinMaxChanged", NamePlateCastBar_OnValueChanged);
	castBar:HookScript("OnShow", NamePlateCastBar_OnValueChanged);
	castBar:HookScript("OnHide", NamePlateCastBar_OnValueChanged);

end

function NamePlate:CreateNamePlate(blizzPlate)
	local id = string.match(blizzPlate:GetName(), "^NamePlate(%d+)$");
	local namePlate = CreateFrame("Frame", "ArenaLiveNamePlate"..id, blizzPlate, "ArenaLiveSpectatorNamePlateTemplate");
	self.namePlates[blizzPlate] = namePlate;
	ArenaLive:ConstructHandlerObject(namePlate, "NamePlate", addonName, "NamePlate");

	blizzPlate:HookScript("OnUpdate", function()
        if blizzPlate.UnitFrame then
            if namePlate.enabled then
                blizzPlate.UnitFrame:SetAlpha(0)
                --blizzPlate.UnitFrame.healthBar.border:SetAlpha(0)
                for i=1, select("#", blizzPlate.UnitFrame.healthBar:GetRegions()) do
                    select(i, blizzPlate.UnitFrame.healthBar:GetRegions()):SetAlpha(0)
                end
                blizzPlate.UnitFrame.castBar:SetAlpha(0)
            else
                blizzPlate.UnitFrame:SetAlpha(1)
                blizzPlate.UnitFrame.healthBar:SetAlpha(1)
                for i=1, select("#", blizzPlate.UnitFrame.healthBar:GetRegions()) do
                    select(i, blizzPlate.UnitFrame.healthBar:GetRegions()):SetAlpha(1)
                end
                blizzPlate.UnitFrame.castBar:SetAlpha(1)
            end
        end
    end)
end

function NamePlate:UpdateAll()
	if ( self.enabled ) then
		for _, namePlate in pairs(NamePlate.namePlates) do
			NamePlate:UpdateNamePlate(namePlate);
		end
	end
end

function NamePlate:UpdateNamePlate(namePlate)
	local blizzPlate = namePlate:GetParent();
	if not blizzPlate.UnitFrame then return end

	namePlate:UpdateUnit(namePlate.unit);
	namePlate:Update();
end

function NamePlate:OnEvent(event, ...)
	local unit = ...;
	if ( ( event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_PREDICTION" ) ) then
		for blizzPlate, namePlate in pairs(self.namePlates) do
			if ( unit == namePlate.unit ) then
				HealthBar:Update(namePlate);
			end
		end
    elseif ( event == "PLAYER_TARGET_CHANGED" ) then
        for blizzPlate, namePlate in pairs(self.namePlates) do
            namePlate:UpdateAppearance();
        end
	elseif ( event == "UNIT_AURA" ) then
		for blizzPlate, namePlate in pairs(self.namePlates) do
			if ( unit == namePlate.unit ) then
                CCIndicator:UpdateCache("UNIT_AURA", unit, namePlate);
				CCIndicator:Update(namePlate);
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        NamePlate:Enable();
    elseif ( event == "NAME_PLATE_CREATED" ) then
        local unitFrame = ...
        self:CreateNamePlate(unitFrame);
        --ArenaLiveNamePlatesFrame:CrawlNamePlateData(unitFrame)
    elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then
        local unit = ... -- nameplate1
        local unitFrame = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        self:SetBlizzPlateStructure(unitFrame);
        unitFrame.unit = unit
        local namePlate = self.namePlates[unitFrame];
        namePlate:UpdateUnit(unit);
        namePlate:Update();
    elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then
        local unit = ... -- nameplate1
        local unitFrame = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        unitFrame.unit = nil
        local namePlate = self.namePlates[unitFrame];
        namePlate:UpdateUnit(nil);
        namePlate:Update();
    elseif (event == "ADDON_LOADED" ) then
        local addonName = ...
        if addonName == "BigDebuffs" then
            hooksecurefunc(BigDebuffs, "UNIT_AURA_NAMEPLATE", function(frame, unit)
                for blizzPlate, namePlate in pairs(self.namePlates) do
                    if ( unit == namePlate.unit ) then
                        CCIndicator:Update(namePlate);
                    end
                end
            end)
        end
	end
end

--[[
****************************************
******* CLASS METHODS START HERE *******
****************************************
]]--
function NamePlateClass:Enable()
	local blizzPlate = self:GetParent();
	
	self:Show();
	self.enabled = true;
	
	NamePlate:UpdateNamePlate(self);
end

function NamePlateClass:Disable()
	local blizzPlate = self:GetParent();

	self:Hide();
	self.enabled = false;
	
	self:Reset();
end

function NamePlateClass:Update()
	if ( self.enabled ) then
		self:UpdateCastBar();
		if self.unit then
		    CCIndicator:UpdateCache("UNIT_AURA", self.unit, self)
		    CCIndicator:Update(self);
		else
            CCIndicator:Reset(self)
        end
		self:UpdateClassIcon();
		self:UpdateHealthBar();
		self:UpdateNameText()
	end
end

function NamePlateClass:UpdateAppearance()
	local blizzPlate = self:GetParent();
	local database = ArenaLive:GetDBComponent(addonName);
	local inInstance, gameType = IsInInstance()
    local isInPvP = isInPvP()
    local isPlayer = self.unit and UnitIsPlayer(self.unit)

	if ( isInPvP and self.unit and isPlayer ) then
		self:SetSize(188, 52);
        if ( self.unit and UnitGUID(self.unit) == UnitGUID("target") ) then
            self:SetScale(NAMEPLATE_TARGET_SIZE);
        else
            self:SetScale(NAMEPLATE_SIZE);
        end
		
		self.classIcon:Show();

		-- we need minimum 81.25% of the original height of the texture to display it, as in 104 of 128 pixels
        -- because textures get stretched, that means we need to display 416 (81.25%) pixel in width
        self.border:SetTexture("Interface\\AddOns\\ArenaLiveNamePlates3\\Textures\\PlayerNamePlateBig");
        self.border:SetTexCoord(0.09875, 0.90125, 0.125, 0.9375);
		
		self.HealthBar:ClearAllPoints();
        self.HealthBar:SetWidth(120)
        self.HealthBar:SetPoint("TOPLEFT", self.classIcon, "TOPRIGHT", 0, 4);

        self.castBar:ClearAllPoints();
        self.castBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 58, 16);

	    --[[
		local role = ArenaLiveSpectator.UnitCache:GetUnitRole(self.unit);
		if ( role == "HEALER" ) then
			self.healerIcon:Show();
		else
			self.healerIcon:Hide();
		end
        ]]

        -- FIXME
        self.healerIcon:Hide();
	else
		self:SetSize(137, 22);
		if ( self.unit and UnitGUID(self.unit) == UnitGUID("target") ) then
            self:SetScale(NAMEPLATE_TARGET_SIZE);
        else
            self:SetScale(NAMEPLATE_SIZE);
        end

		self.classIcon:Hide();
		CCIndicator:Reset(self);

		self.border:SetTexture("Interface\\AddOns\\ArenaLiveNamePlates3\\Textures\\NamePlateBorder");
		self.border:SetTexCoord(0.28125, 0.81640625, 0.2421875, 0.5859375);

		self.HealthBar:ClearAllPoints();
		self.HealthBar:SetWidth(125)
		self.HealthBar:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -2);

		self.castBar:ClearAllPoints();
		self.castBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 0);
		
		self.healerIcon:Hide();
	end
	
	-- Set border colour:
	if ( self.unit ) then
		local unitType = string.match(self.unit, "^([a-z]+)[0-9]+$") or self.unit;
        local red, green, blue = UnitSelectionColor(self.unit);
        self.border:SetVertexColor(red, green, blue);
	elseif blizzPlate.UnitFrame then
		local red, green, blue = blizzPlate.UnitFrame.healthBar:GetStatusBarColor();
		self.border:SetVertexColor(red, green, blue);
	end
end

function NamePlateClass:UpdateCastBar()
	local blizzPlate = self:GetParent();
	if not blizzPlate.UnitFrame then return end

	if ( blizzPlate.UnitFrame.castBar:IsShown() ) then
		if ( not self.castBar:IsShown() ) then
			self.castBar:Show();
		end
		
		local minValue, maxValue = blizzPlate.UnitFrame.castBar:GetMinMaxValues();
		local value = blizzPlate.UnitFrame.castBar:GetValue();
		local texture = blizzPlate.UnitFrame.castBar.Icon:GetTexture();
		local spellName = blizzPlate.UnitFrame.castBar.Text:GetText();
		
		-- Prevent Division by zero:
		if ( maxValue == 0 ) then
			maxValue = 1;
		end		
		
		local red, green, blue = 1, 0.7, 0;
		if ( blizzPlate.UnitFrame.castBar.BorderShield:IsShown() ) then
			red, green, blue = 0, 0.49, 1;
		end
		
		self.castBar:SetStatusBarColor(red, green, blue);
		self.castBar:SetMinMaxValues(minValue, maxValue);
		self.castBar:SetValue(value);
		self.castBar.icon:SetTexture(texture);
		self.castBar.text:SetText(spellName);
	elseif ( self.castBar:IsShown() ) then
		self.castBar:Hide();
	end
end

function NamePlateClass:UpdateClassIcon()
    local inInstance, gameType = IsInInstance()
    local isInPvP = isInPvP()

	if ( isInPvP and self.unit and UnitIsPlayer(self.unit) ) then
		local _, class = UnitClass(self.unit);
		self.classIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]));
		self.classIcon:Show();
	else
		self.classIcon:Hide();
	end
end

function NamePlateClass:UpdateHealthBar()
	local blizzPlate = self:GetParent();
	if not blizzPlate.UnitFrame then return end
	
	-- Set class color if possible:
	local red, green, blue = blizzPlate.UnitFrame.healthBar:GetStatusBarColor();
	if ( self.unit ) then
		HealthBar:Update(self);
		if ( not UnitIsPlayer(self.unit) ) then
			-- A player's pet, use team colour instead:
			local database = ArenaLive:GetDBComponent(addonName);
			local unitType = string.match(self.unit, "^([a-z]+)[0-9]+$") or self.unit;
			self.HealthBar:SetStatusBarColor(red, green, blue);
		end
	else
		local minValue, maxValue = blizzPlate.UnitFrame.healthBar:GetMinMaxValues();
		local value = blizzPlate.UnitFrame.healthBar:GetValue();
		
		-- Prevent Division by zero:
		if ( maxValue == 0 ) then
			maxValue = 1;
		end
		
		HealthBar:Reset(self);
		self.HealthBar:SetStatusBarColor(red, green, blue);
		self.HealthBar:SetMinMaxValues(minValue, maxValue);
		self.HealthBar:SetValue(value);
	end
	
end

function NamePlateClass:UpdateNameText()
	local blizzPlate = self:GetParent();
	if not blizzPlate.UnitFrame then return end

	local name;
	if ( self.unit ) then
		name = NameText:GetNickname(self.unit) or UnitName(self.unit) or blizzPlate.UnitFrame.name:GetText();
	else
		name = blizzPlate.UnitFrame.name:GetText();
	end
	
	self.nameText:SetText(name);
end

function NamePlateClass:Reset()
	if ( self.enabled ) then
		self.castBar:Hide();
		CCIndicator:Reset(self);
		self.classIcon:SetTexCoord(0, 1, 0, 1);
		HealthBar:Reset(self);
		self.nameText:SetText("");
	end
end

function NamePlateClass:UpdateUnit(unit)
    local inInstance, gameType = IsInInstance()
    local isInPvP = isInPvP()

    self.unit = unit;
    if ( unit and isInPvP and UnitIsPlayer(unit) ) then
        self.CCIndicator.enabled = true;
    else
        self.CCIndicator.enabled = nil;
    end
	self:UpdateAppearance();
end

function NamePlateClass:OnShow()
	if ( self.enabled ) then
		NamePlate:UpdateNamePlate(self);
	end
end