data:extend({

  {
    type = "sound",
    name = "kr-collect-creep",
    category = "alert",
    filename = "__Warmonger__/sounds/tiles/creep-deconstruction.ogg",
    volume = 0.75,
    audible_distance_modifier = 0.5,
    aggregation = {
      max_count = 1,
      remove = false,
      count_already_playing = true,
    },
  },

  {
    type = "sound",
    name = "creep-access-denied",
    category = "alert",
    filename = "__Warmonger__/sounds/scripted/enemy_blocks_creep.ogg",
    volume = 1.0,
    audible_distance_modifier = 1.0,
    aggregation = {
      max_count = 3,
      remove = false,
      count_already_playing = false,
    },
  },

  {
    type = "sound",
    name = "acid_burns",
    category = "game-effect",
    filename = "__Warmonger__/sounds/scripted/acid_burns.ogg",
    volume = 0.75,
    audible_distance_modifier = 0.5,
    aggregation = {
      max_count = 1,
      remove = false,
      count_already_playing = false,
    },
  },

  {
    type = "sound",
    name = "creep-counter-attack-explosion",
    category = "game-effect",
    filename = "__Warmonger__/sounds/scripted/counter_attack_explosion.ogg",
    volume = 1.0,
    audible_distance_modifier = 0.8,
    aggregation = {
      max_count = 5,
      remove = false,
      --count_already_playing = false,
    },
  },
  
})
