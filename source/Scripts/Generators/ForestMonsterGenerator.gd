extends Node

const Monster = preload("res://Entities/Battle/Monster.gd")
const SpotFinder = preload("res://Scripts/Maps/SpotFinder.gd")

const MONSTER_VARIANT_DATA = {
	"Normal": {
		"Slime": {
			"type": "Slime",
			"weight": 70,
			"health": 30,
			"strength": 10,
			"defense": 2,
			"turns": 1,
			"experience points": 10,
			
			"skill_probability": 40, # 40 = 40%
			"skills": {
				# These should add up to 100
				"chomp": 100 # 20%,
			}
		},
		"Bat": {
			"type": "Bat",
			"weight": 30,
			"health": 40,
			"strength": 8,
			"defense": 0,
			"turns": 1,
			"experience points": 15,
			
			"skill_probability": 20,
			"skills": {
				# These should add up to 100
				"vampire": 100 # 20%,
			}
		} 
	},
	"Frost": {
		"FrostWolf": {
			"type": "FrostWolf",
			"weight": 30,
			"health": 60,
			"strength": 20,
			"defense": 0,
			"turns": 2,
			"experience points": 15,
			
			"skill_probability": 0, # 40 = 40%
			"skills": {
				# These should add up to 100
				#"chomp": 100 # 20%,
			}
		},
		"IceTerrapin": {
			"type": "IceTerrapin",
			"weight": 60,
			"health": 20,
			"strength": 15,
			"defense": 11,
			"turns": 1,
			"experience points": 12,
			
			"skill_probability": 50, # 40 = 40%
			"skills": {
				# These should add up to 100
				"freeze": 100 # 20%,
			}
		}
	}
}

# Number per screen. Forest is 3-4 guaranteed screens.
const NUM_MONSTERS = [5, 10]

func generate_monsters(forest_map):
	var variation = forest_map.variation
	var monsters_data = MONSTER_VARIANT_DATA[variation]
	
	var monsters = { }
	var total_weight = 0
	# if slime has a weight of three and bat has a weight of two, this array
	# contains: slime, slime, slime, bat, bat. Then select a random item, done.
	var weighted_monsters_array = []
	
	for type in monsters_data.keys():
		monsters[type] = []
		var monster_weight = monsters_data[type]["weight"]
		for i in range(monster_weight):
			weighted_monsters_array.append(type)
	
	var num_monsters = Globals.randint(NUM_MONSTERS[0], NUM_MONSTERS[1])
	
	var occupied_spots = []
	for t in forest_map.transitions:
		occupied_spots.append([t.my_position[0], t.my_position[1]])
	
	for n in num_monsters:
		var coordinates = SpotFinder.find_empty_spot(forest_map.tiles_wide,
			forest_map.tiles_high, forest_map.tile_data[1], occupied_spots)
			
		var pixel_coordinates = [coordinates[0] * Globals.TILE_WIDTH, coordinates[1] * Globals.TILE_HEIGHT]
		var monster = Monster.new()
		monster.initialize(pixel_coordinates[0], pixel_coordinates[1])
		occupied_spots.append(pixel_coordinates)
		
		var type = weighted_monsters_array[randi() % len(weighted_monsters_array)]
		monster.data = monsters_data[type]
		monsters[type].append(monster)
	
	# Map of type => array of coordinates (one pair per entity)
	# TODO: return instances of some data type instead. Monster.new()?
	return monsters