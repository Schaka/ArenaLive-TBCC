local addonName = ...;
local L = ArenaLiveUnitFrames.L;

local prefix = "ALUF_ProfileOptions";
local optionFrames;
local Profiles = ArenaLive:GetHandler("Profiles");

function ALUF_ProfileOptions:Initialise()
	ALUF_ProfileOptionsTitle:SetText(L["ArenaLive [UnitFrames] Profile Options:"]);
	ALUF_ProfileOptions.name = L["Profiles"];
	ALUF_ProfileOptions.parent = L["ArenaLive [UnitFrames]"];
	local category = Settings.RegisterCanvasLayoutCategory(ALUF_ProfileOptions, "ArenaLive Profiles")
    Settings.RegisterAddOnCategory(category)
	
	Profiles:ConstructActiveProfileDropDown(addonName, optionFrames["ActiveProfile"]);
	Profiles:ConstructCopyProfileDropDown(addonName, optionFrames["CopyProfile"]);
	Profiles:ConstructCreateNewProfileFrame(addonName, optionFrames["CreateProfile"]);
end

optionFrames = {
	["ActiveProfile"] = {
		["name"] = prefix.."ActiveProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."Title",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = -10,
		["yOffset"] = -25,
		["width"] = 250,
	},
	["CopyProfile"] = {
		["name"] = prefix.."CopyProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "TOPRIGHT",
		["xOffset"] = 0,
		["yOffset"] = 0,
		["width"] = 250,
	},
	["CreateProfile"] = {
		["name"] = prefix.."CreateProfile",
		["parent"] = prefix,
		["point"] = "TOPLEFT",
		["relativeTo"] = prefix.."ActiveProfile",
		["relativePoint"] = "BOTTOMLEFT",
		["xOffset"] = 20,
		["yOffset"] = -25,
	},
};