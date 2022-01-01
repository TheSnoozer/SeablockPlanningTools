Seablock Planning Tools
========================
This is an unofficial version of the Seablock Planning Tools.
Initial Author: _randomdude_ (https://mods.factorio.com/mod/SeablockPlanningTools)

Commands aided in helping plan builds in Seablock specifically, but some can be helpful elsewhere
NOTE: Some of the commands will change your game in irreversible ways. That mixed with the fact that it's a new mod, its advisable to SAVE!!! your game before executing them.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND (see LICENSE)


SeablockPlanningTools - SPT for short, is a small utility mod comprised of several commands:
	* remove-waste <radius>: This command will remove any tile of land that is not under either an entity or the player. Mostly useful to plan early game builds where unused landfill is pretty wasteful. Bear in mind that radius here should be kept small (more than 50 will freeze your game for a bit), and it's a radius centered on your player
	* northify-inserters-in-radius <radius>: Something that speeds up building blueprints before bots is having all inserters facing the same direction, so you don't need to rotate to place them. This is possible in Seablock because of bob inserters
	* northify-inserter: Will apply the same effect as the previous command but for the single selected (hovered) inserter
	* print-inserter: NERD ALERT - Tweaking bobinserters parameters of the same inserter can speed up or slow down the inserter to the point of making a build possible or not at all. This will print all parameters regarding that to help identifying optimizations. Also, there is a toggle keybind (ALT+SPACE by default) that will print the speed of inserters in a 20 radius.
	* optimize-inserters-in-radius <radius>: If you are not in the mood to manually optimize your inserters, run this command and every inserter in range will try all possible combinations that keep the same pickup and drop targets and keep the fastest one. This won't be the absolute fastest as sometimes moving an inserter can allow to use better angles, but it makes it easier
	* optimize-inserter: Single version of the previous command that works on the hovered inserter

TODO:
	* Make all of this multiplayer friendly(its fine in multiplayer with only one player in it): It 'should' work in multiplayer (with multiple players), but some things take into account things that might not be perfect. I don't think there will be many multiplayer groups planning, but if there are and they want a fix, let me know
