require "mod-gui"

local function research_tree_command(param)
  if not param.parameter then
    game.print("Missing tech parameter")
    return
  end

  local current_player = SeablockPlanningTools.player(param.player_index)

  if not current_player.force.technologies[param.parameter] then
    game.print("No tech found for " .. param.parameter)
    return
  end

  local research = current_player.force.technologies[param.parameter]

  local prerequisites = { research }
  local pending_prerequisites = table.values(research.prerequisites)

  while #pending_prerequisites > 0 do
    local current_tech = table.remove(pending_prerequisites)

    if not current_tech.researched then
      for _, prerequisite in pairs(current_tech.prerequisites) do
        table.insert(pending_prerequisites, prerequisite)
      end

      table.insert(prerequisites, current_tech)
    end
  end

  for _, tech in ipairs(prerequisites) do
    current_player.force.technologies[tech.name].researched = true
  end
end

SeablockPlanningTools.commands["research-tree"] = research_tree_command