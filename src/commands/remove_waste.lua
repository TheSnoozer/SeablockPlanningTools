local can_be_removed

local function remove_waste_command(param)
  if not param.parameter then return game.print("missing <radius>") end

  local current_player = SeablockPlanningTools.player(param.player_index)
  local radius = tonumber(param.parameter)
  local position = current_player.position
  local x = math.floor(position.x)
  local y = math.floor(position.y)

  local area = {left_top = { x - radius, y - radius}, right_bottom = { x + radius + 1.5, y + radius + 1.5 }}
  local surface = current_player.surface
  local existing_entities = surface.find_entities_filtered{area = area, type = { "tile-ghost", "entity-ghost" }, invert = true}

  local player_owned_entities = table.filter(existing_entities, function(entity)
    return current_player == entity.last_user or entity.type == "character"
    end)

  local tiles = surface.find_tiles_filtered{ area = area }
  local changed_tiles = {}

  for _, tile in pairs(tiles) do
    if can_be_removed(tile, player_owned_entities) then
      table.insert(changed_tiles, { name = "deepwater", position = tile.position })
    end
  end

  current_player.surface.set_tiles(changed_tiles)
end


function can_be_removed(tile, entities)
  if tile.name == "deepwater" and tile.name == "water" then
    return false
  end

  local tile_area = {
    left_top = { x = tile.position.x, y = tile.position.y },
    right_bottom = { x = tile.position.x + 1, y = tile.position.y + 1 }
  }

  local result = table.any(entities, function(entity)
    local bounding_box = entity.selection_box

    return (tile_area.left_top.x < bounding_box.right_bottom.x and
      tile_area.right_bottom.x > bounding_box.left_top.x and
      tile_area.left_top.y < bounding_box.right_bottom.y and
      tile_area.right_bottom.y > bounding_box.left_top.y)
    end)

  return not result
end

SeablockPlanningTools.commands["remove-waste"] = remove_waste_command