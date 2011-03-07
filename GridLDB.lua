--[[--------------------------------------------------------------------
	GridLDB.lua
	Creates a DataBroker launcher for Grid.
----------------------------------------------------------------------]]

local GRID, Grid = ...

local L, LOCALE = Grid.L, Grid.LOCALE
if LOCALE == "deDE" then
--@localization(locale="deDE", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "deDE" then
--@localization(locale="esES", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "esMX" then
--@localization(locale="esMX", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "frFR" then
--@localization(locale="frFR", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "ruRU" then
--@localization(locale="ruRU", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "koKR" then
--@localization(locale="koKR", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "zhCN" then
--@localization(locale="zhCN", namespace="GridLDB", format="lua_additive_table")@
elseif LOCALE == "zhTW" then
--@localization(locale="zhTW", namespace="GridLDB", format="lua_additive_table")@
end

------------------------------------------------------------------------

local DataBroker = LibStub("LibDataBroker-1.1", true)
if not DataBroker then return end

local GridLDB = DataBroker:NewDataObject("Grid", {
	type = "launcher",
	label = GetAddOnInfo("Grid", "Title"),
	icon = "Interface\\AddOns\\Grid\\icon",
	OnClick = function(self, button)
		if button == "RightButton" then
			LibStub("AceConfigDialog-3.0"):Open("Grid")
		elseif not InCombatLockdown() then
			local GridLayout = Grid:GetModule("GridLayout")
			GridLayout.db.profile.FrameLock = not GridLayout.db.profile.FrameLock
			LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid")
			GridLayout:UpdateTabVisibility()
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Grid")
		if InCombatLockdown() then
			tooltip:AddLine(L["Click to toggle the frame lock."], 0.5, 0.5, 0.5)
		else
			tooltip:AddLine(L["Click to toggle the frame lock."], 0.2, 1, 0.2)
		end
		tooltip:AddLine(L["Right-Click to open the options menu."], 0.2, 1, 0.2)
	end,
})

local LDBIcon = LibStub("LibDBIcon-1.0", true)
if not LDBIcon then return end

hooksecurefunc(Grid, "OnInitialize", function(self)
	self.db.profile.minimap = self.db.profile.minimap or { }

	LDBIcon:Register("Grid", GridLDB, self.db.profile.minimap)

	self.options.args.minimap = {
		order = -3,
		name = L["Hide minimap icon"],
		desc = L["Hide minimap icon"],
		width = "double",
		type = "toggle",
		get = function()
			return self.db.profile.minimap.hide
		end,
		set = function(_, v)
			if self.db.profile.minimap.hide then
				LDBIcon:Show("Grid")
				self.db.profile.minimap.hide = nil
			else
				LDBIcon:Hide("Grid")
				self.db.profile.minimap.hide = true
			end
		end
	}

	if self.db.profile.minimap.hide then
		LDBIcon:Hide("Grid")
	else
		LDBIcon:Show("Grid")
	end
end)

hooksecurefunc(Grid, "OnProfileEnable", function(self)
	self.db.profile.minimap = self.db.profile.minimap or { }

	LDBIcon:Refresh("Grid", self.db.profile.minimap)

	if self.db.profile.minimap.hide then
		LDBIcon:Hide("Grid")
	else
		LDBIcon:Show("Grid")
	end
end)
