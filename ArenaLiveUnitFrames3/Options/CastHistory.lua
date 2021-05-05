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
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("CastHistory");
Page.title = L["CastHistory"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameCastHistory";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "CastHistory", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryEnable);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowTooltip"], addonName, "CastHistory", "ShowTooltip", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryShowTooltip);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Direction"], addonName, "CastHistory", "Direction", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryDirection);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Size"], addonName, "CastHistory", "Size", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistorySize);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShownIcons"], addonName, "CastHistory", "ShownIcons", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryShownIcons);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Duration"], addonName, "CastHistory", "Duration", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryDuration);
	Page:Hide();
end

optionFrames = {
	["Enable"] = {
		["name"] = prefix.."Enable",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["ShowTooltip"] = {
		["name"] = prefix.."ShowTooltip",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."EnableText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["Direction"] = {
		["name"] = prefix.."Direction",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enable",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -15,
		["yOffset"] = -20,
	},
	["Size"] = {
		["name"] = prefix.."Size",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Direction",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -20,
	},
	["ShownIcons"] = {
		["name"] = prefix.."ShownIcons",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Size",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["Duration"] = {
		["name"] = prefix.."Duration",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ShownIcons",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -1,
		["yOffset"] = -25,
	},
};