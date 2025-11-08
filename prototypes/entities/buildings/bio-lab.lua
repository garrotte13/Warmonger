local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds      = require("__base__/prototypes/entity/sounds")
local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value

local bio_lab_working_sound =
{
	filename = "__Warmonger__/sounds/buildings/bio-lab.ogg",
	volume = 0.75,
	idle_sound = { filename = "__base__/sound/idle1.ogg" },
	aggregation =
	{
		max_count = 3,
		remove = false,
		count_already_playing = true
	}
}

data:extend(
{
	{
		type = "assembling-machine",
		name = "kr-bio-lab",
		icon_size = 64,
		icon =  "__Warmonger__/graphics/icons/entities/bio-lab.png",
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {hardness = 1, mining_time = 1, result = "kr-bio-lab"},
		max_health = 500,
		corpse = "kr-big-random-pipes-remnant",
		dying_explosion = "big-explosion",
		damaged_trigger_effect = hit_effects.entity(),
		module_specification =
		{
			module_slots = 2
		},
		allowed_effects = {"consumption", "speed", "productivity", "pollution"},
		resistances =
		{
			{type = "impact", percent = 50}
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		fluid_boxes =
		{
			{
				production_type = "input",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				base_area = 2,
				height = 1,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "input", direction = defines.direction.east, position = {0, -3} },
				}
			},
			{
				production_type = "input",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				base_area = 2,
				height = 1,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "input-output", direction = defines.direction.west, position = {0, 3} }
				}
			},
			{
				production_type = "output",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				base_area = 2,
				height = 1,
				base_level = 1,
				pipe_connections =
				{
					{ flow_direction = "output", direction = defines.direction.north, position = {3, 0} }
				}
			},
			{
				production_type = "output",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				base_area = 2,
				height = 1,
				base_level = 1,
				pipe_connections =
				{
					{ flow_direction = "output", direction = defines.direction.south, position = {-3, 0} }
				}
			},

		},
		collision_box = {{-3.25, -3.25}, {3.25, 3.25}},
		selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
		--fast_replaceable_group = "kr-greenhouse",
		animation =
		{
			layers =
			{
				{
					filename = "__Warmonger__/graphics/entities/bio-lab/bio-lab.png",
					priority = "high",
					width = 256,
					height = 256,
					frame_count = 1,
					hr_version =
					{
						filename = "__Warmonger__/graphics/entities/bio-lab/hr-bio-lab.png",
						priority = "high",
						width = 512,
						height = 512,
						frame_count = 1,
						scale = 0.5
					}
				},
				{
					filename = "__Warmonger__/graphics/entities/bio-lab/bio-lab-sh.png",
					priority = "high",
					width = 256,
					height = 256,
					shift = {0.32, 0},
					frame_count = 1,
					draw_as_shadow = true,
					hr_version =
					{
						filename = "__Warmonger__/graphics/entities/bio-lab/hr-bio-lab-sh.png",
						priority = "high",
						width = 512,
						height = 512,
						shift = {0.32, 0},
						frame_count = 1,
						draw_as_shadow = true,
						scale = 0.5
					}
				}
			}
		},
		working_visualisations =
		{
			{
				animation =
				{
					filename = "__Warmonger__/graphics/entities/bio-lab/bio-lab-working.png",
					width = 193,
					height = 171,
					shift = {0.05, -0.31},
					frame_count = 30,
					line_length = 5,
					animation_speed = 0.35,
					hr_version =
					{
						filename = "__Warmonger__/graphics/entities/bio-lab/hr-bio-lab-working.png",
						width = 387,
						height = 342,
						shift = {0.05, -0.31},
						frame_count = 30,
						line_length = 5,
						scale = 0.5,
						animation_speed = 0.35,
					}
				}
			}
		},
		crafting_categories = {"bioprocessing"},
		scale_entity_info_icon = false,
		vehicle_impact_sound = sounds.generic_impact,
        working_sound = bio_lab_working_sound,
		crafting_speed = 1,
		return_ingredients_on_change = true,
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 6 }
		},
		energy_usage = "210kW",
		ingredient_count = 3,
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
	},

	{
		type = "item",
		name = "kr-bio-lab",
		icon = "__Warmonger__/graphics/icons/entities/bio-lab.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "production-machine",
		order = "d-g2[bio-lab]",
		place_result = "kr-bio-lab",
		stack_size = 50,
	  },
	
})
