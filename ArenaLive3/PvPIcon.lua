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
local PvPIcon = ArenaLive:ConstructHandler("PvPIcon", true, true);
PvPIcon:SetHandlerClass("IndicatorIcon");
PvPIcon:RegisterEvent("UNIT_FACTION");
PvPIcon:RegisterEvent("PLAYER_FLAGS_CHANGED");


--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PvPIcon:Constructor (icon, texture, text)
	ArenaLive:CheckArgs(icon, "Frame", texture, "Texture");
	
	-- Set texture refrence:
	icon.texture = texture;
	icon.text = text;
end

function PvPIcon:GetTexture (unitFrame)
	local unit = unitFrame.unit;
	local icon = unitFrame[self.name];
	
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
	end
	
	if ( unit == "player" and icon.text ) then
		if ( IsPVPTimerRunning() ) then
			local pvpTime = GetPVPTimer();
			local sec = math.floor(pvpTime/1000);
			local text;
			if ( sec >= 60 ) then
				text = math.ceil(sec/60).."m";
			else
				text = math.floor(sec).."s";
			end

			icon.text:SetText(text);
			icon.text:Show();
		else
			icon.text:Hide();
		end
	end
	
	local factionGroup, factionName = UnitFactionGroup(unit);
	if ( UnitIsPVPFreeForAll(unit) ) then
		return "Interface\\TargetingFrame\\UI-PVP-FFA", 0, 1, 0, 1;
	elseif ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) ) then
		return "Interface\\TargetingFrame\\UI-PVP-"..factionGroup, 0, 1, 0, 1;
	else
		return nil, 0, 1, 0, 1;
	end

end

function PvPIcon:GetShown (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return false;
	end
	
	local factionGroup, factionName = UnitFactionGroup(unit);
	if ( UnitIsPVPFreeForAll(unit) or ( factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(unit) ) ) then
		unitFrame[self.name]["unit"] = unit; -- Use this to enable the tooltip function
		return true;
	else
		unitFrame[self.name]["unit"] = nil;
		return false;
	end

end

function PvPIcon:OnEvent(event, ...)
	local unit = ...;
	if ( ( event == "UNIT_FACTION" and unit == "player" ) or event == "PLAYER_FLAGS_CHANGED" ) then
		if ( IsPVPTimerRunning() ) then
			self:Show();
		else
			self:Hide();
		end
	end
	
	if ( event == "UNIT_FACTION" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					PvPIcon:Update(unitFrame);
				end
			end
		end		
	end
end

local lastSec = 0;
function PvPIcon:OnUpdate(elapsed)
	if ( IsPVPTimerRunning() ) then
		local sec = math.floor(GetPVPTimer()/1000) % 60;
		if ( sec ~= lastSec ) then
			lastSec = sec;
			if ( ArenaLive:IsUnitInUnitFrameCache("player") ) then
				for id in ArenaLive:GetAffectedUnitFramesByUnit("player") do
					local unitFrame = ArenaLive:GetUnitFrameByID(id);
					if ( unitFrame[self.name] and unitFrame[self.name].text ) then
						PvPIcon:Update(unitFrame);
					end
				end
			end
		end
	else
		self:Hide();
	end
end
PvPIcon:Hide();
PvPIcon:SetScript("OnUpdate", PvPIcon.OnUpdate);