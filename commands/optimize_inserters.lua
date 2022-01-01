local function inserter_swing_time(inserter)
  local dotp = SeablockPlanningTools.math.dotp
  local vector_from = SeablockPlanningTools.math.vector_from
  local mag = SeablockPlanningTools.math.mag

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
  local extension_time = (math.abs(pickup_distance - dropoff_distance) / inserter_parameters.extension_speed) / 60.0
  local rotation_time = (angle / (2 * math.pi)) / inserter_parameters.rotation_speed / 60
  local total_swing_time = extension_time * 2 + rotation_time * 2

  return total_swing_time
end

local inserter_technologies = {}

inserter_technologies.long_technology = "long-inserters-1"
inserter_technologies.long2_technology = "long-inserters-2"
inserter_technologies.near_technology = "near-inserters"
inserter_technologies.more_technology = "more-inserters-1"
inserter_technologies.more2_technology = "more-inserters-2"

function tech_unlocked(player, tech)
  return player.force.technologies[tech] and player.force.technologies[tech].researched
end

local function debug(message)
  game.print(message)
  log(message)
end

local function is_straight_or_diagonal_vector(x, y)
  local mag = SeablockPlanningTools.math.mag
  local dotp = SeablockPlanningTools.math.dotp

  local pickup_vector = { x = x, y = y }

  local base_vector = { x = 1, y = 0 }
  local pickup_distance = mag(pickup_vector)
  local base_distance = mag(base_vector)

  local angle = math.acos(dotp(pickup_vector, base_vector) / (pickup_distance * base_distance))

  local sin = math.abs(math.sin(angle))
  local cos = math.abs(math.cos(angle))

  return sin == 1 or cos == 1 or (math.abs(sin - cos) < 0.00000001)
end

local function configuration_is_unlocked(player, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)
  local extension_parameters = { pickup_x, pickup_y, dropoff_x, dropoff_y }
  --local message = string.format("%d, %d, %d, %d, %s, %s", pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)

  if not tech_unlocked(player, inserter_technologies.long_technology) and table.any(extension_parameters, function(parameter) return math.abs(parameter) > 1 end) then
    --debug(message .. " Long")
    return false
  end

  if not tech_unlocked(player, inserter_technologies.long2_technology) and table.any(extension_parameters, function(parameter) return math.abs(parameter) > 2 end) then
    --debug(message .. " Long2")
    return false
  end

  if not tech_unlocked(player, inserter_technologies.more_technology) and ((pickup_x ~= 0 and pickup_y ~= 0) or (dropoff_x ~= 0 and dropoff_y ~= 0)) then
    --debug(message .. " More")
    return false
  end

  if not tech_unlocked(player, inserter_technologies.more2_technology) and
    (not is_straight_or_diagonal_vector(pickup_x, pickup_y) or not is_straight_or_diagonal_vector(dropoff_x, dropoff_y)) then
    --debug(message .. " More2")

    return false
  end

  if drop_offset_x ~= nil and drop_offset_x ~= nil then
    local dropoff_unit_vector = SeablockPlanningTools.math.unit_vector({ x = dropoff_x, y = dropoff_y})
    local offset_unit_vector = SeablockPlanningTools.math.unit_vector({ x = drop_offset_x, y = drop_offset_y})

    if not tech_unlocked(player, inserter_technologies.near_technology) and 
      (dropoff_unit_vector.x ~= offset_unit_vector.x or dropoff_unit_vector.y ~= offset_unit_vector.y) then
      --debug(message .. " Near")
      return false
    end
  end

  --debug(message .. "TRUE")
  return true
end

local function modify_inserter(player, inserter, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)
  if player.mod_settings["spt-lawful-good-inserters"].value and not configuration_is_unlocked(player, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y) then
    return false
  end

  if drop_offset_x == nil then drop_offset_x = 0 end
  if drop_offset_y == nil then drop_offset_y = 0 end

  inserter.pickup_position = { x = inserter.position.x + pickup_x, y = inserter.position.y + pickup_y }
  inserter.drop_position = { x = inserter.position.x + dropoff_x + drop_offset_x * 0.2, y = inserter.position.y + dropoff_y + drop_offset_y * 0.2 }

  return true
end

local function is_in_bounding_box(inserter, position, entity)
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
  local valid_configuration = nil

  for pickup_x = -3, 3 do
    for pickup_y = -3, 3 do

      valid_configuration = (pickup_x ~= 0 or pickup_y ~= 0) and modify_inserter(player, selected, pickup_x, pickup_y, 1, 0, nil, nil)

      if valid_configuration and is_in_bounding_box(selected, selected.pickup_position, original_pickup_target) then
        for dropoff_x = -3, 3 do
          for dropoff_y = -3, 3 do

            valid_configuration = (dropoff_x ~= 0 or dropoff_y ~= 0) and modify_inserter(player, selected, pickup_x, pickup_y, dropoff_x, dropoff_y, nil, nil)

            if valid_configuration and is_in_bounding_box(selected, selected.drop_position, original_dropoff_target) then
              for drop_offset_x = -1, 1 do
                for drop_offset_y = -1, 1 do
                  valid_configuration = modify_inserter(player, selected, pickup_x, pickup_y, dropoff_x, dropoff_y, drop_offset_x, drop_offset_y)

                  local current_swing_time = inserter_swing_time(selected)
                  --log(current_swing_time)

                  if valid_configuration and current_swing_time < best_swing_time then

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
    text = string.format("%.2f/s", 1.0 / best_swing_time),
    scale = 0.8,
    surface = selected.surface,
    target = selected,
    time_to_live = 180,
    color = { r = 1, g = 1, b = 1}
  }

  if best_swing_time < original_swing_time then
    --game.print(string.format("The inserter can be optimized from %f to %f", original_swing_time, best_swing_time))
    --log(string.format("The inserter can be optimized from %f to %f", original_swing_time, best_swing_time))
  end
end

local function optimize_inserter_command(param)
  local current_player = SeablockPlanningTools.player(param.player_index)
  local selected = current_player.selected

  if selected == nil or selected.type ~= "inserter" then return end

  optimize_inserter(current_player, selected)
end

local function optimize_inserters_command(param)
  --debug(serpent.block(param))
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

local function listen_to_optimize_in_range(event, range)
  script.on_event(event, function(event)
    optimize_inserters_command({ player_index = event.player_index, parameter = settings.player[range].value})
  end)
end

listen_to_optimize_in_range("spt-optimize-default-range", "spt-default-range-optimizer")
listen_to_optimize_in_range("spt-optimize-small-range", "spt-small-range-optimizer")
listen_to_optimize_in_range("spt-optimize-large-range", "spt-large-range-optimizer")

exported_commands = {
  ["optimize-inserter"] = optimize_inserter_command,
  ["optimize-inserters-in-radius"] = optimize_inserters_command
}

SeablockPlanningTools.commands = table.merge(SeablockPlanningTools.commands, exported_commands)