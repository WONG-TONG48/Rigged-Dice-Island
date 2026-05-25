extends Node

@onready
var lobby= $"Start Menu/Lobby"
@onready
var lobby_list = $"Start Menu/Lobby/Players/Menu"
@onready
var buttons = $"Start Menu/ButtonMenu"
@export var user_plate:PackedScene
signal host_game
signal join_game
signal leave_game
signal start_game
signal start_editor
signal change_user_data(property:String,data:Variant)

func show_loading():
	$Loading.show()

func hide_loading():
	$Loading.hide()

func get_player_data():
	var username = $"Start Menu/Settings/Player/Menu/Username/LineEdit".text
	var color = $"Start Menu/Settings/Player/Menu/Color/ColorPickerButton".color
	return [username,color]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	leave_lobby()
	$"Start Menu/Lobby/HBoxContainer/Leave button".pressed.connect(leave_game.emit)
	$"Start Menu/ButtonMenu/Host".pressed.connect(host_game.emit)
	$"Start Menu/ButtonMenu/Join".pressed.connect(join_game.emit)
	$"Start Menu/ButtonMenu/Editor".pressed.connect(start_editor.emit)

func get_ip():
	return $"Start Menu/Settings/General/Menu/IP/LineEdit".text

func join_lobby():
	if $Loading.visible:
		$"Start Menu/Lobby/HBoxContainer/Ready button".text = "Ready"
	else:
		$"Start Menu/Lobby/HBoxContainer/Ready button".text = "Start"
	lobby.show()
	buttons.hide()

func remove_player(id):
	lobby_list.get_node(str(id)).queue_free()

func add_player(player:Main.Player):
	var plate = user_plate.instantiate()
	plate.name = str(player.id)
	plate.user_ready = player.id ==1
	lobby_list.add_child(plate)
	plate.set_multiplayer_authority(player.id)
	plate.set_username(player.username,player.color)

func clear_players():
	for i in lobby_list.get_children():
		i.queue_free()

func leave_lobby():
	lobby.hide()
	clear_players()
	buttons.show()

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_color_picker_button_popup_closed() -> void:
	var color = $"Start Menu/Settings/Player/Menu/Color/ColorPickerButton".color
	if lobby.visible:
		change_user_data.emit("color",color)
		lobby_list.get_node(str(multiplayer.get_unique_id())).change_color.rpc(color)

func _on_line_edit_text_changed(new_text: String) -> void:
	if lobby.visible:
		change_user_data.emit("username",new_text)
		lobby_list.get_node(str(multiplayer.get_unique_id())).change_name.rpc(new_text)


func _on_ready_button_pressed() -> void:
	if multiplayer.is_server():
		for i in lobby_list.get_children():
			if !i.user_ready:
				return
		start_game.emit()
	else:
		lobby_list.get_node(str(multiplayer.get_unique_id())).toggle_ready.rpc()


func _on_exit_pressed() -> void:
	get_tree().quit()
