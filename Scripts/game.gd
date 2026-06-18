extends Node

@onready var board:Board = $HSplitContainer/VSplitContainer/SubViewportContainer/Map
@onready var menu := $HSplitContainer/GameMenu
@onready var hand:HandMenu = $HSplitContainer/VSplitContainer/HandContainer
var player:Main.Player
signal setup_done

@rpc("call_local")
func start() -> void:
	board.generate_board(Map.new())

@rpc("any_peer")
func setup_turn():
	board.prompt_settlement(setup_settlement,true)
	menu.set_alert.rpc("place a settlement")

func setup_settlement(corner:Corner):
	if board.count_corner_item(Corner.Type.SETTLEMENT,multiplayer.get_unique_id()) ==1:
		for i in corner.hexes:
			hand.draw_card_from_hex(i.tile)
	corner.set_type.rpc(Corner.Type.SETTLEMENT,multiplayer.get_unique_id())
	menu.send_message.rpc(player.get_player_tag()+" placed a [color=black][u]settlement[/u][/color]!")
	board.prompt_road(setup_road,corner)
	menu.set_alert.rpc("place a road")

func setup_road(edge:Edge):
	edge.make_road.rpc(multiplayer.get_unique_id())
	menu.send_message.rpc(player.get_player_tag()+" placed a [color=darkgray][u]road[/u][/color]!")
	setup_done.emit()
	
@rpc("any_peer")
func start_turn():
	hand.start_turn(process_roll.rpc)
	menu.set_alert.rpc("roll the dice")
	
@rpc("call_local")
func create_player_list(players):
	for id in players:
		menu.add_plate(id)
	
@rpc("call_local")
func set_turn(id):
	menu.set_rolling.rpc(true)
	menu.set_turn(id)

@rpc("call_local")
func process_roll(roll:int):
	menu.set_roll.rpc(roll)
	for i in board.get_hexes_by_roll(roll):
		hand.draw_card_from_hex(i.tile)
