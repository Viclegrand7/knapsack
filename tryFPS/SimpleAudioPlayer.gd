extends Spatial

var audioLaserShot1 = preload("res://assets/CK_Blaster_Shot-226.wav")
var audioLaserShot2 = preload("res://assets/Future Weapons 3 - Grenade Launcher 2 - Hit 2.wav")
var audioLaserShot3 = preload("res://assets/Weapon Shot Blaster-06.wav") #Selected
var audioCannonShot = preload("res://assets/sci-fi_weapon_blaster_laser_boom_zap_08.wav") #Selected

var audioNode = null

func _ready():
	audioNode = $Audio_Stream_Player
	audioNode.connect("finished", self, "destroySelf")
	audioNode.stop()

func playSound(soundName):
	if soundName == "laser1":
		audioNode.stream = audioLaserShot1
	elif soundName == "laser2":
		audioNode.stream = audioLaserShot2
	elif soundName == "laser3":
		audioNode.stream = audioLaserShot3
	elif soundName == "cannon":
		audioNode.stream = audioCannonShot
	else:
		print_debug("No audio is set")
		queue_free()
		return
	audioNode.play()

func destroySelf():
	audioNode.stop()
	queue_free()
