extends AnimationPlayer

# Structure -> Animation name :[Connecting Animation states]
var states = {
	"Default":["FLATTING", "Default"],
	"FLATTING": ["FLATTING", "Default"]
}

var animation_speeds = {
	"Default":1,
	"FLATTING":1
}

var current_state = null
var callback_function = null

func _ready():
	set_animation("Default")
	connect("animation_finished", self, "animation_ended")

func set_animation(animation_name):
	if animation_name == current_state:
		return true


	if has_animation(animation_name):
		if current_state:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print ("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ", animation_name, " from ", current_state)
				return false
		current_state = animation_name
		play(animation_name, -1, animation_speeds[animation_name])
		return true
	return false


func animation_ended(_anim_name):
#
#	# UNARMED transitions
#	if current_state == "Idle_unarmed":
#		pass
#	# KNIFE transitions
#	elif current_state == "Knife_equip":
#		set_animation("Knife_idle")
#	elif current_state == "Knife_idle":
#		pass
#	elif current_state == "Knife_fire":
#		set_animation("Knife_idle")
#	elif current_state == "Knife_unequip":
#		set_animation("Idle_unarmed")
#	# PISTOL transitions
#	elif current_state == "Pistol_equip":
#		set_animation("Pistol_idle")
#	elif current_state == "Pistol_idle":
#		pass
#	elif current_state == "Pistol_fire":
#		set_animation("Pistol_idle")
#	elif current_state == "Pistol_unequip":
#		set_animation("Idle_unarmed")
#	elif current_state == "Pistol_reload":
#		set_animation("Pistol_idle")
#	# RIFLE transitions
#	elif current_state == "Rifle_equip":
#		set_animation("Rifle_idle")
#	elif current_state == "Rifle_idle":
#		pass
#	elif current_state == "Rifle_fire":
#		set_animation("Rifle_idle")
#	elif current_state == "Rifle_unequip":
#		set_animation("Idle_unarmed")
#	elif current_state == "Rifle_reload":
#		set_animation("Rifle_idle")
	set_animation("Default")
	#My test to *NOT* hard code it

func animation_callback():
	if callback_function == null:
		print ("AnimationPlayer_Manager.gd -- WARNING: No callback function for the animation to call!")
	else:
		callback_function.call_func()
