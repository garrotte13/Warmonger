local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value
local ochre_crafting_categories = "advanced-crafting"
local ochre_ingredients
if mods["bobplates"] then
	ochre_crafting_categories = "bob-chemical-furnace"
	ochre_ingredients =	{
		{type = "item", name = "stone", amount = 1},
		{type = "item", name = "iron-ore", amount = 3},
	}
else
	ochre_ingredients =	{
		{type = "item", name = "stone", amount = 1},
		{type = "item", name = "iron-ore", amount = 3},
		{type = "fluid", name = "steam", amount = 25 }
	}
end

data:extend(
{

	{
		type = "recipe",
		name = "wm-ochre",
		energy_required = 8,
		category = ochre_crafting_categories,
		--emissions_multiplier = 2,
		enabled = false,
		ingredients = ochre_ingredients,
		results={
			{type = "item", name = "wm-ochre", amount = 4}
		}
	},

	{
		type = "recipe",
		name = "biters-research-data",
		energy_required = 5,
		category = "advanced-crafting",
		emissions_multiplier = 2,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "stone-wall", amount = 2},
			{type = "item", name = "biomass", amount = brd_cost}
		},
		results={
			{type = "item", name ="biters-research-data", amount = 1}
		}
	},

})
