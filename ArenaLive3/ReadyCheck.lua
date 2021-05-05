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
local ReadyCheck = ArenaLive:ConstructHandler("ReadyCheck", true, true);

-- Register the handler for all needed events:
ReadyCheck:RegisterEvent("READY_CHECK");
ReadyCheck:RegisterEvent("READY_CHECK_CONFIRM");
ReadyCheck:RegisterEvent("READY_CHECK_FINISHED");

-- Create a table to store all active ready check textures we have to iterate over:
local activeTextures = {};

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function ReadyCheck:ConstructObject(readyCheck)
	ArenaLive:CheckArgs(readyCheck, "Texture");
end
function ReadyCheck:Update(unitFrame)
	local unit = unitFrame.unit;
	local readyCheck = unitFrame[self.name];
	
	if ( not unit ) then
		readyCheck:Hide();
		return;
	end
	
	activeTextures[readyCheck] = nil;
	
	local readyCheckStatus = GetReadyCheckStatus(unit);
	if ( readyCheckStatus ) then
		if ( readyCheckStatus == "ready" ) then
			readyCheck:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
			readyCheck.state = "ready";
		elseif ( readyCheckStatus == "notready" ) then
			readyCheck:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady");
			readyCheck.state = "notready";
		else -- "waiting"
			readyCheck:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting");
			readyCheck.state = "waiting";
		end
		readyCheck:SetAlpha(1);
		readyCheck:Show();
	else
		readyCheck:Hide();
	end	
end

function ReadyCheck:Finish(unitFrame)
	local unit = unitFrame.unit;
	local readyCheck = unitFrame[self.name];
	
	if ( not unit ) then
		readyCheck:Hide();
		return;
	end
	
	if ( readyCheck.state == "waiting" ) then
		readyCheck:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady");
		readyCheck.state = "afk";
	end
	
	readyCheck.fadeTimer = 1.5;
	activeTextures[readyCheck] = true;
end

function ReadyCheck:Reset(unitFrame)
	local readyCheck = unitFrame[self.name];
	readyCheck:Hide();
end

function ReadyCheck:OnEvent(event, ...)
	if ( event == "READY_CHECK" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				ReadyCheck:Update(unitFrame);
			end
		end		
	elseif ( event == "READY_CHECK_CONFIRM" ) then
		local unit = ...;
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] ) then
					ReadyCheck:Update(unitFrame);
				end
			end
		end
	elseif ( event == "READY_CHECK_FINISHED" ) then
		for id, unitFrame in ArenaLive:GetAllUnitFrames() do
			if ( unitFrame[self.name] ) then
				ReadyCheck:Finish(unitFrame);
			end
		end
	end
end

function ReadyCheck:OnUpdate(elapsed)
	for readyCheck in pairs(activeTextures) do
		if ( readyCheck.fadeTimer and readyCheck.fadeTimer > 0 ) then
			readyCheck.fadeTimer = readyCheck.fadeTimer - elapsed;
			readyCheck:SetAlpha(readyCheck.fadeTimer / 1.5);
		else
			activeTextures[readyCheck] = nil;
			readyCheck.fadeTimer = nil;
			readyCheck:Hide();
		end
	end
end
ReadyCheck:SetScript("OnUpdate", ReadyCheck.OnUpdate);