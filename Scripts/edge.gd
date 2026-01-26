extends Node2D
class_name Edge

var corners:Array[Corner]
var port:Port=Port.NONE
var port_trade:Trade=null
enum Port{
	NONE,
	THREE_ONE_ANY,
	TWO_ONE_WHEAT,
	TWO_ONE_STONE,
	TWO_ONE_SHEEP,
	TWO_ONE_WOOD,
	TWO_ONE_BRICK,
}

func create(a:Corner,b:Corner) -> void:
	corners.append(a)
	corners.append(b)
	#print($Control.position,$Control.size)
	
	#print($Control.position,$Control.size)
	position=(a.position+b.position)/2
	name=a.name+" "+b.name+" edge"
	$Control.size.x=a.position.distance_to(b.position)-10
	$Control.pivot_offset=$Control.size/2
	$Control.position=$Control.size/-2
	#$Label.text=str(a.position.distance_to(b.position))
	for i in corners:
		i.edges.append(self)
	var angle = atan(abs(a.position.y-b.position.y)/abs(a.position.x-b.position.x))
	var mod = sign(a.position.y-b.position.y)/sign(a.position.x-b.position.x)
	if a.position.x-b.position.x:
		angle*=mod
	$Control.rotation=angle

func position_against_hex(hex:Hex):
	var pos = [hex.get_corner_pos(corners[0]),hex.get_corner_pos(corners[1])]
	#if 5 in pos or 4 in pos:
		#$Control.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	if 4 in pos:
		if abs($Control.rotation)<PI/2:
			$Control.rotation-=PI
	elif 1 in pos:
		if abs($Control.rotation)>PI/2:
			$Control.rotation-=PI
	else:
		if $Control.rotation*(-1 if 0 in pos else 1)>0:
			$Control.rotation-=PI
	if abs($Control.rotation)>PI:
		$Control.rotation-=sign($Control.rotation)*PI*2

func make_port(hex:Hex,type:Port=Port.THREE_ONE_ANY):
	port=type
	$Control/PortLabel.text="2:1"
	match port:
		Port.TWO_ONE_WHEAT:
			$Control/PortRect/PortImg.texture=load("res://Assets/wheat.webp")
		Port.TWO_ONE_STONE:
			$Control/PortRect/PortImg.texture=load("res://Assets/stone.png")
		Port.TWO_ONE_SHEEP:
			$Control/PortRect/PortImg.texture=load("res://Assets/sheep.png")
		Port.TWO_ONE_WOOD:
			$Control/PortRect/PortImg.texture=load("res://Assets/wood.png")
		Port.TWO_ONE_BRICK:
			$Control/PortRect/PortImg.texture=load("res://Assets/brick.png")
		_:
			$Control/PortLabel.text="3:1"
			$Control/PortRect/PortImg.texture=load("res://Assets/mystery.png")
	$Control/PortRect.show()
	$Control/PortLabel.show()
	position_against_hex(hex)
	

func _ready() -> void:
	$Control/PortRect.hide()
	$Control/PortLabel.hide()
