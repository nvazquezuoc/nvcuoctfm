extends Node3D

class_name GameplayManager

@export
var player_chr:NavigableCharacter
@export
var cam_A:Camera3D
@export
var cam_B:Camera3D
@export
var enemies:Array[EnemyBase] = []
@export
var ui_node:Control
@export
var level_scenes:Array[PackedScene] = []
@export
var scn_map:PackedScene
@export
var map_textures:Array[Texture]
@export
var map_mesh:Node3D
@export
var generators:Array[MapBuilder]
@export
var active_builder:MapBuilder
@export
var first_builder:MapBuilder
var active_level:MapNode
var idx_to_load:int = 0
@export
var max_levels:int = 20
var default_max_levels:int = 20
static var instance:GameplayManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.cam_A = cam_A
	GlobalVariables.cam_B = cam_B
	$fail_scene.disable()
	player_chr.disable(true)
	player_chr.take_cam_control(cam_A)
	for enemy in enemies:
		enemy.disable(true)
	instance = self
	pass # Replace with function body.

func load_next()->void:
	if(idx_to_load < max_levels):
		if(is_instance_valid(active_level)):
			active_level.queue_free()
		var prev_builder:MapBuilder = active_builder
		active_builder = active_builder.get_next_generator(idx_to_load, max_levels)
		if(prev_builder != active_builder):
			prev_builder.count = 0
		player_chr.position.y += 200
		player_chr.disable(true)
		for enemy in enemies:
			enemy.disable(true)
		#active_level = generators[0].get_next_map(max_levels-idx_to_load-1)
		active_level = active_builder.get_next_map(max_levels-idx_to_load-1)
		add_child(active_level)
		idx_to_load += 1
		player_chr.position = active_level.player_spawn
		player_chr.set_orientation(active_level.get_spawn_direction())
		player_chr.enable()
		var enemies2send:Array[NavigableCharacter] = []
		for enemy_idx in active_level.dict_map_data["p"]["e"].size():
			enemies[enemy_idx].position = active_level.tilecoord2worldposition(
				active_level.dict_map_data["p"]["e"][enemy_idx])
			enemies2send.push_back(enemies[enemy_idx])
		InputManager._instance.set_target(player_chr)
		put_text()
		active_level.spawn_node.start_level_event(player_chr, enemies2send)
		send_map_texture(active_level.texture_map)
		pass
	else:
		event_victory()
		return
		#
		MainGameNode.goto_main_menu()
		pass
	pass
	
func start_game()->void:
	idx_to_load = 0
	GlobalVariables.begin_vars()
	ui_node.update_keys()
	level_scenes.clear()
	player_chr.disable(true)
	GlobalVariables.randomize_rng()
	GlobalVariables.active_run_seed = GlobalVariables.rng.seed
	active_builder = first_builder
	load_next()
	player_chr.enable()
	pass
	
func add_keys(val:int)->void:
	GlobalVariables.play_dic[&"keys"] += val
	ui_node.update_keys()
	pass
	
func set_interaction_icon(icon:Texture=null)->void:
	ui_node.set_interaction_icon(icon)
	pass
	
func put_text(text:String="")->void:
	ui_node.put_text(text)
	pass
	
func send_map_texture(new_texture:Texture=null)->void:
	ui_node.send_map_texture(new_texture)
	pass

func get_map_node()->MapNode:
	return active_level

func event_victory()->void:
	InputManager._instance.set_target(null)
	if(is_instance_valid(active_level)):
		active_level.queue_free()
	player_chr.disable(true)
	for enemy in enemies:
		enemy.disable(true)
	send_map_texture()
	MainGameNode.goto_victory()
	pass
	
func event_defeat()->void:
	InputManager._instance.set_target(null)
	if(is_instance_valid(active_level)):
		active_level.queue_free()
	player_chr.disable(true)
	for enemy in enemies:
		enemy.disable(true)
	$fail_scene.enable()
	$fail_scene.grab_cam_A()
	MainGameNode.goto_defeat()
	pass
