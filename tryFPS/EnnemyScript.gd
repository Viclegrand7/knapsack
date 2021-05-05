extends RigidBody

const BASE_BULLET_BOOST = 9
const DECREASE_RATE = 0.9
const SPEED = 100
const TURN_RATE = 0.5
const TURN_COMPENSATION = 1 - 0.01

var target

func _ready():
	pass

func bullet_hit(damage, bullet_global_trans):
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST	
	apply_impulse((bullet_global_trans.origin - global_transform.origin).normalized(), direction_vect * damage)

func _process(delta):
	if target:
		set_alert_state()
#		look_at(target.global_transform.origin, global_transform.basis.y)
		var direction = global_transform.origin - target.global_transform.origin;
		
		var left_right = direction.dot(global_transform.basis.x)
		if abs(left_right) < 0.05:
			angular_velocity.y *= TURN_COMPENSATION * delta
#			if abs(left_right) > 0.05:
#				var rotationForce = clamp(TURN_RATE / left_right, -TURN_COMPENSATION, TURN_COMPENSATION)
#				apply_torque_impulse(- rotationForce * global_transform.basis.y)
###
#				var currentForcesOrSomething = get_inverse_inertia_tensor()
#				add_torque(+ TURN_COMPENSATION * sign(left_right) * currentForcesOrSomething.y)
		else:
			apply_torque_impulse(TURN_RATE  * left_right * global_transform.basis.y)

		var up_down = direction.dot(global_transform.basis.y)
		if abs(up_down) < 0.11:
			var rotationForce = clamp(TURN_RATE / up_down, -TURN_COMPENSATION, TURN_COMPENSATION)
			apply_torque_impulse(+ rotationForce * global_transform.basis.x)
#			var currentForcesOrSomething = get_inverse_inertia_tensor()
#			add_torque(+ TURN_COMPENSATION * sign(up_down) * currentForcesOrSomething.x)
		else:
			apply_torque_impulse(- TURN_RATE * up_down * global_transform.basis.x) 
#		add_torque(+1000 * global_transform.basis.y) #Left
#		add_torque(-1000 * global_transform.basis.y) #Right
#		moveTowardsTarget(delta)


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		set_alert_state()


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		set_normal_state()

func moveTowardsTarget(_delta):
	pass

func set_alert_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 0, 0))

func set_normal_state():
	$Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 1, 1))
