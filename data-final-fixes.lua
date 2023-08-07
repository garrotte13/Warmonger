if data.raw.car["tank"].terrain_friction_modifier > 0.1 then data.raw.car["tank"].terrain_friction_modifier = 0.1 end

data.raw.tile["kr-creep"].pollution_absorption_per_second = 0.0002
data.raw.tile["fk-creep"].pollution_absorption_per_second = 0.0001

local militaryrecipe = data.raw.recipe["military-science-pack"]
table.insert(data.raw.technology["military-science-pack"].effects, { type = "unlock-recipe", recipe = "biters-research-data"})
table.insert(data.raw.technology["advanced-material-processing"].effects, { type = "unlock-recipe", recipe = "creep-miner0-radar"})
table.insert(data.raw.technology["electric-energy-distribution-2"].effects, { type = "unlock-recipe", recipe = "creep-miner1-radar"})

local pcapsule = data.raw.recipe["poison-capsule"]
pcapsule.result_count = 2
pcapsule.energy_required = pcapsule.energy_required * 2
for i=1, #pcapsule.ingredients do
  if pcapsule.ingredients[i].amount then pcapsule.ingredients[i].amount = pcapsule.ingredients[i].amount * 2 else pcapsule.ingredients[i][2] = pcapsule.ingredients[i][2] * 2 end
end
table.insert(pcapsule.ingredients, {type="item", name="wm-bio-remains", amount=3})

-- log(serpent.dump(data.raw.recipe))

if mods["RampantArsenal"] then
  if settings.startup["rampant-arsenal-enableVehicle"].value then
    data.raw.car["nuclear-tank-vehicle-rampant-arsenal"].terrain_friction_modifier = 0.1
    data.raw.car["advanced-tank-vehicle-rampant-arsenal"].terrain_friction_modifier = 0.1
  end
  pcapsule = data.raw.recipe["repair-capsule-rampant-arsenal"]
--[[  pcapsule.normal.result_count = 2
  pcapsule.normal.energy_required = pcapsule.normal.energy_required * 2
  pcapsule.expensive.result_count = 2
  pcapsule.expensive.energy_required = pcapsule.expensive.energy_required * 2

  for i=1, #pcapsule.normal.ingredients do
    if pcapsule.normal.ingredients[i].amount then pcapsule.normal.ingredients[i].amount = pcapsule.normal.ingredients[i].amount * 2 else pcapsule.normal.ingredients[i][2] = pcapsule.normal.ingredients[i][2] * 2 end
  end
  for i=1, #pcapsule.expensive.ingredients do
    if pcapsule.expensive.ingredients[i].amount then pcapsule.expensive.ingredients[i].amount = pcapsule.expensive.ingredients[i].amount * 2 else pcapsule.expensive.ingredients[i][2] = pcapsule.expensive.ingredients[i][2] * 2 end
  end ]]
  table.insert( pcapsule.normal.ingredients, {type="item", name="wm-bio-remains", amount=2} )
  table.insert( pcapsule.expensive.ingredients, {type="item", name="wm-bio-remains", amount=3} )
  pcapsule = data.raw.recipe["healing-capsule-rampant-arsenal"]
  table.insert( pcapsule.normal.ingredients, {type="item", name="wm-bio-remains", amount=2} )
  table.insert( pcapsule.expensive.ingredients, {type="item", name="wm-bio-remains", amount=3} )
  pcapsule = data.raw.recipe["speed-capsule-rampant-arsenal"]
  table.insert( pcapsule.normal.ingredients, {type="item", name="wm-bio-remains", amount=2} )
  table.insert( pcapsule.expensive.ingredients, {type="item", name="wm-bio-remains", amount=3} )


  table.insert( data.raw.recipe["power-armor-mk3-armor-rampant-arsenal"].normal.ingredients, {type="item", name="biomass", amount=2400} )
  table.insert( data.raw.recipe["power-armor-mk3-armor-rampant-arsenal"].expensive.ingredients, {type="item", name="biomass", amount=3300} )
  table.insert( data.raw.recipe["mk3-shield-rampant-arsenal"].normal.ingredients, {type="item", name="biomass", amount=450} )
  table.insert( data.raw.recipe["mk3-shield-rampant-arsenal"].expensive.ingredients, {type="item", name="biomass", amount=750} )
  --table.insert( data.raw.recipe[""].ingredients, {type="item", name="biomass", amount=3} )
 end

 if mods["RampantIndustry"] then

  pcapsule = data.raw.recipe["advanced-repair-pack-rampant-industry"]
  --[[pcapsule.result_count = 2
  pcapsule.energy_required = pcapsule.energy_required * 2
  for i=1, #pcapsule.ingredients do
    if pcapsule.ingredients[i].amount then pcapsule.ingredients[i].amount = pcapsule.ingredients[i].amount * 2 else pcapsule.ingredients[i][2] = pcapsule.ingredients[i][2] * 2 end
  end]]
  table.insert( pcapsule.ingredients, {type="item", name="wm-bio-remains", amount=1} )

  table.insert( data.raw.recipe["air-filter-2-rampant-industry"].ingredients, {type="item", name="biomass", amount=150} )
  table.insert( data.raw.recipe["air-filter-rampant-industry"].ingredients, {type="item", name="biomass", amount=90} )
 end

if mods["IndustrialRevolution"] then
  for i, component in pairs(militaryrecipe.ingredients) do
      for _, value in pairs(component) do
        if value == "gunpowder" then
          militaryrecipe.ingredients[i] = {type="item", name="biters-research-data", amount=1}
          break
        end
      end
  end
  local bitersresearch = data.raw.recipe["biters-research-data"]
  for i, component in pairs(bitersresearch.ingredients) do
    for _, value in pairs(component) do
      if value == "stone-wall" then
        bitersresearch.ingredients[i] = {type="item", name="gunpowder", amount=6}
        break
      end
    end
  end
  -- Bioprocessing recipe will be fixed later if anyone notices IR2 compatibility at all...
else
  if militaryrecipe.ingredients then
    for i, component in pairs(militaryrecipe.ingredients) do
      for _, value in pairs(component) do
        if value == "stone-wall" then
          militaryrecipe.ingredients[i] = {type="item", name="biters-research-data", amount=1}
          break
        end
      end
    end
  else
    for i, component in pairs(militaryrecipe.normal.ingredients) do
      for _, value in pairs(component) do
        if value == "stone-wall" then
          militaryrecipe.normal.ingredients[i] = {type="item", name="biters-research-data", amount=1}
          break
        end
      end
    end
    for i, component in pairs(militaryrecipe.expensive.ingredients) do
      for _, value in pairs(component) do
        if value == "stone-wall" then
          militaryrecipe.expensive.ingredients[i] = {type="item", name="biters-research-data", amount=1}
          break
        end
      end
    end
  end
end