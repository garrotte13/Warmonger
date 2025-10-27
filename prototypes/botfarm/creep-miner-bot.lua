local droidMapColour = {r = .05, g = .70, b = .29}
local droidFlameTint = {r=1, g=1, b=1, a=1}
local droidscale = 1.0
local ICONPATH = "__Warmonger__/graphics/testbot/icons/"
local BOTPATH = "__Warmonger__/graphics/testbot/entity/bots/"

function make_rifle_gunshot_sounds(volume)
  return {
    {filename = "__base__/sound/fight/light-gunshot-1.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-2.ogg", volume = 1},
    {filename = "__base__/sound/fight/light-gunshot-3.ogg", volume = 1}
  }
end

local function robotAnimation(sheet, tint, scale)
  return {
    layers = {
      {
          filename = BOTPATH .. "hr-" .. sheet .. ".png",
          width = 160,
          height = 160,
          --tint = tint,
          direction_count = 22,
          frame_count = 1,
          animation_speed = 0.01,
          shift = {0, -0.5},
          scale = (scale / 2),
      },
      {
          filename = BOTPATH .. "hr-" .. sheet .. "-shadow.png",
          width = 320,
          height = 160,
          direction_count = 22,
          frame_count = 1,
          animation_speed = 0.01,
          shift = {0, -0.5},
          scale = (scale / 2),
          draw_as_shadow = true,
      }
    }
  }
end

data:extend({
{
  type = "ammo-category",
  name = "creepmining",
  hidden = true
 },

{
  type = "unit",
  name = "wm-droid-1",
  icon_size = 64,
  icon = ICONPATH .. "droid_flame_undep.png",
  flags = {"placeable-player", "player-creation", "placeable-off-grid"},
  --subgroup="creatures",
  order="e-a-b-d",
  has_belt_immunity = false,
  max_health = 200,
  alert_when_damaged = true,
  healing_per_tick = 0.00,
  collision_box = {{-0.9*droidscale, -0.9*droidscale}, {0.9*droidscale, 0.9*droidscale}},
  selection_box = {{-0.8*droidscale, -0.8*droidscale}, {0.8, 0.8*droidscale}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  vision_distance = 15,
  affected_by_tiles = true,
  is_military_target = true,
  radar_range = 1,
  can_open_gates = true,
  ai_settings =
  {
    allow_destroy_when_commands_fail = false,
    do_separation = true,
    path_resolution_modifier = 2,
    join_attacks = false,
    allow_try_return_to_spawner = false
  },
  movement_speed = 0.04,
  minable = {hardness = 0.1, mining_time = 0.5, result = "wm-droid-1"},
  absorptions_to_join_attack={},
  distraction_cooldown = 0,
  distance_per_frame =  0.03,
  friendly_map_color = droidMapColour,
  dying_explosion = "medium-explosion",
  resistances =
  {
    {
      type = "physical",
      decrease = 1,
      percent = 10
    },
    {
      type = "explosion",
      decrease = 2,
      percent = 10
    },
    {
      type = "acid",
      decrease = 1,
      percent = 10
    },
  {
      type = "fire",
      percent = 60
    }
  },
  destroy_action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      source_effects =
      {
        {
          type = "nested-result",
          affects_target = true,
          action =
          {
            type = "area",
            perimeter = 6,
            collision_mask = { "player-layer" },
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                type = "damage",
                damage = { amount = 40, type = "explosion"}
              }
            }
          },
        },
        {
          type = "create-entity",
          entity_name = "explosion"
        },
        {
          type = "damage",
          damage = { amount = 100, type = "explosion"}
        }
      }
    }

  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    shell_particle =
    {
      name = "shell-particle",
      direction_deviation = 0.1,
      speed = 0.1,
      speed_deviation = 0.03,
      center = {0, 0.1},
      creation_distance = -0.5,
      starting_frame_speed = 0.4,
      starting_frame_speed_deviation = 0.1
    },
    cooldown = 240,
    projectile_center = {-0.6, 1},
    projectile_creation_distance = 0.8,
    range = 2,
    sound = make_rifle_gunshot_sounds(1),
    --animation = robotAnimation("rifle_run", droidRifleTint, droidscale),
    animation = robotAnimation("flame_run", droidFlameTint, 1),
    ammo_type =
    {
      category = "bullet",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot-small"
          },
          target_effects =
          {
            {
              type = "create-entity",
              entity_name = "explosion-hit"
            },
            {
              type = "damage",
              damage = { amount = 0.5 , type = "physical"}
            }
          }
        }
      }
    }
  },

  idle = robotAnimation("flame_run", droidFlameTint, 1),
  run_animation = robotAnimation("flame_run", droidFlameTint, 1),
},

})