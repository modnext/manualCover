--
-- AdditionalSpecialization
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

local modName = g_currentModName

-- specializations to add
local additionalSpecsBySpecialization = {
  ["cover"] = {
    modName .. ".manualCover",
  },
}

AdditionalSpecialization = {}

---Finalize types
-- @param table typeManager type manager
function AdditionalSpecialization.finalizeTypes(typeManager)
  if typeManager.typeName ~= "vehicle" or not g_modIsLoaded[modName] then
    return
  end

  -- iterate types
  for typeName, typeEntry in pairs(typeManager:getTypes()) do
    -- iterate specializations
    for specIndex = #typeEntry.specializationNames, 1, -1 do
      local currentSpecName = typeEntry.specializationNames[specIndex]

      -- check for additional specs
      for baseSpec, additionalSpecs in pairs(additionalSpecsBySpecialization) do
        if currentSpecName == baseSpec then
          for i = 1, #additionalSpecs do
            local additionalSpec = additionalSpecs[i]

            if typeEntry.specializationsByName[additionalSpec] == nil then
              typeManager:addSpecialization(typeName, additionalSpec)
            end
          end
        end
      end
    end
  end
end

---Called when finalizing vehicle types
TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, AdditionalSpecialization.finalizeTypes)
