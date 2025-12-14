local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("PowerBar");
Page.title = L["PowerBar"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFramePowerBar";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ReverseFill"], addonName, "PowerBar", "ReverseFill", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePowerBarReverseFill);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Text"], addonName, "PowerBarText", "Text", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFramePowerBarText);
	Page:Hide();
end

function Page:Show()
	ALUF_UnitFrameOptionsHandlerFramePowerBarReverseFill:Show();
	
	local activeGroup = self:GetActiveFrameGroup();
	if ( activeGroup == "TargetTargetFrame" or activeGroup == "FocusTargetFrame" ) then
		ALUF_UnitFrameOptionsHandlerFramePowerBarText:Hide();
	else
		ALUF_UnitFrameOptionsHandlerFramePowerBarText:Show();
	end
end

optionFrames = {
	["ReverseFill"] = {
		["name"] = prefix.."ReverseFill",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = parent.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 5,
		["yOffset"] = -15,
	},
	["Text"] = {
		["name"] = prefix.."Text",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ReverseFill",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -15,
	},
};