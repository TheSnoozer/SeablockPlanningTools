local function print_inserter_command(param)
  local current_player = SeablockPlanningTools.player(param.player_index)
  local selected = current_player.selected

  if selected == nil or selected.type ~= "inserter" then return end

  print_inserter(current_player, selected)
end

local function print_inserter(player, selected)
  local dotp = SeablockPlanningTools.math.dotp
  local vector_from = SeablockPlanningTools.math.vector_from
  local mag = SeablockPlanningTools.math.mag

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
  local total_swing_time = extension_time * 2 + rotation_time * 2

  rendering.draw_text {
    text = string.format("%.2f/s", 1 / total_swing_time),
    scale = 0.8,
    surface = selected.surface,
    target = selected,
    time_to_live = 180,
    color = { r = 1, g = 1, b = 1}
  }

  if not global.show_inserters_speed[player.index] then
    game.print(serpent.block {
      pickup_distance = pickup_distance,
      dropoff_distance = dropoff_distance,
      angle = angle,
      rot_speed = string.format("%.2f", inserter_parameters.rotation_speed),
      extension_speed = string.format("%.2f", inserter_parameters.extension_speed),
      extension_time = string.format("%.2f", extension_time),
      rotation_time = string.format("%.2f", rotation_time),
      total_swing = string.format("%.2fs", total_swing_time)
    })
  end
end

script.on_event("spt-toggle-inserter-speed", function(event)
  if global.show_inserters_speed == nil then
    global.show_inserters_speed = {}
  end

  global.show_inserters_speed[event.player_index] = not global.show_inserters_speed[event.player_index]
end)

script.on_event(defines.events.on_tick, function(event)
  if game.tick % 60 == 0 then
    for player_index, current_player in pairs(game.players) do
      if global.show_inserters_speed and global.show_inserters_speed[player_index] then
        local radius = 20
        local position = current_player.position
        local x = math.floor(position.x)
        local y = math.floor(position.y)

        local area = { left_top = { x - radius, y - radius}, right_bottom = { x + radius + 1.5, y + radius + 1.5 } }
        local surface = current_player.surface
        local existing_entities = surface.find_entities_filtered{area = area, type = "inserter" }

        for _, inserter in pairs(existing_entities) do
          print_inserter(current_player, inserter)
        end
      end
    end
  end
end)

SeablockPlanningTools.commands["print-inserter"] = print_inserter_command