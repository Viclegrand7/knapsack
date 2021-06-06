extends KinematicBody

export var ACCEL : float = 2
export var MAX_SPEED : float = 30
export var DEACCEL : float = 1

export(float, 0.1, 1) var mouse_sensitivity : float = 0.3

var vel : Vector3 = Vector3(0, 0, 0)

onready var rotation_helper = $yCameraPivot
onready var camera = $yCameraPivot/SpringArm/Camera

onready var reactors = [$yCameraPivot/LeftExhaust, $yCameraPivot/RightExhaust]

var dir = Vector3()

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINTSPEED = 30
const SPRINT_ACCELERATION = 18
var isSprinting = false

var timeShaking : float = 0
const MAX_SHAKING_TIME = 0.5
var doesShake = false
export var CAMERA_SHAKING_STRENGTH = 0.2

const TIME_BETWEEN_ATTACKS = 0.2
var timeBeforeAttack = 0
var laserFromRight : int = 1

const TIME_BETWEEN_MISSILES = 1
var timeBeforeMissileLeft = 0
var timeBeforeMissileRight = 0

var flashlight

var cannonManager = preload("res://Bullet_Scene.tscn")
var cannonMuzzles = []
var laserMuzzles = []

var soundManager = preload("res://Simple_Audio_Player.tscn")

var canLoot = false
onready var lootingScene = get_node("../Inventory")
onready var lootingText = get_node("../LootingText")

var isMouseCaptured = true

#Weapon management
#var animation_manager
#
#var current_weapon_name = "UNARMED"
#var weapons = {"UNARMED": null, "KNIFE": null, "RIFLE": null, "PISTOL": null}
#const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1: "RIFLE", 2: "PISTOL", 3: "KNIFE"}
#const WEAPON_NAME_TO_NUMBER = {"UNARMED": 0, "RIFLE": 1, "PISTOL": 2, "KNIFE": 3}
#var changing_weapon = false
#var changing_weapon_name = "UNARMED"

var health = 100

var UI_status_label
#End of weapon management

func _ready():
#	camera = $Rotation_Helper/Camera
#	rotation_helper = $CameraPivot
	flashlight = [$yCameraPivot/FlashLight1, $yCameraPivot/FlashLight2]
	cannonMuzzles = [$yCameraPivot/LeftMuzzle, $yCameraPivot/RightMuzzle]
	laserMuzzles = [$yCameraPivot/LaserLeftMuzzle, $yCameraPivot/LaserRightMuzzle]
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#Weapon management
#	animation_manager = $Rotation_Helper/Model/Animation_Player
#	animation_manager.callback_function = funcref(self, "fire_bullet")
#
#	weapons["KNIFE"]  = $Rotation_Helper/Gun_Fire_Points/Knife_Point
#	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
#	weapons["RIFLE"]  = $Rotation_Helper/Gun_Fire_Points/Rifle_Point
#
#	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin
#
#	for weapon in weapons:
#		var weapon_node = weapons[weapon]
#		if weapon_node != null:
#			weapon_node.player_node = self
#			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
#			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180)) #So it shoots towards positive Y axis
#
#	current_weapon_name  = "UNARMED"
#	changing_weapon_name = "UNARMED"
#
	#UI_status_label = $HUD/Panel/Gun_label
	#End of weapon management

func _process(delta):
	timeBeforeAttack = clamp(timeBeforeAttack - delta, 0, TIME_BETWEEN_ATTACKS)
	timeBeforeMissileLeft = clamp(timeBeforeMissileLeft - delta, 0, TIME_BETWEEN_MISSILES)
	timeBeforeMissileRight = clamp(timeBeforeMissileRight - delta, 0, TIME_BETWEEN_MISSILES)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
#	process_changing_weapons(delta)
	if doesShake:
		camera_shake(float(1)/16)

func camera_shake(time):
	timeShaking += time
	if timeShaking < MAX_SHAKING_TIME / 4:
		camera.translate(-    camera.global_transform.basis.z * CAMERA_SHAKING_STRENGTH)
		camera.translate(     camera.global_transform.basis.y * CAMERA_SHAKING_STRENGTH)
	elif timeShaking < MAX_SHAKING_TIME / 2:
		camera.translate( 1 * camera.global_transform.basis.z * CAMERA_SHAKING_STRENGTH)
		camera.translate(-    camera.global_transform.basis.y * CAMERA_SHAKING_STRENGTH)
	elif timeShaking < MAX_SHAKING_TIME * 0.75:
		camera.translate(-1 * camera.global_transform.basis.z * CAMERA_SHAKING_STRENGTH)
		camera.translate(     camera.global_transform.basis.y * CAMERA_SHAKING_STRENGTH)
	else:
		camera.translate(     camera.global_transform.basis.z * CAMERA_SHAKING_STRENGTH)
		camera.translate(-    camera.global_transform.basis.y * CAMERA_SHAKING_STRENGTH)
	if timeShaking == MAX_SHAKING_TIME:
		doesShake = false

func process_input(_delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
#Press T to switch between local and world space when selecting a Spatial node
	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	dir -= cam_xform.basis.z * input_movement_vector.y #There is a minus!!!
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		isSprinting = true
	else:
		isSprinting = false

	# ----------------------------------
	# Flashlight toggle on/off
	if Input.is_action_just_pressed("flashlight_toggle"):
		toggleFlashlight()

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			if isMouseCaptured:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# ----------------------------------
	#Firing the weapons
	if Input.is_action_pressed("fire") and isMouseCaptured:
		laser()
			
	if Input.is_action_just_pressed("secondaryAction") and isMouseCaptured:
		missile()

	# ----------------------------------
	#Looting corpses
	if canLoot:
		if Input.is_action_pressed("Interact"):
			hideLootingText()
			showLootingScene()
			isMouseCaptured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hideLootingText():
	lootingText.hide()

func showLootingText():
	lootingText.show()

func hideLootingScene():
	lootingScene.hide()

func showLootingScene():
	lootingScene.show()

func laser():
	if not timeBeforeAttack:
		var scene_root = get_tree().root.get_children()[0]
		var newShot = cannonManager.instance()
#		newShot.scale = Vector3(3, 3, 3)
		scene_root.add_child(newShot)
		newShot.global_transform.origin = laserMuzzles[laserFromRight].global_transform.origin
		newShot.direction = 2 * laserMuzzles[laserFromRight].global_transform.basis.x
		laserFromRight = 1 - laserFromRight
		newShot.BULLET_DAMAGE = 2
		timeBeforeAttack = TIME_BETWEEN_ATTACKS
		newShot.initiator = "Player"
		playSound("laser3")

func missile():
	if not timeBeforeMissileLeft:
		var scene_root = get_tree().root.get_children()[0]
		var newShot = cannonManager.instance()
#		newShot.scale = Vector3(3, 3, 3)
		scene_root.add_child(newShot)
		newShot.global_transform.origin = cannonMuzzles[0].global_transform.origin
		newShot.direction = cannonMuzzles[0].global_transform.basis.x
		newShot.initiator = "Player"
		timeBeforeMissileLeft = TIME_BETWEEN_MISSILES
		playSound("cannon")
	elif not timeBeforeMissileRight:
		var scene_root = get_tree().root.get_children()[0]
		var newShot = cannonManager.instance()
#		newShot.scale = Vector3(3, 3, 3)
		scene_root.add_child(newShot)
		newShot.global_transform.origin = cannonMuzzles[1].global_transform.origin
		newShot.direction = cannonMuzzles[1].global_transform.basis.x
		newShot.initiator = "Player"
		timeBeforeMissileRight = TIME_BETWEEN_MISSILES
		playSound("cannon")

func process_movement(delta):
#	dir.y = 0
	dir = dir.normalized()

#	vel.y += delta * GRAVITY

	var target = dir
	if isSprinting:
		target *= MAX_SPRINTSPEED
	else:
		target *= MAX_SPEED

# warning-ignore:incompatible_ternary
	var accel = (SPRINT_ACCELERATION if isSprinting else ACCEL) if dir.dot(vel) > 0 else DEACCEL

	vel = vel.linear_interpolate(target, accel * delta)
	for reactor in reactors:
# warning-ignore:incompatible_ternary
		reactor.scale = Vector3(1, 8 * vel.length() / (target.length() if target.length() else (MAX_SPRINTSPEED if isSprinting else MAX_SPEED)), 1)

# warning-ignore:incompatible_ternary
	camera.global_translate(camera.global_transform.basis.z * vel.length() / (target.length() if target.length() else (MAX_SPRINTSPEED if isSprinting else MAX_SPEED)))

#	vel.x = hvel.x
#	vel.z = hvel.z
#	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	vel = move_and_slide(vel, Vector3(0, 1, 0), false, 4, 0.785398, false)

#Weapon management
#func process_changing_weapons(_delta):
#	if changing_weapon:
#		var weaponUnequipped = true
#		var currentWeapon = weapons[current_weapon_name]
#
#		if currentWeapon != null:
#			if currentWeapon.is_weapon_enabled:
#				weaponUnequipped = currentWeapon.unequip_weapon()
#
#		if weaponUnequipped:
#			var weaponEquipped = true
#			var weaponToEquip = weapons[changing_weapon_name]
#
#			if weaponToEquip != null:
#				if not weaponToEquip.is_weapon_enabled:
#					weaponEquipped = weaponToEquip.equip_weapon()
#
#			if weaponEquipped:
#				changing_weapon = false
#				current_weapon_name = changing_weapon_name
#				changing_weapon_name = ""
#
#func fire_bullet():
#	if changing_weapon:
#		return
#	weapons[current_weapon_name].fire_weapon()
#End of wepaon management

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		print("beforex = " , self.camera.translation.x  , "    y = " , self.camera.translation.y  , "    z = ", self.camera.translation.z)
		rotation_helper.rotate_z(- deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		var camera_rot = rotation_helper.rotation_degrees
		if camera_rot.z > 90 || camera_rot.z < -90:
#			print("blobjf")
			self.rotate_y(deg2rad(+ event.relative.x * MOUSE_SENSITIVITY))
#			print("      x = " , self.camera.translation.x  , "    y = " , self.camera.translation.y  , "    z = ", self.camera.translation.z)
		else:
			self.rotate_y(deg2rad(- event.relative.x * MOUSE_SENSITIVITY))

func bullet_hit(damage, _bullet_transform):
	health -= damage
	doesShake = true
	timeShaking = 0
	if health < 0:
		print("FUUUUUUUKKKKKCCCCCC")

func playSound(name):
	var audioClone = soundManager.instance()
	var sceneRoot = get_tree().root.get_children()[0]
	sceneRoot.add_child(audioClone)
	audioClone.playSound(name)

func toggleFlashlight():
	if flashlight[0].is_visible_in_tree():
		flashlight[0].hide()
		flashlight[1].hide()
	else:
		flashlight[0].show()
		flashlight[1].show()
