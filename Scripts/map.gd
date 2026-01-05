extends SubViewport
class_name Map

var hex_scene = preload("res://Scenes/hex.tscn")
var corner_scene = preload("res://Scenes/corner.tscn")
var edge_scene = preload("res://Scenes/edge.tscn")
var hex_grid:Array[Array]
var original_pos=null
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_board("errr|rrrr|rrrrr|rrrr|errr")
		
func test():
	var hex:Hex=hex_scene.instantiate()
	add_child(hex)
	hex.position = Vector2(300,300)
	hex.create_corners(corner_scene)
	
	
	for i:Corner in hex.corners:
		add_child(i)
		i.z_index=5
		i.get_node("Label").text = str(hex.get_corner_pos(i))
	for i in hex.create_edges(edge_scene):
		add_child(i)
		i.z_index=5
		
func clear_board():
	for i in get_children():
		if i is Corner or i is Edge or i is Hex:
			i.queue_free()
		
func generate_board(map_code:String):
	var map = map_code.split("|")
	var row=-1
	var col=-1
	hex_grid.resize(len(map))
	#for i in range(len(hex_grid)):
		#hex_grid[i] = []
	for i in map:
		row+=1
		col=-1
		for j in i:
			col+=1
			if j=='e':
				hex_grid[row].append(null)
				continue
			var hex:Hex = hex_scene.instantiate()
			hex.set_type(randi_range(0,4))
			hex.name="Hex"+str(row)+str(col)
			add_child(hex)
			hex.position=Vector2(200+col*Hex.radius*2+Hex.radius*(row%2),200+row*(hex.corner_radius+hex.side_length/2))
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
			for k in hex.corners+hex.create_edges(edge_scene):
				if !k.get_parent():
					add_child(k)
					k.z_index=5
			hex_grid[row].append(hex)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom=(camera.zoom * (1.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.9)).clamp(Vector2(0.3,0.3),Vector2(5,5))
	elif event is InputEventMouseMotion and original_pos:
		camera.position-= event.relative/camera.zoom

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_camera"):
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		original_pos=get_viewport().get_mouse_position()
	elif Input.is_action_just_released("move_camera"):
		#Input.warp_mouse(original_pos)
		original_pos=null
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
