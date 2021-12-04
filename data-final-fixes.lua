
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
	
-- military-recipe.ingredients[2] = {type="item", name=, amount=1}


-- data.raw.item.concrete.condition = {"water-tile", "layer-55"}