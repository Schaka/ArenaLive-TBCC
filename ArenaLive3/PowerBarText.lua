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
-- Create Handler and sat class:
local PowerBarText = ArenaLive:ConstructHandler("PowerBarText");
PowerBarText:SetHandlerClass("StatusBarText");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PowerBarText:GetText(unitFrame)
	local unit = unitFrame.unit;
	if ( not unit ) then
		return "";
	end
	
	local minValue, maxValue, value;
	if ( unitFrame.test ) then
		minValue = 0;
		value = ArenaLive.testModeValues[unitFrame.test]["powerCurr"];
		maxValue = ArenaLive.testModeValues[unitFrame.test]["powerMax"];
	else
		local powerType = UnitPowerType(unit);
		minValue = 0;
		maxValue = UnitPowerMax(unit, powerType);
		value = UnitPower(unit, powerType);
	end

	-- Hide text if max value is 0. Otherwise there would be display errors:
	if ( maxValue == 0 ) then
		return "";
	end

	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local text = database.BarText;
	local showDead = database.ShowDeadOrGhost;
	local showDisconnect = database.ShowDisconnect;
	
	if ( not unitFrame.test and not UnitGUID(unit) ) then
		return "";
	else
		return PowerBarText:FormatText(text, value, maxValue)
	end

end

-- Option frame set ups:
PowerBarText.optionSets = {
	["Text"] = {
		["type"] = "EditBox",
		["width"] = 400,
		["height"] = 24,
		["title"] = L["Shown Powerbar Text"],
		["tooltipTitle"] = L["Powerbar Text:"];
		["tooltip"] = L["Define the text that will be shown in the status bar. \n %PERCENT% = Percent value with 2 decimal digits \n %PERCENT_SHORT% = Percent value \n %CURR% = Current value \n %CURR_SHORT% = Abbreviated current value \n %MAX% = Maximal value \n %MAX_SHORT% = Abbreviated maximal value"],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.BarText; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.BarText = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then PowerBarText:Update(unitFrame); end end end,
	},
	["TextSize"] = {
		["type"] = "DropDown",
		["title"] = L["Text Size"],
		["tooltip"] = L["Sets the size of the powerbar text."],
		["width"] = 125,
		["infoTable"] = {
			[1] = {
				["value"] = "ArenaLiveFont_StatusBarTextVeryLarge",
				["text"] = L["Very Large"],
				["fontObject"] =  "ArenaLiveFont_StatusBarTextVeryLarge",
			},
			[2] = {
				["value"] = "ArenaLiveFont_StatusBarTextLarge",
				["text"] = L["Large"],
				["fontObject"] =  "ArenaLiveFont_StatusBarTextLarge",
			},
			[3] = {
				["value"] = "ArenaLiveFont_StatusBarText",
				["text"] = L["Normal"],
				["fontObject"] =  "ArenaLiveFont_StatusBarText",
			},
			[4] = {
				["value"] = "ArenaLiveFont_StatusBarTextSmall",
				["text"] = L["Small"],
				["fontObject"] =  "ArenaLiveFont_StatusBarTextSmall",
			},
			[5] = {
				["value"] = "ArenaLiveFont_StatusBarTextVerySmall",
				["text"] = L["Very Small"],
				["fontObject"] =  "ArenaLiveFont_StatusBarTextVerySmall",
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.FontObject; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.FontObject = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then PowerBarText:SetTextObject(unitFrame); end end end,
	},
};