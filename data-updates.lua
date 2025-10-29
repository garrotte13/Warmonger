if mods["bobenemies"] then
    for _, sp in pairs(data.raw["unit-spawner"]) do
        if sp.loot and (not string.find(sp.name, "super-spawner")) then
            local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" then
                    j = i
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 3)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 5))
                end
            end
            if j then
                table.remove(sp.loot,j)
            end
        end
    end
    for _, sp in pairs(data.raw["turret"]) do
        if sp.loot then
            local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" then
                    j = i
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 3)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 5))
                end
            end
            if j then
                table.remove(sp.loot,j)
            end
        end
    end
    for _, sp in pairs(data.raw["unit"]) do
        if sp.loot then
            local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" or sp.loot[i].item == "bob-small-alien-artifact" then
                    j = i
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.floor(sp.loot[i].count_min / 3)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 6))
                elseif string.find(sp.loot[i].item, "bob-small-alien-artifact-") then
                    sp.loot[i].count_min = math.floor(sp.loot[i].count_min / 4)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 7))
                end
            end
            if j then
                table.remove(sp.loot,j)
            end
        end
    end
    data:extend(
    {
      {
		type = "recipe",
		name = "wm-bob-artifact-synth",
		energy_required = 10,
		category = "advanced-crafting",
		enabled = false,
		ingredients =
		{
			{type = "item", name = "wm-bio-remains", amount = 30},
			{type = "item", name = "biomass", amount = 12}
		},
		results={
			{type = "item", name ="bob-alien-artifact", amount = 2}
		}
	  },


    })
    table.insert(data.raw.technology["bob-artifact-processing"].effects, { type = "unlock-recipe", recipe = "wm-bob-artifact-synth"})
    
end
