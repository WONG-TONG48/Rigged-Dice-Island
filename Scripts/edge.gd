extends Node2D
class_name Edge

var corners:Array[Corner]
var port:Port=Port.NONE
var port_trade:Trade=null
enum Port{
	NONE,
	TEST
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

func make_port(hex:Hex):
	$Control/PortRect.show()
	$Control/PortLabel.show()
	position_against_hex(hex)
	port=Port.TEST

func _ready() -> void:
	$Control/PortRect.hide()
	$Control/PortLabel.hide()
	$Control/TestLabel.hide()
