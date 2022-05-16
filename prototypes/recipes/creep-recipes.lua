local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value

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
		category = "advanced-crafting",
		emissions_multiplier = 2,
		enabled = false,
		ingredients =
		{
			{"stone-wall", 2},
			{"biomass", brd_cost}
		},
		result = "biters-research-data",
		result_count = 1
	},

	{
		type = "recipe",
		name = "kr-biomass-growing",
		category = "bioprocessing",
		energy_required = 60,
		-- emissions_multiplier = 2.5,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "stone-wall", amount = 20},
			{type = "item", name = "biomass", amount = brd_cost + 1},
			{type = "fluid", name = "sulfuric-acid", amount = 35 }
		},
		result = "biters-research-data",
		result_count = 10
	},

	{
		type = "recipe",
		name = "wm-residue-sulphuric-acid",
		icon = "__Warmonger__/graphics/icons/items/mud_recycle.png",
		icon_size = 32,
		--icon_mipmaps = 4,
		category = "bioprocessing",
		subgroup = "fluid-recipes",
		energy_required = 4,
		emissions_multiplier = 1.5,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "wm-bio-remains", amount = 20},
			{type = "fluid", name = "steam", amount = 10, minimum_temperature = 400, maximum_temperature = 650},
			{type = "fluid", name = "sulfuric-acid", amount = 7 }
		},
		results=
		{
		  {type="fluid", name="sulfuric-acid", amount=25},
		  {type="fluid", name="heavy-oil", amount=5}
		}
	}

})