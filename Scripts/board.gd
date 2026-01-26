extends SubViewport
class_name Board

var hex_scene = preload("res://Scenes/hex.tscn")
var corner_scene = preload("res://Scenes/corner.tscn")
var edge_scene = preload("res://Scenes/edge.tscn")
var hex_grid:Array[Array]
var original_pos=null
var edit=false
enum EditorBrush{
	RESUORCE_HEX,
	PORT
}
var brush:EditorBrush=EditorBrush.RESUORCE_HEX

@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board(Map.new())
	#editor_board()
		
func export_board()->String:
	var map_str=""
	var total_end=9999
	var total_start=9999
	for i in hex_grid:
		var end=0
		var start=0
		for j:Hex in i:
			if j ==null or j.temp:
				map_str+="e"
				end+=1
				if start>-1:
					start+=1
				continue
			if start>-1:
				total_start=min(total_start,start)
				start=-1
			end=0
			map_str+="r"
			map_str+="["
			for l in j.get_edges():
				if l.port:
					map_str+="p"+str(j.get_corner_pos(l.corners[0]))+str(j.get_corner_pos(l.corners[1]))
			map_str+="]"
			map_str=map_str.trim_suffix("[]")
		total_end=min(total_end,end)
		map_str+="|"
	map_str=map_str.rstrip("|")
	var final_str=""
	var end=0
	for i in map_str.split("|"):
		if i.count("e")==len(i):
			if final_str=="":
				continue
			end+=1
		else:
			end=0
		var temp = i
		if total_start:
			temp=temp.right(-total_start)
		if total_end:
			temp=temp.left(-total_end)
		final_str+=temp
		final_str+="|"
	if end:
		final_str=final_str.trim_suffix(("e".repeat(len(hex_grid[0])-total_start-total_end)+"|").repeat(end))
	return final_str.rstrip("|")
	
		
func clear_board():
	for i in get_children():
		if i is Corner or i is Edge or i is Hex:
			i.queue_free()
		
func editor_board():
	edit= true
	generate_board(EditorMap.new())
		
func generate_board(map:Map):
	var map_size = map.get_size()
	hex_grid.resize(map_size.y)
	for row in range(map_size.y):
		for col in range(map_size.x):
			var hex_info:Map.HexInfo=map.get_hex_info(row,col)
			if hex_info==null:
				hex_grid[row].append(null)
				continue
			var hex:Hex = hex_scene.instantiate()
			hex.name="Hex"+str(row)+str(col)
			add_child(hex)
			hex.set_type(hex_info.type)
			if hex_info.dice_val:
				hex.set_dice_val(hex_info.dice_val)
			hex.position=Vector2(col*Hex.radius*2+Hex.radius*(row%2),row*(hex.corner_radius+hex.side_length/2))
			var hexes:Array[Hex]=[]
			var corners:Array[Corner]=[]
			if col!=0 and hex_grid[row][col-1]!=null:
				hexes.append(hex_grid[row][col-1])
				corners.append(hex_grid[row][col-1].corners[5])
				corners.append(hex_grid[row][col-1].corners[0])
			if row!=0:
				var hex1=hex_grid[row-1].get(col-(row+1)%2)
				var hex2=hex_grid[row-1].get(col+row%2)
				if hex1:
					hexes.append(hex1)
					if not hex1.corners[4] in corners:
						corners.append(hex1.corners[4])
					corners.append(hex1.corners[5])
				if hex2:
					hexes.append(hex2)
					corners.append(hex2.corners[4])
					if !hex1:
						corners.append(hex2.corners[3])
			hex.create_corners(corner_scene,corners,hexes)
			for k in hex.corners:
				if !k.get_parent():
					add_child(k)
					k.z_index=5
			for k:Edge in hex.create_edges(edge_scene):
				add_child(k)
				k.z_index=4
				for l:Array in hex_info.ports:
					if hex.get_corner_pos(k.corners[0]) in l.slice(0,2) and hex.get_corner_pos(k.corners[1]) in l.slice(0,2):
						k.make_port(hex,l[2])
			hex_grid[row].append(hex)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom=(camera.zoom * (1.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.9)).clamp(Vector2(0.2,0.2),Vector2(5,5))
		elif edit and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			match brush:
				EditorBrush.RESUORCE_HEX:
					var hex:Hex= get_hex_nearest_mouse()
					hex.set_type(randi_range(0,4))
				EditorBrush.PORT:
					var hex:Hex= get_hex_nearest_mouse()
					var edge = get_edge_nearest_mouse(hex)
					edge.make_port(hex)
	elif event is InputEventMouseMotion and original_pos:
		camera.position-= event.relative/camera.zoom

func get_hex_nearest_mouse() -> Hex:
	var p:Vector2 =(get_mouse_position()-get_visible_rect().size/2)/camera.zoom+camera.position
	var r1:int = (p.y+Hex.radius)/((hex_grid[0][0].corner_radius*2+hex_grid[0][0].side_length)/2)
	var r2:int = round((p.y+Hex.radius)/((hex_grid[0][0].corner_radius*2+hex_grid[0][0].side_length)/2))
	if r1==r2:
		r2-=1
	if abs(r1*((hex_grid[0][0].corner_radius*2+hex_grid[0][0].side_length)/2)-(p.y))<hex_grid[0][0].side_length/2:
		r2=r1
	var c1:int = (p.x+Hex.radius*((r1+1)%2))/(Hex.radius*2)
	var c2:int = (p.x+Hex.radius*((r2+1)%2))/(Hex.radius*2)
	var hex:Hex = hex_grid[min(max(r1,0),len(hex_grid)-1)][min(max(c1,0),len(hex_grid[0])-1)]
	if r1!=r2:
		var hex2=hex_grid[min(max(r2,0),len(hex_grid)-1)][min(max(c2,0),len(hex_grid[0])-1)]
		if p.distance_to(hex.position)>p.distance_to(hex2.position):
			hex=hex2
	return hex

func get_edge_nearest_mouse(hex:Hex) -> Edge:
	var best=null
	var dist=99999999
	var p:Vector2 =(get_mouse_position()-get_visible_rect().size/2)/camera.zoom+camera.position
	for i in hex.get_edges():
		var t = p.distance_to(i.position)
		if t<dist:
			dist=t
			best=i
	return best

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_camera"):
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		original_pos=get_viewport().get_mouse_position()
	elif Input.is_action_just_released("move_camera"):
		#Input.warp_mouse(original_pos)
		original_pos=null
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
