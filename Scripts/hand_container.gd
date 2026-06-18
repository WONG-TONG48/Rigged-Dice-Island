extends PanelContainer
class_name HandMenu

@onready var card_container =$MarginContainer/HBoxContainer/MarginContainer/HBoxContainer
@onready var button_grid = $MarginContainer/HBoxContainer/GridContainer
@export var card_scene:PackedScene
static var reasources:Dictionary[ReasourceCard.Reasource,int] = {ReasourceCard.Reasource.SHEEP:0,ReasourceCard.Reasource.BRICK:0,ReasourceCard.Reasource.STONE:0,ReasourceCard.Reasource.WHEAT:0,ReasourceCard.Reasource.WOOD:0,}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_turn()

func draw_card_from_hex(tile:Hex.Tile):
	if tile<5:
		add_card(int(tile))
		return
	match tile:
		pass

func add_card(type:ReasourceCard.Reasource):
	var card = card_scene.instantiate()
	card.name = ReasourceCard.get_string(type)+str(reasources[type])
	reasources[type]+=1
	card.reasource=type
	card_container.add_child(card)

func start_turn():
	button_grid.get_node("RollButton").disabled = false
	

func end_turn():
	for i in button_grid.get_children():
		i.disabled = true
