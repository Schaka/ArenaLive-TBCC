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
local RaidIcon = ArenaLive:ConstructHandler("RaidIcon", true, false, false);
RaidIcon:SetHandlerClass("IndicatorIcon");

RaidIcon:RegisterEvent("RAID_TARGET_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function RaidIcon:GetTexture (unitFrame)
	
	if ( not unitFrame.unit ) then
		return nil, 0, 1, 0, 1;
	end	
	
	local index = GetRaidTargetIndex(unitFrame.unit);
	if ( index ) then
		index = index - 1;
		local left, right, top, bottom;
		local coordIncrement = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION;
		left = mod(index , RAID_TARGET_TEXTURE_COLUMNS) * coordIncrement;
		right = left + coordIncrement;
		top = floor(index / RAID_TARGET_TEXTURE_ROWS) * coordIncrement;
		bottom = top + coordIncrement;
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcons", left, right, top, bottom;
	end
	
	return nil, 0, 1, 0, 1;
end

function RaidIcon:GetShown(unitFrame)

	if ( not unitFrame.unit ) then
		return false;
	end
	
	local index = GetRaidTargetIndex(unitFrame.unit);
	if ( index ) then
		return true;
	else
		return false;
	end		
end

function RaidIcon:OnEvent(event, ...)
	if ( event == "RAID_TARGET_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				RaidIcon:Update(unitFrame);
			end
		end	
	end
end