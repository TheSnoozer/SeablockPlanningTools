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
    for _, recipe in pairs(module.limitation) do
      local recipe_prototype = data.raw.recipe[recipe]
      if recipe_prototype.name == "nitrogen" then
        log(serpent.block(recipe_prototype))
        log(can_be_unlocked(recipe_prototype))
        log("COMP")
        log(recipe_prototype.enabled == "false")
      end

      if not falsy(recipe_prototype.hidden) and (not falsy(recipe_prototype.enabled) or can_be_unlocked(recipe_prototype)) then
        local results = {recipe_prototype.result}
        if recipe_prototype.result == nil and recipe_prototype.results ~= nil then
          results = table.map(recipe_prototype.results, function(r) return r.name end)
        end

        if recipe_prototype.result ~= nil or recipe_prototype.results ~= nil then
          for _, result in pairs(results) do
            module_limitations = module_limitations .. "\t" .. recipe_prototype.name .. ", " .. (recipe_prototype.category or "crafting") .. ", " .. result .. "\n"
          end
        end
      end
    end

    log(module_limitations)
  end
end

-- 
-- local techs = data.raw["technology"]
-- 
-- table.each(techs, function(tech)
--   local name = tech.name
--   local ingredients = tech.unit.ingredients
-- 
--   local count = tech.unit.count
--   local time = tech.unit.time
-- 
--   local total_ingredients = {}
--   local is_normal_tech = (count ~= nil and next(ingredients))
-- 
--   if is_normal_tech then
--     table.each(ingredients, function(ingredient)
--       if table.find(science_names, function(c_name) return ingredient[1] == c_name end) == nil then
--         is_normal_tech = false
--       end
--       total_ingredients[ingredient[1]] = count * ingredient[2]
--     end)
--   end
-- 
--   log(serpent.block(tech))
--   local beakers = table.max(table.values(total_ingredients))
--   log(beakers)
-- 
--   if is_normal_tech then
--     log(string.format(",%s,,,,%d,%d, %d, %d, %d", name,
--       beakers,
--       time,
--       total_ingredients["science-pack-1"] or 0 ,
--       total_ingredients["science-pack-2"] or 0,
--       total_ingredients["science-pack-3"] or 0
--     ))
--   end
-- end)