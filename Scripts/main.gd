extends Node

class Player:
	var username:String
	var id
	
	func _init(user,pid) -> void:
		username= user
		id = pid


const PORT = 25876

var peer = ENetMultiplayerPeer.new()
var players:Array[Player]=[]
var cur_turn=0

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	
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
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	players.append(Player.new($MainMenu.get_username(),multiplayer.get_unique_id()))


func _on_main_menu_join_game(ip:String) -> void:
	peer.create_client(ip,PORT)
	multiplayer.multiplayer_peer = peer


func peer_connected(id):
	player_joined.rpc_id(id,$MainMenu.get_username())
	
	
@rpc("any_peer","reliable")
func player_joined(username):
	var id = multiplayer.get_remote_sender_id()
	if multiplayer.is_server():
		players.append(Player.new(username,id))


func _on_game_turn_finished() -> void:
	if multiplayer.is_server():
		next_turn()
		return
	next_turn.rpc_id(1)
