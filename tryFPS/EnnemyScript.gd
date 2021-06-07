extends RigidBody

const BASE_BULLET_BOOST = 9
const DECREASE_RATE = 0.9
const SPEED = 1

const TURN_RATE = 0.2
const TURN_COMPENSATION = 0.9
const START_COMPENSATION = 1

const maxRange = 40
const minRange = 20

const ORTHONORMALIZING = 5
var timeSinceLastOrtho : float = 0

var looted = false

var target
var Thrustle

func _ready():
	Thrustle = $Thrustle

func bullet_hit(damage, bullet_global_trans):
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST
	apply_impulse((bullet_global_trans.origin - global_transform.origin).normalized(), direction_vect * damage)

func _process(delta):
	if target:
		set_alert_state()
#		look_at(target.global_transform.origin, global_transform.basis.y)
		var direction = global_transform.origin - target.global_transform.origin;
		
		var left_right = direction.dot(global_transform.basis.x)
		if abs(left_right) < START_COMPENSATION:
			apply_torque_impulse(- sign(angular_velocity.y) * TURN_COMPENSATION / (delta + 1) * global_transform.basis.y)
#			angular_velocity.y *= TURN_COMPENSATION / (delta + 1)
###
#			if abs(left_right) > 0.05:
#				var rotationForce = clamp(TURN_RATE / left_right, -TURN_COMPENSATION, TURN_COMPENSATION)
#				apply_torque_impulse(- rotationForce * global_transform.basis.y)
###
#				var currentForcesOrSomething = get_inverse_inertia_tensor()
#				add_torque(+ TURN_COMPENSATION * sign(left_right) * currentForcesOrSomething.y)
#		else:
		apply_torque_impulse(TURN_RATE  * left_right * global_transform.basis.y / (delta + 1))

		var up_down = direction.dot(global_transform.basis.y)
		if abs(up_down) < START_COMPENSATION:
			apply_torque_impulse(- sign(angular_velocity.z) * TURN_COMPENSATION / (delta + 1) * global_transform.basis.z)
#			angular_velocity.z *= TURN_COMPENSATION / (delta + 1)
###
#			var rotationForce = clamp(TURN_RATE / up_down, -TURN_COMPENSATION, TURN_COMPENSATION)
#			apply_torque_impulse(+ rotationForce * global_transform.basis.x)

#			var currentForcesOrSomething = get_inverse_inertia_tensor()
#			add_torque(+ TURN_COMPENSATION * sign(up_down) * currentForcesOrSomething.x)
#		else:
		apply_torque_impulse(- TURN_RATE * up_down * global_transform.basis.x / (delta + 1)) 
#		add_torque(+1000 * global_transform.basis.y) #Left
#		add_torque(-1000 * global_transform.basis.y) #Right
		moveTowardsTarget(delta)
		timeSinceLastOrtho += delta
		if timeSinceLastOrtho > ORTHONORMALIZING:
			timeSinceLastOrtho -= ORTHONORMALIZING
			transform = transform.orthonormalized()


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		set_alert_state()


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		set_normal_state()

func moveTowardsTarget(delta):
	var direction = global_transform.origin.direction_to(target.global_transform.origin)
	var distance = global_transform.origin.distance_to(target.global_transform.origin)
	var propulsionDirection
	var propulsionForce = direction.dot(global_transform.basis.z)
	if propulsionForce > 0:
		propulsionDirection = global_transform.basis.z
	else:
		propulsionDirection = - global_transform.basis.z
	if distance > maxRange:
		add_force(  propulsionDirection / (1 + abs(propulsionForce)) / (1 + delta), Thrustle.global_transform.origin)
		return true
	elif distance < maxRange:
		add_force(- propulsionDirection / (1 + abs(propulsionForce)) / (1 + delta), Thrustle.global_transform.origin)
	else:
		var z_velocity = get_linear_velocity().z
		add_force(sign(z_velocity) * SPEED * global_transform.basis.z / (1 + abs(propulsionForce)) / (1 + delta), Thrustle.global_transform.origin)
	return false

func set_alert_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 0, 0))

func set_normal_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 1, 1))
