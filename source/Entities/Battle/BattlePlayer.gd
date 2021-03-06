extends Node

const StatType = preload("res://Scripts/Enums/StatType.gd")

signal died
signal poison_damaged

const HEAL_PERCENT = 0.4 # 0.2 = 20%
const DEFEND_MULTIPLIER = 0.3 # 0.3 = 30%+ per defend
const _ENERGY_PER_TURN = 3
const ENERGY_GAIN_PER_ACTION = 2

const _POISON_DAMAGE_PER_TURN_PERCENT = 10 # 10 = 10%
const _ARMOUR_BREAK_LOSS = 3 # 5 means -5 def per break

const _ACTION_ENERGY_COST = {
	"attack": 1,
	"critical": 8,
	"heal": 2,
	"defend": 0,
	"vampire": 15,
	"bash": 10,
	"energy": -1 * ENERGY_GAIN_PER_ACTION
}

var current_health = 0
var max_health = 0
var energy = 0
var max_energy = 0
var strength = 0
# max number of tiles to pick from the grid
var num_pickable_tiles = 0
# max number of actions to pick from picked tiles
var num_actions = 0
var disabled_actions = []
var is_asleep = false

var _defense = 0
var times_defending = 0
var _turns_poisoned = 0

func _init():
	var player_data = Globals.player_data
	self.max_health = player_data.health
	self.current_health = self._total_health()
	self.strength = player_data.strength
	self._defense = player_data.defense
	self.num_actions = player_data.num_actions
	self.energy = self.max_energy / 2

func heal():
	var amount = floor(self._total_health() * HEAL_PERCENT)
	self.heal_amount(amount)
	return amount

func heal_amount(amount):
	self.current_health += amount
	if self.current_health > self._total_health():
		self.current_health = self._total_health()

func defend():
	self.times_defending += 1

func reset():
	self.energy += _ENERGY_PER_TURN
	self.energy = min(self.energy, self.max_energy)
	self.times_defending = 0
	
	if self._turns_poisoned > 0:
		var poison_damage = floor(self._total_health() * _POISON_DAMAGE_PER_TURN_PERCENT / 100)
		self.current_health -= poison_damage
		self._turns_poisoned -= 1
		self.emit_signal("poison_damaged", poison_damage)

func reset_disabled_actions():
	self.disabled_actions = []

### Start: battle action/reactions
func poison(turns):
	self._turns_poisoned += turns
	
func lower_defense():
	self._defense -= _ARMOUR_BREAK_LOSS
### End battle action/reactions

func total_strength():
	var total = self.strength
	total += _get_equipment_modifier(Globals.player_data.weapon, StatType.StatType.Strength)
	total += _get_equipment_modifier(Globals.player_data.armour, StatType.StatType.Strength)
	return total
	
func total_defense():
	var total = self._defense
	total += _get_equipment_modifier(Globals.player_data.weapon, StatType.StatType.Defense)
	total += _get_equipment_modifier(Globals.player_data.armour, StatType.StatType.Defense)
	var grand_total = floor(total * (1.0 + (DEFEND_MULTIPLIER * self.times_defending)))
	return grand_total

func damage(damage):
	if damage > 0:
		self.current_health -= damage

func detract_energy(action):
	# returns true if we had enough energy to do said action
	var cost = _ACTION_ENERGY_COST[action]
	
	if self.energy >= cost:
		self.energy -= cost
		return true
	else:
		return false

func disable(what):
	self.disabled_actions.append(what)

func is_poisoned():
	return self._turns_poisoned > 0

func _get_equipment_modifier(equipment, stat_type):
	var total = 0
	
	if equipment != null:
		if equipment.primary_stat == stat_type:
			total += equipment.primary_stat_modifier
		if equipment.secondary_stat == stat_type:
			total += equipment.secondary_stat_modifier
	
	return total

func _total_health():
	var total = self.max_health
	total += _get_equipment_modifier(Globals.player_data.weapon, StatType.StatType.Health)
	total += _get_equipment_modifier(Globals.player_data.armour, StatType.StatType.Health)
	return total