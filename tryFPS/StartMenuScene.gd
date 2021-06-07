extends Node2D

# boutons de l'écran de chargement

onready var player = $fadeOut

# onready var loadQB = $load_quit
# onready var loadR = $load_retry

# boutons du menu principal
onready var mainNG = $main_new_game
onready var mainLG = $main_load_game
onready var mainO =  $main_options
onready var mainC =  $main_credits_button
onready var mainQ =  $main_quit_button

var isGamePresent = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# boutons désactivés tant que l'on n'est pas connecté
	disable_hide_main_buttons()
	player.play("Fade out")
	# rendre les boutons cliquables quand animation finie
	yield(player, "animation_finished")
	activate_main_buttons()

func _button_pressed():
	print("Привет, мир! (hello world - kosmojet version)")

func disable_hide_main_buttons():
	mainNG.disabled = true
	mainLG.disabled = true
	mainO.disabled = true
	mainC.disabled = true
	mainQ.disabled = true
	
	mainNG.visible = false
	mainLG.visible = false
	mainO.visible = false
	mainC.visible = false
	mainQ.visible = false

func activate_main_buttons():
	mainNG.visible = true
	mainLG.visible = true
	mainO.visible = true
	mainC.visible = true
	mainQ.visible = true
	
	mainNG.disabled = false
	mainO.disabled = false
	mainC.disabled = false
	mainQ.disabled = false
	# check si la blockchain existe et est remplie
	if isGamePresent:
		mainLG.disabled = false
