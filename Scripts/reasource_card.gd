extends PanelContainer
class_name ReasourceCard

enum Reasource{
	WHEAT,
	STONE,
	SHEEP,
	WOOD,
	BRICK
}

var reasource:Reasource

static func get_color(type:Reasource) -> Color:
	match type:
		Reasource.WHEAT:
			return Color(0.89, 0.761, 0.0, 1.0)
		Reasource.STONE:
			return Color(0.509, 0.509, 0.509, 1.0)
		Reasource.SHEEP:
			return Color(0.638, 0.933, 0.0, 1.0)
		Reasource.WOOD:
			return Color(0.0, 0.48, 0.0, 1.0)
		Reasource.BRICK:
			return Color(0.763, 0.259, 0.0, 1.0)
		_:
			return Color.BLACK

static func get_image(type:Reasource):
	match type:
		Reasource.WHEAT:
			return load("res://Assets/wheat.webp")
		Reasource.STONE:
			return load("res://Assets/stone.png")
		Reasource.SHEEP:
			return load("res://Assets/sheep.png")
		Reasource.WOOD:
			return  load("res://Assets/wood.png")
		Reasource.BRICK:
			return load("res://Assets/brick.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_type(type:Reasource):
	reasource=type
	self_modulate = get_color(type)
	$TextureRect.texture = get_image(type)
	
