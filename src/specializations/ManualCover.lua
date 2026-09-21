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
  SpecializationUtil.registerFunction(vehicleType, "getIsCoverOpenForDischarge", ManualCover.getIsCoverOpenForDischarge)
end

---Register overwritten functions
-- @param table vehicleType vehicle type
function ManualCover.registerOverwrittenFunctions(vehicleType)
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToGround", ManualCover.getCanDischargeToGround)
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToObject", ManualCover.getCanDischargeToObject)
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

---Get if the discharge fill unit has an open cover
-- @param table dischargeNode discharge node
-- @return boolean true if the cover is open or the fill unit has no cover
function ManualCover:getIsCoverOpenForDischarge(dischargeNode)
  local spec = self.spec_cover

  if spec == nil or not spec.hasCovers or dischargeNode == nil then
    return true
  end

  local covers = spec.fillUnitIndexToCovers[dischargeNode.fillUnitIndex]

  if covers ~= nil and #covers > 0 then
    for i = 1, #covers do
      if spec.state == covers[i].index then
        return not spec.isDirty
      end
    end

    return false
  end

  return true
end

---Get if unloading to the ground is allowed
-- @param function superFunc original function
-- @param table dischargeNode discharge node
-- @return boolean true if unloading is allowed
function ManualCover:getCanDischargeToGround(superFunc, dischargeNode)
  if not self:getIsCoverOpenForDischarge(dischargeNode) then
    return false
  end

  return superFunc(self, dischargeNode)
end

---Get if unloading to an object is allowed
-- @param function superFunc original function
-- @param table dischargeNode discharge node
-- @return boolean true if unloading is allowed
function ManualCover:getCanDischargeToObject(superFunc, dischargeNode)
  if not self:getIsCoverOpenForDischarge(dischargeNode) then
    return false
  end

  return superFunc(self, dischargeNode)
end
