extends Node2D
class_name Edge

var corners:Array[Corner]

func create(a:Corner,b:Corner) -> void:
	corners.append(a)
	corners.append(b)
	position=(a.position+b.position)/2
	name=a.name+" "+b.name+" edge"
	#$Label.text=str(a.position.distance_to(b.position))
	for i in corners:
		i.edges.append(self)
