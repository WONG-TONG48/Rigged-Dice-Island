extends PanelContainer

@export var user_plate:PackedScene
@onready var player_list := $MarginContainer/Players

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
		
