extends Node2D

onready var takeoff = $takeoff
onready var landing = $landing
onready var bgBlurred = $bg_blurred
onready var player = $fade_bg
onready var inventory = $Inv
onready var doneButton = $done

func _ready():
	takeoff.hide()
	landing.show()
	bgBlurred.hide()
	landing.play()

func _on_landing_finished():
	bgBlurred.show()
	player.play("fade_in")
	yield(player, "animation_finished")
	landing.visible = false
	inventory.show()
	doneButton.show()

func _on_done_pressed():
	# on valide les choix
	inventory.hide()
	doneButton.hide()
	# le Kosmojet redécole
	takeoff.show()
	bgBlurred.hide()
	takeoff.play()
	yield(takeoff, "finished")
	get_tree().change_scene("res://StartMenuScene.tscn")

#func _on_takeoff_finished():
	# retour au menu principal
	# normalement retour dans l'espace
#	get_tree().change_scene("res://StartMenuScene.tscn")
