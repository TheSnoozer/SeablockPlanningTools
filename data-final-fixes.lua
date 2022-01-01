log("WADUS")
require("stdlib/table")

local smeltable_entities = table.filter(data.raw.recipe, function(e)
  return e.category == "smelting"
end)

log("SMELTABLE")
table.each(smeltable_entities, function(e)
  log(e.name)
end)
log("END SMELTABLE")

--table.each(data.raw.technology, function(t)
--  log(serpent.block(t))
--end)

local function falsy(boolean)
  return boolean == "false" or boolean == false
end

local function can_be_unlocked(recipe)
  local unlocking_technology = table.find(data.raw.technology, function(technology)
    local effects = technology.effects or {}
    local unlock_effect = table.any(effects, function(e)
      return e.type == "unlock-recipe" and e.recipe == recipe.name
    end)

    if recipe.name == "nitrogen" and unlock_effect and not falsy(technology.enabled) then
      log(serpent.block(technology))
      log(serpent.block(unlock_effect))
    end

    return unlock_effect and technology.enabled ~= false
  end)

  return unlocking_technology ~= nil
end

for i, module in pairs(data.raw.module) do
  if module.limitation and module.effect.productivity then
    local module_limitations = module.name .. "\n"
    all_limitations = ""
    for _, recipe in pairs(module.limitation) do
      local recipe_prototype = data.raw.recipe[recipe]
      all_limitations = all_limitations .. "\n" .. recipe_prototype.name
      if recipe_prototype.name == "angelsore1-crushed-processing" then
        log(serpent.block(recipe_prototype))
        log(can_be_unlocked(recipe_prototype))
        log("COMP")
        log(recipe_prototype.enabled == "false")
        log(falsy(recipe_prototype.hidden))
        log(falsy(recipe_prototype.enabled))
      end
      if recipe_prototype.name == "nitrogen" then
        log(serpent.block(recipe_prototype))
        log(can_be_unlocked(recipe_prototype))
        log("COMP")
        log(recipe_prototype.enabled == "false")
      end

      if not falsy(recipe_prototype.hidden) and (not falsy(recipe_prototype.enabled) or can_be_unlocked(recipe_prototype)) then
        local prototype_result = recipe_prototype.result or (recipe_prototype.normal and recipe_prototype.normal.result)
        local prototype_results = recipe_prototype.results or (recipe_prototype.normal and recipe_prototype.normal.results)
        local results = {prototype_result}

        if prototype_result == nil and prototype_results ~= nil then
          results = table.map(prototype_results, function(r) return r.name end)
        end


        if recipe_prototype.name == "angelsore1-crushed-processing" then
          log(serpent.block(table.map(recipe_prototype.normal.results, function(r) return r.name end)))
          log(table.map(recipe_prototype.normal.results, function(r) return r.name end))
          log(serpent.block(results))
        end

        if prototype_result ~= nil or prototype_results ~= nil then
          for _, result in pairs(results) do
            module_limitations = module_limitations .. "\t" .. recipe_prototype.name .. ", " .. (recipe_prototype.category or "crafting") .. ", " .. result .. "\n"
          end
        end
      end
    end

    log(module_limitations)
    log(all_limitations)
  end
end
