--[[
    ArenaLive [Core] is an unit frame framework for World of Warcraft.
    Copyright (C) 2014  Harald Böhm <harald@boehm.agency>

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

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler:
local Border = ArenaLive:ConstructHandler("Border");
Border.canToggle = true;


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function Border:OnEnable(unitFrame)
	local border = unitFrame[self.name];
	border:Show();
	Border:Update(unitFrame);
end

function Border:OnDisable(unitFrame)
	local border = unitFrame[self.name];
	border:Hide();
end

function Border:Update(unitFrame)
	local border = unitFrame[self.name];
	
	if ( not border.enabled ) then
		return;
	end
	
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local red = database.Red or 1;
	local green = database.Green or 1;
	local blue = database.Blue or 1;
	border:SetVertexColor(red, green, blue, 1);
end

Border.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the unit frame's border graphic."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then unitFrame:ToggleHandler(Border.name); end end end,
	},
	["Colour"] = {
		["type"] = "ColourPicker",
		["title"] = L["Border Colour"],
		["tooltip"] = L["Set the colour of the unit frame's border graphic."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Red, database.Green, database.Blue; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Red = newValue.red; database.Green = newValue.green; database.Blue = newValue.blue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[Border.name] ) then Border:Update(unitFrame); end end end,
	},
};