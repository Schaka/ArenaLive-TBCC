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
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("DRTracker");
Page.title = L["DRTracker"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameDRTracker";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "DRTracker", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameDRTrackerEnabled);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Direction"], addonName, "DRTracker", "Direction", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameDRTrackerDirection);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Size"], addonName, "DRTracker", "Size", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameDRTrackerSize);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShownIcons"], addonName, "DRTracker", "ShownIcons", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameDRTrackerShownIcons);
	Page:Hide();
end

optionFrames = {
	["Enable"] = {
		["name"] = prefix.."Enabled",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["Direction"] = {
		["name"] = prefix.."Direction",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
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
};