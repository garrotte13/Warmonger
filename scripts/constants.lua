local constants = {}

constants.creep_collection_rate = {
  min = 90,
  max = 95,
}
constants.creep_max_range = 6
constants.creep_max_reach = 10

constants.select_chest_logic = {
  {type = "false", prio = "5"},
  {type = "active-provider", prio = "1"},
  {type = "passive-provider", prio = "2"},
  {type = "storage", prio = "4"},
  {type = "buffer", prio = "3"},
  {type = "requester", prio = "6"}
}

constants.creep_mining_energy = 200
constants.electric_miner_range = 28
constants.burner_miner_range = 18
constants.pollution_miner = 2

function constants.miner_range(name)
  local r = constants.electric_miner_range
  if name == "creep-miner0-radar" then r = constants.burner_miner_range end
  return r
end


return constants
