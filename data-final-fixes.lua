
local militaryrecipe = data.raw.recipe["military-science-pack"]
for i, component in pairs(militaryrecipe.ingredients) do
      for _, value in pairs(component) do
        if value == "stone-wall" then
          militaryrecipe.ingredients[i] = {type="item", name="biters-research-data", amount=1}
          break
        end
      end
end
table.insert(data.raw.technology["military-science-pack"].effects, { type = "unlock-recipe", recipe = "biters-research-data"})
table.insert(data.raw.recipe["poison-capsule"].ingredients, {type="item", name="biomass", amount=1})

-- RampantArsenal
-- table.insert( data.raw.recipe["repair"].normal.ingredients, {type="item", name="biomass", amount=2} )
--

if mods["IndustrialRevolution"] then
  local militaryrecipe = data.raw.recipe["military-science-pack"]
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

end