data:extend({

    {
        type = "int-setting",
        name = "wm-BiomassToBitersReseach",
        description = "wm-BiomassToBitersReseach",
        setting_type = "startup",
        default_value = 7,
        minimum_value = 2,
        maximum_value = 18,

    },

    {
        type = "double-setting",
        name = "wm-CreepMiningPollution_s",
        description = "wm-CreepMiningPollution_s",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 0.2,
        maximum_value = 3,
        order = "m[total]-d[ai]",

    },

    {
        type = "double-setting",
        name = "wm-CreepMiningPollution",
        description = "wm-CreepMiningPollution",
        setting_type = "runtime-global",
        hidden = true,
        default_value = 1.5,
        minimum_value = 0.1,
        maximum_value = 30,
        order = "m[total]-d[ai]",

    },

    {
        type = "int-setting",
        name = "wm-CreepMiningTilesPerCycle",
        description = "wm-CreepMiningTilesPerCycle",
        setting_type = "runtime-global",
        default_value = 7,
        hidden = true,
        minimum_value = 7,
        maximum_value = 8,
        order = "m[total]-d[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CreepMinerFueling",
        description = "wm-CreepMinerFueling",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-a[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CreepCorrosion",
        description = "wm-CreepCorrosion",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-b[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CounterStrike",
        description = "wm-CounterStrike",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-c[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CreepMinerHints",
        description = "wm-CreepMinerHints",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-d[ai]",

    },

})