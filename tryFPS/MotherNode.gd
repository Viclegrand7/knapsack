extends Node

var serverAddress = "localhost"
var network
var mplayer

var spaceLists = ["Testing_Space", "Testing_Space_2", "Testing_Space_3", "Testing_Space_4", "StartMenuScene"]
#var spaceLists = ["Testing_Space", "StartMenuScene"]

var counter = 0

var connectionSuccess = false

func _ready():
	network=NetworkedMultiplayerENet.new()
	network.create_client(serverAddress,4242)
	get_tree().set_network_peer(network)
	mplayer = get_tree().multiplayer
	mplayer.connect("network_peer_packet",self,"_on_packet_received")
	_wait(3)
	sendToServer("C")

func sendToServer(message):
	mplayer.send_bytes(message.to_ascii())

func _on_packet_received(_id, packet):
	var message = packet.get_string_from_ascii()
	print(message)
	if message[0] == 'X':
		connectionSuccess = true
		print("SUCCESSSSSS")
	elif message[0] == 'C':
		$Inventory.computerScore = int(message.right(1))
	elif message[0] == 'R':
		var infos = (message.right(1)).split(',')
		counter = int(infos[0])
		$Inventory.playerScore = int(infos[1])
		$Inventory.computerScore = int(infos[2])
		print(infos)
		var level = get_node(spaceLists[0])
		remove_child(level)
		level.call_deferred("free")
		# Add the next level
		var next_level_resource = load(spaceLists[counter])
		var next_level = next_level_resource.instance()
		add_child(next_level)
		move_child(next_level, 0)
	else:
		print("Unknown message: ", message)


func nextScene():
	counter += 1
	return spaceLists[counter]


signal timer_end

func _wait( seconds ):
	self._create_timer(self, seconds, true, "_emit_timer_end_signal")
	yield(self,"timer_end")

func _emit_timer_end_signal():
	emit_signal("timer_end")

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	var timer = Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()
