extends Node2D

const AreaMap = preload("res://Entities/AreaMap.gd")
const AreaType = preload("res://Scripts/Enums/AreaType.gd")
const ForestGenerator = preload("res://Scripts/Generators/ForestGenerator.gd")
const MapDestination = preload("res://Entities/MapDestination.gd")
const MapLayoutGenerator = preload("res://Scripts/Generators/MapLayoutGenerator.gd")
const OverworldGenerator = preload("res://Scripts/Generators/OverworldGenerator.gd")
const SceneManagement = preload("res://Scripts/SceneManagement.gd")

func _ready():
	self.generate_world()
	SceneManagement.change_map_to(get_tree(), "Overworld")
	get_tree().current_scene.get_node("UI").show_intro_story()
	
func generate_world():
	var forest_generator = ForestGenerator.new()
	var forest_layout = MapLayoutGenerator.generate_layout(4)
	var forest_maps = []
	
	for submap in forest_layout:
		# Generate transitions here, used for path generation
		var data = self._generate_transitions(submap, forest_generator.map_width, forest_generator.map_height)
		var transitions = data["transitions"]
		var entrance = data["entrance"]
		
		var map = forest_generator.generate(submap, transitions)
		map.grid_x = submap.grid_x
		map.grid_y = submap.grid_y
		map.entrance_from_overworld = entrance
		
		forest_maps.append(map)
	
	# return a dictionary, eg. "forest" => forest map
	Globals.maps = {		
		"Forest": forest_maps
	}
	
	# Generate last; generating the entrance into the first sub-map
	# of each dungeon eg. the forest, requires Globals.maps.
	var overworld = OverworldGenerator.new().generate()
	Globals.maps["Overworld"] = overworld
	
	Globals.story_data = {
		"village_name": self._generate_village_name(),
		"boss_type": self._generate_boss_type()
	}

func _generate_village_name():
	var options = ['Nahr', 'Bahr', 'Shajar', 'Aqram', 'Hira']
	return options[randi() % len(options)]

func _generate_boss_type():
	var options = ['snake', 'black dog', 'gargoyle']
	return options[randi() % len(options)]
	
func _generate_transitions(submap, map_width, map_height):
	var transitions = []
	var entrance_from_overworld = null
	
	if submap.area_type == AreaType.ENTRANCE:
		var position = Vector2(0, 0)
		
		###
		# NB: maps are generated independently. The only way we get both sides of a
		# transition to line up (eg. bottom of map (0, 0) connects to top of map (0,1)
		# is to hard-code the center x/y appropriately.
		if submap.connections.has("right") or submap.connections.has("left"):
			position.y = floor(map_height / 2)
			position.x = 0
			if submap.connections.has("left"):
				# Left side is already taken, generate entrance on RHS
				position.x = map_width - 1
		elif submap.connections.has("up") or submap.connections.has("down"):
			position.x = floor(map_width / 2)
			position.y = 0
			if submap.connections.has("up"):
				# Left side is already taken, generate entrance on RHS
				position.x = map_height - 1
		
		transitions.append(MapDestination.new(position, "Overworld", null, null))
		entrance_from_overworld = position
	
	for direction in submap.connections.keys():
		var destination = submap.connections[direction]
		var my_position = Vector2(0, 0)
		var target_position = Vector2(0, 0)
		
		if direction == "left":
			my_position = Vector2(0, floor(map_height / 2))
			target_position = Vector2(map_width - 1, floor(map_height / 2))
		elif direction == "right":
			my_position = Vector2(map_width - 1, floor(map_height / 2))
			target_position = Vector2(0, floor(map_height / 2))
		elif direction == "up":
			my_position = Vector2(floor(map_width / 2), 0)
			target_position = Vector2(floor(map_width / 2), map_height - 1)
		elif direction == "down":
			my_position = Vector2(floor(map_width / 2), map_height - 1)
			target_position = Vector2(floor(map_width / 2), 0)
			
		transitions.append(MapDestination.new(my_position, destination, target_position, direction))
	
	return { "transitions": transitions, "entrance": entrance_from_overworld }