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
local ThreatIndicator = ArenaLive:ConstructHandler("ThreatIndicator", true);

ThreatIndicator:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function ThreatIndicator:ConstructObject(indicator, feedbackUnit)
	indicator.feedbackUnit = feedbackUnit;
end

function ThreatIndicator:Update(unitFrame)
	local unit = unitFrame.unit;
	local indicator = unitFrame[self.name];
	
	if ( not unit or not indicator.feedbackUnit ) then
		indicator:Hide();
		return;
	end
	
	local status;
	if ( indicator.feedbackUnit ~= unit ) then
		status = UnitThreatSituation(indicator.feedbackUnit, unit);
	else
		status = UnitThreatSituation(indicator.feedbackUnit);
	end
		
	if ( status and status > 0 ) then
		indicator:SetVertexColor(GetThreatStatusColor(status));
		indicator:Show();
	else
		indicator:Hide();
	end
end

function ThreatIndicator:Reset(unitFrame)
	local indicator = unitFrame[self.name];
	indicator:Hide();
end

function ThreatIndicator:SetFeedBackUnit(unitFrame, unit)

	local indicator = unitFrame[self.name];
	indicator.feedbackUnit = unit;
end

function ThreatIndicator:OnEvent(event, ...)
	local unit = ...;
	if ( event == "UNIT_THREAT_SITUATION_UPDATE" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					ThreatIndicator:Update(unitFrame);
				end
			end
		end
	end
end