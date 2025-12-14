--[[ ArenaLive Core Functions: Master Looter Icon Handler
Created by: Vadrak
Creation Date: 01.05.2014
Last Update: 17.05.2014
This file contains all relevant functions for pvp status icons.
]]--

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

-- Variable to store the pvp icon that has the GameTooltip owns currently:
local PVP_ICON_OWNS_TOOLTIP;



--[[
****************************************
****** OBJECT METHODS START HERE ******
****************************************
]]--
local function OnEnter (icon)
	
	if ( not icon.unit or ( icon.unit ~= "player" and not UnitIsUnit(icon.unit, "player") ) ) then
		return;
	end
	
	local pvpTime = GetPVPTimer();
	if ( pvpTime > 0 and pvpTime < 300000 ) then
		PvPIcon:Show();
		PVP_ICON_OWNS_TOOLTIP = icon;
		GameTooltip:Show();	
	end
end

local function OnLeave (icon)
	PvPIcon:Hide();
	PVP_ICON_OWNS_TOOLTIP = nil;
	GameTooltip:Hide();
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function PvPIcon:Constructor (icon, texture, unitFrame)
	ArenaLive:CheckArgs(icon, "Frame", texture, "Texture");
	
	-- Set texture refrence:
	icon.texture = texture;

	-- Set Scripts:
	icon:SetScript("OnEnter", OnEnter);
	icon:SetScript("OnLeave", OnLeave);
end

function PvPIcon:GetTexture (unitFrame)
	local unit = unitFrame.unit;
	
	if ( not unit ) then
		return nil, 0, 1, 0, 1;
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

function PvPIcon:OnUpdate(elapsed)

	if ( PVP_ICON_OWNS_TOOLTIP ) then
		local pvpTime = GetPVPTimer();
		local sec = math.floor(pvpTime/1000);
		local min = math.floor(sec/60);
		local text;	
		
		if ( min > 0 ) then
			sec = math.floor(sec - 60 * min);
			min = min..":";
		else
			min = "0:";
		end
		
		if ( sec < 10 ) then
			sec = "0"..sec;
		end			
		
		text = min..sec;
		
		text = string.format(L["Remaining time flagged for PvP: %s"], text);
		GameTooltip_SetDefaultAnchor(GameTooltip, PVP_ICON_OWNS_TOOLTIP);
		GameTooltip:SetText(text);
	end

end
PvPIcon:Hide();
PvPIcon:SetScript("OnUpdate", PvPIcon.OnUpdate);