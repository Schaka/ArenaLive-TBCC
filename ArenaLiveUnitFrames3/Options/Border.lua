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
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("Border");
Page.title = L["Border"];
local Border = ArenaLive:GetHandler("Border");
local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameBorder";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "Border", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameBorderEnabled);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Colour"], addonName, "Border", "Colour", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameBorderColour);
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
		["postUpdate"] = function (frame, newValue, oldValue)
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then
					unitFrame:ToggleHandler(Border.name);
					ArenaLiveUnitFrames:UpdateFrameBorders(unitFrame);
				end
			end
		end,
	},
	["Colour"] = {
		["name"] = prefix.."Colour",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 3,
		["yOffset"] = -5,
		["postUpdate"] = function (frame, newValue, oldValue) 
			for id, unitFrame in ArenaLive:GetAllUnitFrames() do 
				if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then 
					Border:Update(unitFrame);
					ArenaLiveUnitFrames:UpdateFrameBorders(unitFrame);
				end
			end
		end,
	},
};