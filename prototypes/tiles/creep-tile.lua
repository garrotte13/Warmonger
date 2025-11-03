-- Sounds
local collect_creep_sound =
{
	filename = "__Warmonger__/sounds/tiles/creep-deconstruction.ogg",
	aggregation =
	{
		max_count = 1,
		remove = false,
		count_already_playing = true
	}
}
local creep_walking_sound =
{
	variations =
	{
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-1.ogg",
			volume = 0.75
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-2.ogg",
			volume = 0.75
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-3.ogg",
			volume = 0.75
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-4.ogg",
			volume = 0.80
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-5.ogg",
			volume = 0.75
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-6.ogg",
			volume = 0.80
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-7.ogg",
			volume = 0.75
		},
		{
			filename = "__Warmonger__/sounds/tiles/creep-walk-8.ogg",
			volume = 0.80
		}
		
	},
	aggregation =
	{
		max_count = 6,
		remove = false,
		count_already_playing = true
	}
}

-- Sprites
local water_tile_type_names = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud" }
local default_transition_group_id = 0
local water_transition_group_id = 1
local out_of_map_transition_group_id = 2
local patch_for_inner_corner_of_transition_between_transition =
{
  filename = "__base__/graphics/terrain/water-transitions/water-patch.png",
    scale = 0.5,
    width = 64,
    height = 64
}

local function make_tile_transition_from_template_variation(src_x, src_y, cnt_, line_len_, is_tall, normal_res_transition, high_res_transition)
  return
  {
    picture = normal_res_transition,
    count = cnt_,
    line_length = line_len_,
    x = src_x,
    y = src_y,
    tall = is_tall,
    hr_version =
    {
      picture = high_res_transition,
      count = cnt_,
      line_length = line_len_,
      x = 2 * src_x,
      y = 2 * (src_y or 0),
      tall = is_tall,
      scale = 0.5
    }
  }
end


local function init_transition_between_transition_common_options(base)
  local t = base or {}

  t.background_layer_offset = t.background_layer_offset or 1
  t.background_layer_group = t.background_layer_group or "zero"
  if (t.offset_background_layer_by_tile_layer == nil) then
    t.offset_background_layer_by_tile_layer = true
  end

  return t
end

local function init_transition_between_transition_water_out_of_map_options(base)
  return init_transition_between_transition_common_options(base)
end


local function make_generic_transition_template(to_tiles, group1, group2, normal_res_transition, high_res_transition, options, base_layer, background, mask)
  local t = options.base or {}
  t.to_tiles = to_tiles
  t.transition_group = group1
  t.transition_group1 = group2 and group1 or nil
  t.transition_group2 = group2
  local default_count = options.count or 16
  for k,y in pairs({inner_corner = 0, outer_corner = 288, side = 576, u_transition = 864, o_transition = 1152}) do
    local count = options[k .. "_count"] or default_count
    if count > 0 and type(y) == "number" then
      local line_length = options[k .. "_line_length"] or count
      local is_tall = true
      if (options[k .. "_tall"] == false) then
        is_tall = false
      end
      if base_layer == true then
        t[k] = make_tile_transition_from_template_variation(0, y, count, line_length, is_tall, normal_res_transition, high_res_transition)
      end
      if background == true then
        t[k .. "_background"] = make_tile_transition_from_template_variation(544, y, count, line_length, is_tall, normal_res_transition, high_res_transition)
      end
      if mask == true then
        t[k .. "_mask"] = make_tile_transition_from_template_variation(1088, y, count, line_length, nil, normal_res_transition, high_res_transition)
      end

      if options.effect_map ~= nil then
        local effect_default_count = options.effect_map.count or 16
        local effect_count = options.effect_map[k .. "_count"] or effect_default_count
        if effect_count > 0 then
          local effect_line_length = options.effect_map[k .. "_line_length"] or effect_count
          local effect_is_tall = true
          if (options.effect_map[k .. "_tall"] == false) then
            effect_is_tall = false
          end
          t[k .. "_effect_map"] = make_tile_transition_from_template_variation(0, y, effect_count, effect_line_length, effect_is_tall, options.effect_map.filename_norm, options.effect_map.filename_high)
        end
      end
    end
  end
  return t
end

local function generic_transition_between_transitions_template(group1, group2, normal_res_transition, high_res_transition, options)
  return make_generic_transition_template(nil, group1, group2, normal_res_transition, high_res_transition, options, true, true, true)
end

local function make_out_of_map_transition_template(to_tiles, normal_res_transition, high_res_transition, options, base_layer, background, mask)
  return make_generic_transition_template(to_tiles, out_of_map_transition_group_id, nil, normal_res_transition, high_res_transition, options, base_layer, background, mask)
end

local function create_transition_to_out_of_map_from_template(normal_res_template_path, high_res_template_path, options)
  return make_out_of_map_transition_template
  (
    { "out-of-map" },
    normal_res_template_path,
    high_res_template_path,
    {
      o_transition_tall = false,
      side_count = 8,
      inner_corner_count = 4,
      outer_corner_count = 4,
      u_transition_count = 1,
      o_transition_count = 1,
      base = init_transition_between_transition_common_options()
    },
    options.has_base_layer == true,
    options.has_background == true,
    options.has_mask == true
  )
end


local function water_transition_template_with_effect(to_tiles, normal_res_transition, high_res_transition, options)
  return make_generic_transition_template(to_tiles, water_transition_group_id, nil, normal_res_transition, high_res_transition, options, true, false, true)
end

local ground_to_out_of_map_transition =
  create_transition_to_out_of_map_from_template("__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
                                                "__base__/graphics/terrain/out-of-map-transition/hr-out-of-map-transition.png",
                                                { has_base_layer = false, has_background = true, has_mask = true })
local base_tile_transition_effect_maps = {}
local ttfxmaps = base_tile_transition_effect_maps


ttfxmaps.water_creep =
{
  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-mask.png",
  count = 8,
  o_transition_tall = false,
  u_transition_count = 2,
  o_transition_count = 1,
}

ttfxmaps.water_creep_to_land =
{
  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-to-land-mask.png",
  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-to-land-mask.png",
  count = 3,
  u_transition_count = 1,
  o_transition_count = 0,
}

ttfxmaps.water_creep_to_out_of_map =
{
  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-to-out-of-map-mask.png",
  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-to-out-of-map-mask.png",
  count = 3,
  u_transition_count = 0,
  o_transition_count = 0,
}


-- ~~~CREEP
local tile_graphics = require("__base__.prototypes.tile.tile-graphics")
local tile_spritesheet_layout = tile_graphics.tile_spritesheet_layout


local creep_out_of_map_transition = {
    transition_group1 = default_transition_group_id,
    transition_group2 = out_of_map_transition_group_id,
  
    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,
  
    spritesheet = "__base__/graphics/terrain/out-of-map-transition/dirt-out-of-map-transition.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    overlay_enabled = false,
}
  

local creep_transitions = {
    {
      to_tiles = water_tile_type_names,
      transition_group = water_transition_group_id,
  
      spritesheet = "__base__/graphics/terrain/water-transitions/dry-dirt.png",
      layout = tile_spritesheet_layout.transition_8_8_8_2_4,
      background_enabled = false,
      effect_map_layout = {
        spritesheet = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
        o_transition_count = 1,
      },
    },
    -- This is ground_to_out_of_map_transition (data/base/prototypes/tile/tiles.lua)
    {
      to_tiles = out_of_map_tile_type_names,
      transition_group = out_of_map_transition_group_id,
  
      background_layer_offset = 1,
      background_layer_group = "zero",
      offset_background_layer_by_tile_layer = true,
  
      spritesheet = "__base__/graphics/terrain/out-of-map-transition/out-of-map-transition.png",
      layout = tile_spritesheet_layout.transition_4_4_8_1_1,
      overlay_enabled = false,
    },
}

local creep_transitions_between_transitions = {
  {
    transition_group1 = default_transition_group_id,
    transition_group2 = water_transition_group_id,

    spritesheet = "__base__/graphics/terrain/water-transitions/dry-dirt-transition.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    background_enabled = false,
    effect_map_layout = {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-dirt-to-land-mask.png",
      o_transition_count = 0,
    },

    water_patch = patch_for_inner_corner_of_transition_between_transition,
  },
  creep_out_of_map_transition,
  {
    transition_group1 = water_transition_group_id,
    transition_group2 = out_of_map_transition_group_id,

    background_layer_offset = 1,
    background_layer_group = "zero",
    offset_background_layer_by_tile_layer = true,

    spritesheet = "__base__/graphics/terrain/out-of-map-transition/dry-dirt-shore-out-of-map-transition.png",
    layout = tile_spritesheet_layout.transition_3_3_3_1_0,
    effect_map_layout = {
      spritesheet = "__base__/graphics/terrain/effect-maps/water-dirt-to-out-of-map-mask.png",
      u_transition_count = 0,
      o_transition_count = 0,
    },
  },
}

local c_layers = {ghost = true, ground_tile = true}
if not settings.startup["wm-CreepCorrosion"].value then
  data:extend(
    {
      {
        type = "collision-layer",
        name = "creep_tile"
      }
    })
  c_layers = {ghost = true, ground_tile = true, creep_tile = true}
  local ignore_types =
  {
    ["unit"] = true,
    ["explosion"] = true,
    ["tree"] = true,
    ["combat-robot"] = true,
    ["construction-robot"] = true,
    ["logistic-robot"] = true,
    ["land-mine"] = true,
    ["vehicle"] = true,
    ["character"] = true,
    ["simple-entity"] = true,
    ["rock"] = true,
  }

  
end

data:extend(
{
	{
		type = "tile",
		name = "kr-creep",
		order = "b-a-a",
		needs_correction = false,
		can_be_part_of_blueprint = false,
    --collision_mask = { "ghost-layer", "ground-tile", "colliding-with-tiles-only" },
		--collision_mask = { layers = { ghost = true, ground_tile = true, water_tile = true},  not_colliding_with_itself = true},
    collision_mask = { layers = c_layers,  not_colliding_with_itself = true},
    minable = {mining_time = 10000},
		--minable = {mining_time = 1000, result = "biomass", probability = 0.0, amount = 0},
		walking_speed_modifier = 0.35,
		layer = 200,
    --flags = { "hidden" },
    --hidden = true,
		transition_overlay_layer_offset = 3,
		decorative_removal_probability = 0.35,
    --effect = "water", White water?
    variants = tile_variations_template
		(
			--"__Warmonger__/graphics/tiles/creep/creep.png", "__base__/graphics/terrain/masks/transition-1.png",
			"__Warmonger__/graphics/tiles/creep/creep.png",      
      "__base__/graphics/terrain/masks/transition-1.png",
			{
				max_size = 4,
				[1] = { weights =                  {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
				[2] = { probability = 1, weights = {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
				[4] = { probability = 1, weights = {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
			}
		),		
		map_color={r=80, g=60, b=65},
		absorptions_per_second = {pollution = 0.0002},
		vehicle_friction_modifier = 70,
		
		mined_sound = collect_creep_sound,
		walking_sound = creep_walking_sound,
    RestrictionsOnArtificialTiles_DoNotRegister = true,
		
		transitions = creep_transitions,
		transitions_between_transitions = creep_transitions_between_transitions
	},

	{
		type = "tile",
		name = "fk-creep", -- creep with no biomass inside
		order = "b-a-a",
		needs_correction = false,
		can_be_part_of_blueprint = false,
		--collision_mask = { "ghost-layer", "ground-tile", "floor-layer", "not-colliding-with-itself" },
    --collision_mask = { layers = { ghost = true, ground_tile = true, water_tile = true},  not_colliding_with_itself = true},
    collision_mask = { layers = c_layers,  not_colliding_with_itself = true},
    minable = {mining_time = 10000},
		--minable = {mining_time = 1000, result = "wm-bio-remains", probability = 0, amount = 0},
		walking_speed_modifier = 0.35,
		layer = 201,
    --flags = { "hidden" },
    --hidden = true,
		transition_overlay_layer_offset = 3,
    decorative_removal_probability = 0.35,
    variants = tile_variations_template
		(
			--"__Warmonger__/graphics/tiles/creep/creep.png", "__base__/graphics/terrain/masks/transition-1.png",
			"__Warmonger__/graphics/tiles/creep/creep.png",
      "__base__/graphics/terrain/masks/transition-1.png",
			{
				max_size = 4,
				[1] = { weights =                  {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
				[2] = { probability = 1, weights = {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
				[4] = { probability = 1, weights = {0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 }, },
			}
		),
		map_color={r=80, g=60, b=65},
		absorptions_per_second = {pollution = 0.0001},
		vehicle_friction_modifier = 60,
		
		mined_sound = collect_creep_sound,
		walking_sound = creep_walking_sound,
    RestrictionsOnArtificialTiles_DoNotRegister = true,
		
		transitions = creep_transitions,
		transitions_between_transitions = creep_transitions_between_transitions
	}

})
