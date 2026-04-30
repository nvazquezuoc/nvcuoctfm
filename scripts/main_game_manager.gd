extends Node3D

class_name GameplayManager

@export
var player_chr:NavigableCharacter
@export
var ui_node:Control
@export
var level_scenes:Array[PackedScene] = []
var active_level:Node3D
var idx_to_load:int = 0
static var instance:GameplayManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_chr.disable()
	instance = self
	pass # Replace with function body.

func load_next()->void:
	if(idx_to_load < len(level_scenes)):
		if(is_instance_valid(active_level)):
			active_level.queue_free()
		active_level = level_scenes[idx_to_load].instantiate()
		add_child(active_level)
		idx_to_load += 1
		player_chr.position = active_level.player_spawn
		InputManager._instance.set_target(player_chr)
		pass
	else:
		InputManager._instance.set_target(null)
		if(is_instance_valid(active_level)):
			active_level.queue_free()
		player_chr.disable()
		MainGameNode.goto_main_menu()
		pass
	pass
	
func start_game()->void:
	idx_to_load = 0
	GlobalVariables.begin_vars()
	ui_node.update_keys()
	load_next()
	player_chr.enable()
	pass
	
func add_keys(val:int)->void:
	GlobalVariables.play_dic[&"keys"] += val
	ui_node.update_keys()
	pass
