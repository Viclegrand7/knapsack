extends RigidBody

const BASE_BULLET_BOOST = 9

var target

func _ready():
	pass

func bullet_hit(damage, bullet_global_trans):
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST
	
	apply_impulse((bullet_global_trans.origin - global_transform.origin).normalized(), direction_vect * damage)

func _process(_delta):
	if target:
		look_at(target.global_transform.origin, Vector3.UP)


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		set_alert_state()


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		set_normal_state()

func set_alert_state():
	$ship2_modif/Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 0, 0))

func set_normal_state():
	$ship2_modif/Cube011_Cube017.get_surface_material(3).set_albedo(Color(1, 1, 1))
