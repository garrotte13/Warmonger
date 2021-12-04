data:extend(
{

	{
		type = "recipe",
		name = "kr-bio-lab",
		energy_required = 20,
		enabled = false,
		ingredients =
		{
			{"biomass", 900},
			{"steel-plate", 5},
			{"iron-gear-wheel", 5},
			{"pipe", 5},
			{"electronic-circuit", 5}
		},
		result = "kr-bio-lab"
    },

	{
		type = "recipe",
		name = "biters-research-data",
		energy_required = 5,
		category = "basic-crafting",
		enabled = false,
		ingredients =
		{
			{"stone-wall", 2},
			{"biomass", 6}
		},
		result = "biters-research-data",
		result_count = 1
	},

	{
		type = "recipe",
		name = "kr-biomass-growing",
		category = "bioprocessing",
		energy_required = 60,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "stone-wall", amount = 20},
			{type = "item", name = "biomass", amount = 6},
			{type = "fluid", name = "sulfuric-acid", amount = 10 }
		},
		result = "biters-research-data",
		result_count = 10
	}

})