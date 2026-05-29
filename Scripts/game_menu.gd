extends PanelContainer

@export var user_plate:PackedScene
@onready var player_list := $MarginContainer/VBoxContainer/Players
@onready var chat_box := $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel
@onready var line_edit := $MarginContainer/VBoxContainer/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@rpc("call_local","any_peer")
func send_message(msg:String,chat=false):
	if chat:
		msg = Main.Player.player_db[multiplayer.get_remote_sender_id()].get_player_tag()+": "+msg
	chat_box.text += "\n"+msg

func add_plate(player_id):
	var plate = user_plate.instantiate()
	plate.name = str(player_id)
	player_list.add_child(plate)
	plate.set_multiplayer_authority(player_id)
	plate.set_username(player_id)
	plate.game_display()
	
func set_turn(player_id):
	for i in player_list.get_children():
		i.set_active(i.get_multiplayer_authority()==player_id)
		

func _on_line_edit_text_submitted(new_text: String) -> void:
	if !new_text.strip_edges().is_empty():
		send_message.rpc(new_text,true)
	line_edit.clear()
