--
-- AdditionalConfiguration
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

local controlModeNames = {
  [ManualCoverConstants.MODE_MANUAL] = "coverControlMode_manual",
  [ManualCoverConstants.MODE_VEHICLE] = "coverControlMode_vehicle",
  [ManualCoverConstants.MODE_BOTH] = "coverControlMode_both"
}

---Get configurations from XML
-- @includeCode
local function getConfigurationsFromXML(manager, superFunc, xmlFile, key, baseDir, customEnvironment, isMod, storeItem)
  local configurations, defaultConfigurationIds = superFunc(manager, xmlFile, key, baseDir, customEnvironment, isMod, storeItem)

  if storeItem ~= nil and xmlFile:hasProperty("vehicle.cover") then
    configurations = configurations or {}
    defaultConfigurationIds = defaultConfigurationIds or {}

    if configurations["coverControlMode"] == nil then
      local configurationItems = {}

      for index, name in ipairs(controlModeNames) do
        local configItem = VehicleConfigurationItem.new("coverControlMode")
        configItem:setIndex(index)
        configItem.isDefault = index == ManualCoverConstants.MODE_MANUAL
        configItem.name = g_i18n:getText(name)
        table.insert(configurationItems, configItem)
      end

      configurations["coverControlMode"] = configurationItems
      defaultConfigurationIds["coverControlMode"] = ConfigurationUtil.getDefaultConfigIdFromItems(configurationItems)
    end
  end

  return configurations, defaultConfigurationIds
end

---
ConfigurationUtil.getConfigurationsFromXML = Utils.overwrittenFunction(ConfigurationUtil.getConfigurationsFromXML, getConfigurationsFromXML)
