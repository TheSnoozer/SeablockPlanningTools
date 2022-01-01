require("stdlib/table")

SeablockPlanningTools = {
  commands = {},
  player = function(player_index) return game.players[player_index] end,
  on_init_functions = { add_commands },
  on_configuration_changed_functions = {}
}

require("util")

require("commands/northify_inserters")
require("commands/remove_waste")
require("commands/print_inserter")
require("commands/optimize_inserters")
require("commands/research_tree")

local function add_commands()
  for command, command_function in pairs(SeablockPlanningTools.commands) do
    commands.add_command(command, "", command_function)
  end
end

script.on_init(function()
  for _, init_function in ipairs(SeablockPlanningTools.on_init_functions) do
    init_function()
  end
end)


script.on_load(add_commands)
