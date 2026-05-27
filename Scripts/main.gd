extends Node
class_name Main

class Player:
	static var player_db:Dictionary[int,Player]={}
	var username:String
	var id:int
	var color:Color
	
	func _init(_id,_username,_color) -> void:
		username= _username
		id = _id
		color = _color
		player_db[id]=self


const PORT = 25876

var players:Array[int]=[]
var cur_turn=-1
@onready var main_menu := $"Main Menu"
@onready var game := $Game

func _ready() -> void:
	main_menu.leave_game.connect(leave_game)
	main_menu.change_user_data.connect(change_player_data.rpc)
	main_menu.start_game.connect(start_game)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.connected_to_server.connect(connection_succses)
	multiplayer.peer_disconnected.connect(player_leave)
	multiplayer.connection_failed.connect(connection_failed)

func player_leave(id):
	if multiplayer.is_server():
		var ind = 0
		for i in players:
			if i == id:
				players.remove_at(ind)
				break
			ind+=1
	main_menu.remove_player(id)

func start_game():
	game.start.rpc()
	show_game.rpc()
	players.shuffle()
	setup_turn()

@rpc("call_local")
func show_game():
	game.show()
	main_menu.hide()

@rpc("any_peer")
func setup_turn():
	for i in players:
		if game.board.count_corner_item(Corner.Type.SETTLEMENT,i)<1:
			if i ==1:
				game.setup_turn()
			else:
				game.setup_turn.rpc_id(i)
			return
	for i in range(len(players)-1,-1,-1):
		if game.board.count_corner_item(Corner.Type.SETTLEMENT,players[i])<2:
			if players[i]==1:
				game.setup_turn()
			else:
				game.setup_turn.rpc_id(players[i])
			return
	next_turn()

@rpc("any_peer","reliable")
func next_turn():
	cur_turn+=1
	if cur_turn>=len(players):
		cur_turn=0
	game.set_turn.rpc(players[cur_turn])
	if players[cur_turn]==1:
		game.start_turn()
	else:
		game.start_turn.rpc_id(players[cur_turn])

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
	var player = Player.new.callv([multiplayer.get_unique_id()]+main_menu.get_player_data())
	players.append(player.id)
	main_menu.add_player(player)


func _on_main_menu_join_game() -> void:
	main_menu.show_loading()
	main_menu.join_lobby()
	var peer = ENetMultiplayerPeer.new()
	if peer.create_client(main_menu.get_ip(),PORT):
		connection_failed()
		return
	multiplayer.multiplayer_peer = peer
	main_menu.add_player(Player.new.callv([multiplayer.get_unique_id()]+main_menu.get_player_data()))

@rpc("any_peer")
func change_player_data(property:String,data):
	Player.player_db[multiplayer.get_remote_sender_id()].set(property,data)

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
	main_menu.add_player(Player.new.callv([id]+data))
	if multiplayer.is_server():
		players.append(id)


func _on_game_turn_finished() -> void:
	if multiplayer.is_server():
		next_turn()
		return
	next_turn.rpc_id(1)


func _on_game_setup_done() -> void:
	if multiplayer.is_server():
		setup_turn()
		return
	setup_turn.rpc_id(1)
	
