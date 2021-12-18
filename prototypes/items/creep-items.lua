data:extend(
{

   --[[ {
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
			condition = { "water-tile" }
		},
		stack_size = 400
	},

  {
		type = "item",
		name = "fk-creep",
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
			result = "fk-creep",
			condition_size = 1,
			condition = { "water-tile" }
		},
		stack_size = 100
	}, --]]

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
		fuel_category = "chemical",
		fuel_value = "2MJ",
		fuel_emissions_multiplier = 2.0,
		fuel_acceleration_multiplier = 0.8,
		fuel_top_speed_multiplier = 0.8,
		subgroup = "raw-material",
		order = "a[biomass]",
		stack_size = 400
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
    flags = { "not-stackable", "spawnable", "only-in-cursor" },
    stack_size = 1,
    subgroup = "terrain",
    order = "z-[collector-tools]-b[creep-collector]",
    selection_color = { r = 0.50, g = 0, b = 0.35 },
    alt_selection_color = { r = 0.55, g = 0, b = 0.40 },
    selection_mode = {
      "any-tile",
    },
    alt_selection_mode = {
      "any-tile",
    },
    selection_cursor_box_type = "not-allowed",
    alt_selection_cursor_box_type = "not-allowed",
    always_include_tiles = true,
    show_in_library = false,
    tile_filters = { "kr-creep", "fk-creep" },
    alt_tile_filters = { "kr-creep", "fk-creep" },
    tile_filter_mode = "whitelist",
    alt_tile_filter_mode = "whitelist",
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
  }

})
