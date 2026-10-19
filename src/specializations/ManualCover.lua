--
-- ManualCover
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

ManualCover = {}

---Initialize specialization
function ManualCover.initSpecialization()
  g_vehicleConfigurationManager:addConfigurationType("coverControlMode", g_i18n:getText("configuration_coverControlMode"), "coverControlMode", VehicleConfigurationItem)
end

---Returns if all prerequisite specializations are present
-- @param table specializations specializations table
-- @return boolean true if all prerequisites are present
function ManualCover.prerequisitesPresent(specializations)
  return SpecializationUtil.hasSpecialization(Cover, specializations)
end

---Register functions
-- @param table vehicleType vehicle type
function ManualCover.registerFunctions(vehicleType)
  SpecializationUtil.registerFunction(vehicleType, "getCoverControlMode", ManualCover.getCoverControlMode)
end

---Register overwritten functions
-- @param table vehicleType vehicle type
function ManualCover.registerOverwrittenFunctions(vehicleType)
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToGround", ManualCover.getCanDischarge)
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToObject", ManualCover.getCanDischarge)
end

---Register event listeners
-- @param table vehicleType vehicle type
function ManualCover.registerEventListeners(vehicleType)
  SpecializationUtil.registerEventListener(vehicleType, "onLoad", ManualCover)
end

---Called on load
-- @param table savegame savegame
function ManualCover:onLoad(savegame)
  local spec = self.spec_cover

  if spec == nil or not spec.hasCovers then
    return
  end

  -- read control mode
  self.coverControlMode = self.configurations["coverControlMode"] or ManualCoverConstants.MODE_MANUAL

  -- block cover action registration in manual mode
  if self.coverControlMode == ManualCoverConstants.MODE_MANUAL then
    SpecializationUtil.removeEventListener(self, "onRegisterActionEvents", Cover)
  end

  -- block automatic cover reactions to triggers and tipping
  spec.openCoverWhileTipping = false

  for i = 1, #spec.covers do
    spec.covers[i].autoReactToTrigger = false
    spec.covers[i].forceOpenOnTip = false
  end

  SpecializationUtil.removeEventListener(self, "onFillUnitTriggerChanged", Cover)
  SpecializationUtil.removeEventListener(self, "onRemovedFillUnitTrigger", Cover)

  -- block automatic cover opening while unloading
  SpecializationUtil.removeEventListener(self, "onStartTipping", Cover)
  SpecializationUtil.removeEventListener(self, "onOpenBackDoor", Cover)
end

---Get cover control mode
-- @return integer controlMode current control mode
function ManualCover:getCoverControlMode()
  return self.coverControlMode or ManualCoverConstants.MODE_MANUAL
end

---Get if unloading is allowed by the cover state
-- @param function superFunc original function
-- @param table dischargeNode discharge node
-- @return boolean true if unloading is allowed
function ManualCover:getCanDischarge(superFunc, dischargeNode)
  local spec = self.spec_cover

  if spec ~= nil and spec.hasCovers and dischargeNode ~= nil then
    local covers = spec.fillUnitIndexToCovers[dischargeNode.fillUnitIndex]

    if covers ~= nil and #covers > 0 then
      if spec.isDirty or not table.hasElement(covers, spec.covers[spec.state]) then
        return false
      end
    end
  end

  return superFunc(self, dischargeNode)
end
