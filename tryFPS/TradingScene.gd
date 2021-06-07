extends Node2D

onready var takeoff = $takeoff
onready var landing = $landing
onready var bgBlurred = $bg_blurred
onready var player = $fade_bg
onready var inventory = get_node("/root/MotherNode/Inventory")
onready var root = get_node("/root/MotherNode/")

var isMouseCaptured = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventory.connect("onButtonPressed", self, "_on_DoneButton_pressed")
	inventory.createPlanetInventory()
	#inventory.show()
	takeoff.hide()
	landing.show()
	bgBlurred.hide()
	landing.play()
	
func _process_input(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if isMouseCaptured:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_landing_finished():
	bgBlurred.show()
	player.play("fade_in")
	yield(player, "animation_finished")
	landing.visible = false
	inventory.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	isMouseCaptured = false

func _on_DoneButton_pressed():
	# on valide les choix
	inventory.hide()
	# le Kosmojet redécole
	takeoff.show()
	bgBlurred.hide()
	takeoff.play()
	yield(takeoff, "finished")
	
	var level = root.get_children()[0]
	root.remove_child(level)
	level.call_deferred("free")
	# Add the next level
	var next_level_resource = load(root.nextScene() + ".tscn")
	var next_level = next_level_resource.instance()
	root.add_child(next_level)
