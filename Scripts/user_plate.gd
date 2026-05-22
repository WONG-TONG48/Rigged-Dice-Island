extends PanelContainer

@onready
var username_lbl := $VBoxContainer/Username
@onready
var ready_lbl := $VBoxContainer/ReadyLabel
var user_ready := false

func set_username(username:String,color:Color):
	username_lbl.text = username
	username_lbl.label_settings.outline_color = color

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	username_lbl.label_settings = username_lbl.label_settings.duplicate()
	ready_lbl.label_settings = ready_lbl.label_settings.duplicate()
	ready_lbl.text = "Ready" if user_ready else "Not Ready"
	ready_lbl.label_settings.font_color = Color.GREEN if user_ready else Color.RED
