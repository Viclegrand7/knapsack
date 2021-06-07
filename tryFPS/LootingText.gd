extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for action in InputMap.get_action_list("Interact"):
		if action is InputEventKey:
			set_text("Press %s to interact" % OS.get_scancode_string(action.scancode))
			return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
