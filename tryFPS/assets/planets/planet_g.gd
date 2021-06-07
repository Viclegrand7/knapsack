extends RigidBody

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		body.showLootingText()
		body.canTrade = true
	
func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		body.hideLootingText()
		body.canTrade = false
