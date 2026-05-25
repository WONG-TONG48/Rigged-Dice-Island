extends Node2D
class_name Corner

@onready var obj_tex := $ObjectTexture
var city_tex:Texture = preload("res://Assets/city.svg")
var settlement_tex:Texture = preload("res://Assets/house.svg")

enum Type{
	EMPTY,
	CITY,
	SETTLEMENT
}

var owner_id:int=0
var edges:Array[Edge]
var hexes:Array[Hex]
var object:Type = Type.EMPTY

func is_adjacent(corner) -> bool:
	for i in edges:
		if corner in i.corners:
			return true
	return false
	
func get_edge(corner):
	for i in edges:
		if corner in i.corners:
			return i
	return null
	
func set_type(type:Type=Type.EMPTY,player_id:int=0):
	object=type
	obj_tex.show()
	if player_id!=0:
		var player = Main.Player.player_db[player_id]
		obj_tex.modulate=player.color
		owner_id=player_id
	match type:
		Type.CITY:
			obj_tex.texture = city_tex
		Type.SETTLEMENT:
			obj_tex.texture = settlement_tex
		_:
			obj_tex.hide()
			owner_id=0

func is_empty():
	return owner_id==0

func _ready() -> void:
	obj_tex.hide()
	
