ArenaLiveUnitFrames.handlersToPosition = {
	["Aura"] = true,
	["CastBar"] = true,
	["CastHistory"] = true,
	["DRTracker"] = true,
	["PetFrame"] = true,
	["TargetFrame"] = true,
	["AltPowerBar"] = true,
};

local frameToUpdate = {};

function ArenaLiveUnitFrames:SetFramePositions(frame)
	if ( not InCombatLockdown() ) then
		local database = ArenaLive:GetDBComponent(frame.addon, nil, frame.group);
		
		--[[ First clear all points of the handlers.
			 We do this in an extra for-loop to prevent
			 two handlers from being attached to eachother.
			 Normally this shouldn't happen, but just to
			 be sure do it this way.]]
		for handlerName in pairs(ArenaLiveUnitFrames.handlersToPosition) do
			if ( frame[handlerName] and database[handlerName] and database[handlerName]["Position"] ) then
				frame[handlerName]:ClearAllPoints();
			end
		end
		
		-- Now set new values:
		for handlerName in pairs(ArenaLiveUnitFrames.handlersToPosition) do
			if ( frame[handlerName] and database[handlerName] and database[handlerName]["Position"] ) then
				local position, attachedTo, xOffset, yOffset = database[handlerName]["Position"]["Position"], database[handlerName]["Position"]["AttachedTo"], database[handlerName]["Position"]["XOffset"], database[handlerName]["Position"]["YOffset"];
				local relativeTo = frame[attachedTo] or frame;
				
				local point, relativePoint;
				if ( position == "LEFT" ) then
					point = "TOPRIGHT"
					relativePoint = "TOPLEFT";
				elseif ( position == "RIGHT" ) then
					point = "TOPLEFT"
					relativePoint = "TOPRIGHT";
				elseif ( position == "ABOVE" ) then
					point = "BOTTOMLEFT"
					relativePoint = "TOPLEFT";
				elseif ( position == "BELOW" ) then
					point = "TOPLEFT"
					relativePoint = "BOTTOMLEFT";
				else
					-- Fallback:
					point = "TOPRIGHT"
					relativePoint = "TOPLEFT";
				end
				
				frame[handlerName]:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
			end
		end
	else
		frameToUpdate[frame] = true;
	end
end

function ArenaLiveUnitFrames:UpdateFramePositionsAfterLockDown()
	for frame in pairs(frameToUpdate) do
		ArenaLiveUnitFrames:SetFramePositions(frame);
	end
end