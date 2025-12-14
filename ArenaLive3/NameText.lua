--[[ ArenaLive Core Functions: Name Text Handler
Created by: Vadrak
Creation Date: 09.04.2014
Last Update: 17.05.2014
This file contains all relevant functions for name font strings and nicknames.
Basically nicknames are names for players that are displayed instead of their charactername.
They are mainly used in ArenaLive [Spectator] in order to show the known names of tournament players instead
of their char names, which are often different from their nicknames in the community.
	TODO: Make Text Size changeable
	TODO: Find a way to use alternative fonts for new created font instances.
]]--

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
]]--
function NameText:ConstructObject(nameText)

	ArenaLive:CheckArgs(nameText, "FontString");
	
	-- Set initial font size:
	--NameText:SetFontSize(nameText)
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
		name = GetUnitName(unit);
	end

	name = NameText:GetNickname(unit) or name;
	
	-- Check if unit is AFK or DND (Cool suggestion by Nick lul).
	if ( UnitIsAFK(unit) ) then
		tag = L["<AFK>"];
	elseif ( UnitIsDND(unit) ) then
		tag = L["<DND>"];
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
		if ( not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) ) then
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

function NameText:AddNickname(keyName, nickname)
	ArenaLive:CheckArgs(keyName, "string", nickname, "string");
	
	displayedNames[keyName] = nickname;
	
	ArenaLive:Message(L["Added nickname %s for player %s"], "debug", nickname, keyName);
end

function NameText:RemoveNickname(keyName)
	ArenaLive:CheckArgs(keyName, "string");
	
	if ( displayedNames[keyName] ) then
		displayedNames[keyName] = nil;
	else
		ArenaLive:Message(L["Couldn't remove nickname for player %s, because there is no nickname registered for this player!"], "error", keyName);
	end
	
	ArenaLive:Message(L["Removed nickname for player %s"], "debug", keyName);
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