extends KinematicBody2D

const AlphaFluctuator = preload("res://Scripts/Effects/AlphaFluctuator.gd")

signal done # glowing

# TODO: use single spritesheet instead
func face_down():
	$HumanSpriteUp.visible = false
	$HumanSpriteDown.visible = false
	$Sprite.visible = true
	$Normal.visible = false
	
func face_up():
	$HumanSpriteUp.visible = true
	$HumanSpriteDown.visible = false

func become_normal():
	$HumanSpriteUp.visible = false
	$HumanSpriteDown.visible = false
	$Sprite.visible = false
	$Normal.visible = true
	
func glow(seconds):
	$WhiteOut.visible = true
	$WhiteOut.modulate.a = 0
	
	var fluc = AlphaFluctuator.new($WhiteOut)
	self.add_child(fluc)
	fluc.connect("done", self, "_on_glow_done")
	fluc.run(seconds)

func _on_glow_done():
	self.emit_signal("done")