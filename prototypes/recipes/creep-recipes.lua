data:extend(
{

	{
		type = "recipe",
		name = "kr-bio-lab",
		energy_required = 20,
		enabled = false,
		ingredients =
		{
			{"biomass", 200},
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
		energy_required = 20,
		category = "basic-crafting",
		enabled = false,
		-- allow_productivity = true,
		ingredients =
		{
			{"stone-wall", 5},
			{"biomass", 1}
		},
		result = "biters-research-data",
		result_count = 2
	},
	
	{
		type = "recipe",
		name = "kr-biomass-growing",
		category = "bioprocessing",
		energy_required = 300,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "stone-wall", amount = 45},			
			{type = "item", name = "biomass", amount = 1},
			{type = "fluid", name = "sulfuric-acid", amount = 20 }
		},
		result = "biters-research-data",
		result_count = 20
	}

})