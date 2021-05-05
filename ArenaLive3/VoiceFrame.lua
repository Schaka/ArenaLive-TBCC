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
local VoiceFrame = ArenaLive:ConstructHandler("VoiceFrame", true);

--VoiceFrame:RegisterEvent("VOICE_START");
--VoiceFrame:RegisterEvent("VOICE_STOP");
--VoiceFrame:RegisterEvent("MUTELIST_UPDATE");

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function VoiceFrame:ConstructObject(voiceFrame, icon, flash, muted)
	voiceFrame.icon = icon;
	voiceFrame.flash = flash;
	voiceFrame.muted = muted;
end

function VoiceFrame:Update(unitFrame)
	local unit = unitFrame.unit;
	local voiceFrame = unitFrame[self.name];

	if ( not unit ) then
		voiceFrame:Hide();
		return;
	end
	
	local mode;	
	local inInstance, instanceType = IsInInstance();
	if ( (instanceType == "pvp") or (instanceType == "arena") ) then
		mode = "Battleground";
	elseif ( IsInRaid() ) then
		mode = "raid";
	else
		mode = "party";
	end
	
	local status = GetVoiceStatus(unit, mode);
	if ( status ) then
		voiceFrame.icon:Show();
		
		if ( GetMuteStatus(unit, mode) ) then
			voiceFrame.flash:Hide();
			voiceFrame.muted:Show();
		elseif ( UnitIsTalking(UnitName(unit)) ) then
			voiceFrame.flash:Show();
			voiceFrame.muted:Hide();
		else
			voiceFrame.flash:Hide();
			voiceFrame.muted:Hide();
		end
	else
		voiceFrame:Hide();
	end
end

function VoiceFrame:Reset(unitFrame)
	local voiceFrame = unitFrame[self.name];
	voiceFrame:Hide();
end

function VoiceFrame:SetFeedBackUnit(unitFrame, unit)

	local indicator = unitFrame[self.name];
	indicator.feedbackUnit = unit;
end

function VoiceFrame:OnEvent(event, ...)
	local unit = ...;
	if ( event == "VOICE_START" or event == "VOICE_STOP" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					VoiceFrame:Update(unitFrame);
				end
			end
		end
	elseif ( event == "MUTELIST_UPDATE" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				VoiceFrame:Update(unitFrame);
			end
		end
	end
end