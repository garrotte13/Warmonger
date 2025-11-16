local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value

data:extend(
{

	{
		type = "recipe",
		name = "wm-ochre",
		energy_required = 8,
		category = "advanced-crafting",
		--emissions_multiplier = 2,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "stone", amount = 2},
			{type = "item", name = "iron-ore", amount = 1},
			{type = "fluid", name = "steam", amount = 35 }
		},
		results={
			{type = "item", name = "wm-ochre", amount = 2}
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