extends Node

const PORT: int = 9999
const MAX_CLIENTS: int = 8
var player_scene: PackedScene = load("res://Scenes/Player.tscn")
@export var world: Node3D
@export var ui: Control
@export var join_ui: Control
@export var join_text: TextEdit
@export var spawner: MultiplayerSpawner
@export var players: Node

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_out_peer_connect)
	multiplayer.server_disconnected.connect(_on_serve_disconnected)

func _host() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)
	if error == OK:
		print("OK")
		multiplayer.multiplayer_peer = peer
		var player: Node = player_scene.instantiate()
		player.position = Vector3(0, 50, 0)
		player.name = "1"
		player.set_multiplayer_authority(1)
		players.add_child(player)
		player.get_node("Camera3D").make_current()
	else:
		print("wrong")
		return
	ui.visible = false
	world.visible = true



func _jost() -> void:
	join_ui.visible = true


func _join_room() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(join_text.text, PORT)
	multiplayer.multiplayer_peer = peer
	ui.visible = false
	world.visible = true

func _on_peer_connect(id: int):
	if not multiplayer.is_server():
		return
	var player:Node = player_scene.instantiate()
	player.position = Vector3(0, 50, 0)
	player.name = str(id)
	players.add_child(player)
	player.set_multiplayer_authority(id)

func _out_peer_connect(id: int):
	var player: Node =  players.get_node_or_null(str(id))
	if player == null:
		return
	players.remove_child(player)
	player.queue_free()
	player.set_multiplayer_authority(id)

func _on_serve_disconnected():
	for player in players.get_children():
		player.queue_free()
	multiplayer.multiplayer_peer = null
