--
-- ManualCover
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

---@class ManualCover: Cover, FillUnit
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
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToGround", ManualCover.getCanDischarge)
  SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanDischargeToObject", ManualCover.getCanDischarge)
end

---Register event listeners
-- @param table vehicleType vehicle type
function ManualCover.registerEventListeners(vehicleType)
  SpecializationUtil.registerEventListener(vehicleType, "onLoad", ManualCover)
  SpecializationUtil.registerEventListener(vehicleType, "onStartTipping", ManualCover)
  SpecializationUtil.registerEventListener(vehicleType, "onOpenBackDoor", ManualCover)
  SpecializationUtil.registerEventListener(vehicleType, "onFillUnitTriggerChanged", ManualCover)
  SpecializationUtil.registerEventListener(vehicleType, "onRemovedFillUnitTrigger", ManualCover)
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

  -- handle automatic cover changes only for AI
  SpecializationUtil.removeEventListener(self, "onStartTipping", Cover)
  SpecializationUtil.removeEventListener(self, "onOpenBackDoor", Cover)
  SpecializationUtil.removeEventListener(self, "onFillUnitTriggerChanged", Cover)
  SpecializationUtil.removeEventListener(self, "onRemovedFillUnitTrigger", Cover)
end

---Get cover control mode
-- @return integer controlMode current control mode
function ManualCover:getCoverControlMode()
  return self.coverControlMode or ManualCoverConstants.MODE_MANUAL
end

---Called when tipping starts
-- @param integer tipSide tip side index
function ManualCover:onStartTipping(tipSide)
  if self:getIsAIActive() then
    Cover.onStartTipping(self, tipSide)
  end
end

---Called when the back door opens
-- @param integer tipSide tip side index
function ManualCover:onOpenBackDoor(tipSide)
  if self:getIsAIActive() then
    Cover.onOpenBackDoor(self, tipSide)
  end
end

---Called when the fill trigger changes
function ManualCover:onFillUnitTriggerChanged(...)
  if self:getIsAIActive() then
    Cover.onFillUnitTriggerChanged(self, ...)
  end
end

---Called when a fill trigger is removed
-- @param integer numTriggers remaining trigger count
function ManualCover:onRemovedFillUnitTrigger(numTriggers)
  if self:getIsAIActive() then
    Cover.onRemovedFillUnitTrigger(self, numTriggers)
  end
end

---Update fill unit trigger range and allow automatic cover changes for AI
-- @param function superFunc original function
-- @param integer fillUnitIndex fill unit index
-- @param boolean isInRange true if in trigger range
function ManualCover:setFillUnitInTriggerRange(superFunc, fillUnitIndex, isInRange)
  if self:getIsAIActive() then
    return superFunc(self, fillUnitIndex, isInRange)
  end

  return FillUnit.setFillUnitInTriggerRange(self, fillUnitIndex, isInRange)
end

---Get if unloading is allowed by the cover state
-- @param function superFunc original function
-- @param table dischargeNode discharge node
-- @return boolean true if unloading is allowed
function ManualCover:getCanDischarge(superFunc, dischargeNode)
  local spec = self.spec_cover

  if spec ~= nil and spec.hasCovers and dischargeNode ~= nil and not self:getIsAIActive() then
    local covers = spec.fillUnitIndexToCovers[dischargeNode.fillUnitIndex]

    if covers ~= nil and #covers > 0 then
      if spec.isDirty or not table.hasElement(covers, spec.covers[spec.state]) then
        return false
      end
    end
  end

  return superFunc(self, dischargeNode)
end
