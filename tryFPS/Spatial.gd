extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var plasmaBall = preload("res://Bullet_Scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("fire"):
		var clone = plasmaBall.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)
