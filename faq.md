# Intro

A short help with __Warmonger__ and __Rampant__ mods.

Warmonger adds some challenge in battles with Nauvis fauna and a few additional production chains.

# Creep

It's generated by natives during structures (nests and worms) building, like zergs do in SC. Walking and driving over it is much slower even with speed bonuses. It's better to run around or go through small creep bridges from one clear area to another.

All buildings installed on creep are affected by corrosion and loose about 10% actual health per second till they or creep underneath are removed - it's very huge a DoT (damage over time) for full-health buildings, but harmless when building is almost destroyed. Buildings with small hitpoints (containers, creep collectors, electric poles) are much easier and cheaper to repair.

Creep can be type-1 and type-2. Type-1 is located in core zones (under structures) and contains biomass ingredient. Type-2 is found in distal zones and strike-back / creeper2 footprints. Its derivatives are only small amounts of bio remains (residue).

Creep miners collect it in their range (18 tiles for burner and 28 tiles for electric one), going from center to edge and prioritizing corroding tiles. Pollution is produced by miner when creep is purged. When no creep at all is available miners go into inactive state for 2 minutes. Both types of creep have the same value for miner, but...

Creep excavation is prevented when enemy structures are near target creep tile (for creep type-2) and when enemies (both structures and units) are in adjacent to miner chunks. Therefore you must kill everything before all creep can be removed. When all creep is protected, miner goes into sleep for 3 seconds to avoid energy losts.

Creep type-1 produces biomass in 100%. It's a valuable ingredient. Creep type-2 produces bio residue in 30% (random), which can be used as low value chemical fuel in early game and as a source of sulphuric acid and heavy oil in late game. Miners put extracted biomass and bio residue into nearby chest. Burner miner can put residue into fuel inventory. When there is nowhere to store residue it is wasted. When there is no place to store biomass miner collects creep type-2 or goes into sleep for 3 seconds.

As creep absorbs much more pollution than common terrain it is reasonable not to hurry with removing it in early game. That will reduce pollution cloud instead of increasing it.

# Biomass

Biomass is required for military science packs in ration 3.5 per 1 pack. Therefore some enemy bases must be purged before first technologies with military science can be researched. Amount of biomass available in game depends on few factors:

- Enemy bases frequency and size (big size bases have more creep type-1 than creep type-2, while small bases have more of type-2)
- Rampant mod active and its settings (AI states, difficulty). Biters settle near player base and bring creep - that's so cute!
- Evolution. Creep areas grow in size with evolution considerably.
- Distance from starting area. Usual thing in Factorio. I don't know how it goes with RSO mod.
- Game difficulty. Double technologies costs require double amount of biomass. 200% bases size map setting is highly recommended here.
- Rampant new enemies and as a consequence - Rampant Arsenal mod items, some of them need biomass.

# Creep revenge strikes

It's not to kill game interest, but to grow it, add some when player is technologically winning all conflicts with natives.

At midgame (starting ~40% evo) when enemy nest is killed by player from afar (distance is determined by evolution factor), other nests (only if there are any survivors nearby) try sometimes to revenge sending a creep seeding artillery shell in direction of death bringer. Upon landing it does some lethal damage (unlike corrosion hurts everything including player and vehicles/bots, and can kill) and deploying small area of creep type-2.

This counter strike can be negated by healing tools/buildings and creep miner(s). Creep miner is automatically awaken when creep shell has landed nearby. Artillery should not stay in place (especially after nuclear attack) or should cease firing when damaged.

Smaller counter strikes can occur when player fires rockets/capsule launcher ammo/cannons. It happens rarely, but maybe more often when using hit&run tactics.

# Rampant

Rampant mod introduces several nice features:

- Biters attack in squads from one or several enemy bases (bases = nests packs).
- Biters go into berserk when nearby their target and attack all player's creations including electric poles, walls in form of "dragon teeth" and "labyrinth of death", effectively making war part of the game not so stupid boring like it is in vanilla. But of course they still prefer turrets if can reach them.
- Biters regularly change the path they go from their home to player's structures, therefore one can't install turrets in one place and be happy the rest of the game like in vanilla.
- Enemy squads attacks and bases expansion are scaled with rising evolution factor (like in vanilla, but in more aspects therefore automated abundant ammo/energy provided defense lines are a must).
- Pheromones pathfinding for biters. Player body attracts nearby biters and guides them (until they die or go into berserk)
- Different states of AI state with different strategy. One can turn on announcement messages to learn about state change, but it spoils the game and with game experience state can be detected easily when seeing specific biters activites.
- Siege AI attacks player base and tries to build new enemy bases close to player. Easy to detect new nests, but can be a pain in early game or in later game with incorrect defenses pattern
- Raiding AI sends waves of units from very different sides of map.
- Migration AI focuses on existing bases growth and claiming new territories. Especially areas with resources.
- New enemies mode. A big game changer. Factorio fun doesn't end with laser and flame turrets installation or by getting armor MK2 with exoskeleton. Worms and nests have evolution factor dependent health, damage and range (depends on max tier level in Startup options) - so they can't be destroyed by one common rocket per nest / worm in late game. Also this game mode requires different types of ammo and weapons used in late-game defense lines to be ready for any attack of any enemy faction. Till evolution 30% everything looks as usual except some new factions, but then depending on startup settings biters, spitters and worms become more dangerous with every x % evolution, special ultra-spawners named hives can be encountered (mostly near resources), then new factions appear...

# New game map settings recommendations

Keep trees options as is. Reducing its mass even to value 75% greatly decreases pollution absorption.

 Rampant biters often build new bases as a revenge for destroying their nests (they sometimes do it even under heavy weapon fire). In result evolution destroy factor is multiplied by 1.3-2 depending on your play style and bases frequency/size (e.g. for enemy bases 200%/200% difficulty it's better to set destroy factor 100 or less, while for 100%/100% the original value of 200 is Ok).
