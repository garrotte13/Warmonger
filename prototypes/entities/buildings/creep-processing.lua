
data:extend(
{

	{
		type = "assembling-machine",
		name = "creep-processor1",
		icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-processor1/crusher33_icon.png",
		flags = {"placeable-neutral","player-creation"},
		minable = {mining_time = 1, result = "creep-processor1"},
		max_health = 500,
		corpse = "big-remnants",
		resistances = {{type = "acid",percent = 40},{type = "impact", percent = 50}},
		collision_box = {{-1.2,-1.2},{1.2,1.2}},
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		animation = {
			filename = "__Warmonger__/graphics/entities/creep-processor1/crusher33_sheet.png",
			priority = "medium", width = 128, height = 128, frame_count = 12, shift = {0.4, 0.1}, scale=0.85, animation_speed=0.5,
		},
		crafting_categories = {"creep-raw-material-recipe"},
		crafting_speed = 1.0,
		--mining_drill_radius = 10,
		--reach_resource_distance = 10,
		--reach_distance = 10,
		--created_effect = {}
		energy_source = {type = "electric", input_priority = "secondary", usage_priority = "secondary-input", emissions_per_minute = 3.75, },
		energy_usage = "600kW",
		ingredient_count = 1,
		return_ingredients_on_change = false,
		show_recipe_icon = false,
		fixed_recipe = "biomass-collecting",
		--{{fluid_boxes =
		{
			off_when_no_fluid_recipe = true,
			{
				production_type = "input",
				--pipe_covers = pipecoverspictures(),
				base_area = 10,
				base_level = -1,
				pipe_connections = {{ type="input", position = { 0, 2} }}
			},
			{
				production_type = "output",
				--pipe_covers = pipecoverspictures(),
				base_level = 1,
				pipe_connections = {{position = { 0, -2} }}
			},
		},--]]
		allowed_effects = nil
	},

	{
		type="item", name="creep-processor1", icon_size="32", icon="__Warmonger__/graphics/entities/creep-processor1/crusher33_icon.png",
		subgroup="production-machine", order="c1",
		stack_size = 25,
		place_result="creep-processor1",
	 },

	{
		type = "assembling-machine",
		name = "creep-processor0",
		icon = "__Warmonger__/graphics/icons/entities/bt-Pollution-Production-Machine.png",
		icon_size = 32,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1, result = "creep-processor0"},
		max_health = 400,
		corpse = "big-remnants",
		resistances = {{type = "acid",percent = 20},{type = "impact", percent = 30}},
		repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
		mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
		open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
		close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
		vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
		working_sound =
		{
		  sound = { filename = "__base__/sound/furnace.ogg", }
		},
		collision_box = {{-1.35, -0.85}, {1.35, 0.85}},
		selection_box = {{-1.5, -1}, {1.5, 1}},
		crafting_categories = {"creep-raw-material-recipe"},
		result_inventory_size = 1,
		energy_usage = "100kW",
		crafting_speed = 1,
		source_inventory_size = 1,
		fixed_recipe = "biomass-collecting",
		show_recipe_icon = false,
		return_ingredients_on_change = false,
		allowed_effects = nil,
		energy_source =
		{
		  type = "burner",
		  fuel_category = "chemical",
		  effectivity = 1,
		  fuel_inventory_size = 1,
		  emissions = 1,
		  smoke =
		  {
			{
			  name = "smoke",
			  deviation = {0.1, 0.1},
			  frequency = 5,
			  position = util.by_pixel(0, -90),
			  starting_vertical_speed = 0.08,
			  starting_frame_deviation = 60
			}
		  }
		},
		animation =
		{
		layers =
		  {
			{
			  filename = "__Warmonger__/graphics/entities/creep-processor0/bt-Pollution-Production-Machine.png",
			  priority = "extra-high",
			  width = 157,
			  height = 121,
			  frame_count = 1,
			  shift = util.by_pixel(32, -20)
			}
		  }
		},
		working_visualisations =
		{
		  {
			north_position = {0.0, 0.0},
			east_position = {0.0, 0.0},
			south_position = {0.0, 0.0},
			west_position = {0.0, 0.0},
			animation =
			{
			  filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
			  line_length = 10,
			  priority = "extra-high",
			  width = 20,
			  height = 40,
			  frame_count = 60,
			  animation_speed = 0.75,
			  shift = util.by_pixel(0, -90)
			}
		  }
		}
	  },

	  {
		type = "item",
		name = "creep-processor0",
		icon = "__Warmonger__/graphics/icons/entities/bt-Pollution-Production-Machine.png",
		icon_size = 32,
		subgroup = "production-machine",
		order = "z[creep-processor0]",
		place_result = "creep-processor0",
		stack_size = 50
	  },

	  {
		type = "recipe",
		name = "creep-processor0",
		enabled = false,
		ingredients =
		{
		  {"stone-brick", 10},
		  {"iron-plate", 5}
		},
		result = "creep-processor0"
	  },

	  {
		type = "recipe",
		name = "creep-processor1",
		category = "crafting",
		enabled = "true",
		energy_required = 2.00,
		ingredients = {
		  { type = "item", name = "assembling-machine-2" , amount = 1.0, },
		  { type = "item", name = "electric-furnace" , amount = 1.0, },
		},
		results = {
		  { type = "item", name = "creep-processor1", amount = 1.0, },
		},
		main_product = "creep-processor1",
		icon = "__Warmonger__/graphics/entities/creep-processor1/crusher33_icon.png",
		icon_size = "32"

	  },

	  {
		type = "item",
		name = "extracted-creep",
		icon = "__Warmonger__/graphics/icons/items/creep-virus.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures = {
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items/creep-virus.png",
        scale = 0.25,
        mipmap_count = 4,
      },
		},
		order = "z[extracted-creep]",
		subgroup = "raw-material",
		hidden = true,
		stack_size = 500
	},

	  {
		type = "recipe",
		name = "biomass-collecting",
		enabled = "true",
		energy_required = 2,
		ingredients = {{type = "item", name = "extracted-creep", amount = 20}},
		result = "biomass",
		result_count = 1,
		category="creep-raw-material-recipe",
		order="dfd1",
	},
})