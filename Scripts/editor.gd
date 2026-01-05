extends Node

@onready var map:Map = $SubViewportContainer/Map

func _on_button_pressed() -> void:
	DisplayServer.clipboard_set($TextEdit.text.replace("\n","|"))
	map.clear_board()
	map.generate_board($TextEdit.text.replace("\n","|"))
