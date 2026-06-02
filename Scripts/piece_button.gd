extends Button

@export var cost:Dictionary[ReasourceCard.Reasource,int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.hide()


func _on_mouse_entered() -> void:
	$Panel.show()


func _on_mouse_exited() -> void:
	$Panel.hide()
