local addonName = ...;
local L = ArenaLiveUnitFrames.L;
local Page = ALUF_UnitFrameOptions:ConstructHandlerPage("CastHistory");
Page.title = L["CastHistory"];

local parent = "ALUF_UnitFrameOptionsHandlerFrame";
local prefix = "ALUF_UnitFrameOptionsHandlerFrameCastHistory";
local optionFrames;

function Page:Initialise()
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Enable"], addonName, "CastHistory", "Enable", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryEnabled);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Direction"], addonName, "CastHistory", "Direction", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryDirection);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Size"], addonName, "CastHistory", "Size", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistorySize);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["ShownIcons"], addonName, "CastHistory", "ShownIcons", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryShownIcons);
	ArenaLive:ConstructOptionFrameByHandler(optionFrames["Duration"], addonName, "CastHistory", "Duration", "PlayerFrame");
	Page:RegisterFrame(ALUF_UnitFrameOptionsHandlerFrameCastHistoryDuration);
	Page:Hide();
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
	["Direction"] = {
		["name"] = prefix.."Direction",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Enabled",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -15,
		["yOffset"] = -20,
	},
	["Size"] = {
		["name"] = prefix.."Size",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Direction",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -20,
	},
	["ShownIcons"] = {
		["name"] = prefix.."ShownIcons",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Size",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 0,
		["yOffset"] = -35,
	},
	["Duration"] = {
		["name"] = prefix.."Duration",
		["parent"] = parent,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ShownIcons",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -1,
		["yOffset"] = -25,
	},
};