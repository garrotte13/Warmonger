
data:extend(
{

	{
		type = "radar",
		name = "creep-miner-radar",
		-- icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		
		
		--corpse = "big-remnants",
		--collision_box = {{-0.1,-0.1},{0.1,0.1}},
		selection_box = {{-0.5,-0.5},{0.5,0.5}},
		allow_copy_paste = false,
		selection_priority = 70,

		flags = {"not-blueprintable", "not-deconstructable", "placeable-off-grid"},
		pictures = {
			filename = "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_sheet.png",
			priority = "high", width = 256, height = 256, direction_count = 16, shift = {0.1, 0.1}, scale=0.5, animation_speed=0.5,
		},
		energy_source = {type = "electric", input_priority = "secondary", usage_priority = "secondary-input", emissions_per_minute = 3.75, },
		energy_usage = "1200KW",
		max_distance_of_nearby_sector_revealed = 1,
		max_distance_of_sector_revealed = 0,
		energy_per_nearby_scan = "4.8MJ",
		

	},
	{
		type = "container",
		name = "creep-miner-chest",
		resistances = {{type = "acid",percent = 40},{type = "impact", percent = 50}},
		max_health = 500,
		inventory_size = 48,
		minable = {mining_time = 2, result = "creep-miner-chest"},
		icon_size = 32, icon =  "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		collision_box = {{-1.5,-1.5},{1.5,1.5}},
		selection_box = {{-1.5,-1.5},{1.5,1.5}},
		selection_priority = 50,
		picture = {
			filename = "__core__/graphics/empty.png",
			priority = "low",
			width = 1,
			height = 1,
			line_length = 1,
			shift = {0.1875, -0.2}
		},
	},
	{
		type="item", name="creep-miner-chest", icon_size="32", icon="__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		subgroup="production-machine", order="z[creep-miner-chest]",
		stack_size = 50,
		place_result="creep-miner-chest"
	},

	{
		type = "recipe",
		name = "creep-miner-chest",
		category = "basic-crafting",
		enabled = "false",
		energy_required = 5.00,
		ingredients = {
		  { type = "item", name = "radar" , amount = 1, },
		  { type = "item", name = "steel-furnace" , amount = 1, },
		  { type = "item", name = "steel-chest" , amount = 2, },
		  { type = "item", name = "electronic-circuit" , amount = 5, }
		},
		results = {
		  { type = "item", name = "creep-miner-chest", amount = 1.0, },
		},
		main_product = "creep-miner-chest",
		icon = "__Warmonger__/graphics/entities/creep-miner/fuel_mixer_icon.png",
		icon_size = "32"
	},

--[[	{
		type = "assembling-machine",
		name = "creep-processor0",
		icon = "__Warmonger__/graphics/icons/entities/bt-Pollution-Production-Machine.png",
		icon_size = 32,
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 1, result = "creep-processor0"},
		max_health = 400,
		corpse = "big-remnants",
		resistances = {{type = "acid",percent = 35},{type = "impact", percent = 30}},
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
		energy_usage = "60kJ",
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
		  fuel_inventory_size = 2,
		  emissions_per_minute = 20,
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
		stack_size = 25
	  },

	  {
		type = "recipe",
		name = "creep-processor0",
		enabled = false,
		energy_required = 3.00,
		ingredients =
		{
		  {"stone-brick", 10},
		  {"iron-gear-wheel", 5},
		  {"steel-plate", 4},
		  {"electronic-circuit", 7}
		},
		result = "creep-processor0"
	  },--]]
})