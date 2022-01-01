local function dotp(v1, v2)
  return v1.x * v2.x + v1.y * v2.y
end

local function mag(v)
  return math.sqrt(math.pow(math.abs(v.x), 2) + math.pow(math.abs(v.y), 2))
end

local function vector_from(start_pos, end_pos)
  return { x = end_pos.x - start_pos.x, y = end_pos.y - start_pos.y }
end

local function print_inserter_command(param)
  local current_player = SeablockPlanningTools.player(param.player_index)
  local selected = current_player.selected

  if selected == nil or selected.type ~= "inserter" then return end

  local pickup = selected.pickup_position
  local position = selected.position
  local dropoff = selected.drop_position
  local inserter_parameters = {
    extension_speed = selected.prototype.inserter_extension_speed,
    rotation_speed = selected.prototype.inserter_rotation_speed
  }

  local pickup_vector = vector_from(position, pickup)
  local dropoff_vector = vector_from(position, dropoff)
  local pickup_distance = mag(pickup_vector)
  local dropoff_distance = mag(dropoff_vector)

  local dropoff_offset = { x = 0, y = 0 }

  local angle = math.acos(dotp(pickup_vector, dropoff_vector) / (pickup_distance * dropoff_distance))

  local extension_time = math.abs(pickup_distance - dropoff_distance) / inserter_parameters.extension_speed / 60.0
  local rotation_time = (angle / (2 * math.pi)) / inserter_parameters.rotation_speed / 60

  game.print(serpent.block {
    pickup_distance = pickup_distance,
    dropoff_distance = dropoff_distance,
    angle = angle,
    rot_speed = string.format("%.2f", inserter_parameters.rotation_speed),
    extension_speed = string.format("%.2f", inserter_parameters.extension_speed),
    extension_time = string.format("%.2f", extension_time),
    rotation_time = string.format("%.2f", rotation_time),
    total_swing = string.format("%.2fs", extension_time * 2 + rotation_time * 2)
    })
end

SeablockPlanningTools.commands["print-inserter"] = print_inserter_command