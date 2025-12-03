local ICONPATH = "__Warmonger__/graphics/testbot/icons/"
data:extend({
 {
    type = "item-subgroup",
    name = "wm-devices",
    group = "combat",
    order = "c-2",
 },
 {
    type = "item",
    name = "wm-droid-1",
    icon = ICONPATH .. "droid_flame_undep.png",
    icon_size = 64,
    flags = {},
    place_result = "wm-droid-1",
    stack_size = 25,
    subgroup = "wm-devices",
    order = "z[droid]-e",
  },
  --[[{
    type = "item",
    name = "wm-droid-1-dummy",
    icon_size = 64,
    icon = ICONPATH .. "droid_flame.png",
    flags = {},
    order = "z-z",
    subgroup = "capsule",
    
    stack_size = 1,
  },]]

  {
    type = "recipe",
    name = "wm-droid-1",
    enabled = false,
    category = "advanced-crafting",
    energy_required = 10,
    ingredients =
    {
      {type="item", name="steel-plate", amount=7},
      {type="item", name="electronic-circuit", amount=15},
      {type="item", name="engine-unit", amount=4},
      {type="item", name="light-armor", amount=1}
    },
    results={ {type="item", name="wm-droid-1", amount=1} },
  },
  --[[
  {
    type = "recipe",
    name = "wm-droid-1-dummy",
    hide_from_player_crafting = true,
    enabled = false,
    category = "advanced-crafting",
   -- category = "droids",
    energy_required = 8,
    ingredients =
    {
      {type="item", name="wm-droid-1", amount=1}
    },
    results={ {type="item", name="wm-droid-1-dummy", amount=1} },
  },
  ]]

  {
    type = "technology",
    name = "wm-creepmining-droid-1",
    icon_size = 256, icon_mipmaps = 4,
    icon = "__Warmonger__/graphics/testbot/robotarmy-tech-droid-flame.png",
    prerequisites = {"engine", "logistics-2"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},        
      },
      time = 30
    },
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "wm-droid-1"
      },
    },
    order = "c-c-e"
  },

})