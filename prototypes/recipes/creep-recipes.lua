local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value

data:extend(
{

	{
		type = "recipe",
		name = "wm-ochre",
		energy_required = 15,
		category = "advanced-crafting",
		--emissions_multiplier = 2,
		enabled = true,
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
		name = "kr-bio-lab",
		energy_required = 20,
		enabled = false,
		ingredients =
		{
			{type = "item", name = "biomass", amount = 900},
			{type = "item", name = "steel-plate", amount = 5},
			{type = "item", name = "iron-gear-wheel", amount = 5},
			{type = "item", name = "pipe", amount = 5},
			{type = "item", name = "advanced-circuit", amount = 5}
		},
		results={
			{type = "item", name ="kr-bio-lab",	amount = 1}
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

	{
		type = "recipe",
		name = "kr-biomass-growing",
		category = "bioprocessing",
		energy_required = 60,
		emissions_multiplier = 2,
		enabled = false,
		icon =  "__Warmonger__/graphics/icons/cards/biters-research-data.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "science-pack",
		ingredients =
		{
			{type = "item", name = "stone-wall", amount = 20},
			{type = "item", name = "biomass", amount = brd_cost + 1},
			{type = "fluid", name = "sulfuric-acid", amount = 35 }
		},
		results =
    	{
			{type = "item", name="wm-bio-remains", amount_min = math.ceil(brd_cost/3), amount_max = brd_cost+1, probability=.30},
			{type = "item", name="biters-research-data", amount = 10}
		},
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