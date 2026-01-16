extends Object
class_name Map
	
var reasources:Dictionary[Hex.Tile,int]
var height = 0
var width = 0
var board:Array[Array]

class HexInfo:
	var ports = []
	var type:Hex.Tile

func decode_map_string(map_str:String):
	var rows = map_str.split("|")
	var info = rows[0]
	rows.remove_at(0)
	var y=0
	for row in rows:
		var i = -1
		var x=-1
		board.append([])
		while i+1<len(row):
			x+=1
			i+=1
			if row[i]=="e":
				board[y].append(null)
				continue
			board[y].append(HexInfo.new())
			board[y][x].type=Hex.Tile.WHEAT
			if i+1>=len(row) or row[i+1]!="[":
				continue
			while row[i+1]!="]":
				i+=1
				if row[i]=="p":
					board[y][x].ports.append([int(row[i+1]),int(row[i+2])])
					i+=2
			i+=1
		y+=1
	height=len(board)
	width=len(board[0])
func get_size()->Vector2:
	return Vector2(width,height)

func get_hex_info(row,col):
	return board[row][col]
	
func _init() -> void:
	decode_map_string("e|r[p23]e|rr[p21]|ee|re")
