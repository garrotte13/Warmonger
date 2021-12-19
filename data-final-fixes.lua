local militaryrecipe = data.raw.recipe["military-science-pack"]
table.insert(data.raw.technology["military-science-pack"].effects, { type = "unlock-recipe", recipe = "biters-research-data"})
table.insert(data.raw.recipe["poison-capsule"].ingredients, {type="item", name="biomass", amount=1})
table.insert(data.raw.technology["steel-processing"].effects, { type = "unlock-recipe", recipe = "creep-processor0"})
table.insert(data.raw.technology["electric-energy-distribution-1"].effects, { type = "unlock-recipe", recipe = "creep-processor1"})


-- log(serpent.dump(data.raw.recipe))

if mods["RampantArsenal"] then
  table.insert( data.raw.recipe["repair-capsule-rampant-arsenal"].normal.ingredients, {type="item", name="biomass", amount=2} )
  table.insert( data.raw.recipe["repair-capsule-rampant-arsenal"].expensive.ingredients, {type="item", name="biomass", amount=3} )
  table.insert( data.raw.recipe["power-armor-mk3-armor-rampant-arsenal"].normal.ingredients, {type="item", name="biomass", amount=2500} )
  table.insert( data.raw.recipe["power-armor-mk3-armor-rampant-arsenal"].expensive.ingredients, {type="item", name="biomass", amount=3500} )
  table.insert( data.raw.recipe["mk3-shield-rampant-arsenal"].normal.ingredients, {type="item", name="biomass", amount=600} )
  table.insert( data.raw.recipe["mk3-shield-rampant-arsenal"].expensive.ingredients, {type="item", name="biomass", amount=800} )
  --table.insert( data.raw.recipe[""].ingredients, {type="item", name="biomass", amount=3} )
 end

 if mods["RampantIndustry"] then
  table.insert( data.raw.recipe["advanced-repair-pack-rampant-industry"].ingredients, {type="item", name="biomass", amount=2} )
  table.insert( data.raw.recipe["air-filter-2-rampant-industry"].ingredients, {type="item", name="biomass", amount=300} )
  table.insert( data.raw.recipe["air-filter-rampant-industry"].ingredients, {type="item", name="biomass", amount=120} )
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
  for i, component in pairs(militaryrecipe.ingredients) do
    for _, value in pairs(component) do
      if value == "stone-wall" then
        militaryrecipe.ingredients[i] = {type="item", name="biters-research-data", amount=1}
        break
      end
    end
  end
end