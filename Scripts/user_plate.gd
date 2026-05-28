extends PanelContainer

@onready
var username_lbl := $VBoxContainer/Username
@onready
var ready_lbl := $VBoxContainer/ReadyLabel
var user_ready := false

func set_username(player_id):
	username_lbl.text = Main.Player.player_db[player_id].username
	username_lbl.label_settings.outline_color = Main.Player.player_db[player_id].color

@rpc("call_local")
func change_color(color):
	username_lbl.label_settings.outline_color = color
	
@rpc("call_local")
func change_name(username):
	username_lbl.text = username

@rpc("call_local")
func toggle_ready():
	user_ready = !user_ready
	ready_lbl.text = "Ready" if user_ready else "Not Ready"
	ready_lbl.label_settings.font_color = Color.GREEN if user_ready else Color.RED

func menu_display():
	ready_lbl.show()

func set_active(active:bool):
	modulate = Color(1.0,1.0,1.0) if active else Color(0.667, 0.667, 0.667, 1.0)

func game_display():
	ready_lbl.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	username_lbl.label_settings = username_lbl.label_settings.duplicate()
	ready_lbl.label_settings = ready_lbl.label_settings.duplicate()
	ready_lbl.text = "Ready" if user_ready else "Not Ready"
	ready_lbl.label_settings.font_color = Color.GREEN if user_ready else Color.RED
