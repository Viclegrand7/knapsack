extends KinematicBody

const TIME_BETWEEN_REPAIRS = 10
var timeSinceLastRepair = 0

const MAX_HEALTH = 100
var health = MAX_HEALTH

var target = null
var needToFight = false

const MAX_SPEED = 30
const ACCEL = 2
const DECEL = 1
const SLOW_DECEL = 0.1
var velocity : Vector3

const MAX_SHOOTING_RANGE = 70
const NORMAL_SHOOTING_RANGE = 60
const CLOSE_RANGE = 30

const TIME_BETWEEN_ATTACKS = 1.5
var timeBeforeAttack = 0

var cannonManager = preload("res://Bullet_Scene.tscn")
onready var muzzle = $Turrets

func bullet_hit(damage, bulletGlobalTransform):
	health -= damage
	needToFight = true
	set_alert_state()
	move_and_slide(bulletGlobalTransform.basis.z, Vector3(0, 1, 0), false, 4, 0.75398, false)
	if health < 0 :
		print("Ok I'm dead")

func _process(delta):
	if needToFight and target:
		set_alert_state()
		timeSinceLastRepair += delta
		if timeSinceLastRepair > TIME_BETWEEN_REPAIRS:
			timeSinceLastRepair -= TIME_BETWEEN_REPAIRS
			autoRepair()
		rotate_towards_ennemy(delta, target)
		move_towards_ennemy(delta, target)
		attack(delta)

func attack(delta):
	timeBeforeAttack = clamp(timeBeforeAttack - delta, 0, TIME_BETWEEN_ATTACKS)
	if not timeBeforeAttack:
		var scene_root = get_tree().root.get_children()[0]
		var newShot = cannonManager.instance()
		scene_root.add_child(newShot)
		newShot.global_transform.origin = muzzle.global_transform.origin
		newShot.direction = muzzle.global_transform.origin.direction_to(target.global_transform.origin)
		timeBeforeAttack = TIME_BETWEEN_ATTACKS

func autoRepair():
	health = clamp(health + 10, 0, MAX_HEALTH)
	if health == MAX_HEALTH:
		set_normal_state()
		needToFight = false

func move_towards_ennemy(delta, target):
	var distance = global_transform.origin.distance_to(target.global_transform.origin)
	if distance > NORMAL_SHOOTING_RANGE:
		var direction = global_transform.origin.direction_to(target.global_transform.origin)
		direction *= MAX_SPEED
		var acceleration
		if direction.dot(velocity) > 0:
			acceleration = ACCEL
		else:
			acceleration = DECEL
		velocity = velocity.linear_interpolate(direction, acceleration * delta)
		velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, 0.75398, false)
	elif distance < CLOSE_RANGE:
		var direction = global_transform.origin.direction_to(target.global_transform.origin)
		direction *= - MAX_SPEED
		var acceleration
		if direction.dot(velocity) > 0:
			acceleration = DECEL
		else:
			acceleration = ACCEL
		velocity = velocity.linear_interpolate(direction, acceleration * delta)
		velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, 0.75398, false)
	else:
		velocity = velocity.linear_interpolate(Vector3(0, 0, 0), DECEL * delta)
		velocity = move_and_slide(velocity, Vector3(0, 1, 0), false, 4, 0.75398, false)


func rotate_towards_ennemy(delta, target):
	var desiredRotation = global_transform.looking_at(target.global_transform.origin, Vector3(0, 1, 0))
	var transform = Quat(global_transform.basis.get_rotation_quat()).slerp(desiredRotation.basis.get_rotation_quat(), 0.05)
#	global_transform = Transform(transform, global_transform.origin)
	global_transform.basis = Basis(transform)

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null

func set_alert_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 0, 0))

func set_normal_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 1, 1))