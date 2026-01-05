extends Node2D
class_name Corner

var edges:Array[Edge]
var hexes:Array[Hex]
var object:String = "empty"

func is_adjacent(corner) -> bool:
	for i in edges:
		if corner in i.corners:
			return true
	return false
