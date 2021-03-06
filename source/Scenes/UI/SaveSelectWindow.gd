extends PopupPanel

const AudioManager = preload("res://Scripts/AudioManager.gd")
const PlayerData = preload("res://Entities/PlayerData.gd")
const SaveManager = preload("res://Scripts/SaveManager.gd")
const SceneFadeManager = preload("res://Scripts/Effects/SceneFadeManager.gd")

signal close

var _selected_slot = null
var _save_disabled = false # for titlescreen only

func _ready():
	$VBoxContainer/HBoxContainer/Container/ItemList.add_item("AutoSave")
	
	for i in range(Globals.NUM_SAVES):
		var n = i + 1
		$VBoxContainer/HBoxContainer/Container/ItemList.add_item("File " + str(n))
	
	$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()
	$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.hide()
	AudioManager.new().add_click_noise_to_controls($VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer)
	
func disable_saving():
	# From titlescreen we came, and to it we will return on close.
	_save_disabled = true
	$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.hide()
	
	self.connect("popup_hide", self, "_back_to_titlescreen")

func title(value):
	$VBoxContainer/Titlebar.title = value

func _back_to_titlescreen():
	var tree = get_tree()
	SceneFadeManager.fade_out(tree, Globals.SCENE_TRANSITION_TIME_SECONDS)
	yield(tree.create_timer(Globals.SCENE_TRANSITION_TIME_SECONDS), 'timeout')
	#tree.change_scene("res://Scenes/Title.tscn")
	emit_signal("close")

func _on_ItemList_item_selected(index):
	var save_key = _index_to_save_id(index)
		
	_selected_slot = index

	var label = $VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/StatsLabel
	var sprite = $VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/ScreenshotSprite
	var save_exists = SaveManager.save_exists(save_key)
	
	# we're loading, or autosave (can't save over it)
	if not _save_disabled and index > 0:
		$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.show()
	else:
		$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/SaveButton.disabled = not save_exists

	$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.visible = save_exists
	
	if save_exists:
		var data = SaveManager.load_data(save_key)
		
		label.text = "World: #{seed}\nPlay time: {play_time}\nLevel: {level}" \
			.format({
				"seed": str(data["seed_value"]),
				"play_time": PlayerData.seconds_to_time(data["player_data"].play_time_seconds),
				"level": int(data["player_data"].level)
			})
		sprite.texture = _get_screenshot_for(save_key)
	else:
		label.text = "Empty"
		sprite.texture = null
		
func _get_screenshot_for(save_key):

	var file = File.new()
	file.open(Globals.screenshot_path(save_key), File.READ)
	var buffer = file.get_buffer(file.get_len())
	file.close()
	
	var image = Image.new()
	image.load_png_from_buffer(buffer)
	
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	
	image_texture.flags = 0 # turn off "Filter"
	
	return image_texture

func _on_SaveButton_pressed():
	if not _save_disabled and _selected_slot != null:
		var save_id = _index_to_save_id(_selected_slot)
		SaveManager.save_with_screenshot(save_id)
		
		AudioManager.new().play_sound("save")
		
		# Refresh so it LOOKS saved
		_on_ItemList_item_selected(_selected_slot)
		
func _on_LoadButton_pressed():
	if _selected_slot != null:
		$VBoxContainer/HBoxContainer/Container2/SaveDetailsPanel/VBoxContainer/LoadButton.disabled = true
		# disappear without triggering popup_hide, which takes us to the titlescreen
		self.modulate.a = 0 
		AudioManager.new().play_sound("load")
		var save_id = _index_to_save_id(_selected_slot)
		SaveManager.load(save_id, get_tree())

func _index_to_save_id(index):
	var save_id = "save" + str(index)
	if index == 0:
		save_id = "autosave"
	return save_id