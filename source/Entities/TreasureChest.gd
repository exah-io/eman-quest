extends StaticBody2D

const _CHEST_OPEN_X = 64

var is_opened = false
var contents # equipment instance
var tile_x = 0
var tile_y = 0

var _player_is_in_range = false

### DO NOT USE _INIT HERE! This will break when you create this with .instance()
# For details, see: https://github.com/godotengine/godot/issues/15866
func initialize(x, y, contents):
	self.tile_x = x
	self.tile_y = y
	self.contents = contents

func open():
	if not self.is_opened:
		# Grant item
		Globals.player_data.inventory.append(self.contents)
		self.consume()

func consume():
	self.is_opened = true
	self._appear_open()

func _appear_open():
	$Sprite.region_rect.position.x = _CHEST_OPEN_X

func _on_Area2D_body_entered(body):
	if not self.is_opened and body == Globals.player:
		self._player_is_in_range = true

func _on_Area2D_body_exited(body):
	if not self.is_opened and body == Globals.player:
		self._player_is_in_range = false

func _process(delta):
	if not self.is_opened and self._player_is_in_range and Input.is_key_pressed(KEY_SPACE):
		self.open()