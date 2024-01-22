extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

const Player = preload("res://Scenes/Player.tscn")
const Mur = preload("res://Scenes/Mur.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var grab_mouse = false

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		grab_mouse = !grab_mouse
	
func rectangle_wall(x,z):
	for xi in 3:
		for yi in 3:
			for zi in 3:
				var spawn_mur = Mur.instantiate()
				spawn_mur.position.x = x+xi*1
				spawn_mur.position.y = yi*1
				spawn_mur.position.z = z+zi*1
				add_child(spawn_mur)

func _ready():
	get_node("CanvasLayer/HUD").visible = false
	get_node("CanvasLayer/HUD/Hoster").visible = false
	get_node("CanvasLayer/HUD/Hoster/GameSettingsPanel").visible = false
	for xi in range(-16+3,16+1,8):
		for zi in range(-16+3,16+1,8):
			rectangle_wall(xi,zi)
	

func _process(delta):
	if grab_mouse == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	grab_mouse = true
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	get_node("CanvasLayer/HUD/Hoster").visible = true
	get_node("CanvasLayer/HUD").visible = true

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	grab_mouse = true
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	get_node("CanvasLayer/HUD").visible = true

func add_player(peer_id):
	MultiplayerStats.players += 1
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value


func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)


func _on_game_settings_pressed():
	pass # Replace with function body.
