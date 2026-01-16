extends Map
class_name DefaultMap

var map_string:String

func _init(map_string="errr|rrrr|rrrrr|rrrr|errr") -> void:
	reasources= {
		Hex.Tile.WHEAT:4,
		Hex.Tile.WOOD:4,
		Hex.Tile.SHEEP:4,
		Hex.Tile.BRICK:3,
		Hex.Tile.STONE:3,
		Hex.Tile.DESERT:1
	}
	self.map_string=map_string

func get_map_string() -> String:
	return map_string
