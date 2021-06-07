extends Spatial


func _ready():
	var firstShip = $EnnemyShip
	var secondShip = $EnnemyShip2

	firstShip.connect("timeForWar", secondShip, "set_alert_state")
	secondShip.connect("timeForWar", firstShip, "set_alert_state")

	firstShip.connect("timeForPeace", secondShip, "set_normal_state")
	secondShip.connect("timeForPeace", firstShip, "set_normal_state")

