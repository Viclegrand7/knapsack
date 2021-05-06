extends KinematicBody

export var ACCEL : float = 2
export var MAX_SPEED : float = 30
export var DEACCEL : float = 1

export(float, 0.1, 1) var mouse_sensitivity : float = 0.3

var vel : Vector3

onready var rotation_helper = $xCameraPivot
onready var camera = $xCameraPivot/yCameraPivot/SpringArm/Camera

var dir = Vector3()

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINTSPEED = 30
const SPRINT_ACCELERATION = 18
var isSprinting = false

const TIME_BETWEEN_ATTACKS = 1
var timeBeforeAttack = 0

var flashlight

var cannonManager = preload("res://Bullet_Scene.tscn")
onready var muzzle = $xCameraPivot/Canons/Muzzle

var timeShaking : float = 0
const MAX_SHAKING_TIME = 0.5
var doesShake = false

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
	flashlight = [$CameraPivot/Cube011_Cube017/FlashLight1, $CameraPivot/Cube011_Cube017/FlashLight2]

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

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
#	process_changing_weapons(delta)
	timeBeforeAttack = clamp(timeBeforeAttack - delta, 0, TIME_BETWEEN_ATTACKS)
	camera_shake(float(1)/16)

func camera_shake(time):
	if not doesShake:
		return
	timeShaking += time
	if timeShaking < MAX_SHAKING_TIME / 4:
		camera.translate(Vector3(-0.3, -0.3,  0))
	elif timeShaking < MAX_SHAKING_TIME / 2:
		camera.translate(Vector3( 0.6,  0.3,  0))
	elif timeShaking < MAX_SHAKING_TIME * 0.75:
		camera.translate(Vector3(-0.6,  0.3,  0))
	else:
		camera.translate(Vector3(1, 1, 0))
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
		if flashlight[0].is_visible_in_tree():
			flashlight[0].hide()
			flashlight[1].hide()
		else:
			flashlight[0].show()
			flashlight[1].show()

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	#Weapon management
	# ----------------------------------
	#Changing weapons
#	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
#
#	if Input.is_action_pressed("KEY_5"): #5
#		weapon_change_number = 0
#	if Input.is_action_pressed("KEY_1"): #1
#		weapon_change_number = 1
#	if Input.is_action_pressed("KEY_2"): #2
#		weapon_change_number = 2
#	if Input.is_action_pressed("KEY_3"): #3
#		weapon_change_number = 3
#
#	if Input.is_action_just_pressed("next_weapon"):
#		weapon_change_number += 1
#	if Input.is_action_just_pressed("previous_weapon"):
#		weapon_change_number -= 1
#
#	weapon_change_number = (weapon_change_number + WEAPON_NUMBER_TO_NAME.size()) % WEAPON_NUMBER_TO_NAME.size()
#
#	if not changing_weapon:
#		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
#			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
#			changing_weapon = true
#
	# ----------------------------------
	#Firing the weapons
	if Input.is_action_pressed("fire"):
		if not timeBeforeAttack:
			var scene_root = get_tree().root.get_children()[0]
			var newShot = cannonManager.instance()
			scene_root.add_child(newShot)
			newShot.global_transform.origin = muzzle.global_transform.origin
			newShot.direction = muzzle.global_transform.basis.y
			timeBeforeAttack = TIME_BETWEEN_ATTACKS
	#End of weapon management

func process_movement(delta):
#	dir.y = 0
	dir = dir.normalized()

#	vel.y += delta * GRAVITY

	var hvel = vel
#	hvel.y = 0

	var target = dir
	if isSprinting:
		target *= MAX_SPRINTSPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if isSprinting:
			accel = SPRINT_ACCELERATION
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
#	vel.x = hvel.x
#	vel.z = hvel.z
	vel = hvel
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
