extends Node
class_name Main

class Player:
	var username:String
	var id:int
	var color:Color
	
	func _init(_id,_username,_color) -> void:
		username= _username
		id = _id
		color = _color


const PORT = 25876

var players:Array[Player]=[]
var cur_turn=-1
@onready
var main_menu := $"Main Menu"

func _ready() -> void:
	main_menu.leave_game.connect(leave_game)
	main_menu.change_user_data.connect(change_player_data.rpc)
	main_menu.start_game.connect(start_game.rpc)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.connected_to_server.connect(connection_succses)
	multiplayer.peer_disconnected.connect(player_leave)
	multiplayer.connection_failed.connect(connection_failed)

func player_leave(id):
	var ind = 0
	for i in players:
		if i.id == id:
			players.remove_at(ind)
			break
		ind+=1
	main_menu.remove_player(id)

@rpc("call_local","reliable")
func start_game():
	pass

@rpc("any_peer","reliable")
func next_turn():
	cur_turn+=1
	if cur_turn>=len(players):
		cur_turn=0
	$Game.set_turn_name.rpc(players[cur_turn].username)
	if players[cur_turn].id==1:
		$Game.start_turn()
	else:
		$Game.start_turn.rpc_id(players[cur_turn].id)

func start_button_pressed():
	for i:Node in $Lobby/UserPlateContainer.get_children():
		if not i.readied:
			return
	players.shuffle()
	cur_turn=-1
	next_turn()
	start_game.rpc()
	
func _on_main_menu_host_game() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	main_menu.join_lobby()
	multiplayer.multiplayer_peer = peer
	players.append(Player.new.callv([multiplayer.get_unique_id()]+main_menu.get_player_data()))
	main_menu.add_player(players.back())


func _on_main_menu_join_game() -> void:
	main_menu.show_loading()
	main_menu.join_lobby()
	var peer = ENetMultiplayerPeer.new()
	if peer.create_client(main_menu.get_ip(),PORT):
		connection_failed()
		return
	multiplayer.multiplayer_peer = peer
	players.append(Player.new.callv([multiplayer.get_unique_id()]+main_menu.get_player_data()))
	main_menu.add_player(players.back())

@rpc("any_peer")
func change_player_data(property:String,data):
	for i in players:
		if i.id == multiplayer.get_remote_sender_id():
			i.set(property,data)
			break

func connection_succses():
	main_menu.hide_loading()

func connection_failed():
	main_menu.hide_loading()
	main_menu.leave_lobby()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players = []

@rpc()
func kick_players():
	connection_failed()

func leave_game():
	if multiplayer.is_server():
		kick_players.rpc()
		await get_tree().create_timer(0.25).timeout
		connection_failed()
	else:
		connection_failed()


func peer_connected(id):
	player_joined.rpc_id(id,main_menu.get_player_data())

@rpc("any_peer","reliable")
func player_joined(data):
	var id = multiplayer.get_remote_sender_id()
	players.append(Player.new.callv([id]+data))
	main_menu.add_player(players.back())
	if multiplayer.is_server():
		pass


func _on_game_turn_finished() -> void:
	if multiplayer.is_server():
		next_turn()
		return
	next_turn.rpc_id(1)
