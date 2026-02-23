--
-- AdditionalConfiguration
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

---Get configurations from XML
-- @includeCode
local function getConfigurationsFromXML(manager, superFunc, xmlFile, key, baseDir, customEnvironment, isMod, storeItem)
  local configurations, defaultConfigurationIds = superFunc(manager, xmlFile, key, baseDir, customEnvironment, isMod, storeItem)

  if storeItem ~= nil and xmlFile:hasProperty("vehicle.cover") then
    if configurations == nil then
      configurations = {}
    end

    if defaultConfigurationIds == nil then
      defaultConfigurationIds = {}
    end

    if configurations["coverControlMode"] == nil then
      local configurationItems = {}

      -- manual
      local configItem1 = VehicleConfigurationItem.new("coverControlMode")
      configItem1.isDefault = true
      configItem1.name = g_i18n:getText("coverControlMode_manual")
      configItem1.index = ManualCoverConstants.MODE_MANUAL
      configItem1.saveId = tostring(ManualCoverConstants.MODE_MANUAL)
      configItem1.price = 0
      table.insert(configurationItems, configItem1)

      -- vehicle
      local configItem2 = VehicleConfigurationItem.new("coverControlMode")
      configItem2.name = g_i18n:getText("coverControlMode_vehicle")
      configItem2.index = ManualCoverConstants.MODE_VEHICLE
      configItem2.saveId = tostring(ManualCoverConstants.MODE_VEHICLE)
      configItem2.price = 0
      table.insert(configurationItems, configItem2)

      -- both
      local configItem3 = VehicleConfigurationItem.new("coverControlMode")
      configItem3.name = g_i18n:getText("coverControlMode_both")
      configItem3.index = ManualCoverConstants.MODE_BOTH
      configItem3.saveId = tostring(ManualCoverConstants.MODE_BOTH)
      configItem3.price = 0
      table.insert(configurationItems, configItem3)

      configurations["coverControlMode"] = configurationItems
      defaultConfigurationIds["coverControlMode"] = ConfigurationUtil.getDefaultConfigIdFromItems(configurationItems)
    end
  end

  return configurations, defaultConfigurationIds
end

---
ConfigurationUtil.getConfigurationsFromXML = Utils.overwrittenFunction(ConfigurationUtil.getConfigurationsFromXML, getConfigurationsFromXML)
