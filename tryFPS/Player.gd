extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 1
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINTSPEED = 30
const SPRINT_ACCELERATION = 18
var isSprinting = false

var flashlight

#Weapon management
var animation_manager

var current_weapon_name = "UNARMED"
var weapons = {"UNARMED": null, "KNIFE": null, "RIFLE": null, "PISTOL": null}
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1: "RIFLE", 2: "PISTOL", 3: "KNIFE"}
const WEAPON_NAME_TO_NUMBER = {"UNARMED": 0, "RIFLE": 1, "PISTOL": 2, "KNIFE": 3}
var changing_weapon = false
var changing_weapon_name = "UNARMED"

var health = 100

var UI_status_label
#End of weapon management

func _ready():
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	flashlight = $Rotation_Helper/Flashlight

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#Weapon management
	animation_manager = $Rotation_Helper/Model/Animation_Player
	animation_manager.callback_function = funcref(self, "fire_bullet")
	
	weapons["KNIFE"]  = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"]  = $Rotation_Helper/Gun_Fire_Points/Rifle_Point
	
	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin
	
	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180)) #So it shoots towards positive Y axis
	
	current_weapon_name  = "UNARMED"
	changing_weapon_name = "UNARMED"
	
	UI_status_label = $HUD/Panel/Gun_label
	#End of weapon management

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_changing_weapons(delta)

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
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED

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
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
	
	if Input.is_action_pressed("KEY_5"): #5
		weapon_change_number = 0
	if Input.is_action_pressed("KEY_1"): #1
		weapon_change_number = 1
	if Input.is_action_pressed("KEY_2"): #2
		weapon_change_number = 2
	if Input.is_action_pressed("KEY_3"): #3
		weapon_change_number = 3
	
	if Input.is_action_just_pressed("next_weapon"):
		weapon_change_number += 1
	if Input.is_action_just_pressed("previous_weapon"):
		weapon_change_number -= 1
	
	weapon_change_number = (weapon_change_number + WEAPON_NUMBER_TO_NAME.size()) % WEAPON_NUMBER_TO_NAME.size()
	
	if not changing_weapon:
		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
			changing_weapon = true
	
	# ----------------------------------
	#Firing the weapons
	if Input.is_action_pressed("fire"):
		if not changing_weapon:
			var currentWeapon = weapons[current_weapon_name]
			if currentWeapon != null:
				if animation_manager.current_state == currentWeapon.IDLE_ANIM_NAME:
					animation_manager.set_animation(currentWeapon.FIRE_ANIM_NAME)
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
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

#Weapon management
func process_changing_weapons(_delta):
	if changing_weapon:
		var weaponUnequipped = true
		var currentWeapon = weapons[current_weapon_name]
		
		if currentWeapon != null:
			if currentWeapon.is_weapon_enabled:
				weaponUnequipped = currentWeapon.unequip_weapon()
		
		if weaponUnequipped:
			var weaponEquipped = true
			var weaponToEquip = weapons[changing_weapon_name]
			
			if weaponToEquip != null:
				if not weaponToEquip.is_weapon_enabled:
					weaponEquipped = weaponToEquip.equip_weapon()
		
			if weaponEquipped:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""

func fire_bullet():
	if changing_weapon:
		return
	weapons[current_weapon_name].fire_weapon()
#End of wepaon management

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
#		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
#
#		var camera_rot = rotation_helper.rotation_degrees
#		camera_rot.x = clamp(camera_rot.x, -70, 70)
#		rotation_helper.rotation_degrees = camera_rot
#
#		print("beforex = " , self.camera.translation.x  , "    y = " , self.camera.translation.y  , "    z = ", self.camera.translation.z)
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		var camera_rot = rotation_helper.rotation_degrees
		if camera_rot.x > 90 || camera_rot.x < -90:
#			print("blobjf")
			self.rotate_y(deg2rad(  event.relative.x * MOUSE_SENSITIVITY))
#			print("      x = " , self.camera.taranslation.x  , "    y = " , self.camera.translation.y  , "    z = ", self.camera.translation.z)
		else:
			self.rotate_y(deg2rad(- event.relative.x * MOUSE_SENSITIVITY))
#		camera_rot.x = clamp(camera_rot.x, -70, 70)
#		rotation_helper.rotation_degrees = camera_rot
#		print("x = " , camera_rot.x , "    y = " , camera_rot.y)
#		print("      x = " , self.camera.taranslation.x  , "    y = " , self.camera.translation.y  , "    z = ", self.camera.translation.z)

