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
-- Create handler:
local IconGroupHeader = ArenaLive:ConstructHandler("IconGroupHeader", false, false, false);

-- Create table that stores all icon groups:
local iconGroups = {};

local X_OFFSET = 3;
local Y_OFFSET = 3;
--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
function IconGroupHeader:ConstructGroup(groupName, direction, offset, point, relativeTo, relativePoint, xOffset, yOffset)
	
	ArenaLive:CheckArgs(groupName, "string");

	if ( not iconGroups[groupName] ) then
		iconGroups[groupName] = {};
		iconGroups[groupName]["direction"] = direction or "RIGHT";
		iconGroups[groupName]["offset"] = offset;
		iconGroups[groupName]["point"] = point;
		iconGroups[groupName]["relativeTo"] = relativeTo;
		iconGroups[groupName]["relativePoint"] = relativePoint;
		iconGroups[groupName]["xOffset"] = xOffset;
		iconGroups[groupName]["yOffset"] = yOffset;
	else
		ArenaLive:Message(L["Couldn't construct new icon group, because a group with the name %s already exists!"], "error", groupName);
	end
end

function IconGroupHeader:Update(groupName)
	
	local lastShownIndex;
	for index, icon in ipairs(iconGroups[groupName]) do
		if ( icon:IsShown() ) then
			local point, relativeTo, relativePoint, xOffset, yOffset;
			if ( lastShownIndex ) then	
				if ( iconGroups[groupName]["direction"] == "LEFT" ) then
					point = "RIGHT";
					relativePoint = "LEFT";
					xOffset = -iconGroups[groupName]["offset"] or -X_OFFSET;
					yOffset = 0;
				elseif ( iconGroups[groupName]["direction"] == "RIGHT" ) then
					point = "LEFT";
					relativePoint = "RIGHT";
					xOffset = iconGroups[groupName]["offset"] or X_OFFSET;
					yOffset = 0;
				elseif ( iconGroups[groupName]["direction"] == "UP" ) then
					point = "BOTTOM";
					relativePoint = "TOP";
					xOffset = 0;
					yOffset = iconGroups[groupName]["offset"] or Y_OFFSET;
				elseif ( iconGroups[groupName]["direction"] == "DOWN" ) then
					point = "TOP";
					relativePoint = "BOTTOM";
					xOffset = 0;
					yOffset = -iconGroups[groupName]["offset"] or -Y_OFFSET;
				end
					
					relativeTo = iconGroups[groupName][lastShownIndex];
			else
					-- This is the first icon of the group that is shown, so set the position the initial ones:
					point, relativeTo, relativePoint, xOffset, yOffset = iconGroups[groupName]["point"], iconGroups[groupName]["relativeTo"], iconGroups[groupName]["relativePoint"] , iconGroups[groupName]["xOffset"] , iconGroups[groupName]["yOffset"];
			end
				
			icon:ClearAllPoints();
			icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
			lastShownIndex = index;
		end
	end

end

function IconGroupHeader:AddIconToGroup(groupName, icon, index)

	if ( iconGroups[groupName] ) then
		if ( index ) then
			table.insert(iconGroups[groupName], index, icon);
		else
			table.insert(iconGroups[groupName], icon);
		end
		icon.id = index or #iconGroups[groupName];
		icon.group = groupName;
		IconGroupHeader:Update(groupName);
	else
		ArenaLive:Message(L["Couldn't add icon to icon group, because a group with the name %s doesn't exist!"], "error", groupName);
	end

end

function IconGroupHeader:RemoveIconFromGroup(icon)
	local index = icon.id;
	local groupName = icon.group;
	table.remove(iconGroups[groupName], index);
end