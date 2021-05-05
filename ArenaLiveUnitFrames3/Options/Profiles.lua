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

local prefix = "ALUF_ProfileOptions";
local optionFrames;
local Profiles = ArenaLive:GetHandler("Profiles");

function ALUF_ProfileOptions:Initialise()
	ALUF_ProfileOptionsTitle:SetText(L["ArenaLive [UnitFrames] Profile Options:"]);
	ALUF_ProfileOptions.name = L["Profiles"];
	ALUF_ProfileOptions.parent = L["ArenaLive [UnitFrames]"];
	InterfaceOptions_AddCategory(ALUF_ProfileOptions);
	
	Profiles:ConstructActiveProfileDropDown(addonName, optionFrames["ActiveProfile"]);
	Profiles:ConstructCopyProfileDropDown(addonName, optionFrames["CopyProfile"]);
	Profiles:ConstructCreateNewProfileFrame(addonName, optionFrames["CreateProfile"]);
	ArenaLive:ConstructOptionFrame(optionFrames["DeleteActiveProfile"], addonName);
end

function ALUF_ProfileOptions:ToggleDeleteProfileButton()
	if ( ArenaLiveUnitFrames.database.ActiveProfile == "default" ) then
		ALUF_ProfileOptionsDeleteActiveProfile:Disable();
	else
		ALUF_ProfileOptionsDeleteActiveProfile:Enable();
	end
end

optionFrames = {
	["ActiveProfile"] = {
		["name"] = prefix.."ActiveProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -10,
		["yOffset"] = -25,
		["width"] = 250,
	},
	["CopyProfile"] = {
		["name"] = prefix.."CopyProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "TOPRIGHT",
		["xOffset"] = 0,
		["yOffset"] = 0,
		["width"] = 250,
	},
	["CreateProfile"] = {
		["name"] = prefix.."CreateProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -25,
	},
	["DeleteActiveProfile"] = {
		["name"] = prefix.."DeleteActiveProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."CreateProfile",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -25,
		["type"] = "Button",
		["title"] = L["Delete Active Profile"],
		["func"] = function(frame) local profileName = Profiles:GetActiveProfile(addonName); Profiles:DeleteProfile(addonName, profileName); UIDropDownMenu_SetText(ALUF_ProfileOptionsActiveProfile, Profiles:GetActiveProfile(addonName)); end
	},
};