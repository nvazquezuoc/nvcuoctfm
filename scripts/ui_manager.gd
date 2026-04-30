extends CanvasLayer

class_name UI_Manager

static var instance:UI_Manager
@export var first_menu:Control
var ui_dict:Dictionary[StringName, Control] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	instance = self
	ui_dict = {
		&"main": $main_menu,
		&"score": $score_board,
		&"game": $ingame_ui
	}
	pass # Replace with function body.

func make_visible(key:StringName, exclusive:bool=true)->void:
	if(exclusive):
		for node in ui_dict.values():
			node.visible = false
	ui_dict[key].visible = true
	pass
