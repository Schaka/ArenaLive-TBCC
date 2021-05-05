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

local function frameInitFunc(frame)
	local prefix = frame:GetName();
	local id = frame:GetID();
	
	-- Initialise unit frame:
	frame:RegisterHandler(_G[prefix.."Name"], "NameText", nil, frame);
	frame:RegisterHandler(_G[prefix.."Border"], "Border");
	frame:RegisterHandler(_G[prefix.."HealthBar"], "HealthBar", nil, _G[prefix.."HealthBarHealPredictionBar"], _G[prefix.."HealthBarAbsorbBar"], _G[prefix.."HealthBarAbsorbBarOverlay"], 32, _G[prefix.."HealthBarAbsorbBarFullHPIndicator"], nil, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."HealthBarText"], "HealthBarText", nil, frame);
	frame:RegisterHandler(_G[prefix.."PowerBar"], "PowerBar", nil, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."PowerBarText"], "PowerBarText", nil, frame);
	frame:RegisterHandler(_G[prefix.."Icon1"], "Icon", 1, _G[prefix.."Icon1Texture"],_G[prefix.."Icon1Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Icon2"], "Icon", 2, _G[prefix.."Icon2Texture"], _G[prefix.."Icon2Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Icon3"], "Icon", 3, _G[prefix.."Icon3Texture"], _G[prefix.."Icon3Cooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."Portrait"], "Portrait", _G[prefix.."PortraitBackground"], nil, _G[prefix.."PortraitTexture"],  _G[prefix.."PortraitThreeD"], frame);
	frame:RegisterHandler(_G[prefix.."PortraitCCIndicator"], "CCIndicator", nil, _G[prefix.."PortraitCCIndicatorTexture"], _G[prefix.."PortraitCCIndicatorCooldown"], addonName);
	frame:RegisterHandler(_G[prefix.."CastBar"], "CastBar", nil, _G[prefix.."CastBarIcon"], _G[prefix.."CastBarText"], _G[prefix.."CastBarBorderShieldGlow"], _G[prefix.."CastBarAnimation"], _G[prefix.."CastBarAnimationFadeOut"], true, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."CastHistory"], "CastHistory");
	frame:RegisterHandler(_G[prefix.."DRTracker"], "DRTracker", nil, addonName, "ArenaEnemyFrames");
	frame:RegisterHandler(_G[prefix.."TargetIndicator"], "TargetIndicator");
	
	ArenaLiveUnitFrames:UpdateCastBarDisplay(frame);
	
	ArenaLiveUnitFrames:UpdateFrameBorders(frame);

end

function ALUF_ArenaEnemyFrames:Initialise()
	ArenaLive:ConstructHandlerObject(self, "ArenaHeader", "ALUF_ArenaEnemyFrameTemplate", frameInitFunc, addonName, "ArenaEnemyFrames");
	ALUF_ArenaEnemyFrames:UpdateElementPositions();
end

function ALUF_ArenaEnemyFrames:UpdateElementPositions()
	for i = 1, 5 do
		ArenaLiveUnitFrames:SetFramePositions(self["Frame"..i]);
	end
end


-- Fix for position/attachement option menu:
ALUF_ArenaEnemyFrames.UnitFrame = true;
ALUF_ArenaEnemyFrames.CastBar = true;
ALUF_ArenaEnemyFrames.CastHistory = true;
ALUF_ArenaEnemyFrames.DRTracker = true;