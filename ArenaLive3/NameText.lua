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
-- Create new Handler and register for all important events:
local NameText = ArenaLive:ConstructHandler("NameText", true, false);
NameText:RegisterEvent("UNIT_NAME_UPDATE");
NameText:RegisterEvent("UNIT_FACTION");
NameText:RegisterEvent("PLAYER_FLAGS_CHANGED");

-- Create a local table for name aliases
local displayedNames = {};

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new name text font string.
		nameText (FontString): The FontString object that is going to be set up as a name text.
		unitFrame (Button): The name text's parent that contains addon name, frame group etc.
]]--
function NameText:ConstructObject(nameText, unitFrame, hideAFKAndDND, hideRealm)

	ArenaLive:CheckArgs(nameText, "FontString", unitFrame, "Button");
	
	nameText.hideAFKAndDND = hideAFKAndDND;
	nameText.hideRealm = hideRealm;	
	
	-- Set initial text object:
	NameText:SetTextObject(unitFrame);
end

function NameText:Update (unitFrame)

	local unit = unitFrame.unit;
	local name;
	local tag;
	
	if ( not unit ) then
		return;
	end
	
	local nameText = unitFrame[self.name];
	
	if ( unitFrame.test ) then
		name = ArenaLive.testModeValues[unitFrame.test]["name"];
	else
		if ( nameText.hideRealm ) then
			name = UnitName(unit);
		else
			name = GetUnitName(unit);
		end
	end

	name = NameText:GetNickname(unit) or name;
	
	-- Check if unit is AFK or DND (Cool suggestion by Nick lel).
	if ( not nameText.hideAFKAndDND ) then
		if ( UnitIsAFK(unit) ) then
			tag = L["<AFK>"];
		elseif ( UnitIsDND(unit) ) then
			tag = L["<DND>"];
		end
	end
	
	NameText:SetColour(unitFrame);
	
	if ( tag ) then
		nameText:SetText(tag..name);
	else
		nameText:SetText(name);
	end

end

function NameText:Reset(unitFrame)
	local nameText = unitFrame[self.name];
	nameText:SetText();
end

function NameText:SetColour(unitFrame)
		
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return;
	end

	local nameText = unitFrame[self.name];
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local colourMode = database.ColourMode;	
	
	local isPlayer = UnitIsPlayer(unit);
	local red, green, blue = 1, 1, 1;
	if ( colourMode == "class" and ( isPlayer or unitFrame.test ) ) then
		local _, class;
		if ( unitFrame.test ) then
			class = ArenaLive.testModeValues[unitFrame.test]["class"];
		else
			_, class = UnitClass(unit);
		end
		
		if ( class ) then
			red, green, blue = RAID_CLASS_COLORS[class]["r"], RAID_CLASS_COLORS[class]["g"], RAID_CLASS_COLORS[class]["b"];
		end	
	
	elseif ( colourMode == "reaction" or not isPlayer ) then
	
		red, green, blue = UnitSelectionColor(unit);
		
		-- If the unit is a NPC that was tapped by another person, I reflect that in the name colour by colouring it grey.
		if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
			red = 0.5;
			green = 0.5;
			blue = 0.5;
		else
			-- Blue names are very hard to read, so switch to plain white. math.ceil for blue because the colour isn't exactly 1, but 0,999... 
			if ( red == 0 and green == 0 and blue > 0.9 ) then
				red = 1;
				green = 1;
				blue = 1;
			end
			
		end
	end
	
	nameText:SetTextColor(red, green, blue);	
end

function NameText:SetTextObject(unitFrame)
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local nameText = unitFrame[self.name];
	nameText:SetFontObject(database.FontObject);
end

function NameText:AddNickname(keyName, nickname)
	ArenaLive:CheckArgs(keyName, "string", nickname, "string");
	
	displayedNames[keyName] = nickname;
	
	ArenaLive:Message("Added nickname %s for player %s", "debug", nickname, keyName);
	
	-- Update all unit frames
	for id, unitFrame in ArenaLive:GetAllUnitFrames() do
		if ( unitFrame.enabled and unitFrame[self.name] ) then
			NameText:Update(unitFrame);
		end
	end
end

function NameText:RemoveNickname(keyName)
	ArenaLive:CheckArgs(keyName, "string");
	
	if ( displayedNames[keyName] ) then
		displayedNames[keyName] = nil;
		
		-- Update all unit frames
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame.enabled and unitFrame[self.name] ) then
				NameText:Update(unitFrame);
			end
		end
		
		ArenaLive:Message("Removed nickname for player %s", "debug", keyName);
	else
		ArenaLive:Message("Couldn't remove nickname for player %s, because there is no nickname registered for this player!", "debug", keyName);
	end

end


function NameText:GetNickname(unit, keyName)
	
	local name, realm;
	if ( unit ) then
		name, realm = UnitName(unit);
	
		if ( not name ) then
			return nil;
		end
	
		if ( not realm or realm == "" ) then
			realm = GetRealmName();
		end
	
		name = name.."-"..realm;
	else
		ArenaLive:CheckArgs(keyName, "string");
		name = keyName;
	end
	
	return displayedNames[name];	
	
end

function NameText:OnEvent(event, ...)
	local unit = ...;
	if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
		for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
			local unitFrame = ArenaLive:GetUnitFrameByID(id);
			if ( unitFrame[self.name] ) then
				NameText:Update(unitFrame);
			end
		end
	end
end

NameText.optionSets = {
	["ColourMode"] = {
		["type"] = "DropDown",
		["title"] = L["Colour Mode"],
		["tooltip"] = L["Sets the colour mode of the name text."],
		["infoTable"] = {
			[1] = {
				["value"] = "none",
				["text"] = L["None"],
			},
			[2] = {
				["value"] = "class",
				["text"] = L["Class Colour"],
			},
			[3] = {
				["value"] = "reaction",
				["text"] = L["Reaction Colour"],
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.ColourMode; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.ColourMode = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then NameText:SetColour(unitFrame); end end end,
	},
	["TextSize"] = {
		["type"] = "DropDown",
		["title"] = L["Text Size"],
		["tooltip"] = L["Sets the size of the name text."],
		["infoTable"] = {
			[1] = {
				["value"] = "ArenaLiveFont_NameVeryLarge",
				["text"] = L["Very Large"],
				["fontObject"] =  "ArenaLiveFont_NameVeryLarge",
			},
			[2] = {
				["value"] = "ArenaLiveFont_NameLarge",
				["text"] = L["Large"],
				["fontObject"] =  "ArenaLiveFont_NameLarge",
			},
			[3] = {
				["value"] = "ArenaLiveFont_Name",
				["text"] = L["Normal"],
				["fontObject"] =  "ArenaLiveFont_Name",
			},
			[4] = {
				["value"] = "ArenaLiveFont_NameSmall",
				["text"] = L["Small"],
				["fontObject"] =  "ArenaLiveFont_NameSmall",
			},
			[5] = {
				["value"] = "ArenaLiveFont_NameVerySmall",
				["text"] = L["Very Small"],
				["fontObject"] =  "ArenaLiveFont_NameVerySmall",
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.FontObject; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.FontObject = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[frame.handler] ) then NameText:SetTextObject(unitFrame); end end end,
	},
};