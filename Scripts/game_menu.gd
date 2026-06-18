extends PanelContainer

@export var user_plate:PackedScene
@onready var player_list := $MarginContainer/VBoxContainer/Players
@onready var chat_box := $MarginContainer/VBoxContainer/ScrollContainer/RichTextLabel
@onready var line_edit := $MarginContainer/VBoxContainer/LineEdit
var dice_textures:Array[Texture]
var rolling = true
var last_time
var roll_val = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_time=Time.get_unix_time_from_system()
	
	for i in range(1,7):
		dice_textures.append(load("res://Assets/Dice/%d.png"%i))

@rpc("call_local")
func set_rolling(val:bool):
	rolling=val
	
@rpc("call_local")
func set_roll(roll):
	rolling=false
	var roll1
	if roll<8:
		roll1 = randi()%(roll-1)+1
	else:
		roll1 = randi_range(roll-6,6)
	var roll2 = roll-roll1
	$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = dice_textures[roll1]
	$MarginContainer/VBoxContainer/HBoxContainer/TextureRect2.texture = dice_textures[roll2]


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

@rpc("call_local")
func set_alert(action:String):
	if multiplayer.get_unique_id() == multiplayer.get_remote_sender_id():
		$MarginContainer/VBoxContainer/Label.text = action.capitalize()
	else:
		$MarginContainer/VBoxContainer/Label.text = "Waiting for %s to %s" % [Main.Player.player_db[multiplayer.get_remote_sender_id()].get_player_tag(), action.to_lower()]

func _on_line_edit_text_submitted(new_text: String) -> void:
	if !new_text.strip_edges().is_empty():
		send_message.rpc(new_text,true)
	line_edit.clear()

func _process(delta: float) -> void:
	if rolling && Time.get_unix_time_from_system()-last_time>0.15:
		roll_val+=randi()%2+1
		last_time=Time.get_unix_time_from_system()
		$MarginContainer/VBoxContainer/HBoxContainer/TextureRect.texture = dice_textures[roll_val%6]
		$MarginContainer/VBoxContainer/HBoxContainer/TextureRect2.texture = dice_textures[(roll_val+randi()%6)%6]
