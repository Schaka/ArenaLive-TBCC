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
local MultiGroupIcon = ArenaLive:ConstructHandler("MultiGroupIcon", true, false, false);
local IconGroupHeader =  ArenaLive:GetHandler("IconGroupHeader");

-- Register the handler for all needed events:
MultiGroupIcon:RegisterEvent("GROUP_ROSTER_UPDATE");
MultiGroupIcon:RegisterEvent("UPDATE_CHAT_COLOR");



--[[
****************************************
****** OBJECT METHODS START HERE ******
****************************************
]]--
local function OnEnter(multiGroupIcon)
	GameTooltip_SetDefaultAnchor(GameTooltip, multiGroupIcon);
	multiGroupIcon.homePlayers = GetHomePartyInfo(multiGroupIcon.homePlayers);

	if ( IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
		GameTooltip:SetText(PLAYER_IN_MULTI_GROUP_RAID_MESSAGE, nil, nil, nil, nil, true);
		GameTooltip:AddLine(format(MEMBER_COUNT_IN_RAID_LIST, #multiGroupIcon.homePlayers + 1), 1, 1, 1, true);
	else
		GameTooltip:AddLine(PLAYER_IN_MULTI_GROUP_PARTY_MESSAGE, 1, 1, 1, true);
		local playerList = multiGroupIcon.homePlayers[1] or "";
		for i=2, #multiGroupIcon.homePlayers do
			playerList = playerList..PLAYER_LIST_DELIMITER..multiGroupIcon.homePlayers[i];
		end
		GameTooltip:AddLine(format(MEMBERS_IN_PARTY_LIST, playerList));
	end
	
	GameTooltip:Show();
end

local function OnLeave(multiGroupIcon)
	GameTooltip:Hide();
end



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function MultiGroupIcon:ConstructObject (multiGroupIcon, homePartyIcon, instancePartyIcon, groupName, groupIndex)
	ArenaLive:CheckArgs(multiGroupIcon, "Button", homePartyIcon, "Texture", instancePartyIcon, "Texture");
	
	if ( groupName ) then
		IconGroupHeader:AddIconToGroup(groupName, multiGroupIcon, groupIndex);
	end

	-- Set references for textures.
	multiGroupIcon.homePartyIcon = homePartyIcon;
	multiGroupIcon.instancePartyIcon = instancePartyIcon;	
	
	-- Set Scripts:
	multiGroupIcon:SetScript("OnEnter", OnEnter);
	multiGroupIcon:SetScript("OnLeave", OnLeave);
end

function MultiGroupIcon:Update(unitFrame)
	
	local multiGroupIcon = unitFrame[self.name];
	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		MultiGroupIcon:UpdateColour(multiGroupIcon);
		multiGroupIcon:Show();
	else
		multiGroupIcon:Hide();
	end
end

local public, private;
function MultiGroupIcon:UpdateColour(multiGroupIcon)
	public = ChatTypeInfo["INSTANCE_CHAT"];
	private = ChatTypeInfo["PARTY"];
	multiGroupIcon.homePartyIcon:SetVertexColor(private.r, private.g, private.b);
	multiGroupIcon.instancePartyIcon:SetVertexColor(public.r, public.g, public.b);
end

function MultiGroupIcon:Reset(multiGroupIcon)
	multiGroupIcon:Hide();
end

function MultiGroupIcon:OnEvent(event, ...)
	if ( event == "GROUP_ROSTER_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MultiGroupIcon:Update(unitFrame);
			end
		end	
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				MultiGroupIcon:UpdateColour(unitFrame[self.name]);
			end
		end	
	end
end