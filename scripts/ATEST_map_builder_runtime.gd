extends Node

class_name MapBuilder

@export
var map_textures:Array[Texture]
@export var dict_locknkey:Dictionary[StringName, Array]
@export var auxiliar_interactions:Array[PackedScene] = []
@export var map_meshes:Node3D
@export var newmap_pck:PackedScene
@export var min_obstacles:int = 0
@export var max_obstacles:int = 0
@export var min_enemies:int = 0
@export var max_enemies:int = 0
@export var next_A:Node
@export var condition_A:int = 0
@export var next_B:Node
@export var condition_B:int = 0
var count:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_next_map(floor_number:int=-1)->MapNode:
	var newmap:MapNode = newmap_pck.instantiate()
	newmap.floor_number = floor_number
	newmap.texture_map = map_textures[GlobalVariables.randi_l(0, map_textures.size()-1)]
	var rotations:int = GlobalVariables.randi_l(0, 3)
	if(rotations == 1):
		var new_image:Image = newmap.texture_map.get_image()
		new_image.rotate_90(ClockDirection.CLOCKWISE)
		newmap.texture_map = ImageTexture.create_from_image(new_image)
		pass
	elif(rotations == 2):
		var new_image:Image = newmap.texture_map.get_image()
		new_image.rotate_180()
		newmap.texture_map = ImageTexture.create_from_image(new_image)
		pass
	elif(rotations == 3):
		var new_image:Image = newmap.texture_map.get_image()
		new_image.rotate_180()
		new_image.rotate_90(ClockDirection.CLOCKWISE)
		newmap.texture_map = ImageTexture.create_from_image(new_image)
		pass
	newmap._meshes_map = map_meshes
	newmap.regenerate()
	change_map_palete(newmap)
	setup_data_points_of_interest(newmap)
	generate_event_entities(newmap)
	return newmap

func setup_data_points_of_interest(target:MapNode)->void:
	var idx:int
	var valids:Dictionary = target.dict_map_data["v"]
	var points:Dictionary = target.dict_map_data["p"]
	# Create spawn
	idx = GlobalVariables.randi_l(0, valids.size()-1)
	points["s"] = valids.keys()[idx]
	target.player_spawn = target.tilecoord2worldposition(valids.keys()[idx])
	valids.erase(valids.keys()[idx])
	# Create exit
	idx = GlobalVariables.randi_l(0, valids.size()-1)
	points["g"] = valids.keys()[idx]
	valids.erase(valids.keys()[idx])
	pass
	
func generate_event_entities(target:MapNode)->void:
	#var tilemode:int = 0
	var dict_map_data = target.dict_map_data
	var interaction_pckscn = target.interaction_pckscn
	var _node_events:Node3D = target._node_events
	var dict_g = dict_map_data["g"]
	var dict_valid = dict_map_data["v"]
	var dict_points = dict_map_data["p"]
	var dict_inter = dict_map_data["i"]
	var dictavailable:Dictionary = dict_valid.duplicate()
	var con4:Array[bool]
	var event_node:Node3D = interaction_pckscn.instantiate()
	
	var test_cross = load("res://scenes/events/ev_cross.tscn")
	var test_cross_node:Node3D
	for key in dict_inter:
		con4.assign(dict_inter[key])
		event_node = interaction_pckscn.instantiate()
		event_node.position = target.tilecoord2worldposition(key)
		test_cross_node = test_cross.instantiate()
		test_cross_node.set_connections(con4)
		event_node.set_active_event(test_cross_node)
		_node_events.add_child(event_node)
		
	dictavailable.erase(dict_points["s"])
	
	var prev_lock:interactable_base = target.add_event_at(target.dict_event_scenes[&"elevator"], dict_points["g"],
	dict_g, dict_points, dictavailable)
	prev_lock.set_floor_number(target.floor_number)
	
	event_node = target.dict_event_scenes[&"elevator"].instantiate()
	target.spawn_node = event_node
	event_node.position = target.tilecoord2worldposition(dict_points["s"])
	event_node.set_floor_number(target.floor_number)
	var tilemode:int = dict_g[dict_points["s"]][1]
	if(tilemode == 3 or tilemode == 5):
		event_node.rotation_degrees.y = -90
	_node_events.add_child(event_node)
	
	var lock_ammount:int = GlobalVariables.randi_l(min_obstacles, max_obstacles)
	var next_pair:Array = dict_locknkey[&"number"]
	var next_lock:Node3D
	var next_key:interactable_base
	var is_strongbox:bool = true
	
	for idx in range(lock_ammount):
		# get pair of lock n key
		if((idx+1) == lock_ammount):
			next_pair = dict_locknkey[&"lock"]
			is_strongbox = false
			pass
		next_lock = next_pair[0].instantiate()
		next_key = next_pair[1].instantiate()
		
		next_lock.prepare()
		# add lock to previous object
		prev_lock.add_secondary_interaction(next_lock)
		# add table
		if(is_strongbox):
			#print("adding strongbox")
			prev_lock = target.add_event_at(auxiliar_interactions[1], target.get_random_valid(dictavailable),
			dict_g, dict_points, dictavailable)
		else:
			#print("adding table")
			prev_lock = target.add_event_at(auxiliar_interactions[0], target.get_random_valid(dictavailable),
			dict_g, dict_points, dictavailable)
		# add key
		next_key.prepare()
		prev_lock.add_secondary_interaction(next_key)
		pass
	#prev_lock = add_event_at(next_key, get_random_valid(dictavailable),
	#dict_g, dict_points, dictavailable)
	var num_enemies:int = GlobalVariables.randi_l(min_enemies, max_enemies)
	for idx in range(num_enemies):
		dict_points["e"].append(target.get_random_valid(dictavailable))
		
func get_next_generator(steps:int=0, max:int=0)->Node:
	if(condition_B < 0):
		if(condition_B == steps-max):
			count = 0
			return next_B
	if(0 < condition_A):
		if(condition_A == count):
			count = 0
			return next_A
	count += 1
	return self
	
func change_map_palete(target:MapNode)->void:
	var new_image:Image = target.texture_map.get_image()
	for x in range(new_image.get_width()):
		for y in range(new_image.get_height()):
			var new_color:Color = Color8(0,0,0)
			if(new_image.get_pixel(x, y) != Color.WHITE):
				new_color = Color8(127,127,127)
			new_image.set_pixel(x, y, new_color)
			pass
	target.texture_map = ImageTexture.create_from_image(new_image)
	pass
