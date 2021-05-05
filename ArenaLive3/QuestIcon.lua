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
local QuestIcon = ArenaLive:ConstructHandler("QuestIcon", true, false, false);
QuestIcon:SetHandlerClass("IndicatorIcon");

QuestIcon:RegisterEvent("UNIT_CLASSIFICATION_CHANGED");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function QuestIcon:GetTexture (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end

    -- TODO: do we even want to fix this?
	if ( false and UnitIsQuestBoss(unit) ) then
		return "Interface\\TargetingFrame\\PortraitQuestBadge", 0, 1, 0, 1;
	else
		return nil, 0, 1, 0, 1;
	end	
end

function QuestIcon:GetShown (unitFrame)
	
	local unit = unitFrame.unit;
	if ( not unit ) then
		return false;
	end

    -- TODO: do we even want to fix this?
	if ( false and  UnitIsQuestBoss(unit) ) then
		return true;
	else
		return false;
	end	
end

function QuestIcon:OnEvent(event, ...)
	if ( event == "UNIT_CLASSIFICATION_CHANGED" ) then
		local unit = ...;
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id, unitFrame in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					self:Update(unitFrame);
				end
			end
		end
	end
end