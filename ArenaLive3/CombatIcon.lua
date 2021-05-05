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
local CombatIcon = ArenaLive:ConstructHandler("CombatIcon", false, true);
CombatIcon:SetHandlerClass("IndicatorIcon");

local unitCombatCache = {};
local ON_UPDATE_THROTTLE = 1;
CombatIcon.elapsed = 0;

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function CombatIcon:AddUnitEntry(unit)
	unitCombatCache[unit] = UnitAffectingCombat(unit) or false;
end

function CombatIcon:GetUnitCombatStatus(unit)
	if ( type(unitCombatCache[unit]) == "nil" ) then
		-- Add unit to cache if it wasn't until now:
		self:AddUnitEntry(unit);
	end
	
	return unitCombatCache[unit];
end

function CombatIcon:GetTexture (unitFrame)

	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return;
	end
	
	if ( self:GetUnitCombatStatus(unit) ) then
		return "Interface\\CharacterFrame\\UI-StateIcon", 0.5, 1 , 0, 0.5;
	else
		return nil, 0, 1, 0, 1;
	end

end

function CombatIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	if ( self:GetUnitCombatStatus(unit) ) then
		return true;
	else
		return false;
	end
	
end

function CombatIcon:OnUpdate (elapsed)
	CombatIcon.elapsed = CombatIcon.elapsed + elapsed;
	if ( CombatIcon.elapsed >= ON_UPDATE_THROTTLE ) then
		CombatIcon.elapsed = 0;
		for unit in pairs(unitCombatCache) do
			local currentCombatStatus = UnitAffectingCombat(unit) or false;
			if ( currentCombatStatus ~= unitCombatCache[unit] ) then
				unitCombatCache[unit] = currentCombatStatus;
				if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
					for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
						local unitFrame = ArenaLive:GetUnitFrameByID(id);
						if ( unitFrame[self.name] ) then
							CombatIcon:Update(unitFrame);
						end
					end
				end
			end
		end
	end
end

CombatIcon:SetScript("OnUpdate", CombatIcon.OnUpdate);