local constants = require("scripts.constants")
local generic_impact =
{
  {
    filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5
  },
  {
    filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5
  }
}

local trivial_smoke = function(opts)
	return
	{
	  type = "trivial-smoke",
	  name = opts.name,
	  duration = opts.duration or 600,
	  fade_in_duration = opts.fade_in_duration or 0,
	  fade_away_duration = opts.fade_away_duration or ((opts.duration or 600) - (opts.fade_in_duration or 0)),
	  spread_duration = opts.spread_duration or 600,
	  start_scale = opts.start_scale or 0.20,
	  end_scale = opts.end_scale or 1.0,
	  color = opts.color,
	  cyclic = true,
	  affected_by_wind = opts.affected_by_wind or true,
	  animation =
	  {
		width = 152,
		height = 120,
		line_length = 5,
		frame_count = 60,
		shift = {-0.53125, -0.4375},
		priority = "high",
		animation_speed = 0.25,
		filename = "__base__/graphics/entity/smoke/smoke.png",
		flags = { "smoke" }
	  }
	}
  end

data:extend(
{

	trivial_smoke{name = "apm_dark_smoke", color = {r = 0.32, g = 0.32, b = 0.32, a = 0.4}, duration=1000},
	{
		type = "radar",
		name = "creep-miner1-overlay",
		icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		
		minable = {mining_time = 1, result = "creep-miner1-overlay"},
		--corpse = "big-remnants",
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		collision_box = {{-1.4,-1.4},{1.4,1.4}},
		-- allow_copy_paste = false,
		selection_priority = 70,
		max_health = 500,
		flags = {"placeable-player", "player-creation"},
		pictures = {
			filename = "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_sheet.png",
			priority = "high", width = 256, height = 256, direction_count = 16,
			shift = {0.5, -0.325},
			 scale=0.5, animation_speed=0.5, line_length = 4
		},
		radius_visualisation_specification = {
			distance = constants.miner_range("creep-miner1-overlay"),
			sprite = {
				filename = "__Warmonger__/graphics/entities/circle-32.png",
				priority = "high",
				width = 32,
				height = 32,
				line_length = 1,
				tint = {r=0.5, g=0.2, b=0.5}
			},
			draw_in_cursor = true
		},
		energy_source = {type = "electric", input_priority = "secondary", usage_priority = "secondary-input", emissions_per_minute = 0, },
		energy_usage = "600KW",
		max_distance_of_nearby_sector_revealed = 1,
		max_distance_of_sector_revealed = 0,
		energy_per_sector = "1800KJ",
		energy_per_nearby_scan = "600KJ",
		

	},

	{
		type = "radar",
		name = "creep-miner1-radar",
		icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		--corpse = "big-remnants",
		collision_box = {{-0.1,-0.1},{0.1,0.1}},
		selection_box = {{-0.8,-0.8},{0.8,0.8}},
		allow_copy_paste = false,
		selection_priority = 70,
		create_ghost_on_death = false,
		flags = {"not-deconstructable", "player-creation"},
		radius_visualisation_specification = {
			distance = constants.miner_range("creep-miner1-radar"),
			sprite = {
				filename = "__Warmonger__/graphics/entities/circle-32.png",
				priority = "high",
				width = 32,
				height = 32,
				line_length = 1,
				tint = {r=0.5, g=0.2, b=0.5}
			},
			draw_in_cursor = true
		},
		pictures = {
			filename = "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_sheet.png",
			priority = "high", width = 256, height = 256, direction_count = 16,
			  shift = {0.5, -0.325},
			  scale=0.5, animation_speed=0.5, line_length = 4
		},
		energy_source = {type = "electric", input_priority = "secondary", usage_priority = "secondary-input", emissions_per_minute = 0, },
		energy_usage = "600KW",
		max_distance_of_nearby_sector_revealed = 1,
		max_distance_of_sector_revealed = 0,
		energy_per_sector = "2400KJ",
		energy_per_nearby_scan = "1200KJ",
		working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/radar.ogg",
          volume = 0.8
        }
      },
    max_sounds_per_type = 3,
    --audible_distance_modifier = 0.8,
    use_doppler_shift = false
    },
    radius_minimap_visualisation_color = { r = 0.059, g = 0.092, b = 0.235, a = 0.275 },

	},

	{
		type = "container",
		name = "creep-miner1-chest",
		resistances = {{type = "acid",percent = 25},{type = "fire",percent = 70},{type = "impact", percent = 40}},
		max_health = 500,
		inventory_size = 24,
		minable = {mining_time = 1, result = "creep-miner1-overlay"},
		icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		collision_box = {{-1.4,-1.4},{1.4,1.4}},
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		selection_priority = 50,
		allow_copy_paste = true,
		create_ghost_on_death = false,
		flags = {"placeable-player", "player-creation"},
		vehicle_impact_sound = generic_impact,
		open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
		close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
		picture = {
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			line_length = 1,
			-- shift = {0.1875, -0.2}
		},
	},
	{
		type="item", name="creep-miner1-overlay", icon_size="32", icon="__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		subgroup="defensive-structure", order="z[creep-miner1]",
		stack_size = 50,
		place_result="creep-miner1-overlay"
	},
	{
		type="item", name="creep-miner1-chest", icon_size="32", icon="__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		subgroup="defensive-structure", order="z[creep-miner1]",
		stack_size = 50,
		flags = {"hidden"},
		place_result="creep-miner1-chest"
	},
	{
		type="item", name="creep-miner1-radar", icon_size="32", icon="__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		subgroup="defensive-structure", order="z[creep-miner1]",
		stack_size = 50,
		flags = {"hidden"},
		place_result="creep-miner1-radar"
	},

	{
		type = "recipe",
		name = "creep-miner1-overlay",
		category = "advanced-crafting",
		enabled = "false",
		energy_required = 5.00,
		ingredients = {
		  { type = "item", name = "radar" , amount = 1 },
		  { type = "item", name = "accumulator" , amount = 2 },
		  { type = "item", name = "iron-chest" , amount = 1 },
		  { type = "item", name = "substation" , amount = 1 }
		},
		results = {
		  { type = "item", name = "creep-miner1-overlay", amount = 1.0, },
		},
		main_product = "creep-miner1-overlay",
		icon = "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		icon_size = "32"
	},

	{
		type = "item",
		name = "creep-miner0-overlay",
		icon = "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		icon_size = 64,
		subgroup = "defensive-structure",
		order = "z[creep-miner0]",
		place_result = "creep-miner0-overlay",
		stack_size = 50
	  },

	  {
		type = "item",
		name = "creep-miner0-radar",
		icon = "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		icon_size = 64,
		subgroup = "defensive-structure",
		order = "z[creep-miner0]",
		flags = {"hidden"},
		place_result = "creep-miner0-radar",
		stack_size = 50
	  },

	  {
		type = "item",
		name = "creep-miner0-chest",
		icon = "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		icon_size = 64,
		subgroup = "defensive-structure",
		order = "z[creep-miner0]",
		flags = {"hidden"},
		place_result = "creep-miner0-chest",
		stack_size = 50
	  },

	  {
		type = "recipe",
		name = "creep-miner0-overlay",
		category = "advanced-crafting",
		enabled = false,
		energy_required = 3.00,
		ingredients =
		{
			{ type = "item", name = "radar" , amount = 1, },
			{ type = "item", name = "steel-furnace" , amount = 1, },
			{ type = "item", name = "iron-chest" , amount = 1, },
			{ type = "item", name = "electronic-circuit" , amount = 5, }
		},
		result = "creep-miner0-overlay"
	  },

	  {
		type = "radar",
		name = "creep-miner0-overlay",
		icon = "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		icon_size = 64,
		flags = {"placeable-player", "player-creation"},
		minable = {mining_time = 1, result = "creep-miner0-overlay"},
		max_health = 300,
		corpse = "big-remnants",
		resistances = {{type = "acid",percent = 15},{type = "impact", percent = 40},{type = "fire",percent = 60}},
		repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
		mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
		-- open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		-- close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
		working_sound =
		{
		  sound = { filename = "__base__/sound/furnace.ogg", volume = 0.8}
		},
		collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		max_distance_of_nearby_sector_revealed = 1,
		max_distance_of_sector_revealed = 0,
		energy_per_sector = "1200KJ",
		energy_per_nearby_scan = "600KJ",
		energy_usage = "300KW",
		source_inventory_size = 1,
		energy_source =
		{
		  type = "burner",
		  fuel_categories = {"chemical"},
		  effectivity = 1,
		  fuel_inventory_size = 2,
		  emissions_per_minute = 5,
		  light_flicker =
		  {
			minimum_light_size = 1,
			light_intensity_to_size_coefficient = 0.2,
			color = {1,0.6,0},
			minimum_intensity = 0.05,
			maximum_intensity = 0.2
		  },
		  smoke =
		  {
			{
			  name = "apm_dark_smoke",
			  deviation = {0.1, 0.1},
			  frequency = 10,
			  position = nil,
			  north_position = {-0.65, -2.05},
			  south_position = {-0.65, -2.05},
			  east_position = {-0.65, -2.05},
			  west_position = {-0.65, -2.05},
			  starting_vertical_speed = 0.08,
			  starting_frame_deviation = 60,
			  slow_down_factor = 1
			}
		  }
		},
		radius_visualisation_specification = {
			distance = constants.miner_range("creep-miner0-overlay"),
			sprite = {
				filename = "__Warmonger__/graphics/entities/circle-32.png",
				priority = "high",
				width = 32,
				height = 32,
				line_length = 1,
				tint = {r=0.5, g=0.2, b=0.5}
			},
			draw_in_cursor = true
		},
		pictures =
		{
		layers =
		  {
			{
			  filename = "__Warmonger__/graphics/entities/creep-miner/centrifuge_0.png",
			  priority = "high",
			  line_length = 8,
			  width = 160,
			  height = 128,
			  animation_speed = 1.0666667,
			  apply_projection = false,
			  direction_count = 32,
			  shift = {0.4375, -0.38125},
			  hr_version =
			  {
				filename = "__Warmonger__/graphics/entities/creep-miner/hr_centrifuge_0.png",
				priority = "high",
				line_length = 8,
				width = 320,
				height = 256,
				animation_speed = 1.0666667,
				apply_projection = false,
				direction_count = 32,
				-- shift = {0.4375, -0.28125},
				shift = {0.4375, -0.38125},
				scale = 0.5
			  }
			},
		
		  
			{
			  filename = "__Warmonger__/graphics/entities/creep-miner/centrifuge_shadow.png",
			  line_length = 8,
			  priority = "high",
			  draw_as_shadow = true,
			  width = 160,
			  height = 128,
			  direction_count = 32,
			  animation_speed = 1.0666667,
			  shift = {0.4375, -0.38125},
			  hr_version =
			  {
				filename = "__Warmonger__/graphics/entities/creep-miner/hr_centrifuge_shadow.png",
				priority = "high",
				draw_as_shadow = true,
				line_length = 8,
				width = 320,
				height = 256,
				animation_speed = 1.0666667,
				apply_projection = false,
				direction_count = 32,
				shift = {0.4375, -0.38125},
				scale = 0.5
			  }
			}
		  
		}
	  },
	},

	  {
		type = "container",
		name = "creep-miner0-chest",
		resistances = {{type = "acid",percent = 15},{type = "impact", percent = 40},{type = "fire",percent = 60}},
		max_health = 300,
		inventory_size = 24,
		minable = {mining_time = 1, result = "creep-miner0-chest"},
		corpse = "big-remnants",
		create_ghost_on_death = false,
		icon_size = 64, icon =  "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		collision_box = {{-1.35,-1.35},{1.35,1.35}},
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		selection_priority = 50,
		allow_copy_paste = true,
		repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
		mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
		open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
		close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
		flags = {"placeable-player", "player-creation"},
		vehicle_impact_sound = generic_impact,
		picture = {
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			line_length = 1,
			-- shift = {0.1875, -0.2}
		},
	},

	{
		type = "radar",
		name = "creep-miner0-radar",
		icon = "__Warmonger__/graphics/icons/entities/apm_machine_base_0.png",
		icon_size = 64,
		flags = {"placeable-player", "player-creation", "not-deconstructable", "not-blueprintable"},
		-- flags = {"placeable-player", "player-creation"},
		-- minable = {mining_time = 1, result = "creep-miner0-radar"},
		-- max_health = 300,
		-- corpse = "big-remnants",
		create_ghost_on_death = false,
		resistances = {{type = "acid",percent = 15},{type = "impact", percent = 40},{type = "fire",percent = 60}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
		working_sound =
		{
		  sound = { filename = "__base__/sound/furnace.ogg", volume = 0.8}
		},
		collision_box = {{-0.1, -0.1}, {0.1, 0.1}},
		selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
		selection_priority = 70,
		allow_copy_paste = false,
		max_distance_of_nearby_sector_revealed = 1,
		max_distance_of_sector_revealed = 0,
		energy_per_sector = "1200KJ",
		energy_per_nearby_scan = "600KJ",
		energy_usage = "300KW",
		energy_source =
		{
		  type = "burner",
		  fuel_category = "chemical",
		  effectivity = 1,
		  fuel_inventory_size = 2,
		  emissions_per_minute = 5,
		  smoke =
		  {
			{
			  name = "apm_dark_smoke",
			  deviation = {0.1, 0.1},
			  frequency = 10,
			  position = nil,
			  north_position = {-0.65, -2.05},
			  south_position = {-0.65, -2.05},
			  east_position = {-0.65, -2.05},
			  west_position = {-0.65, -2.05},
			  starting_vertical_speed = 0.08,
			  starting_frame_deviation = 60,
			  slow_down_factor = 1
			}
		  }
		},
		radius_visualisation_specification = {
			distance = constants.miner_range("creep-miner0-radar"),
			sprite = {
				filename = "__Warmonger__/graphics/entities/circle-32.png",
				priority = "high",
				width = 32,
				height = 32,
				line_length = 1,
				tint = {r=0.5, g=0.2, b=0.5}
			},
			draw_in_cursor = true
		},
		pictures =
		{
		layers =
		  {
			{
			  filename = "__Warmonger__/graphics/entities/creep-miner/centrifuge_0.png",
			  priority = "high",
			  line_length = 8,
			  width = 160,
			  height = 128,
			  animation_speed = 1.0666667,
			  apply_projection = false,
			  direction_count = 32,
			  shift = {0.4375, -0.38125},
			  hr_version =
			  {
				filename = "__Warmonger__/graphics/entities/creep-miner/hr_centrifuge_0.png",
				priority = "high",
				line_length = 8,
				width = 320,
				height = 256,
				animation_speed = 1.0666667,
				apply_projection = false,
				direction_count = 32,
				-- shift = {0.4375, -0.28125},
				shift = {0.4375, -0.38125},
				scale = 0.5
			  }
			},
		
		  
			{
			  filename = "__Warmonger__/graphics/entities/creep-miner/centrifuge_shadow.png",
			  line_length = 8,
			  priority = "high",
			  draw_as_shadow = true,
			  width = 160,
			  height = 128,
			  direction_count = 32,
			  animation_speed = 1.0666667,
			  shift = {0.4375, -0.38125},
			  hr_version =
			  {
				filename = "__Warmonger__/graphics/entities/creep-miner/hr_centrifuge_shadow.png",
				priority = "high",
				draw_as_shadow = true,
				line_length = 8,
				width = 320,
				height = 256,
				animation_speed = 1.0666667,
				apply_projection = false,
				direction_count = 32,
				shift = {0.4375, -0.38125},
				scale = 0.5
			  }
			}
		  
		}
	  },
	}

})