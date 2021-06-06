extends Button

func _ready():
	pass # Replace with function body.

func _on_Button_button_up():
	print("changing scene...")
	get_tree().change_scene("res://Testing_Space.tscn")
	#get_tree().change_scene("res://TradingScene.tscn")
