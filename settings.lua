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
        name = "wm-CreepMiningPollution",
        description = "wm-CreepMiningPollution",
        setting_type = "runtime-global",
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
        minimum_value = 3,
        maximum_value = 20,
        order = "m[total]-d[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CreepCorrosion",
        description = "wm-CreepCorrosion",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-a[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CounterStrike",
        description = "wm-CounterStrike",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-b[ai]",

    },

    {
        type = "bool-setting",
        name = "wm-CreepMinerHints",
        description = "wm-CreepMinerHints",
        setting_type = "runtime-global",
        default_value = true,
        order = "m[total]-c[ai]",

    },

})