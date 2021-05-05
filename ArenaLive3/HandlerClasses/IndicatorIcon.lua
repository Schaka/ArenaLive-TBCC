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
local IndicatorIcon = ArenaLive:ConstructHandler("IndicatorIcon");
local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function IndicatorIcon:ConstructObject(icon, groupName, groupIndex, addonName, frameType, ...)
	
	if ( groupName ) then
		IconGroupHeader:AddIconToGroup(groupName, icon, groupIndex);
	end
	
	if ( self.Constructor ) then
		self:Constructor(icon, ...);
	end
	
	self:UpdateSettings(icon, addonName, frameType);	
end

function IndicatorIcon:Update(unitFrame)
	
	local icon = unitFrame[self.name];
	
	-- Update icon texture:
	local texture, coordLeft, coordRight, coordTop, coordBottom = self:GetTexture(unitFrame);
	if ( icon.texture ) then
		icon.texture:SetTexture(texture);
		icon.texture:SetTexCoord(coordLeft, coordRight, coordTop, coordBottom);
	else
		icon:SetTexture(texture);
		icon:SetTexCoord(coordLeft, coordRight, coordTop, coordBottom);
	end
	
	-- Update icon visibility:
	local isShown = self:GetShown(unitFrame);
	if ( isShown ) then
		icon:Show(isShown);
	else
		icon:Hide();
	end
	
	-- Update the icons group, if there is one:
	if ( icon.group ) then
		IconGroupHeader:Update(icon.group);
	end

end

function IndicatorIcon:Reset(unitFrame)
	local icon = unitFrame[self.name];
	icon:Hide();
	
	-- Update the icons group, if there is one:
	if ( icon.group ) then
		IconGroupHeader:Update(icon.group);
	end	
end

function IndicatorIcon:UpdateSettings (icon, addonName, frameType)
	local database = ArenaLive:GetDBComponent(addonName, self.name, frameType);
	local size = database.Size;
	icon:SetSize(size, size);
end