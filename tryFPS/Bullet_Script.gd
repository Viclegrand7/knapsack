extends Spatial

var BULLET_SPEED = 140
var BULLET_DAMAGE = 15
var BULLET_ROTATION = 2

const KILL_TIMER = 4
var timer = 0

var direction
var initiator

var hit_something = false

func _ready():
# warning-ignore:return_value_discarded
	$Area.connect("body_entered", self, "collided")

func _physics_process(delta):
	global_translate(direction * BULLET_SPEED * delta)
#	rotate_x(-1 * BULLET_ROTATION * delta)
#	rotate_y(+2 * BULLET_ROTATION * delta)
#	rotate_z(-1 * BULLET_ROTATION * delta)
	
	timer += delta
	if timer > KILL_TIMER:
		queue_free()

func collided(body):
	if body == initiator:
		return
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)
	
	hit_something = true
	queue_free()
