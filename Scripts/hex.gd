extends Node2D
class_name Hex

enum Tile{
	WHEAT,
	STONE,
	SHEEP,
	WOOD,
	BRICK,
	DESERT,
	GOLD,
	TEMP
}


const radius:int=100
var corners:Array[Corner]
var side_length:float
var corner_radius:float
var tile:Tile
var temp=false
var time=0

func set_type(type:Tile):
	if type==Tile.TEMP:
		temp=true
		return
	temp=false
	modulate=Color(1.0, 1.0, 1.0, 1.0)
	tile=type
	match tile:
		Tile.WHEAT:
			set_color(Color(0.89, 0.761, 0.0, 1.0))
			$TextureRect.texture = load("res://Assets/wheat.webp")
		Tile.STONE:
			set_color(Color(0.509, 0.509, 0.509, 1.0))
			$TextureRect.texture = load("res://Assets/stone.png")
		Tile.SHEEP:
			set_color(Color(0.638, 0.933, 0.0, 1.0))
			$TextureRect.texture = load("res://Assets/sheep.png")
		Tile.WOOD:
			set_color(Color(0.0, 0.48, 0.0, 1.0))
			$TextureRect.texture = load("res://Assets/wood.png")
		Tile.BRICK:
			set_color(Color(0.763, 0.259, 0.0, 1.0))
			$TextureRect.texture = load("res://Assets/brick.png")
		Tile.DESERT:
			set_color(Color("490086ff"))
			$TextureRect.custom_minimum_size=Vector2(1,1)*radius*1.9
			$TextureRect.texture = load("res://Assets/desert.png")
	
func set_color(color,rand=0.2):
	var val = randf()
	$Polygon.color = color.lerp(Color(val,val,val),rand)

func _ready() -> void:
	time=randf()
	$TextureRect.custom_minimum_size = Vector2(radius,radius)
	update_verticies()

func create_corners(corner_scene:PackedScene,other_corners:Array[Corner]=[],other_hexes:Array[Hex]=[]):
	var verticies=$Polygon.polygon
	if !other_corners:
		var num=0
		for i in verticies:
			var corner = corner_scene.instantiate()
			corner.name= name+" corner"+str(num)
			corner.position=i+position
			corners.append(corner)
			num+=1
		return
	corners.resize(6)
	
	for i in other_corners:
		var hex:Hex = null
		for j in other_hexes:
			if i in j.corners:
				hex=j
				break
		var ind = 0
		var pos=hex.get_corner_pos(i)
		if int(position.y)==int(hex.position.y):
			if pos<3:
				ind=0 if pos==2 else 2
			else:
				ind=5 if pos==3 else 3
		elif hex.position.y<position.y:
			if pos==4:
				ind=2 if hex.position.x<position.x else 0
			else:
				ind=1
		corners[ind]=i
	for i in range(len(corners)):
		if corners[i]!=null:
			continue
		var corner = corner_scene.instantiate()
		corner.name= name+" corner"+str(i)
		corner.position=verticies[i]+position
		corners[i] = corner
	return

			
func create_edges(edge_scene:PackedScene):
	var edges=[]
	for i in range(len(corners)):
		var next=(i+1)%6
		if corners[i].is_adjacent(corners[next]):
			continue
		var edge =edge_scene.instantiate()
		edge.create(corners[i],corners[next])
		edges.append(edge)
	return edges
		
func get_edges() -> Array[Edge]:
	var edges:Array[Edge]=[]
	for i in range(len(corners)):
		var next=(i+1)%6
		edges.append(corners[i].get_edge(corners[next]))
	return edges
		
func get_corner_pos(corner):
	return corners.find(corner)

func update_verticies():
	var verticies:PackedVector2Array = []
	side_length=radius*tan(deg_to_rad(30))*2
	corner_radius=radius/cos(deg_to_rad(30))
	for i in range(-1,2,2):
		verticies.append(Vector2(-radius*i,side_length/2*i))
		verticies.append(Vector2(0,corner_radius*i))
		verticies.append(Vector2(radius*i,side_length/2*i))
	$Polygon.polygon=verticies

func _process(delta: float) -> void:
	if temp:
		time+=delta
		if time == 360:
			time=0
		modulate.a=(sin(deg_to_rad(time*100))+1)/8+0.3
