extends Node

@onready var board:Board = $SubViewportContainer/Map

func _on_button_pressed() -> void:
	print(board.export_board())



func _on_port_button_pressed() -> void:
	board.brush=Board.EditorBrush.PORT


func _on_hex_button_pressed() -> void:
	board.brush=Board.EditorBrush.RESUORCE_HEX
