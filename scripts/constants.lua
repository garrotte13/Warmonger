local constants = {}

constants.creep_collection_rate = {
  min = 90,
  max = 95,
}
constants.creep_max_range = 6
constants.creep_max_reach = 10

constants.creep_mining_energy = 200
constants.electric_miner_range = 28
constants.burner_miner_range = 18
constants.pollution_miner = 5

constants.minersTable = {
  overlay = {"creep-miner0-overlay", "creep-miner1-overlay"},
  radar = {"creep-miner0-radar", "creep-miner1-radar"},
  chest = {"creep-miner0-chest", "creep-miner1-chest"},
  miner_range = {18, 28}
}

function constants.miner_range(name)
  local r = constants.electric_miner_range
  if name == "creep-miner0-radar" or name == "creep-miner0-overlay" or name == "creep-miner0-chest" then r = constants.burner_miner_range end
  return r
end


return constants
