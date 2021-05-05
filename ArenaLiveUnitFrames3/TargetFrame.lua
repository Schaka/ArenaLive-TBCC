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

function ALUF_TargetFrame:Initialise()

		local prefix = self:GetName();
		ArenaLive:ConstructHandlerObject(self, "UnitFrame", addonName, "TargetFrame", "target", "togglemenu");
		
		-- Register Frame constituents:
		self:RegisterHandler(_G[prefix.."Border"], "Border");
		self:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "TargetFrame");
		self:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "TargetFrame");
		self:RegisterHandler(_G[prefix.."Icon1"], "Icon", 1, _G[prefix.."Icon1Texture"],_G[prefix.."Icon1Cooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Icon2"], "Icon", 2, _G[prefix.."Icon2Texture"], _G[prefix.."Icon2Cooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Portrait"], "Portrait", nil, _G[prefix.."PortraitBackground"], _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], self);
		self:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
		self:RegisterHandler(_G[prefix.."Name"], "NameText", nil, self);
		self:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, self);
		self:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, self);
		self:RegisterHandler(_G[prefix.."CastBar"], "CastBar", nil, _G[prefix.."CastBarIcon"], _G[prefix.."CastBarText"], _G[prefix.."CastBarBorderShieldGlow"], _G[prefix.."CastBarAnimation"], _G[prefix.."CastBarAnimationFadeOut"], true, addonName, "TargetFrame");
		self:RegisterHandler(_G[prefix.."CastHistory"], "CastHistory");
		self:RegisterHandler(_G[prefix.."AuraFrame"], "Aura", nil, _G[prefix.."AuraFrameBuffFrame"], _G[prefix.."AuraFrameDebuffFrame"]);
		self:RegisterHandler(_G[prefix.."LevelText"], "LevelText", nil , nil, "(%s)");
		self:RegisterHandler(_G[prefix.."ReadyCheck"], "ReadyCheck");
		self:RegisterHandler(_G[prefix.."DRTracker"], "DRTracker", nil, addonName, "TargetFrame");
		self:RegisterHandler(_G[prefix.."ComboFrame"], "ComboFrame", nil, _G[prefix.."ComboFrameComboPoint1"], _G[prefix.."ComboFrameComboPoint2"], _G[prefix.."ComboFrameComboPoint3"], _G[prefix.."ComboFrameComboPoint4"], _G[prefix.."ComboFrameComboPoint5"]);
		
		local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");
		IconGroupHeader:ConstructGroup("ALUF_TargetFrameIconGroup", "LEFT", 0, "TOPRIGHT", _G[prefix.."LevelText"], "TOPLEFT", 1, 2);
		self:RegisterHandler(_G[prefix.."CombatIcon"], "CombatIcon", nil, "ALUF_TargetFrameIconGroup", nil, addonName, "TargetFrame");	 
		self:RegisterHandler(_G[prefix.."LeaderIcon"], "LeaderIcon", nil, "ALUF_TargetFrameIconGroup", nil, addonName, "TargetFrame");
		self:RegisterHandler(_G[prefix.."RaidIcon"], "RaidIcon", nil, "ALUF_TargetFrameIconGroup", nil, addonName, "TargetFrame");

		self:RegisterHandler(_G[prefix.."PvPIcon"], "PvPIcon", nil, nil, nil, addonName, "TargetFrame", _G[prefix.."PvPIconTexture"]);
		self:RegisterHandler(_G[prefix.."QuestIcon"], "QuestIcon", nil, nil, nil, addonName, "TargetFrame");

		-- Update Constituent positions and border colours:
		ArenaLiveUnitFrames:UpdateFrameBorders(self);
		self:UpdateElementPositions();
end

function ALUF_TargetFrame:UpdateElementPositions()
	ArenaLiveUnitFrames:SetFramePositions(self);
end

function ALUF_TargetFrame:OnEnable()
	self:UpdateUnit("target");
	
	-- Disable Blizzard's TargetFrame:
	TargetFrame:UnregisterAllEvents();
	TargetFrame:Hide();
	ComboFrame:UnregisterAllEvents();
	ComboFrame:Hide();
end

function ALUF_TargetFrame:OnDisable()
	-- Check if we've disabled Blizzard's TargetFrame by checking for a registered event:
	if ( not TargetFrame:IsEventRegistered("PLAYER_ENTERING_WORLD") ) then
		-- Suggest UI Reload if we disabled Blizzard's TargetFrame before, because we tainted it by disabling it and won't work correctly until the UI reload.
		StaticPopup_Show("ALUF_CONFIRM_RELOADUI");
		local onLoad = TargetFrame:GetScript("OnLoad");
		onLoad(TargetFrame, "target", TargetFrameDropDown_Initialize);
		onLoad = ComboFrame:GetScript("OnLoad");
		onLoad(ComboFrame);
	end
end