extends Node2D


@export var PlayerScene: PackedScene
@export var host: String = "localhost"
@export var port: int = 3000

@onready var reconnect_timer: Timer = $ReconnectTimer
@onready var net_work_status_label: Label = $NetworkStatusLabel
@onready var networked_nodes: Node = $NetworkedNodes


var peer: ENetMultiplayerPeer

func _ready():
	start_network()


func _on_reconnect_timer_timeout():
	var message = ""

	if peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_DISCONNECTED or peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTING:
		peer.create_client(host, port)
		message = "切断されています。再接続を試みます..."
		net_work_status_label.modulate = Color(1, 0, 0, 1)
	elif peer.get_connection_status() == ENetMultiplayerPeer.CONNECTION_CONNECTED:
		message = "サーバに接続済みです。"
		net_work_status_label.modulate = Color(0, 1, 0, 1)
	
	net_work_status_label.text = message


func start_network() -> void:
	peer = ENetMultiplayerPeer.new()
	if "--server" in OS.get_cmdline_args():
		multiplayer.peer_connected.connect(create_player)
		multiplayer.peer_disconnected.connect(destroy_player)
		peer.create_server(port)
		print("server listening on localhost " + str(port))

	else:
		peer.create_client(host, port)
		reconnect_timer.start()

	multiplayer.multiplayer_peer = peer


func create_player(id: int) -> void:
	print(str(id) + " が接続しました。")
	var player = PlayerScene.instantiate()
	player.name = str(id)
	networked_nodes.add_child(player)


func destroy_player(id: int) -> void:
	print(str(id) + " が切断しました。")
	networked_nodes.get_node(str(id)).queue_free()
