local function dotp(v1, v2)
  return v1.x * v2.x + v1.y * v2.y
end

local function mag(v)
  return math.sqrt(math.pow(math.abs(v.x), 2) + math.pow(math.abs(v.y), 2))
end

local function vector_from(start_pos, end_pos)
  return { x = end_pos.x - start_pos.x, y = end_pos.y - start_pos.y }
end

local function inserter_swing_time(inserter)
  local selected = inserter
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

  log(serpent.block { extension = math.abs(pickup_distance - dropoff_distance) })

  local extension_time = (math.abs(pickup_distance - dropoff_distance) / inserter_parameters.extension_speed) / 60.0
  log(serpent.block { extension = math.abs(pickup_distance - dropoff_distance), extension_time = extension_time })

  local rotation_time = (angle / (2 * math.pi)) / inserter_parameters.rotation_speed / 60
  local total_swing_time = extension_time * 2 + rotation_time * 2

  return total_swing_time
end

local function modify_inserter(inserter, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)
  inserter.pickup_position = { x = inserter.position.x + pickup_x, y = inserter.position.y + pickup_y }
  inserter.drop_position = { x = inserter.position.x + dropoff_x + drop_offset_x * 0.2, y = inserter.position.y + dropoff_y + drop_offset_y * 0.2 }
end

local function is_in_bounding_box(player, inserter, position, entity)
  if not entity then
    game.print("Some inserters don't have a set pickup or target, those will be ignored")
    rendering.draw_rectangle {
      color = { r = 1 },
      width = 1,
      filled = false,
      left_top = inserter,
      left_top_offset = { -0.5, -0.5 },
      right_bottom = inserter,
      right_bottom_offset = { 0.5, 0.5 },

      time_to_live = 180,
      surface = inserter.surface}

    return false
  end

  local bounding_box = entity.bounding_box

  return (position.x <= bounding_box.right_bottom.x and
    position.x >= bounding_box.left_top.x and
    position.y <= bounding_box.right_bottom.y and
    position.y >= bounding_box.left_top.y)
end

local function optimize_inserter(player, selected)
  local current_swing_time = inserter_swing_time(selected)
  local best_swing_time = current_swing_time

  local original_swing_time = current_swing_time

  local original_pickup = selected.pickup_position
  local original_dropoff = selected.drop_position

  local best_pickup = original_pickup
  local best_dropoff = original_dropoff

  local original_pickup_target = selected.pickup_target
  local original_dropoff_target = selected.drop_target

  for pickup_x = -3, 3 do
    for pickup_y = -3, 3 do

      modify_inserter(selected, pickup_x, pickup_y, 1, 1, 0, 0)

      if is_in_bounding_box(player, selected, selected.pickup_position, original_pickup_target) then
        for dropoff_x = -3, 3 do
          for dropoff_y = -3, 3 do

            modify_inserter(selected, pickup_x, pickup_y, dropoff_x, dropoff_y, 0, 0)

            if is_in_bounding_box(player, selected, selected.drop_position, original_dropoff_target) then
              for drop_offset_x = -1, 1 do
                for drop_offset_y = -1, 1 do
                  modify_inserter(selected, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)

                  local current_swing_time = inserter_swing_time(selected)

                  if current_swing_time < best_swing_time then
                    best_swing_time = current_swing_time
                    best_pickup = selected.pickup_position
                    best_dropoff = selected.drop_position
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  selected.pickup_position = best_pickup
  selected.drop_position = best_dropoff

  rendering.draw_text {
    text = string.format("%.2fs", best_swing_time),
    surface = selected.surface,
    target = selected,
    time_to_live = 180,
    color = { r = 1, g = 1, b = 1}
  }

  if best_swing_time < original_swing_time then
    game.print(string.format("The inserter can be optimized from %f to %f", original_swing_time, best_swing_time))
    log(string.format("The inserter can be optimized from %f to %f", original_swing_time, best_swing_time))
  end
end

local function optimize_inserter_command(param)
  local current_player = SeablockPlanningTools.player(param.player_index)
  local selected = current_player.selected

  if selected == nil or selected.type ~= "inserter" then return end

  optimize_inserter(current_player, selected)
end

local function optimize_inserters_command(param)
  if not param.parameter then return game.print("missing <radius>") end

  local current_player = SeablockPlanningTools.player(param.player_index)
  local radius = tonumber(param.parameter)
  local position = current_player.position
  local x = math.floor(position.x)
  local y = math.floor(position.y)

  local area = { left_top = { x - radius, y - radius}, right_bottom = { x + radius + 1.5, y + radius + 1.5 } }
  local surface = current_player.surface
  local existing_entities = surface.find_entities_filtered{area = area, type = "inserter" }

  for _, inserter in pairs(existing_entities) do
    optimize_inserter(current_player, inserter)
  end
end

exported_commands = {
  ["optimize-inserter"] = optimize_inserter_command,
  ["optimize-inserters-in-radius"] = optimize_inserters_command
}

SeablockPlanningTools.commands = table.merge(SeablockPlanningTools.commands, exported_commands)