require("stdlib/table")

SeablockPlanningTools = {
  commands = {},
  player = function(player_index) return game.players[player_index] end
}

require("commands/northify_inserters")
require("commands/remove_waste")
require("commands/print_inserter")

local function add_commands()
  for command, command_function in pairs(SeablockPlanningTools.commands) do
    commands.add_command(command, "", command_function)
  end
end

script.on_init(add_commands)
script.on_load(add_commands)
