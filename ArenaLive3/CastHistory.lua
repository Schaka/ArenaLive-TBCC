--[[ ArenaLive Core Functions: Cast History Handler
Created by: Vadrak
Creation Date: 20.04.2014
Last Update: 10.09.2014
This file contains all relevant functions for cast histories.
	-- TODO: Create an OnUpdate based animation system, because fixing the icon flickering bug is ridiculously complicated otherwise.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler:
local CastHistory = ArenaLive:ConstructHandler("CastHistory", true, true);
CastHistory.canToggle = true;

-- Register the handler for all needed events.
CastHistory:RegisterEvent("UNIT_SPELLCAST_START");
CastHistory:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
CastHistory:RegisterEvent("UNIT_SPELLCAST_STOP");
CastHistory:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
CastHistory:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
CastHistory:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
CastHistory:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_DAMAGE");
CastHistory:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_HEAL");
CastHistory:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_CAST_SUCCESS");
CastHistory:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED_SPELL_INTERRUPT");

-- Set default icon duration and X and Y offset modifiers for cast history icons:
local DEFAULT_ICON_DURATION = 7;
local DEFAULT_X_MOD = 3;
local DEFAULT_Y_MOD = 3;

-- Throttle for OnUpdate script:
CastHistory.elapsed = 0;
local THROTTLE_INTERVAL = 1; -- Throttle time in seconds.

-- Table for currently active icons that need their expire timer checked:
local ActiveIcons = {};



--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
--[[ Method: ConstructObject
	 Creates a new frame of the type cast history.
		castHistory (Frame): The frame that is going to be set up as a cast history.
]]--
function CastHistory:ConstructObject(castHistory)

	ArenaLive:CheckArgs(castHistory, "Frame");

	-- Set basic info:
	castHistory.icons = 0;
	castHistory.next = 1; -- Number of the next icon that will be used when a spell is cast.
	castHistory.last = 0; -- Number of the icon that was used for the last spell cast.

end

-- ICON SPECIFIC FUNCTIONS:
--[[ Method: CreateIcon
	 Creates a new icon for the cast history.
		castHistory (Frame): The frame that is going to be set up as a cast history.
]]--
function CastHistory:CreateIcon (unitFrame, castHistory)
	
	local icon = CreateFrame("Frame", nil, castHistory, "ArenaLive_CastHistoryIconTemplate");
	
	-- Set basic info:
	icon.timesMoved = 0;
	
	-- NOTE: References for icon textures, animations etc. are set in the CastHistory.xml via parentKey="";
		-- Texture: icon.texture
		-- Border: icon.border
		-- LockOut Texture: icon.lockOut
		-- Fade in animation: icon.fadeInAnim
		-- Fade out animation: icon.fadeOutAnim
		-- Move animation: icon.moveAnim
			-- translation animation: icon.moveAnim.translation
		-- Casting animation: icon.castAnim
	
	-- Update icon size and anchor etc.
	CastHistory:UpdateIcon(unitFrame, icon);
	
	-- Update cast history:
	castHistory.icons = castHistory.icons + 1;
	
	-- Set ID and create reference for the icon in the cast history frame:
	icon:SetID(castHistory.icons);
	castHistory["icon"..castHistory.icons] = icon;

	-- Set scripts for the animations:
	icon.fadeInAnim:SetScript("OnFinished", CastHistory.StartIcon);
	icon.fadeOutAnim:SetScript("OnFinished", CastHistory.FinishIcon);
	icon.castAnim:SetScript("OnFinished", CastHistory.FinishCastIcon);
	icon.moveAnim:SetScript("OnFinished", CastHistory.MoveIcon);
	
	-- Return icon so it can be used:
	return icon;
end

--[[ Method: UpdateIcon
	 Updates a icon's position etc.
		icon (Frame): The icon that is going to be updated.
]]--
function CastHistory:UpdateIcon (unitFrame, icon)
	
	local castHistory = icon:GetParent();
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local size = database.Size;
	local direction = database.Direction;
	local point, translationX, translationY;
	
	-- Set icon and border size:
	icon:SetSize(size, size);
	icon.border:SetSize(size+1, size+1);
	
	-- Set point according to direction:
	if ( direction == "LEFT" )  then
		point = "RIGHT";
		translationX, translationY = -size*0.8, 0;
	elseif ( direction == "RIGHT" ) then
		point = "LEFT";
		translationX, translationY = size*0.8, 0;
	elseif ( direction == "UP" ) then
		point = "BOTTOM";
		translationX, translationY = 0, size*0.8;
	elseif ( direction == "DOWN" ) then
		point = "TOP";
		translationX, translationY = 0, -size*0.8;
	else
		-- Default to direction RIGHT, if the direction entry is invalid:
		point = "LEFT";
		translationX, translationY = size*0.8, 0;
	end
	
	-- Set icon anchor point and translation animation offset:
	icon:ClearAllPoints();
	icon:SetPoint(point, 0, 0);
	icon.moveAnim.translation:SetOffset(translationX, translationY);
	
end

function CastHistory.StartIcon (animationGroup, requested)
	local icon = animationGroup:GetParent();
	local unitFrame = icon:GetParent():GetParent(); -- Temporary fix until we've an OnUpdate based animation system.
	local castHistory = icon:GetParent();
	local database = ArenaLive:GetDBComponent(unitFrame.addon, "CastHistory", unitFrame.group);
	local duration = database.IconDuration or DEFAULT_ICON_DURATION;

	icon:SetAlpha(1);
	icon.expires = GetTime() + duration;
	
	-- Add icon to the list of active icons:
	ActiveIcons[icon] = true;
end

function CastHistory.MoveIcon (animationGroup, requested)
	
	local icon = animationGroup:GetParent();
	local unitFrame = icon:GetParent():GetParent(); -- Temporary fix until we've an OnUpdate based animation system.
	local castHistory = icon:GetParent();
	local size = icon:GetSize();
	local database = ArenaLive:GetDBComponent(unitFrame.addon, "CastHistory", unitFrame.group);
	local direction = database.Direction;
	
	-- Get new position and transition values:
	local point, relativeTo, relativePoint, xOffset, yOffset, translationX, translationY = icon:GetPoint();
	if ( direction == "LEFT" ) then
		xOffset, yOffset = (-size - DEFAULT_X_MOD) * icon.timesMoved, 0;
		translationX, translationY = -size*0.8, 0;
	elseif ( direction == "RIGHT" ) then
		xOffset, yOffset = ( size + DEFAULT_X_MOD ) * icon.timesMoved, 0;
		translationX, translationY = size*0.8, 0;
	elseif ( direction == "UP" ) then
		xOffset, yOffset = 0, (size + DEFAULT_Y_MOD) * icon.timesMoved;
		translationX, translationY = 0, size*0.8;
	elseif ( direction == "DOWN" ) then
		xOffset, yOffset = 0, (-size - DEFAULT_Y_MOD) * icon.timesMoved;
		translationX, translationY = 0, -size*0.8;
	end	

	-- Reset move animation's xOffset to default:
	icon.moveAnim.translation:SetOffset(translationX, translationY);
	
	-- Set new position:
	icon:ClearAllPoints();
	icon:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
end

function CastHistory.FinishIcon (animationGroup, requested)
	local icon = animationGroup:GetParent();
	local ID = icon:GetID();
	local castHistory = icon:GetParent();
	
	CastHistory:ResetIcon(icon);
	
	-- Change the next icon number, if it is larger than the current icon's ID.
	if ( castHistory.next > ID ) then
		castHistory.next = ID;
	end
	
end

function CastHistory.FinishCastIcon (animationGroup, requested)
	local icon = animationGroup:GetParent();
	
	if ( icon.fading ) then
		icon.fadeOutAnim:Play();
	else
		icon.fadeInAnim:Play();
	end
end

function CastHistory:ResetIcon (icon)
	icon:Hide();
	
	-- Remove icon from active icons table:
	ActiveIcons[icon] = nil;
	
	-- Reset icon style:
	icon:SetAlpha(1);
	icon.texture:SetTexture();
	icon.border:SetVertexColor(1, 1, 1, 1);
	icon.border:Hide();
	icon.lockOut:Hide();
	
	-- Reset all control variables to their initial state:
	icon.timesMoved = 0;
	icon.expires = nil;
	icon.fading = nil;
	icon.spellID = nil;
	
	-- Stop animations:
	icon.castAnim:Stop();
	icon.moveAnim:Stop();
	icon.fadeInAnim:Stop();
	icon.fadeOutAnim:Stop();

end

-- CAST HISTORY SPECIFIC FUNCTIONS:
function CastHistory:OnEnable (unitFrame)
	local castHistory = unitFrame[self.name];
	castHistory:Show();
	CastHistory:Update(unitFrame);
end

function CastHistory:OnDisable (unitFrame)
	local castHistory = unitFrame[self.name];
	CastHistory:Reset(unitFrame);
	castHistory:Hide();
end

function CastHistory:Update (unitFrame)
	 CastHistory:Reset(unitFrame);
end

function CastHistory:Reset (unitFrame)
	local castHistory = unitFrame[self.name];
	for i = 1, castHistory.icons do
		local icon = castHistory["icon"..i];
		CastHistory:ResetIcon(icon);
	end	
end

function CastHistory:Rotate (unitFrame, event, spellID, lineID)
	local unit = unitFrame.unit;
	local castHistory = unitFrame[self.name];
	local name, _, texture = GetSpellInfo(spellID);
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name, unitFrame.group);
	local size = database.Size;
	local direction = database.Direction;
	local maxIcons = database.MaxIcons;
	local icon;

	--[[ It is possible that there is no visible frame on the initial position due to the fadeout of failed casts.
		 If this is the case, we don't need to move anything, because we already have enough space to show the new icon.
	]]
	local dontMove = true;
	if ( castHistory.last > 0 ) then
		icon = castHistory["icon"..castHistory.last];
		if ( icon.castAnim:IsPlaying() or ( icon.timesMoved == 0 and icon:IsShown() and not icon.fading ) ) then
			dontMove = nil;
		end
	end
	
	-- If the next icon doesn't exist we need to create it:
	if ( castHistory.next > castHistory.icons ) then
		icon = CastHistory:CreateIcon(unitFrame, castHistory);
	else
		icon = castHistory["icon"..castHistory.next];
	end
	
	-- Fallback if the icon is already in use:
	if ( icon:IsShown() ) then
		--ArenaLive:Message(L["Chosen icon is already in use, searching for free icon..."], "debug");
		for i = 1, castHistory.icons do
			if ( not castHistory["icon"..i]:IsShown() ) then
				icon = castHistory["icon"..i];
				break;
			else
				icon = CastHistory:CreateIcon(unitFrame, castHistory);
			end
		end
	end

	-- Set up new icon:
	icon.spellID = spellID;
	
	-- The PvP trinket's spell has a different icon than the trinket itself. So we replace it here with the correct one:
	if ( spellID == ArenaLive.spellDB.Trinket[1] ) then
		local _, faction = UnitFactionGroup(unit);
					
		if ( faction == "Alliance" ) then
			texture = ("Interface\\ICONS\\INV_Jewelry_TrinketPVP_01");
		else
			texture = ("Interface\\ICONS\\INV_Jewelry_TrinketPVP_02");
		end
	end	
	
	icon.texture:SetTexture(texture);
	icon:SetAlpha(0);
	CastHistory:UpdateIcon(unitFrame, icon);
	icon:Show();
	
	if ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		castHistory.castingIcon = icon;
		icon.castAnim:Play();
	elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		icon.fadeInAnim:Play();
	end
	
	-- Update next and last entries:
	castHistory.next = icon:GetID() + 1;
	castHistory.last = icon:GetID();
	
	if ( not dontMove ) then
		-- Move all old active icons:
		for i = 1, castHistory.icons do
			icon = castHistory["icon"..i];
			
			-- Ignore inactive icons and the icon we've just set up:
			if ( i ~= castHistory.last and icon:IsShown() ) then
				icon.timesMoved = icon.timesMoved + 1;
				
				if ( icon.moveAnim:IsPlaying() ) then
					-- If the icon is already moving we simply increase its offset:
					local xOffset, yOffset = icon.moveAnim.translation:GetOffset();
					
					if ( direction == "LEFT" ) then
						xOffset = xOffset - size*0.8;
					elseif ( direction == "RIGHT" ) then
						xOffset = xOffset + size*0.8;
					elseif ( direction == "UP" ) then
						yOffset = yOffset + size*0.8;
					elseif ( direction == "DOWN" ) then
						yOffset = yOffset - size*0.8;
					end
					
					icon.moveAnim.translation:SetOffset(xOffset, yOffset);
				else
					icon.moveAnim:Play();
				end
				
				if ( icon.timesMoved >= maxIcons and not icon.fadeOutAnim:IsPlaying() ) then
					icon.fadeOutAnim:Play();
				end
			end
		end
	end
end

function CastHistory:StartCast (unitFrame, event, spellID, lineID)
	
	local castHistory = unitFrame[self.name];
	-- If we're already channeling the same spell, ignore the new one:
	if ( event == "UNIT_SPELLCAST_CHANNEL_START" and castHistory.channeling and spellID == castHistory.spellID ) then
		return;
	end
	
	if ( event == "UNIT_SPELLCAST_START" ) then
		castHistory.casting = true;
		castHistory.channeling = nil;
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		castHistory.channeling = true;
		castHistory.casting = nil;
	end
	
	castHistory.spellID = spellID;
	castHistory.lineID = lineID;
	CastHistory:Rotate(unitFrame, event, spellID, lineID);
end

function CastHistory:StopCast (castHistory, event, lineID)

	if ( event == "UNIT_SPELLCAST_STOP" and lineID ~= castHistory.lineID ) then
		return;
	end

	local icon = castHistory.castingIcon;
	if ( not icon ) then
		return;
	end
	
	if ( event == "UNIT_SPELLCAST_STOP" ) then
		icon.fading = true;
	else
		icon.fading = nil;
	end
	
	castHistory.castingIcon = nil;
	castHistory.lastCastingIcon = icon;
	castHistory.casting = nil;
	castHistory.channeling = nil;
	castHistory.spellID = nil;
	castHistory.lineID = nil;
	
	icon.castAnim:Finish();
end

function CastHistory:SuccessfulCast (unitFrame, spellID, lineID)
	
	local castHistory = unitFrame[self.name];
	if ( not castHistory.channeling and not castHistory.casting and not ArenaLive.spellDB.FilteredSpells[spellID] ) then
		-- Instant cast:
		CastHistory:Rotate(unitFrame, "UNIT_SPELLCAST_SUCCEEDED", spellID, lineID);
	elseif ( castHistory.casting and castHistory.castingIcon and lineID == castHistory.lineID ) then
		local icon = castHistory.castingIcon;
		castHistory.castingIcon = nil;
		castHistory.casting = nil;
		castHistory.spellID = nil;
		castHistory.lineID = nil;
		icon.fading = nil;
		icon.castAnim:Finish();
	end

end

function CastHistory:LockOutCast (castHistory, spellID)

	local icon = castHistory.lastCastingIcon;
	
	if ( icon and icon.fading and icon.spellID and icon.spellID == spellID ) then
		castHistory.lastCastingIcon = nil; 
		icon.fading = nil;
		icon.border:Show();
		icon.border:SetVertexColor(1, 0, 0, 1);
		icon.lockOut:Show();		
	end

end

function CastHistory:UpdateBorder (castHistory, spellID, destGUID)

	local icon = castHistory["icon"..castHistory.last];
	
	if ( icon and icon.spellID and spellID == icon.spellID ) then
		local _, class;
		if ( destGUID and destGUID~= "" and destGUID ~= "0x0000000000000000" ) then
			_, class = GetPlayerInfoByGUID(destGUID);
		end
		
		if ( class ) then
			icon.border:Show();
			icon.border:SetVertexColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, 1);
		else
			icon.border:Hide();
		end		
		
	end

end

function CastHistory:OnEvent (event, ...)
	
	local unit, lineID, spellID = ...;
	if ( event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] and unitFrame[self.name]["enabled"] ) then
					CastHistory:StartCast(unitFrame, event, spellID, lineID);
				end
			end
		end
	elseif ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] and unitFrame[self.name]["enabled"] ) then
					CastHistory:SuccessfulCast (unitFrame, spellID, lineID);
				end
			end
		end
	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
		if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
			for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] and unitFrame[self.name]["enabled"] ) then
					CastHistory:StopCast(unitFrame[self.name], event, lineID);
				end
			end
		end
	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_DAMAGE" or event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_HEAL" or event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_CAST_SUCCESS" ) then
		local sourceGUID = select(4, ...);
		local spellID = select(12, ...);
		local destGUID = select(8, ...);
		if ( ArenaLive:IsGUIDInUnitFrameCache(sourceGUID) ) then
			for id in ArenaLive:GetAffectedUnitFramesByGUID(sourceGUID) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] and unitFrame[self.name]["enabled"] ) then
					CastHistory:UpdateBorder(unitFrame[self.name], spellID, destGUID);
				end
			end	
		end
	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED_SPELL_INTERRUPT" ) then
		local destGUID = select(8, ...);
		local spellID = select(12, ...);
		if ( ArenaLive:IsGUIDInUnitFrameCache(destGUID) ) then
			for id in ArenaLive:GetAffectedUnitFramesByGUID(destGUID) do
				local unitFrame = ArenaLive:GetUnitFrameByID(id);
				if ( unitFrame[self.name] and unitFrame[self.name]["enabled"] ) then
					CastHistory:LockOutCast(unitFrame[self.name], spellID);
				end
			end	
		end
	end

end

function CastHistory:OnUpdate (elapsed)
	CastHistory.elapsed = CastHistory.elapsed + elapsed;
	
	if ( CastHistory.elapsed >= THROTTLE_INTERVAL ) then
		local theTime = GetTime();
		CastHistory.elapsed = 0;
		for icon in pairs(ActiveIcons) do
			if ( icon.expires ) then
				if ( theTime >= icon.expires ) then
					ActiveIcons[icon] = nil;
					icon.fadeOutAnim:Play();
				end
			else
				ActiveIcons[icon] = nil;
			end
		end
	end

end

CastHistory:SetScript("OnUpdate", CastHistory.OnUpdate);

CastHistory.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the cast history."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[CastHistory.name] ) then unitFrame:ToggleHandler(CastHistory.name); end end end,
	},
	["Size"] = {
		["type"] = "Slider",
		["title"] = L["Icon Size"],
		["tooltip"] = L["Sets the size of the cast history icons."],
		["width"] = 100,
		["height"] = 17,		
		["min"] = 1,
		["max"] = 64,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Size; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Size = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[CastHistory.name] ) then CastHistory:Reset(unitFrame); end end end,
	},
	["Direction"] = {
		["type"] = "DropDown",
		["title"] = L["Direction"],
		["tooltip"] = L["Sets the moving direction of the cast history icons."],
		["infoTable"] = {
			[1] = {
				["value"] = "UP",
				["text"] = L["Up"],
			},
			[2] = {
				["value"] = "RIGHT",
				["text"] = L["Right"],
			},
			[3] = {
				["value"] = "DOWN",
				["text"] = L["Down"],
			},
			[4] = {
				["value"] = "LEFT",
				["text"] = L["Left"],
			},
		},
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Direction; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Direction = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[CastHistory.name] ) then CastHistory:Reset(unitFrame); end end end,
	},
	["Duration"] = {
		["type"] = "EditBoxSmall",
		["title"] = L["Icon Duration"],
		["tooltip"] = L["Sets the time in seconds until a cast history icon fades."],
		["width"] = 28,
		["height"] = 20,		
		["maxLetters"] = 2,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.IconDuration; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.IconDuration = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[CastHistory.name] ) then CastHistory:Reset(unitFrame); end end end,
	},
	["ShownIcons"] = {
		["type"] = "Slider",
		["title"] = L["Shown Icons"],
		["tooltip"] = L["Sets the maximal number of cast history icons that are shown simultaneously."],
		["width"] = 100,
		["height"] = 17,		
		["min"] = 1,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.MaxIcons; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.MaxIcons = newValue; end,
	},
};