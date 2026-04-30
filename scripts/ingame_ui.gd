extends VBoxContainer

@export
var lbl_keys:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(func()->void:
		$SpinBox.value = 0
		pass)
	$btn_end.pressed.connect(func()->void:
		MainGameNode.instance.save_data.add_score($SpinBox.value)
		$"../../Game".load_next()
		UI_Manager.instance.make_visible(&"main")
		pass)
	pass # Replace with function body.
	
func update_keys()->void:
	lbl_keys.text = str(GlobalVariables.play_dic[&"keys"]) + " x"
	pass
