local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds      = require("__base__/prototypes/entity/sounds")
local brd_cost = settings.startup["wm-BiomassToBitersReseach"].value

local  kr_pipe_path =
 {
	north = util.empty_sprite(),
	east = util.empty_sprite(),
	south = {
	  filename = "__Warmonger__/graphics/entities/pipe-patch/hr-pipe-patch.png",
	  priority = "high",
	  width = 55,
	  height = 50,
	  scale = 0.5,
	  shift = { 0.01, -0.58 },
	},
	west = util.empty_sprite(),
  }
  

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
		module_slots = 3,
		allowed_effects = {"consumption", "speed", "pollution"},
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
				--base_area = 2,
				height = 2,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "input", direction = defines.direction.east, position = {3, 0} },
				}
			},
			{
				production_type = "output",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				--base_area = 2,
				height = 2,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "output", direction = defines.direction.west, position = {-3, 0} }
				}
			},
			{
				production_type = "input",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				--base_area = 2,
				height = 1,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "input", direction = defines.direction.north, position = {0, -3} }
				}
			},
			{
				production_type = "output",
				pipe_picture = kr_pipe_path,
				pipe_covers = pipecoverspictures(),
				volume = 1000,
				--base_area = 2,
				height = 1,
				base_level = -1,
				pipe_connections =
				{
					{ flow_direction = "output", direction = defines.direction.south, position = {0, 3} }
				}
			},

		},
		collision_box = {{-3.25, -3.25}, {3.25, 3.25}},
		selection_box = {{-3.5, -3.5}, {3.5, 3.5}},
		graphics_set = {
		animation =
		{
			layers =
			{
				{
						filename = "__Warmonger__/graphics/entities/bio-lab/hr-bio-lab.png",
						priority = "high",
						width = 512,
						height = 512,
						frame_count = 1,
						scale = 0.5
				},
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
		},
		working_visualisations =
		{
			{
				animation =
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
			emissions_per_minute = { pollution = 4 }
		},
		energy_usage = "310kW",
		ingredient_count = 4,
	},

	{
		type = "recipe",
		name = "kr-bio-lab",
		energy_required = 35,
		enabled = false,
		ingredients =
		mods["bobplates"] and
		{
			{type = "item", name = "biomass", amount = 100},
			{type = "item", name = "bob-cobalt-steel-alloy", amount = 12},
			{type = "item", name = "bob-brass-gear-wheel", amount = 5},
			{type = "item", name = "bob-plastic-pipe", amount = 8},
			{type = "item", name = "bob-glass", amount = 10},
			{type = "item", name = "advanced-circuit", amount = 12}
		}
		or
		{
			{type = "item", name = "biomass", amount = 100},
			{type = "item", name = "steel-plate", amount = 5},
			{type = "item", name = "iron-gear-wheel", amount = 5},
			{type = "item", name = "plastic-bar", amount = 8},
			{type = "item", name = "pipe", amount = 8},
			{type = "item", name = "advanced-circuit", amount = 12}
		},
		results={
			{type = "item", name ="kr-bio-lab",	amount = 1}
		}
    },

	{
		type = "recipe",
		name = "wm-residue-sulphuric-acid",
		icon = "__Warmonger__/graphics/icons/items/mud_recycle.png",
		icon_size = 32,
		--icon_mipmaps = 4,
		category = "chemistry",
		subgroup = "fluid-recipes",
		energy_required = 4,
		emissions_multiplier = 1.5,
		enabled = false,
		allow_productivity = false,
		ingredients =
		{
			{type = "item", name = "wm-bio-remains", amount = 20},
			{type = "fluid", name = "steam", amount = 20, minimum_temperature = 400},
			{type = "fluid", name = "sulfuric-acid", amount = 10 }
		},
		results=
		{
		  {type="fluid", name="sulfuric-acid", amount=35},
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
		stack_size = 10,
	  },
	
})

if brd_cost > 0 then
	data:extend(
	{
	{
		type = "recipe",
		name = "kr-biomass-growing",
		category = "bioprocessing",
		energy_required = (brd_cost + 1) * 15,
		emissions_multiplier = 2,
		enabled = false,
		--[[icon =  "__Warmonger__/graphics/icons/cards/biters-research-data.png",
		icon_size = 64,
		icon_mipmaps = 4,]]
		group = mods["bobenemies"] and "bob-resource-products" or "intermediate-products",
		subgroup = mods["bobenemies"] and "bob-alien-artifact" or "science-pack",
		order = "a00[biomass]",
		main_product = "biomass",
		allow_productivity = false,
		allow_speed = false,
		ingredients =
		mods["bobplates"] and
		{
			{type = "item", name = "wm-bio-remains", amount = math.ceil(brd_cost * 1.5) + 5},
			{type = "item", name = "biomass", amount = 2 * (brd_cost * 3 + 1)},
			{type = "fluid", name = "bob-oxygen", amount = 25 + brd_cost * 5 },
			{type = "fluid", name = "bob-pure-water", amount = 38 + brd_cost * 2 }
		}
		or
		{
			{type = "item", name = "wm-bio-remains", amount = math.ceil(brd_cost * 1.5) + 5},
			{type = "item", name = "biomass", amount = 2* (brd_cost * 3 + 1)},
			{type = "fluid", name = "petroleum-gas", amount = 20 + brd_cost * 5 },
			{type = "fluid", name = "water", amount = 46 + brd_cost * 4 }
		},
		results =
		mods["bobplates"] and
    	{
			{type = "item", name="wm-bio-remains", amount_min = 1, amount_max = 2},
			{type = "item", name="biomass", amount = 2 * (brd_cost * 3 + 1 + math.ceil(brd_cost/2))},
			{type = "fluid", name = "bob-sulfur-dioxide", amount = 8 + math.ceil(brd_cost/2)*2 }
		}
		or
		{
			{type = "item", name="wm-bio-remains", amount_min = 1, amount_max = 2},
			{type = "item", name="biomass", amount = 2 * (brd_cost * 3 + 1 + math.ceil(brd_cost/2))},
			{type = "fluid", name = "sulfuric-acid", amount = 4 + math.ceil(brd_cost/2)*2}
		}
	}
	})
end