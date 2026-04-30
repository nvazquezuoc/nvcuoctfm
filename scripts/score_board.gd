extends VBoxContainer

var board:VBoxContainer
var board_items:Array[Control] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = $scroll/board
	$btn_back.pressed.connect(func()->void:
		UI_Manager.instance.make_visible(&"main")
		pass)
	visibility_changed.connect(func()->void:
		if(visible):
			var lbl:Label = Label.new()
			lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
			for item in MainGameNode.instance.save_data.score_list:
				var lbl_1:Label = lbl.duplicate()
				var lbl_2:Label = lbl.duplicate()
				lbl_1.text = item[0]
				lbl_2.text = item[1]
				var entry:HBoxContainer = HBoxContainer.new()
				entry.add_child(lbl_1)
				entry.add_child(lbl_2)
				board.add_child(entry)
				board_items.push_back(entry)
				pass
			pass
		else:
			for item in board_items:
				item.queue_free()
			board_items.clear()
			pass
		pass)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
