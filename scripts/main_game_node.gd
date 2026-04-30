extends Node

class_name MainGameNode

static var instance:MainGameNode
@export
var node_ui:Node
@export
var node_game:Node
var save_data:SaveData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	if(ResourceLoader.exists("res://SaveData.tres")):
		save_data = load("res://SaveData.tres")
	else:
		save_data = SaveData.new()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
static func goto_main_menu()->void:
	instance.node_ui.make_visible(&"main")
	instance.node_game.visible = false
	pass
	
static func goto_new_game()->void:
	instance.node_ui.make_visible(&"game")
	instance.node_game.visible = true
	instance.node_game.start_game()
	pass
	
