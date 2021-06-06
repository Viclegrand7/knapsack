extends Node2D

onready var takeoff = $takeoff
onready var landing = $landing
onready var bgBlurred = $bg_blurred
onready var player = $fade_bg

func _ready():
	takeoff.visible = false
	landing.visible = true
	bgBlurred.visible = false
	landing.play()

func _on_landing_finished():
	bgBlurred.visible = true
	player.play("fade_in")
	yield(player, "animation_finished")
	landing.visible = false
