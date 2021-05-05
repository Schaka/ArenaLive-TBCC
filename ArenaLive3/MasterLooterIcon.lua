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
local MasterLooterIcon = ArenaLive:ConstructHandler("MasterLooterIcon", true, false, false);
MasterLooterIcon:SetHandlerClass("IndicatorIcon");

MasterLooterIcon:RegisterEvent("PARTY_LOOT_METHOD_CHANGED");



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function MasterLooterIcon:GetTexture (unitFrame)
	return "Interface\GroupFrame\UI-Group-MasterLooter", 0, 1, 0, 1;
end

function MasterLooterIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	local lootMethod, lootMaster = GetLootMethod();
	local unitType = string.match(unit, "^([a-z]+)[0-9]+$") or unit;
	local unitNumber = tonumber(string.match(unit, "^[a-z]+([0-9]+)$")) or -1;

	if ( not lootMaster ) then
		lootMaster = -2;
	end
	
	if ( IsInGroup() and ( ( lootMaster == 0 and unit == "player" ) or ( (unitType == "party" or unitType == "raid") and unitNumber == lootMaster ) ) ) then
		return true;
	else
		return false;
	end	
end

function MasterLooterIcon:OnEvent(event, ...)
	if ( event == "PARTY_LOOT_METHOD_CHANGED" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MasterLooterIcon:Update(unitFrame);
			end
		end	
	end
end