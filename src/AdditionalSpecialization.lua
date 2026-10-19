--
-- AdditionalSpecialization
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

local modName = g_currentModName
local specializationName = modName .. ".manualCover"

AdditionalSpecialization = {}

---Finalize types
-- @param table typeManager type manager
function AdditionalSpecialization.finalizeTypes(typeManager)
  if typeManager.typeName ~= "vehicle" or not g_modIsLoaded[modName] then
    return
  end

  -- iterate types
  for typeName, typeEntry in pairs(typeManager:getTypes()) do
    if typeEntry.specializationsByName["cover"] ~= nil and typeEntry.specializationsByName[specializationName] == nil then
      typeManager:addSpecialization(typeName, specializationName)
    end
  end
end

---Called when finalizing vehicle types
TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, AdditionalSpecialization.finalizeTypes)
