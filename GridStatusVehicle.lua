--
-- Provides a status indicating whether a unit is currently driving a vehicle
-- with a ui or not.

local L = AceLibrary("AceLocale-2.2"):new("Grid")

GridStatusVehicle = GridStatus:NewModule("GridStatusVehicle")
GridStatusVehicle.menuName = L["In Vehicle"]

GridStatusVehicle.defaultDB = {
	debug = false,
	alert_vehicleui = {
		text = L["Driving"],
		enable = false,
		color = { r = 0.8, g = 0.8, b = 0.8, a = 0.7 },
		priority = 50,
		range = false,
	},
}

GridStatusVehicle.options = false

function GridStatusVehicle:OnInitialize()
	self.super.OnInitialize(self)
	self:RegisterStatus("alert_vehicleui", L["In Vehicle"], nil, true)
end

function GridStatusVehicle:OnEnable()
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateUnit")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateUnit")
end

function GridStatusVehicle:UpdateUnit(unitid)
	local guid = UnitGUID(unitid)

	if UnitHasVehicleUI(unitid) then
		local settings = self.db.profile.alert_vehicleui

		self.core:SendStatusGained(
								   guid,
								   "alert_vehicleui",
								   settings.priority,
								   (settings.range and 40),
								   settings.color,
								   settings.text,
								   nil,
								   nil,
								   settings.icon
							   )
	else
		self.core:SendStatusLost(guid, "alert_vehicleui")
	end
end
