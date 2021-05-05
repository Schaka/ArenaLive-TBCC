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
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("PowerBar");
Page.title = L["PowerBar"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFramePowerBar";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ReverseFill"], addonName, "PowerBar", "ReverseFill", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePowerBarReverseFill);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Text"], addonName, "PowerBarText", "Text", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePowerBarText);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["TextSize"], addonName, "PowerBarText", "TextSize", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePowerBarTextSize);
	Page:Hide();
end

function Page:Show()
	ALUF_UnitFrameOptionsHandlerFramePowerBarReverseFill:Show();
	
	local activeGroup = self:GetActiveFrameGroup();
	if ( activeGroup == "TargetTargetFrame" or activeGroup == "FocusTargetFrame" ) then
		ALUF_UnitFrameOptionsHandlerFramePowerBarText:Hide();
		ALUF_UnitFrameOptionsHandlerFramePowerBarTextSize:Hide();
	else
		ALUF_UnitFrameOptionsHandlerFramePowerBarText:Show();
		ALUF_UnitFrameOptionsHandlerFramePowerBarTextSize:Show();
	end
end

optionFrames = {
	["ReverseFill"] = {
		["name"] = prefix.."ReverseFill",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["Text"] = {
		["name"] = prefix.."Text",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ReverseFill",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -15,
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