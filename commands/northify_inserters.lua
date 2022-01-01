require("stdlib/table")

local function northify_inserter(inserter)
  local pickup = inserter.pickup_position
  local dropoff = inserter.drop_position

  while inserter.direction ~= defines.direction.north do
    inserter.rotate()
  end

  inserter.pickup_position = pickup
  inserter.drop_position = dropoff
end

local function northify_inserter_command(param)
	local selected = SeablockPlanningTools.player(param.player_index).selected
	if not selected or selected.type ~= "inserter" then return end

	northify_inserter(selected)
end

local function northify_inserters_command(param)
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
		northify_inserter(inserter)
	end
end

exported_commands = {
  ["northify-inserter"] = northify_inserter_command,
  ["northify-inserters-in-radius"] = northify_inserters_command
}

SeablockPlanningTools.commands = table.merge(SeablockPlanningTools.commands, exported_commands)