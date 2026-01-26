extends Object
class_name Map
	

var height = 0
var width = 0
var board:Array[Array]

class HexInfo:
	var ports = []
	var type:Hex.Tile
	var dice_val=0
	
func get_num(str:String) -> int:
	var final = ""
	var i=0
	while i<len(str) and str[i].is_valid_int():
		final+=str[i]
		i+=1
	return int(final)
	
func pick_random_dict(dict:Dictionary,banned_keys=[]):
	var keys = dict.keys().filter(func(k): return dict[k] and not k in banned_keys)
	var options = []
	for i in keys:
		for j in range(dict[i]):
			options.append(i)
	if len(options)==0:
		return -1
	return options.pick_random()

func decode_map_string(map_str:String):
	var reasources:Dictionary[String,Dictionary]
	var dice_vals:Dictionary[String,Dictionary]
	var ports:Dictionary[String,Dictionary]
	var rows = map_str.split("|")
	var info = rows[0]
	var i= -1
	while i+1<len(info):
		i+=1
		var char = info[i]
		reasources[char]={}
		while i+1<len(info) and info[i+1]=="_":
			i+=2
			var num1 = get_num(info.right(-i))
			i+=len(str(num1))+1
			var num2 = get_num(info.right(-i))
			i+=len(str(num2))-1
			reasources[char][num1]=num2
	rows.remove_at(0)
	info = rows[0]
	i= -1
	while i+1<len(info):
		i+=1
		var char = info[i]
		dice_vals[char]={}
		while i+1<len(info) and info[i+1]=="_":
			i+=2
			var num1 = get_num(info.right(-i))
			i+=len(str(num1))+1
			var num2 = get_num(info.right(-i))
			i+=len(str(num2))-1
			dice_vals[char][num1]=num2
	rows.remove_at(0)
	info = rows[0]
	i= -1
	while i+1<len(info):
		i+=1
		var char = info[i]
		ports[char]={}
		while i+1<len(info) and info[i+1]=="_":
			i+=2
			var num1 = get_num(info.right(-i))
			i+=len(str(num1))+1
			var num2 = get_num(info.right(-i))
			i+=len(str(num2))-1
			ports[char][num1]=num2
	rows.remove_at(0)
	var y=0
	board=[]
	for row in rows:
		i = -1
		var x=-1
		board.append([])
		while i+1<len(row):
			x+=1
			i+=1
			var cur = row[i]
			if cur=="e":
				board[y].append(null)
				continue
			board[y].append(HexInfo.new())
			var type = pick_random_dict(reasources[cur])
			reasources[cur][type]-=1
			board[y][x].type=type
			if type!=5:
				var other_hexes = []
				if board[y].get(x-1):
					other_hexes.append(board[y][x-1])
				if y>0 and board[y-1].get(x):
					other_hexes.append(board[y-1][x])
				if y>0 and board[y-1].get(x+ (1 if y%2 else -1)):
					other_hexes.append(board[y-1][x+ (1 if y%2 else -1)])
				var red_banned= false
				for l in other_hexes:
					if abs(l.dice_val-7)==1:
						red_banned=true
						break
				var dice_val = pick_random_dict(dice_vals[cur],[8,6] if red_banned else [])
				if dice_val==-1:
					decode_map_string(map_str)
					return
				dice_vals[cur][dice_val]-=1
				board[y][x].dice_val=dice_val
			if i+1>=len(row) or row[i+1]!="[":
				continue
			while row[i+1]!="]":
				i+=1
				if row[i]=="p":
					var p_type=pick_random_dict(ports[cur])
					ports[cur][p_type] -= 1
					board[y][x].ports.append([int(row[i+1]),int(row[i+2]),p_type])
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
	decode_map_string("r_0-4_1-3_2-4_3-4_4-3_5-1|r_2-1_3-2_4-2_5-2_6-2_8-2_9-2_10-2_11-2_12-1|r_1-4_2-1_3-1_4-1_5-1_6-1|er[p12]r[p01]re|r[p32]rrr[p10]e|rrrrr[p50]|r[p32]rrr[p45]e|er[p34]r[p45]re")
