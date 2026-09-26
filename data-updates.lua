local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value
if mods["bobenemies"] then
    for _, sp in pairs(data.raw["unit-spawner"]) do
        if sp.loot and (not string.find(sp.name, "super-spawner")) then
            --local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" then
                    --j = i
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 2)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 3))
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 3)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 5))
                end
            end
            --[[if j then
                table.remove(sp.loot,j)
            end]]
        end
    end
    for _, sp in pairs(data.raw["turret"]) do
        if sp.loot then
            --local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" then
                    --j = i
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 2)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 3))
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.ceil(sp.loot[i].count_min / 3)
                    sp.loot[i].count_max = math.max(sp.loot[i].count_min, math.ceil(sp.loot[i].count_max / 5))
                end
            end
            --[[if j then
                table.remove(sp.loot,j)
            end]]
        end
    end
    local loot_min
    for _, sp in pairs(data.raw["unit"]) do
        if sp.loot then
            --local j
            for i = 1, #sp.loot do
                if sp.loot[i].item == "bob-alien-artifact" or sp.loot[i].item == "bob-small-alien-artifact" then
                    sp.loot[i].count_min = math.floor(sp.loot[i].count_min / 2)
                    loot_min = math.max(sp.loot[i].count_min, 1)
                    sp.loot[i].count_max = math.max(loot_min, math.ceil(sp.loot[i].count_max / 3))
                    --j = i
                elseif string.find(sp.loot[i].item, "bob-alien-artifact-") then
                    sp.loot[i].count_min = math.floor(sp.loot[i].count_min / 3)
                    loot_min = math.max(sp.loot[i].count_min, 1)
                    sp.loot[i].count_max = math.max(loot_min, math.ceil(sp.loot[i].count_max / 6))
                elseif string.find(sp.loot[i].item, "bob-small-alien-artifact-") then
                    sp.loot[i].count_min = math.floor(sp.loot[i].count_min / 4)
                    loot_min = math.max(sp.loot[i].count_min, 1)
                    sp.loot[i].count_max = math.max(loot_min, math.ceil(sp.loot[i].count_max / 7))
                end
            end
            --[[if j then
                table.remove(sp.loot,j)
            end]]
        end
    end
    data:extend(
    {
      {
		type = "recipe",
		name = "wm-bob-artifact-synth",
		energy_required = 15,
		category = "advanced-crafting",
		enabled = false,
		ingredients =
		{
			{type = "item", name = "wm-bio-remains", amount = 17+brd_cost},
			{type = "item", name = "biomass", amount = 7+brd_cost}
		},
		results={
			{type = "item", name ="bob-alien-artifact", amount = 3}
		}
	  }
    })
    table.insert(data.raw.technology["bob-artifact-processing"].effects, { type = "unlock-recipe", recipe = "wm-bob-artifact-synth"})
    
end
