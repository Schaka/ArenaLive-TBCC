--[[
    ArenaLive [UnitFrames] is an unit frame addon for World of Warcraft.
    Copyright (C) 2015  Harald Böhm <harald@boehm.agency>

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

local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("UnitFrame");
Page.title = L["UnitFrame"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameUnitFrame";
local optionFrames;

local function PositionFramesOnEvent(frame, event, ...)
	
	if ( not frame:IsVisible() ) then
		return;
	end

	local addon, frameName = ...;
	if ( event == "ARENALIVE_FRAME_MOVER_ON_DRAG_STOP" and addon == addonName and frameName == frame.group ) then
		frame:UpdateShownValue();
	end
end

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "UnitFrame", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabled);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["EnableArenaHeader"], addonName, "ArenaHeader", "Enable", "ArenaEnemyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledArenaHeader);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["EnabledPartyHeader"], addonName, "PartyHeader", "Enable", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledPartyHeader);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ClickThrough"], addonName, "UnitFrame", "ClickThrough", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameClickThrough);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["HideOutOfCombat"], addonName, "UnitFrame", "HideOutOfCombat", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameHideOutOfCombat);	
	ArenaLive:ConstructOptionFrame(optionFrames["LargerFrame"], addonName, "UnitFrame", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameLargerFrame);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowPlayer"], addonName, "PartyHeader", "ShowPlayer", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowPlayer);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowInParty"], addonName, "PartyHeader", "ShowParty", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInParty);	
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowInRaid"], addonName, "PartyHeader", "ShowRaid", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInRaid);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShowInArena"], addonName, "PartyHeader", "ShowArena", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInArena);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["TooltipDisplayMode"], addonName, "UnitFrame", "ToolTipMode", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameTooltipDisplayMode);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Scale"], addonName, "UnitFrame", "Scale", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameScale);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["GrowthDirectionArenaHeader"], addonName, "ArenaHeader", "GrowthDirection", "ArenaEnemyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionArenaHeader);	
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["SpaceBetweenFramesArenaHeader"], addonName, "ArenaHeader", "SpaceBetweenFrames", "ArenaEnemyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesArenaHeader);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["GrowthDirectionPartyHeader"], addonName, "PartyHeader", "GrowthDirection", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionPartyHeader);	
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["SpaceBetweenFramesPartyHeader"], addonName, "PartyHeader", "SpaceBetweenFrames", "PartyFrames");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesPartyHeader);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["PositionPoint"], addonName, "FrameMover", "Point", "ALUF_PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionPoint);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["PositionRelativeTo"], addonName, "FrameMover", "RelativeTo", "ALUF_PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativeTo);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["PositionRelativePoint"], addonName, "FrameMover", "RelativePoint", "ALUF_PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativePoint);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["PositionXOffset"], addonName, "FrameMover", "XOffset", "ALUF_PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionXOffset);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["PositionYOffset"], addonName, "FrameMover", "YOffset", "ALUF_PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionYOffset);
	Page:Hide();
	
	-- Equip positioning frames with event methods so that they can update after a frame was dragged by the player:
	ArenaLive:ConstructEventObject(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionPoint);
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionPoint.OnEvent = PositionFramesOnEvent;
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionPoint:RegisterEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");
	
	ArenaLive:ConstructEventObject(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativeTo);
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativeTo.OnEvent = PositionFramesOnEvent;
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativeTo:RegisterEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");
	
	ArenaLive:ConstructEventObject(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativePoint);
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativePoint.OnEvent = PositionFramesOnEvent;
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativePoint:RegisterEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");
	
	ArenaLive:ConstructEventObject(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionXOffset);
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionXOffset.OnEvent = PositionFramesOnEvent;
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionXOffset:RegisterEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");
	
	ArenaLive:ConstructEventObject(ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionYOffset);
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionYOffset.OnEvent = PositionFramesOnEvent;
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionYOffset:RegisterEvent("ARENALIVE_FRAME_MOVER_ON_DRAG_STOP");
end

function Page:Show()
	-- Depending on the current frame type we need to show/hide some elements:
	local frameGroup = self:GetActiveFrameGroup();	
	if ( frameGroup == "ArenaEnemyFrames" ) then
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabled:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameHideOutOfCombat:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowPlayer:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInRaid:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInArena:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledArenaHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesArenaHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionArenaHeader:Show();
	elseif ( frameGroup == "PartyFrames" ) then
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabled:Hide();
			ALUF_UnitFrameOptionsHandlerFrameUnitFrameHideOutOfCombat:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledArenaHeader:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesArenaHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionArenaHeader:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledPartyHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionPartyHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesPartyHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowPlayer:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInParty:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInRaid:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInArena:Show();
	else
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabled:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameHideOutOfCombat:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledArenaHeader:Show();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesArenaHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionArenaHeader:Hide();
		
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameEnabledPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameGrowthDirectionPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameSpaceBetweenFramesPartyHeader:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowPlayer:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInParty:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInRaid:Hide();
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameShowInArena:Hide();
	end
	
	if ( frameGroup == "TargetTargetFrame" or frameGroup == "FocusTargetFrame" ) then
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameLargerFrame:Show();
	else
		ALUF_UnitFrameOptionsHandlerFrameUnitFrameLargerFrame:Hide();
	end
	
	ALUF_UnitFrameOptionsHandlerFrameUnitFrameClickThrough:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFrameTooltipDisplayMode:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFrameScale:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionPoint:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativeTo:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionRelativePoint:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionXOffset:Show();
	ALUF_UnitFrameOptionsHandlerFrameUnitFramePositionYOffset:Show();
end

optionFrames = {
	["Enable"] = {
		["name"] = prefix.."Enabled",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},	
	["EnableArenaHeader"] = {
		["name"] = prefix.."EnabledArenaHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "TOPLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["EnabledPartyHeader"] = {
		["name"] = prefix.."EnabledPartyHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "TOPLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["ClickThrough"] = {
		["name"] = prefix.."ClickThrough",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."EnabledText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["HideOutOfCombat"] = {
		["name"] = prefix.."HideOutOfCombat",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."ClickThroughText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["LargerFrame"] = {
		["type"] = "CheckButton",
		["name"] = prefix.."LargerFrame",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."HideOutOfCombatText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
		["title"] = L["Larger Frame"],
		["tooltip"] = L["If checked, the unit frame's size will be increased."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.LargerFrame; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.LargerFrame = newValue; end,
		["postUpdate"] = function(frame, newValue, OldValue)
			if ( frame.group == "TargetTargetFrame" ) then
				ArenaLiveUnitFrames:UpdateTargetFrameDisplay(ALUF_TargetTargetFrame);
			elseif ( frame.group == "FocusTargetFrame" ) then
				ArenaLiveUnitFrames:UpdateTargetFrameDisplay(ALUF_FocusTargetFrame);
			end
		end,
	},
	["ShowPlayer"] = {
		["name"] = prefix.."ShowPlayer",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -5,
	},
	["ShowInParty"] = {
		["name"] = prefix.."ShowInParty",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."ShowPlayerText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["ShowInRaid"] = {
		["name"] = prefix.."ShowInRaid",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."ShowInPartyText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = -1,
	},
	["ShowInArena"] = {
		["name"] = prefix.."ShowInArena",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."ShowInRaidText",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = 0,
	},
	["TooltipDisplayMode"] = {
		["name"] = prefix.."TooltipDisplayMode",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ShowPlayer",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -15,
		["yOffset"] = -20,
	},
	["Scale"] = {
		["name"] = prefix.."Scale",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."TooltipDisplayMode",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -20,
	},
	["GrowthDirectionArenaHeader"] = {
		["name"] = prefix.."GrowthDirectionArenaHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Scale",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -20,
		["yOffset"] = -30,
	},
	["SpaceBetweenFramesArenaHeader"] = {
		["name"] = prefix.."SpaceBetweenFramesArenaHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."GrowthDirectionArenaHeader",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -20,
	},
	["GrowthDirectionPartyHeader"] = {
		["name"] = prefix.."GrowthDirectionPartyHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."GrowthDirectionArenaHeader",
		["relativePoint"] = "TOPLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["SpaceBetweenFramesPartyHeader"] = {
		["name"] = prefix.."SpaceBetweenFramesPartyHeader",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."SpaceBetweenFramesArenaHeader",
		["relativePoint"] = "TOPLEFT",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	["PositionPoint"] = {
		["name"] = prefix.."PositionPoint",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."PositionText",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -10,
		["yOffset"] = -15,
	},
	["PositionRelativeTo"] = {
		["name"] = prefix.."PositionRelativeTo",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."PositionPoint",
		["relativePoint"] = "RIGHT",
		["xOffset"] = -10,
		["yOffset"] = 2,
	},
	["PositionRelativePoint"] = {
		["name"] = prefix.."PositionRelativePoint",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."PositionRelativeTo",
		["relativePoint"] = "RIGHT",
		["xOffset"] = -10,
		["yOffset"] = -2,
	},
	["PositionXOffset"] = {
		["name"] = prefix.."PositionXOffset",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."PositionRelativePoint",
		["relativePoint"] = "RIGHT",
		["xOffset"] = -10,
		["yOffset"] = 2,
	},
	["PositionYOffset"] = {
		["name"] = prefix.."PositionYOffset",
		["parent"] = parent,
		["point"] = "LEFT",
		["relativeTo"] = prefix.."PositionXOffset",
		["relativePoint"] = "RIGHT",
		["xOffset"] = 5,
		["yOffset"] = 0,
	},
};