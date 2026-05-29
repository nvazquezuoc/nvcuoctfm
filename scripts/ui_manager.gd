extends CanvasLayer

class_name UI_Manager

@export var first_menu:Control
@export var game_ui:Control
var ui_dict:Dictionary[StringName, Control] = {}
var ui_updict:Dictionary[StringName, Control] = {}
static var instance:UI_Manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	set_process(false)
	ui_dict = {
		&"main": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/main_menu,#$AspectRatioContainer/main_menu,
		&"score": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/score_board,
		&"game": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/ingame_ui,
		&"victoryscreen": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/end_screen,
		&"defeatscreen": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/end_screen,
		&"intro": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer2/SubViewport/CanvasLayer/introduction
	}
	ui_updict = {
		&"title": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer/SubViewport/CanvasLayer/maintitle,
		&"victory": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer/SubViewport/CanvasLayer/victory,
		&"intro": $AspectRatioContainer/CenterContainer/VBoxContainer2/SubViewportContainer/SubViewport/CanvasLayer/start
	}
	#make_visible(&"main")
	await $"..".ready
	if(MainGameNode.instance.save_data.score_list.size() < 1):
		make_visible(&"intro")
	else:
		make_visible(&"main")
	pass # Replace with function body.

func make_visible(key:StringName, exclusive:bool=true)->void:
	if(exclusive):
		for node in ui_dict.values():
			node.visible = false
	ui_dict[key].visible = true
	if(key == &"main"):
		make_upvisible(&"title")
	elif(key == &"victoryscreen"):
		make_upvisible(&"victory")
	elif(key == &"intro"):
		make_upvisible(&"intro")
	else:
		make_upvisible()
	pass

func make_upvisible(key:StringName=&"", exclusive:bool=true)->void:
	if(exclusive):
		for node in ui_updict.values():
			node.visible = false
	if(key in ui_updict):
		ui_updict[key].visible = true
	if(key == &"victory"):
		ui_updict[key].action()
		pass
	pass
	
func update_map_score()->void:
	ui_dict[&"victoryscreen"].show_data()
	pass
