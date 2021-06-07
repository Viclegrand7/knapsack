extends Button

onready var root = get_node("/root/MotherNode/")

func _ready():
	pass # Replace with function body.

func _on_Button_button_up():
	print("changing scene...")
	# Remove the current level
	var level = root.get_node("NodeMainMenu")
	root.remove_child(level)
	level.call_deferred("free")
	# Add the next level
	var next_level_resource = load("res://Testing_Space.tscn")
	var next_level = next_level_resource.instance()
	root.add_child(next_level)
	root.move_child(next_level, 0)
