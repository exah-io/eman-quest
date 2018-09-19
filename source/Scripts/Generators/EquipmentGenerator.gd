extends Node

const Equipment = preload("res://Entities/Equipment.gd")
const StatType = preload("res://Scripts/StatType.gd")

# primary_stat is a Stats. Power is a number that indicates relative power.
# Something that's power 20 should be roughly 2x as strong as something power 10.
static func generate(primary_stat, power):
	var secondary_stat = randi() % StatType.StatType.size()
	
	while secondary_stat == primary_stat:
		secondary_stat = randi() % StatType.StatType.size()
	
	var primary_name = names[primary_stat]
	var secondary_name = names[secondary_stat]
	
	# Not exactly what we want, but works well with small powers like 10
	var secondary_power = ceil(power * 0.33)
	var item_name = _generate_name(primary_name, secondary_name)
	
	return Equipment.new(item_name, primary_stat, _get_random_amount(primary_name, power),
		secondary_stat, _get_random_amount(secondary_name, secondary_power))
	
# We need to keep a power curve without too much variation. It would suck
# to get a low-powered weapon/armour when you really need a high-power one.
# Basic equipment starts with power=10
static func _get_random_amount(stat_name, power):
	if stat_name == "Health":		
		return randint(power * 2, power * 3)
	elif stat_name == "Energy":
		# to start, energy is ~1/3 of HP.
		return randint(power * 0.7, ceil(power))
	elif stat_name == "Strength" or stat_name == "Defense":
		# strength or defense
		return randint(ceil(power * 0.4), ceil(power * 0.6))

# Returns integer value from min to max inclusive
# Source: https://godotengine.org/qa/2539/how-would-i-go-about-picking-a-random-number
static func randint(minimum, maximum):
	return range(minimum, maximum + 1)[randi() % range(minimum, maximum + 1).size()]

static func _generate_name(primary_stat, secondary_stat):
	# TODO: grammar with all that jazz
	# 8-10 letters. Start with primary_stat + vowel + secondary_stat + vowel
	var vowels = ["a", "i", "o", "u", "oo"]
	# NB: if secondary stat is energy ... we could get, like daee or haei
	var name = ""#primary_stat[0] + vowels[randint(0, len(vowels) - 1)]
	#if secondary_stat != "Energy":
	#name += secondary_stat[0] + vowels[randint(0, len(vowels) - 1)]
	#var sounds = ["r", "sn", "tr", "l", "ph", "f", "m", "n", "sh", "b", "g", "kh", "fr", "gh"]
	var sounds = ["s", "sh", "ch", "b", "d", "n", "r", "z", "t", "m"]
	while len(name) < 6:
		name += sounds[randint(0, len(sounds) - 1)]
		name += vowels[randint(0, len(vowels) - 1)]
		
	return name.to_lower().capitalize()
	
	
	
	