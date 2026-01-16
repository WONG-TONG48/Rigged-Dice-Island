extends Node2D
class_name Corner

enum Type{
	EMPTY,
	CITY,
	SETTLEMENT
}

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
