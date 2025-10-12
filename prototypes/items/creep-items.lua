data:extend(
{
--[[
   {
		type = "item",
		name = "kr-creep",
		icon = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures = {
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-1.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-2.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-3.png",
        scale = 0.25,
        mipmap_count = 4,
      },
    },
		subgroup = "terrain",
		order = "z[creep]-z[creep]",
		place_as_tile =
		{
			result = "kr-creep",
			condition_size = 1,
			condition = { layers = { water_tile = true} }
		},
		stack_size = 100
	},

  {
		type = "item",
		name = "fk-creep",
		--icon = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
    icon = "__base__/graphics/icons/dry-tree.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures = {
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-1.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-2.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-3.png",
        scale = 0.25,
        mipmap_count = 4,
      },
    },
		subgroup = "terrain",
		order = "z[creep]-z[creep]",
		place_as_tile =
		{
			result = "fk-creep",
			condition_size = 1,
      condition = { layers = { water_tile = true} }
		},
		stack_size = 100
	},
]]
	{
		type = "item",
		name = "biomass",
		icon = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures = {
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-1.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-2.png",
        scale = 0.25,
        mipmap_count = 4,
      },
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items-with-variations/biomass/biomass-3.png",
        scale = 0.25,
        mipmap_count = 4,
      },
    },
	--	fuel_category = "chemical",
	--	fuel_value = "2MJ",
	--	fuel_emissions_multiplier = 2.0,
	--	fuel_acceleration_multiplier = 0.8,
	--	fuel_top_speed_multiplier = 0.8,
		subgroup = "raw-material",
		order = "a[biomass]",
		stack_size = 100
	},

  {
		type = "item",
		name = "wm-bio-remains",
		icon = "__Warmonger__/graphics/icons/items/dry_mud_icon.png",
		icon_size = 32,
		--icon_mipmaps = 4,
		pictures = {
      {
        size = 32,
        filename = "__Warmonger__/graphics/icons/items/dry_mud_icon.png",
        scale = 0.5,
      },
    },
		fuel_category = "chemical",
		fuel_value = "1MJ",
		fuel_emissions_multiplier = 2.0,
		fuel_acceleration_multiplier = 0.9,
		fuel_top_speed_multiplier = 0.9,
		subgroup = "raw-material",
		order = "a[wm-bio-remains]",
		stack_size = 150
	},

  {
		type = "item",
		name = "wm-ochre",
		icon = "__Warmonger__/graphics/icons/items/apm_slag.png",
		icon_size = 64,
		icon_mipmaps = 4,
		pictures = {
      {
        size = 64,
        filename = "__Warmonger__/graphics/icons/items/apm_slag.png",
        scale = 0.5,
      },
    },
		subgroup = "raw-material",
		order = "a[wm-ochre]",
		stack_size = 50
	},

  {
    type = "selection-tool",
    name = "kr-creep-collector",
    icon = "__Warmonger__/graphics/icons/items/creep-collector.png",
    icon_size = 64,
    icon_mipmaps = 4,
    pictures = {
      { size = 64, filename = "__Warmonger__/graphics/icons/items/creep-collector.png", scale = 0.25, mipmap_count = 4 },
    },
    flags = { "not-stackable", "spawnable", "only-in-cursor"},
    hidden = true,
    stack_size = 1,
    subgroup = "terrain",
    order = "z-[collector-tools]-b[creep-collector]",
    select = {
      border_color = { r = 0.50, g = 0, b = 0.35 },
		  cursor_box_type = "not-allowed",
		  mode =  { "any-tile", },
      tile_filters = { "kr-creep", "fk-creep" },
      tile_filter_mode = "whitelist",
    },
    alt_select = {
      border_color = { r = 0.55, g = 0.35, b = 0.40 },
		  cursor_box_type = "not-allowed",
		  mode =  { "any-tile", },
      tile_filters = { "kr-creep", "fk-creep" },
      tile_filter_mode = "whitelist",
    },
    always_include_tiles = true,
    show_in_library = false,
  },

	{
		type = "item",
		name = "biters-research-data",
		icon =  "__Warmonger__/graphics/icons/cards/biters-research-data.png",
		icon_size = 64,
		icon_mipmaps = 4,
		subgroup = "science-pack",
		order = "a01[biters-research-data]",
		stack_size = 200
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

--[[
  {
    type = "flying-text",
    name = "true_creep_protected",
    speed = 0.01,
    time_to_live = 150,
    text_alignment = "center",
    --localised_name = "message.wm-true-creep-protected",

  }
]]

})
