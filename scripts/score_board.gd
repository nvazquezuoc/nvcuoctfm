extends VBoxContainer

var board:VBoxContainer
var board_items:Array[Control] = []
@export var basic_entry:Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board = $scroll/board
	$btn_back.pressed.connect(func()->void:
		UI_Manager.instance.make_visible(&"main")
		pass)
	visibility_changed.connect(func()->void:
		if(visible):
			var new_entry:Control
			var new_list:Array = MainGameNode.instance.save_data.score_list.duplicate(true)
			new_list.reverse()
			for item in new_list:
				new_entry = basic_entry.duplicate()
				new_entry.visible = true
				board_items.push_back(new_entry)
				board.add_child(new_entry)
				update_entry(new_entry, item[0], item[1])
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
	

func update_entry(node:Control=null, val1:String="", val2:String="")->void:
	node.get_node(^"lbl_name").text = val1
	node.get_node(^"lbl_points").text = val2
	pass
