extends Node

class_name MainGameNode

static var instance:MainGameNode
@export
var phone_mode:bool = false
@export
var node_ui:Node
@export
var node_game:Node
@export
var simpleAudioPlayer:AudioStreamPlayer
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
	
static func goto_victory()->void:
	instance.node_ui.make_visible(&"victoryscreen")
	instance.node_ui.update_map_score()
	instance.node_game.visible = false
	save_score()
	pass
	
static func goto_defeat()->void:
	instance.node_ui.make_visible(&"defeatscreen")
	GameplayManager.instance.send_map_texture()
	instance.node_ui.update_map_score()
	save_score()
	pass
	
static func save_score()->void:
	instance.save_data.add_score(GlobalVariables.play_dic[&"totalpoints"], GlobalVariables.active_run_seed)
	ResourceSaver.save(instance.save_data, "./SaveData.tres")
	pass
	
static func play_sound(sound:AudioStream)->void:
	if(is_instance_valid(instance)):
		instance.simpleAudioPlayer.stream = sound
		instance.simpleAudioPlayer.play()
	pass
	
