extends Node

@onready var board:Board = $HSplitContainer/VSplitContainer/SubViewportContainer/Map

func _ready() -> void:
	board.generate_board(Map.new())
