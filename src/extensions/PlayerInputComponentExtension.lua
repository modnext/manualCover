--
-- PlayerExtension
--
-- Author: Sławek Jaskulski
-- Copyright (C) Mod Next, All Rights Reserved.
--

local coverVehicle = nil
local toggleCoverActionId = nil

---Get targeted cover vehicle
-- @param table player player
-- @return table|nil vehicle or nil
local function getCoverVehicleFromTargeter(player)
  local node = player.targeter:getClosestTargetedNodeFromType(PlayerInputComponent)

  if node == nil then
    return nil
  end

  local object = g_currentMission:getNodeObject(node)

  if object ~= nil then
    local spec = object.spec_cover

    if spec ~= nil and spec.hasCovers and g_currentMission.accessHandler:canPlayerAccess(object, player) and object:getCoverControlMode() ~= ManualCoverConstants.MODE_VEHICLE then
      return object
    end
  end

  return nil
end

---Get action text for cover state
-- @param table vehicle vehicle with cover
-- @return string action text
local function getActionText(vehicle)
  local spec = vehicle.spec_cover

  if spec.state == #spec.covers then
    return spec.texts.closeCover
  elseif spec.state == 0 then
    return spec.texts.openCover
  end

  return spec.texts.nextCover
end

---Toggle cover callback
local function onInputToggleCover()
  if coverVehicle ~= nil then
    Cover.actionEventToggleCover(coverVehicle)
  end
end

---Called on update
-- @param table inputComponent input component
local function onPlayerInputComponentUpdate(inputComponent)
  if inputComponent.player.isOwner and g_inputBinding:getContextName() == PlayerInputComponent.INPUT_CONTEXT_NAME and toggleCoverActionId ~= nil then
    coverVehicle = nil

    local player = inputComponent.player

    if player.isControlled and not player:getIsInVehicle() then
      coverVehicle = getCoverVehicleFromTargeter(player)
    end

    g_inputBinding:setActionEventActive(toggleCoverActionId, coverVehicle ~= nil)

    if coverVehicle ~= nil then
      g_inputBinding:setActionEventText(toggleCoverActionId, getActionText(coverVehicle))
    end
  end
end

---
PlayerInputComponent.update = Utils.appendedFunction(PlayerInputComponent.update, onPlayerInputComponentUpdate)

---Register action events
-- @param table inputComponent input component
local function onPlayerInputComponentRegisterActionEvents(inputComponent)
  if inputComponent.player.isOwner then
    g_inputBinding:beginActionEventsModification(PlayerInputComponent.INPUT_CONTEXT_NAME)

    local _, eventId = g_inputBinding:registerActionEvent(InputAction.TOGGLE_COVER_ON_FOOT, inputComponent, onInputToggleCover, false, true, false, true, nil, true)

    toggleCoverActionId = eventId

    if toggleCoverActionId ~= nil then
      g_inputBinding:setActionEventActive(toggleCoverActionId, false)
      g_inputBinding:setActionEventTextPriority(toggleCoverActionId, GS_PRIO_NORMAL)
    end

    g_inputBinding:endActionEventsModification()
  end
end

---
PlayerInputComponent.registerActionEvents = Utils.appendedFunction(PlayerInputComponent.registerActionEvents, onPlayerInputComponentRegisterActionEvents)
