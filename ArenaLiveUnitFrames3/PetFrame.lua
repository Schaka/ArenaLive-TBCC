--[[
    ArenaLive [UnitFrames] is an unit frame addon for World of Warcraft.
    Copyright (C) 2015  Harald Böhm <harald@boehm.agency>

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

local addonName = ...;
local L = ArenaLiveUnitFrames.L;

function ALUF_PetFrame:Initialise()

	local prefix = self:GetName();
	ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "PetFrame", "target", "togglemenu");
	
	-- Register Frame constituents:
	self:RegisterHandler(_G[prefix.."Border"], "Border");
	self:RegisterHandler(_G[prefix.."Flash"], "ThreatIndicator", "target");
	self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "PetFrame");
	self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "PetFrame");
	self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
	self:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
	self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
	self:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, self);
	self:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, self);
	self:RegisterHandler(_G[prefix.."AuraFrame"], "Aura", nil, _G[prefix.."AuraFrameBuffFrame"], _G[prefix.."AuraFrameDebuffFrame"]);
	
	-- Update Constituent positions and border colours:
	ArenaLiveUnitFrames:UpdateFrameBorders(self);
	self:UpdateElementPositions();
end

function ALUF_PetFrame:UpdateElementPositions()
	ArenaLiveUnitFrames:SetFramePositions(self);
end

function ALUF_PetFrame:OnEnable()
	self:UpdateUnit("pet");
	
	-- Disable Blizzard's PetFrame:
	PetFrame:UnregisterAllEvents();
	PetFrame:Hide();
end

function ALUF_PetFrame:OnDisable()
	-- Check if we've disabled Blizzard's PetFrame by checking for a registered event:
	if ( not PetFrame:IsEventRegistered("UNIT_PET") ) then
		-- Suggest UI Reload if we disabled Blizzard's PetFrame before, because we tainted it by disabling it and won't work correctly until the UI reload.
		StaticPopup_Show("ALUF_CONFIRM_RELOADUI");
		local onLoad = PetFrame:GetScript("OnLoad");
		onLoad(PetFrame);
	end
end