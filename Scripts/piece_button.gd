extends Button

@export var cost:Dictionary[ReasourceCard.Reasource,int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.hide()
	var count=0;
	for r in cost:
		for i in range(cost[r]):
			var txr = TextureRect.new()
			txr.texture = ReasourceCard.get_image(r)
			txr.name = ReasourceCard.get_string(r)+str(i)
			txr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			txr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			txr.size_flags_vertical = Control.SIZE_EXPAND_FILL
			txr.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$Panel/GridContainer.add_child(txr)
	$Panel/GridContainer.columns = min(cost.values().reduce(func(accum, number): return accum + number, 0),3)
	
func _on_mouse_entered() -> void:
	var reasources = HandMenu.reasources.duplicate()
	for r in cost:
		for i in range(cost[r]):
			var txr = $Panel/GridContainer.get_node(ReasourceCard.get_string(r)+str(i))
			if reasources[r]>0:
				reasources[r]-=1
				txr.modulate = Color.WHITE
			else:
				txr.modulate = Color(0.234, 0.234, 0.234, 1.0)
	$Panel.show()

func _on_mouse_exited() -> void:
	$Panel.hide()
