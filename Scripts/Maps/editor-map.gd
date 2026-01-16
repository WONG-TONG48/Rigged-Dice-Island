extends Map
class_name EditorMap

func _init() -> void:
	width=20
	height=20
	board.resize(20)
	for i in range(20):
		for j in range(20):
			board[i].append(HexInfo.new())
			board[i][j].type=Hex.Tile.TEMP
func get_map_string() -> String:
	var s = []
	s.resize(20)
	s.fill("t".repeat(20))
	return "|".join(s)
