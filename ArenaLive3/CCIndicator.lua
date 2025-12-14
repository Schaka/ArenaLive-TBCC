--[[ ArenaLive Core Functions: Crowd Control Indicator Handler
Created by: Vadrak
Creation Date: 11.04.2014
Last Update: 27.04.2014
Used to create a indicator that shows current CC or important auras on the unit.
]]--

-- ArenaLive addon Name and localisation table:
local addonName, L = ...;

--[[
**************************************************
******* GENERAL HANDLER SET UP STARTS HERE *******
**************************************************
]]--
-- Create new Handler and register for aura event:
local CCIndicator = ArenaLive:ConstructHandler("CCIndicator", true);
CCIndicator.canToggle = true;
CCIndicator:RegisterEvent("UNIT_AURA", "UpdateCache");
CCIndicator:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateCache");
CCIndicator:RegisterEvent("PLAYER_FOCUS_CHANGED", "UpdateCache");
CCIndicator:RegisterEvent("ADDON_LOADED", "ADDON_LOADED");

-- Create CC cache. This will be sorted by unitID and inside the unitID table by spellID:
local unitCCCache = {};

-- Variables for max buffs and debuffs:
local MAX_BUFFS = 40;
local MAX_DEBUFFS = 40;

-- localized spellname table
local locSpells = {};
for spellID,type in pairs(ArenaLive.spellDB["CCIndicator"]) do
	local name = GetSpellInfo(spellID)
	if name then
		locSpells[name] = type
	end
end

--[[
****************************************
****** HANDLER METHODS START HERE ******
****************************************
]]--
function CCIndicator:ConstructObject (indicator, texture, cooldown, addonName)
	
	-- Add references:
	indicator.texture = texture;
	indicator.cooldown = cooldown;
	
	local width, height = indicator:GetSize();
	local parent = indicator:GetParent();
	if ( width == 0 and height == 0 and parent ) then
		-- BUGFIX: If size and height is 0, try to use parent's size, because it seems like SetAllPoints doesn't work for LUA created frames somehow:
		width, height = parent:GetSize();
		indicator:SetSize(width, height);
	end
	
	-- Set up cooldown (without frameType, as I want to store cooldown options per addon and not per frame type):
	ArenaLive:ConstructHandlerObject(cooldown, "Cooldown", addonName, indicator);

end

function CCIndicator:OnEnable (unitFrame)
	CCIndicator:Update(unitFrame);
end

function CCIndicator:OnDisable (unitFrame)
	CCIndicator:Reset(unitFrame);
end

function CCIndicator:Update (unitFrame)
	
	local unit = unitFrame.unit;
	local indicator = unitFrame[self.name];
	
	if ( not unit or not indicator.enabled ) then
		return;
	end

    -- if BigDebuffs is enabled, we "steal" spell data
    -- it has support for a lot more stuff than ArenaLive directly and adding anchor support for ArenaLive to BigDebuffs makes less sense imo
    if BigDebuffs and BigDebuffs.UnitFrames ~= nil --[[IsAddOnLoaded("BigDebuffs")]] then
        local bigDebuffsFrame = BigDebuffs.UnitFrames[unit] or BigDebuffs.Nameplates[unit]

        -- only read values if the frame is in use
        if bigDebuffsFrame and bigDebuffsFrame:IsShown() then
            local cd = bigDebuffsFrame.cooldown
            local startTime, duration = cd:GetCooldownTimes()
            local icon = bigDebuffsFrame.current

            indicator.texture:SetTexture(icon);
            -- custom duration set to 1 for auras like smokebomb, druid forms etc
            if duration > 1000 then
                indicator.cooldown:Set(startTime / 1000, duration  / 1000);
            else
                indicator.cooldown:Set(0,0);
            end
            indicator:Show();
            return
        elseif not bigDebuffsFrame or not bigDebuffsFrame:IsShown() then
            indicator:Hide();
            return
        end
    end
	
	local priority, highestID, highestPriority, highestExpires;
	local database = ArenaLive:GetDBComponent(unitFrame.addon, self.name);

	-- Update according to cache entries:
	if ( unitCCCache[unit] ) then
		-- Iterate through all cached CCs in order to find the most important one:
		for spellID, infoTable in pairs(unitCCCache[unit]) do
			priority = database.Priorities[infoTable["priorityType"]];
			if ( priority > 0 ) then
				if ( GetTime() > unitCCCache[unit][spellID]["expires"] ) then
					-- Important spell has run out already. Remove entry from cache:
					table.wipe(unitCCCache[unit][spellID]);
					unitCCCache[unit][spellID] = nil;
				elseif ( not highestPriority or priority > highestPriority or ( priority == highestPriority and unitCCCache[unit][spellID]["expires"] > highestExpires ) ) then
					highestExpires = unitCCCache[unit][spellID]["expires"];
					highestID = spellID;
					highestPriority = priority;
				end
			end
		end
		
		if ( highestID ) then
			local startTime = unitCCCache[unit][highestID]["expires"] - unitCCCache[unit][highestID]["duration"];
			indicator.texture:SetTexture(unitCCCache[unit][highestID]["texture"]);
			indicator.cooldown:Set(startTime, unitCCCache[unit][highestID]["duration"]);
			indicator:Show();
		else
			CCIndicator:Reset(unitFrame);
		end
		
	else
		CCIndicator:Reset(unitFrame);
	end
end

function CCIndicator:Reset(unitFrame)
	local indicator = unitFrame[self.name];
	indicator.texture:SetTexture();
	indicator.cooldown:Reset();
	indicator:Hide();
end

function CCIndicator:UpdateCache (event, unit)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		unit = "target";
	elseif ( event == "PLAYER_FOCUS_CHANGED" ) then
		unit = "focus";
	end

	-- Reset table if there is one:
	if ( unitCCCache[unit] ) then
		table.wipe(unitCCCache[unit]);
	end

	local name, texture, count, dispelType, duration, expires, _, _, _, spellID, _, _, _, _, timeMod, shouldConsolidate, priorityType

	-- Check Buffs:
	for i = 1, MAX_BUFFS, 1 do
		name, texture, count, dispelType, duration, expires, _, _, _, spellID, _, _, _, _, timeMod, shouldConsolidate = UnitBuff(unit, i);
		
		if ( spellID ) then
			priorityType = locSpells[name];
			--priorityType = ArenaLive.spellDB.CCIndicator[spellID];

			-- Found an important buff, store it in the cache:
			if ( priorityType ) then
				-- No cc was tracked for this unit until now. Create table for the new unit:
				if ( not unitCCCache[unit] ) then
					unitCCCache[unit] = {};
				end
				
				-- Update the cache if necessary:
				if ( not unitCCCache[unit][spellID] or ( unitCCCache[unit][spellID] and expires > unitCCCache[unit][spellID]["expires"] ) ) then
					
					if ( not unitCCCache[spellID] ) then
						unitCCCache[unit][spellID] = {};
					end
				
					unitCCCache[unit][spellID]["texture"] = texture;
					unitCCCache[unit][spellID]["duration"] = duration;
					unitCCCache[unit][spellID]["expires"] = expires;
					unitCCCache[unit][spellID]["priorityType"] = priorityType;
				end
			end
		else
			break;
		end
	end

	-- Check Debuffs:
	for i = 1, MAX_DEBUFFS, 1 do
		name, texture, count, dispelType, duration, expires, _, _, _, spellID, _, _, _, _, timeMod, shouldConsolidate = UnitDebuff(unit, i);
		
		if ( spellID ) then
			--priorityType = ArenaLive.spellDB.CCIndicator[spellID];
			priorityType = locSpells[name];
			
			-- Found an important buff, store it in the cache:
			if ( priorityType ) then
				
				-- No cc was tracked for this unit until now. Create table for the new unit:
				if ( not unitCCCache[unit] ) then
					unitCCCache[unit] = {};
				end
				
				-- Update the cache if necessary:
				if ( not unitCCCache[unit][spellID] or ( unitCCCache[unit][spellID] and expires > unitCCCache[unit][spellID]["expires"] ) ) then
					
					if ( not unitCCCache[spellID] ) then
						unitCCCache[unit][spellID] = {};
					end
				
					unitCCCache[unit][spellID]["texture"] = texture;
					unitCCCache[unit][spellID]["duration"] = duration;
					unitCCCache[unit][spellID]["expires"] = expires;
					unitCCCache[unit][spellID]["priorityType"] = priorityType;
				end
			end
		else
			break;
		end
	end

	-- Inform all affected cc indicators that something has changed:
	if ( ArenaLive:IsUnitInUnitFrameCache(unit) ) then
		for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
			local unitFrame = ArenaLive:GetUnitFrameByID(id);
			if ( unitFrame[self.name] ) then
				CCIndicator:Update(unitFrame);
			end
		end
	end
end

function CCIndicator:ADDON_LOADED (event, addonName)
    if addonName == "BigDebuffs" then
        print("BigDebuffs loaded, ArenaLive will use it instead of of its own CCIndicator")
        hooksecurefunc(BigDebuffs, "UNIT_AURA", function(frame, unit, spellId)
            if ArenaLive:GetAffectedUnitFramesByUnit(unit) and not unit:find("nameplate") then
                for id in ArenaLive:GetAffectedUnitFramesByUnit(unit) do
                    local unitFrame = ArenaLive:GetUnitFrameByID(id);
                    if ( unitFrame[self.name] ) then
                         -- we need to wait for BigDebuffs to update successfully first
                         CCIndicator:Update(unitFrame);
                    end
                end
            end
        end)
    end
end

--[[
****************************************
**** OPTION FRAME SETUP STARTS HERE ****
****************************************
]]--
CCIndicator.optionSets = {
	["Enable"] = {
		["type"] = "CheckButton",
		["title"] = L["Enable"],
		["tooltip"] = L["Enables the Crowd Control Indicator."],
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Enabled; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Enabled = newValue; end,
		["postUpdate"] = function (frame, newValue, oldValue) for id, unitFrame in ArenaLive:GetAllUnitFrames() do if ( unitFrame.addon == frame.addon and unitFrame.group == frame.group and unitFrame[CCIndicator.name] ) then unitFrame:ToggleHandler(CCIndicator.name); end end end,
	},
	["DefCD"] = {
		["type"] = "Slider",
		["title"] = L["Defensive Cooldowns"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.defCD; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.defCD = newValue; end,
	},
	["OffCD"] = {
		["type"] = "Slider",
		["title"] = L["Offensive Cooldowns"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.offCD; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.offCD = newValue; end,
	},
	["Stun"] = {
		["type"] = "Slider",
		["title"] = L["Stuns"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.stun; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.stun = newValue; end,
	},
	["Silence"] = {
		["type"] = "Slider",
		["title"] = L["Silences"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.silence; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.silence = newValue; end,
	},
	["CrowdControl"] = {
		["type"] = "Slider",
		["title"] = L["Crowd Control"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.crowdControl; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.crowdControl = newValue; end,
	},
	["Root"] = {
		["type"] = "Slider",
		["title"] = L["Roots"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.root; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.root = newValue; end,
	},
	["Disarm"] = {
		["type"] = "Slider",
		["title"] = L["Disarms"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.disarm; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.disarm = newValue; end,
	},
	["UsefulBuff"] = {
		["type"] = "Slider",
		["title"] = L["Useful Buffs"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.usefulBuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.usefulBuffs = newValue; end,
	},
	["UsefulDebuff"] = {
		["type"] = "Slider",
		["title"] = L["Useful Debuffs"],
		["width"] = 150,
		["height"] = 17,
		["min"] = 0,
		["max"] = 10,
		["step"] = 1,
		["inputType"] = "NUMERIC",
		["GetDBValue"] = function (frame) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); return database.Priorities.usefulDebuffs; end,
		["SetDBValue"] = function (frame, newValue) local database = ArenaLive:GetDBComponent(frame.addon, frame.handler, frame.group); database.Priorities.usefulDebuffs = newValue; end,
	},
};
