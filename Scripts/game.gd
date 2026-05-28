extends Node

@onready var board:Board = $HSplitContainer/VSplitContainer/SubViewportContainer/Map
@onready var menu := $HSplitContainer/GameMenu
signal setup_done

@rpc("call_local")
func start() -> void:
	board.generate_board(Map.new())

@rpc("any_peer")
func setup_turn():
	board.prompt_settlement(setup_settlement,true)

func setup_settlement(corner:Corner):
	corner.set_type.rpc(Corner.Type.SETTLEMENT,multiplayer.get_unique_id())
	setup_done.emit()
	
@rpc("call_local")
func create_player_list(players):
	for id in players:
		menu.add_plate(id)
	
@rpc("call_local")
func set_turn(id):
	print(id)
	menu.set_turn(id)
