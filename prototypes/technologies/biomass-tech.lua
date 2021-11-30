data:extend(
{
	{
		type = "technology",
		name = "kr-bio-processing",
		mod = "Warmonger",
		icon = "__Warmonger__/graphics/technologies/bio-lab.png",
		icon_size = 256, 
		icon_mipmaps = 4,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "kr-bio-lab"
			},
			{
				type = "unlock-recipe",
				recipe = "kr-biomass-growing"
			}
		},
		prerequisites = { "kovarex-enrichment-process", "power-armor-mk2"},
		unit =
		{
			count = 3000,
			
			ingredients = 
			{
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
				{"military-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1}
			},
			time = 45
		}
	}
	
})