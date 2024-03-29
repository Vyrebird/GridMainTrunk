--[[--------------------------------------------------------------------
	Grid
	Compact party and raid unit frames.
	Copyright (c) 2006-2014 Kyle Smith (Pastamancer), Phanx
	All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info5747-Grid.html
	http://www.curse.com/addons/wow/grid
	http://www.wowace.com/addons/grid/
------------------------------------------------------------------------
	Role.lua
	Grid status module for tank/healer/damager roles.
----------------------------------------------------------------------]]

local _, Grid = ...
local L = Grid.L

local GridRoster = Grid:GetModule("GridRoster")

local GridStatusRole = Grid:NewStatusModule("GridStatusRole")
GridStatusRole.menuName = L["Role"]
GridStatusRole.options = false
GridStatusRole.defaultDB = {
	role = {
		priority = 35,
		TANK = {
			enable = true,
			hideInCombat = false,
			text = string.utf8sub(TANK, 1, 1),
			color = { r = 1, g = 1, b = 0, a = 1, ignore = true },
		},
		HEALER = {
			enable = true,
			hideInCombat = false,
			text = string.utf8sub(HEALER, 1, 1),
			color = { r = 0, g = 1, b = 0, a = 1, ignore = true },
		},
		DAMAGER = {
			enable = false,
			hideInCombat = false,
			text = string.utf8sub(DAMAGER, 1, 1),
			color = { r = 1, g = 0, b = 0, a = 1, ignore = true },
		},
	},
}

local ROLE_TEXTURE = "Interface\\LFGFRAME\\LFGROLE"
local ROLE_TEXCOORDS = {
	TANK    = { left = 33/64, right = 47/64, top = 1/16, bottom = 15/16 },
	HEALER  = { left = 49/64, right = 63/64, top = 1/16, bottom = 15/16 },
	DAMAGER = { left = 17/64, right = 31/64, top = 1/16, bottom = 15/16 },
}

function GridStatusRole:PostInitialize()
	self:Debug("PostInitialize")

	local optionsForStatus = {
		enable = false,
		color = false,
	}

	local function getSetting(info)
		local t = info[#info-1]
		local k = info[#info]
		local v = self.db.profile.role[t][k]
		if type(v) == "table" then
			self:Debug("get", t, k, v.r, v.g, v.b, v.a)
			return v.r, v.g, v.b, v.a
		else
			self:Debug("get", t, k, v)
			return v
		end
	end

	local function setSetting(info, r, g, b, a)
		local t = info[#info-1]
		local k = info[#info]
		local v = self.db.profile.role[t][k]
		self:Debug("set", t, r, g, b, a)
		if type(v) == "table" then
			v.r, v.g, v.b, v.a = r, g, b, a
		else
			self.db.profile.role[t][k] = r
		end
	end

	for role in pairs(ROLE_TEXCOORDS) do
		local roleName = role
		optionsForStatus[roleName] = {
			name = _G[roleName],
			type = "group",
			dialogInline = true,
			get = getSetting,
			set = setSetting,
			args = {
				enable = {
					name = L["Enable"],
					order = 1,
					type = "toggle",
				},
				hideInCombat = {
					name = L["Hide in combat"],
					order = 1,
					type = "toggle",
				},
				color = {
					name = L["Color"],
					order = 10,
					type = "color",
					hasAlpha = true,
				},
				text = {
					name = L["Text"],
					order = 20,
					type = "input",
				},
			}
		}
	end

	self:RegisterStatus("role", L["Role"], optionsForStatus, true)
end

function GridStatusRole:OnStatusEnable(status)
	if status ~= "role" then return end
	self:Debug("OnStatusEnable", status)

	self:RegisterEvent("ROLE_CHANGED_INFORM", "UpdateAllUnits")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateAllUnits")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateAllUnits")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateAllUnits")

	self:RegisterMessage("Grid_RosterUpdate", "UpdateAllUnits")
end

function GridStatusRole:OnStatusDisable(status)
	if status ~= "role" then return end
	self:Debug("OnStatusDisable", status)

	self:UnregisterEvent("ROLE_CHANGED_INFORM")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")

	self:UnregisterMessage("Grid_PartyTransition")

	self.core:SendStatusLostAllUnits("role")
end

function GridStatusRole:UpdateAllUnits(event)
	self:Debug("UpdateAllUnits", event)
	for guid, unit in GridRoster:IterateRoster() do
		self:UpdateUnit("UpdateAllUnits", unit, guid)
	end
end

function GridStatusRole:UpdateUnit(event, unit, guid)
	local role = UnitGroupRolesAssigned(unit) or "NONE"
	self:Debug("UpdateUnit", event, unit, "=>", role)

	local settings = self.db.profile.role
	local roleSettings = settings[role]

	if roleSettings and roleSettings.enable and not (roleSettings.hideInCombat and UnitAffectingCombat("player")) then
		self.core:SendStatusGained(guid, "role",
			settings.priority,
			nil,
			roleSettings.color,
			roleSettings.text,
			nil,
			nil,
			ROLE_TEXTURE,
			nil,
			nil,
			ROLE_TEXCOORDS[role]
		)
	else
		self.core:SendStatusLost(guid, "role")
	end
end
