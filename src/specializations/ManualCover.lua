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
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "setFillUnitInTriggerRange", ManualCover.setFillUnitInTriggerRange)
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

  -- block automatic cover reactions to triggers
  SpecializationUtil.removeEventListener(self, "onFillUnitTriggerChanged", Cover)
  SpecializationUtil.removeEventListener(self, "onRemovedFillUnitTrigger", Cover)
end

---Get cover control mode
-- @return integer controlMode current control mode
function ManualCover:getCoverControlMode()
  return self.coverControlMode or ManualCoverConstants.MODE_MANUAL
end

---Sets the fill unit in trigger range
-- @param function superFunc original function
-- @param integer fillUnitIndex fill unit index
-- @param boolean isInRange true if in trigger range
function ManualCover:setFillUnitInTriggerRange(superFunc, fillUnitIndex, isInRange)
  local fillUnitSpec = self.spec_fillUnit

  -- update fillUnit state only
  if fillUnitSpec ~= nil and fillUnitSpec.fillUnitsInTriggerRange ~= nil then
    if isInRange then
      fillUnitSpec.fillUnitsInTriggerRange[fillUnitIndex] = true
    else
      fillUnitSpec.fillUnitsInTriggerRange[fillUnitIndex] = nil
    end
  end
end
