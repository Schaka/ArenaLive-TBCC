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
local LevelText = ArenaLive:ConstructHandler("LevelText", true, false, false);

-- Register the handler for all needed events.
LevelText:RegisterEvent("UNIT_LEVEL");
LevelText:RegisterEvent("UNIT_FACTION");
LevelText:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type health bar.
		levelText (FontString): The font string that is going to be set up as level text.
		highLevelTexture (texture [optional]): A texture that is shown for high level unit's instead of ??.
		formatText (string [optional]): A string that the unit's level will be embeded in via string.format.
]]--
function LevelText:ConstructObject (levelText, highLevelTexture, formatText)

	ArenaLive:CheckArgs(levelText, "FontString");
	
	-- Set references:
	levelText.highLevelTexture = highLevelTexture;
	levelText.formatText = formatText;
	
end

local colour;
function LevelText:Update (unitFrame)

	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return;
	end
	
	local levelText = unitFrame[self.name];
	local level, levelMod;
	local classification = UnitClassification(unit);
	local red, green, blue;

	-- Find the correct text for the unit's level:
	if ( unitFrame.test ) then
		level = ArenaLive.testModeValues[unitFrame.test]["level"];
	elseif ( UnitIsCorpse(unit) ) then
		level = "??";
	else
		level = UnitLevel(unit);
		if ( level <= 0 ) then
			-- Target is too high level to tell
			level = "??";
		end
	end
	
	-- Set the colour for the level text according to the level difference:
	if ( level == "??" ) then
		red, green, blue = 1, 0, 0;
	elseif ( UnitCanAttack("player", unit) ) then
		colour =  GetQuestDifficultyColor(level);
		red, green, blue = colour.r, colour.g, colour.b;
	else
		red, green, blue = 1.0, 0.82, 0.0;
	end
	
	-- Set level modifier to reflect elite/rare mobs:
	if ( classification == "worldboss" or classification == "elite" ) then
		levelMod = "+";
	elseif ( classification == "rareelite" ) then
		levelMod = "R+";
	elseif ( classification == "rare" ) then
		levelMod = "R";
	else
		levelMod = "";
	end	
	
	-- Combine modifier and text if app appropriate:
	if ( level ~= "??" ) then
		level = level..levelMod;

		if ( levelText.highLevelTexture ) then
			levelText.highLevelTexture:Hide();
		end
	else
		-- Hide text, if there is a high level texture that should replace it:
		if ( levelText.highLevelTexture ) then
			levelText:Hide();
			levelText.highLevelTexture:Show();
			return;
		end
	end

	levelText:SetTextColor(red, green, blue);
	
	-- Apply the text template if there is one:
	if ( levelText.formatText ) then
		level = string.format(levelText.formatText, level);
	end
	
	levelText:SetText(level);	
	
	levelText:Show();
end

function LevelText:Reset(unitFrame)
	local levelText = unitFrame[self.name];
	levelText:SetText("");
	levelText:Hide();
	if ( levelText.highLevelTexture ) then
		levelText.highLevelTexture:Hide();
	end

end

function LevelText:OnEvent(event, ...)
	local unit = ...;
	if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
		for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
			local unitFrame = ArenaLive:GetUnitFrameByID(id);
			if ( unitFrame[self.name] ) then
				LevelText:Update(unitFrame);
			end
		end
	end
end