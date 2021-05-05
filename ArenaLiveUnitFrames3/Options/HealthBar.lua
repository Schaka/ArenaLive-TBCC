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
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("HealthBar");
Page.title = L["HealthBar"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameHealthBar";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["EnableAbsorb"], addonName, "HealthBar", "EnableAbsorb", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarEnableAbsorb);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["EnablePredictedHeal"], addonName, "HealthBar", "EnablePredictedHeal", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarEnablePredictedHeal);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ReverseFill"], addonName, "HealthBar", "ReverseFill", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ColourMode"], addonName, "HealthBar", "ColourMode", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarColourMode);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Text"], addonName, "HealthBarText", "Text", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarText);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["TextSize"], addonName, "HealthBarText", "TextSize", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameHealthBarTextSize);
	Page:Hide();
end

function Page:Show()
	local activeGroup = self:GetActiveFrameGroup();
	if ( activeGroup == "TargetTargetFrame" or activeGroup == "FocusTargetFrame" ) then
		ALUF_UnitFrameOptionsHandlerFrameHealthBarEnableAbsorb:Hide();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarEnablePredictedHeal:Hide();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarColourMode:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarText:Hide();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarTextSize:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:ClearAllPoints();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:SetPoint(optionFrames.EnableAbsorb.point, optionFrames.EnableAbsorb.relativeTo, optionFrames.EnableAbsorb.relativePoint, optionFrames.EnableAbsorb.xOffset, optionFrames.EnableAbsorb.yOffset);
	else
		ALUF_UnitFrameOptionsHandlerFrameHealthBarEnableAbsorb:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarEnablePredictedHeal:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarColourMode:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarText:Show();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarTextSize:Show();
		
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:ClearAllPoints();
		ALUF_UnitFrameOptionsHandlerFrameHealthBarReverseFill:SetPoint(optionFrames.ReverseFill.point, optionFrames.ReverseFill.relativeTo, optionFrames.ReverseFill.relativePoint, optionFrames.ReverseFill.xOffset, optionFrames.ReverseFill.yOffset);
	end
end

optionFrames = {
	["EnableAbsorb"] = {
		["name"] = prefix.."EnableAbsorb",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["EnablePredictedHeal"] = {
		["name"] = prefix.."EnablePredictedHeal",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."EnableAbsorbText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["ReverseFill"] = {
		["name"] = prefix.."ReverseFill",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."EnableAbsorb",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["ColourMode"] = {
		["name"] = prefix.."ColourMode",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ReverseFill",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -15,
		["yOffset"] = -20,
	},
	["Text"] = {
		["name"] = prefix.."Text",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ColourMode",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 15,
		["yOffset"] = -20,
	},
	["TextSize"] = {
		["name"] = prefix.."TextSize",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Text",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -15,
		["yOffset"] = -20,
	},
};