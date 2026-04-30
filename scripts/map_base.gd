@tool
extends Node3D

enum CARDINALS {
	NONE=-1,
	N,E,S,W,
	MAX,
}

@export var texture_map:Texture
@export var tile_size:float = 2
@export var intersection_pckscn:PackedScene = preload("res://scenes/perspective_changer.tscn")
@export var interaction_pckscn:PackedScene = preload("res://scenes/interactable_element.tscn")
var _texture_map_img:Image
var _default_material = preload("res://resources/materials/test_room.tres")
var _meshes_map:Node3D
@export var player_spawn:Vector3 = Vector3(-1, -1, -1)
@onready var _navigation_region:NavigationRegion3D = $NavigationRegion3D

func _ready()->void:
	_texture_map_img = texture_map.get_image()
	if not Engine.is_editor_hint():
		setup_navmesh()
		setup_event_entities()
		if(false):
			$StaticBody3D.input_event.connect(func(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
				if event is InputEventMouseButton and event.pressed:
					$"../CharacterBody3D".set_movement_target(event_position))
	pass

func regenerate() -> void:
	_texture_map_img = texture_map.get_image()
	
	for child in $Events.get_children():
		child.queue_free()
	setup_visualmesh()
	setup_collisions()
	pass
	
func get_conections4(x:int, y:int)->Array[bool]:
	var result:Array[bool] = [false,false,false,false]
	#N,E,S,W
	
	if(0 < y):
		result[0] = _texture_map_img.get_pixel(x, y-1) != Color.WHITE
	if(x+1 < _texture_map_img.get_width()):
		result[1] = _texture_map_img.get_pixel(x+1, y) != Color.WHITE
	if(y+1 < _texture_map_img.get_height()):
		result[2] = _texture_map_img.get_pixel(x, y+1) != Color.WHITE
	if(0 < x):
		result[3] = _texture_map_img.get_pixel(x-1, y) != Color.WHITE
	
	return result
	
func get_diagonals(x:int, y:int)->Array[bool]:
	var result:Array[bool] = [false,false,false,false]
	#N,E,S,W
	
	if(0 < y):
		if(0 < x):
			result[0] = _texture_map_img.get_pixel(x-1, y-1) != Color.WHITE
		if(x+1 < _texture_map_img.get_width()):
			result[1] = _texture_map_img.get_pixel(x+1, y-1) != Color.WHITE
	if(y+1 < _texture_map_img.get_height()):
		if(0 < x):
			result[2] = _texture_map_img.get_pixel(x-1, y+1) != Color.WHITE
		if(x+1 < _texture_map_img.get_width()):
			result[3] = _texture_map_img.get_pixel(x+1, y+1) != Color.WHITE
	
	return result

func setup_visualmesh()->void:
	var con4:Array[bool]
	var offset:float = tile_size
	var new_idx_offset:int = 0
	var diagonals:int = 0
	var connections:int = 0
	var pos_offset:Vector3
	var ground:Array = _meshes_map.get_node(^"Ground").mesh.surface_get_arrays(0)
	
	var wall:Array = _meshes_map.get_node(^"Wall").mesh.surface_get_arrays(0)
	var wall_oriented:Array = [wall]
	var temp_trans:Transform3D = Transform3D().rotated(basis.y, PI/2)
	var temp_array_mesh:Array = wall.duplicate(true)
	for idx in range(temp_array_mesh[Mesh.ARRAY_VERTEX].size()):
		temp_array_mesh[Mesh.ARRAY_VERTEX][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_VERTEX][idx]
	for idx in range(temp_array_mesh[Mesh.ARRAY_NORMAL].size()):
		temp_array_mesh[Mesh.ARRAY_NORMAL][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_NORMAL][idx]
	wall_oriented.push_back(Array(temp_array_mesh))
	temp_array_mesh = temp_array_mesh.duplicate(true)
	for idx in range(temp_array_mesh[Mesh.ARRAY_VERTEX].size()):
		temp_array_mesh[Mesh.ARRAY_VERTEX][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_VERTEX][idx]
	for idx in range(temp_array_mesh[Mesh.ARRAY_NORMAL].size()):
		temp_array_mesh[Mesh.ARRAY_NORMAL][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_NORMAL][idx]
	wall_oriented.push_back(Array(temp_array_mesh))
	temp_array_mesh = temp_array_mesh.duplicate(true)
	for idx in range(temp_array_mesh[Mesh.ARRAY_VERTEX].size()):
		temp_array_mesh[Mesh.ARRAY_VERTEX][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_VERTEX][idx]
	for idx in range(temp_array_mesh[Mesh.ARRAY_NORMAL].size()):
		temp_array_mesh[Mesh.ARRAY_NORMAL][idx] = temp_trans * temp_array_mesh[Mesh.ARRAY_NORMAL][idx]
	wall_oriented.push_back(Array(temp_array_mesh))	
	
	var ceiling:Array = _meshes_map.get_node(^"Ceiling").mesh.surface_get_arrays(0)
	var main_mesh:MeshInstance3D = $MeshInstance3D
	var new_array:Array = []
	new_array.resize(Mesh.ARRAY_MAX)
	var array_vtx:PackedVector3Array = []
	var array_nrm:PackedVector3Array = []
	var array_uv:PackedVector2Array = []
	var array_idx:PackedInt32Array = []
	new_array[Mesh.ARRAY_VERTEX] = array_vtx
	new_array[Mesh.ARRAY_NORMAL] = array_nrm
	new_array[Mesh.ARRAY_TEX_UV] = array_uv
	new_array[Mesh.ARRAY_INDEX] = array_idx
	var __data:Array
	for y in range(_texture_map_img.get_height()):
		for x in range(_texture_map_img.get_width()):
			if(_texture_map_img.get_pixel(x, y) != Color.WHITE):
				if(_texture_map_img.get_pixel(x, y) == Color8(0, 0, 1)):
					player_spawn = position + Vector3(x*tile_size,0,y*tile_size)
				
				con4 = get_conections4(x, y)
				pos_offset = Vector3(x*offset,0,y*offset)
				connections = 0
				diagonals = 0
				
				var d = get_diagonals(x, y)
				for b in d:
					if(b):
						diagonals+=1
				for b in con4:
					if(b):
						connections += 1
				if(1 < connections):
					if(2 == connections and !(con4[0] and con4[2]) and !(con4[1] and con4[3])):
						print("Corner without diagonalsB!")
						print("intersection at ",x,", ", y, " with conections ", con4,)
						var intersection_node:Node3D = intersection_pckscn.instantiate()
						intersection_node.position = Vector3(x*offset,0,y*offset)
						intersection_node.set_connections(con4)
						_add_owned_child(intersection_node, ^"Events")
					elif(3 == connections):
						print("3 Connections!")
						print(x,", ", y, " with conections ", con4,)
						var intersection_node:Node3D = intersection_pckscn.instantiate()
						intersection_node.position = Vector3(x*offset,0,y*offset)
						intersection_node.set_connections(con4)
						_add_owned_child(intersection_node, ^"Events")
						pass
					else:
						if(!(con4[0] and con4[2]) and !(con4[1] and con4[3])):
							print("Corner without diagonalsA!")
							print("intersection at ",x,", ", y, " with conections ", con4,)
							if(false):
								var intersection_node:Node3D = intersection_pckscn.instantiate()
								intersection_node.position = Vector3(x*offset,0,y*offset)
								intersection_node.set_connections(con4)
								_add_owned_child(intersection_node, ^"Events")
				
				# vtx, nrm, uv, idx
				__data = [new_idx_offset, pos_offset, new_array]
				_mesh_add_arraymesh(__data, ground)
				new_idx_offset = __data[0]
				__data = [new_idx_offset, pos_offset, new_array]
				_mesh_add_arraymesh(__data, ceiling)
				new_idx_offset = __data[0]
				if(not con4[0]):
					__data = [new_idx_offset, pos_offset, new_array]
					_mesh_add_arraymesh(__data, wall_oriented[2])
					new_idx_offset = __data[0]
				if(not con4[1]):
					__data = [new_idx_offset, pos_offset, new_array]
					_mesh_add_arraymesh(__data, wall_oriented[1])
					new_idx_offset = __data[0]
				if(not con4[2]):
					__data = [new_idx_offset, pos_offset, new_array]
					_mesh_add_arraymesh(__data, wall_oriented[0])
					new_idx_offset = __data[0]
				if(not con4[3]):
					__data = [new_idx_offset, pos_offset, new_array]
					_mesh_add_arraymesh(__data, wall_oriented[3])
					new_idx_offset = __data[0]
	var new_array_mesh:ArrayMesh = ArrayMesh.new()
	new_array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_array)
	main_mesh.mesh = new_array_mesh

func setup_collisions()->void:
	var shape:ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	var faces:PackedVector3Array
	var n_faces:PackedVector3Array
	var n_shape:CollisionShape3D = $StaticBody3D/CollisionShape3D
	var n_mesh:Node3D
	shape.set_faces($MeshInstance3D.mesh.get_faces())
	n_shape.shape = shape
	pass
	
func setup_navmesh()->void:
	var navigation_mesh: NavigationMesh = NavigationMesh.new()
	_texture_map_img = texture_map.get_image()
	#var region_rid: RID = NavigationServer3D.region_create()

	# Enable the region and set it to the default navigation map.
	#NavigationServer3D.region_set_enabled(region_rid, true)
	#NavigationServer3D.region_set_map(region_rid, get_world_3d().get_navigation_map())
	var tile_connections:int = -1
	var connections:Array[bool] = []
	var _next_coord:Vector2i = Vector2i(-1, -1)
	var _walkable_coord:bool = true
	var _walk_end:Vector2i = Vector2i(-1, -1)
	var _walk_lists:Array[Array] = []
	var _terrain_dict:Dictionary[Vector2i, Vector2i] = {}
	var coord:Vector2i = Vector2i(-1, -1)
	var h_off:float = 0
	for y in range(_texture_map_img.get_height()):
		for x in range(_texture_map_img.get_width()):
			if(_texture_map_img.get_pixel(x, y) != Color.WHITE):
				coord = Vector2i(x, y)
				if(not coord in _terrain_dict):
					tile_connections = 0
					connections = get_conections4(x, y)
					_walk_end = coord
					for val in connections:
						if(val):
							tile_connections += 1
					if(0 < tile_connections):
						if(tile_connections < 2):
							# is end
							# goes from top left to bot right
							# only right and bot make sense to check
							_next_coord = coord
							_walkable_coord = true
							var step = Vector2i(0, 1)
							if(connections[CARDINALS.E]):
								step = Vector2i(1, 0)
								pass
							elif(connections[CARDINALS.S]):
								pass
							else:
								print("ERROR! IS END", coord)
							while(_walkable_coord and tile_connections < 3):
								_walk_end = _next_coord
								_terrain_dict[_next_coord] = coord
								_next_coord += step
								if(_next_coord.x < _texture_map_img.get_width() and
								_next_coord.y < _texture_map_img.get_height()):
									_walkable_coord = _texture_map_img.get_pixel(_next_coord.x, _next_coord.y) != Color.WHITE
									if(_walkable_coord):
										tile_connections = 0
										connections = get_conections4(_next_coord.x, _next_coord.y)
										for val in connections:
											if(val):
												tile_connections += 1
								else:
									_walkable_coord = false
							_walk_lists.push_back([coord, _walk_end])
							pass
						elif(tile_connections == 2):
							if((connections[CARDINALS.N] and (connections[CARDINALS.E] or
							connections[CARDINALS.W])) or
								(connections[CARDINALS.S] and (connections[CARDINALS.E] or
								connections[CARDINALS.W]))):
								# is corner
								_terrain_dict[coord] = coord
								_walk_lists.push_back([coord, coord])
								pass
							else:
								# is walk after corner or intersection
								
								_next_coord = coord
								_walkable_coord = true
								var step = Vector2i(0, 1)
								if(connections[CARDINALS.E]):
									step = Vector2i(1, 0)
									pass
								elif(connections[CARDINALS.S]):
									pass
								else:
									print("ERROR! IS END", coord)
								while(_walkable_coord and tile_connections < 3):
									_walk_end = _next_coord
									_terrain_dict[_next_coord] = coord
									_next_coord += step
									
									if(_next_coord.x < _texture_map_img.get_width() and
									_next_coord.y < _texture_map_img.get_height()):
										_walkable_coord = _texture_map_img.get_pixel(_next_coord.x, _next_coord.y) != Color.WHITE
										if(_walkable_coord):
											tile_connections = 0
											connections = get_conections4(_next_coord.x, _next_coord.y)
											for val in connections:
												if(val):
													tile_connections += 1
											if((connections[CARDINALS.N] and (connections[CARDINALS.E] or
												connections[CARDINALS.W])) or
													(connections[CARDINALS.S] and (connections[CARDINALS.E] or
													connections[CARDINALS.W]))):
												tile_connections = 7
												pass
									else:
										_walkable_coord = false
								_walk_lists.push_back([coord, _walk_end])
								pass
						else:
							# is intersection
							_terrain_dict[coord] = coord
							_walk_lists.push_back([coord, coord])
							pass
						pass
	# STEP 1: Add unrepeated vertices to an array
	# STEP 2: Add vertices of each tri to an array
	# STEP 3: Convert Arrays to packed array
	# STEP 4: Set vertices
	# STEP 5: Add each polygon
	# STEP 0: create vertex array, idx array and vertex2idx dict
	var vertices:PackedVector3Array = []
	var tris:Array[PackedInt32Array] = []
	var quads:Array[PackedInt32Array] = []
	var vertices2indexes:Dictionary[Vector3, int] = {}
	var offset:float = tile_size
	var tile_dif:Vector2i = Vector2i(0, 0)
	var temp_vertices:Array[Vector3]
		
	for pair in _walk_lists:
		tile_dif = pair[0] - pair[1]
		# va, vb
		# vc, vd
		var vtx_idx:int = 0
		var temp_indexes:Array[int] = []
		temp_indexes.resize(4)
		var temp_i:int = 0
		if(tile_dif == Vector2i(0, 0)):
			temp_vertices = [
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2, 0, offset/2),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2, 0, offset/2),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2, 0, -offset/2),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2, 0, -offset/2)
			]
			# test new method
			# N
			temp_vertices = [
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, -offset/2+0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2-0.5, 0, -offset/2+0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, -offset/2),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2+0.5, 0, -offset/2)
			]
			temp_i = 0
			for new_vertex in temp_vertices:
				if(new_vertex in vertices2indexes):
					vtx_idx = vertices2indexes[new_vertex]
					pass
				else:
					vtx_idx = len(vertices)
					vertices2indexes[new_vertex] = vtx_idx
					vertices.push_back(new_vertex)
					pass
				temp_indexes[temp_i] = vtx_idx
				temp_i += 1
			quads.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2],temp_indexes[3]]))
			# E
			temp_vertices = [
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2, 0, -offset/2+0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, -offset/2+0.5)
			]
			temp_i = 0
			for new_vertex in temp_vertices:
				if(new_vertex in vertices2indexes):
					vtx_idx = vertices2indexes[new_vertex]
					pass
				else:
					vtx_idx = len(vertices)
					vertices2indexes[new_vertex] = vtx_idx
					vertices.push_back(new_vertex)
					pass
				temp_indexes[temp_i] = vtx_idx
				temp_i += 1
			quads.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2],temp_indexes[3]]))
			# S
			temp_vertices = [
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, offset/2),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2-0.5, 0, offset/2),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, offset/2-0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2+0.5, 0, offset/2-0.5)
			]
			temp_i = 0
			for new_vertex in temp_vertices:
				if(new_vertex in vertices2indexes):
					vtx_idx = vertices2indexes[new_vertex]
					pass
				else:
					vtx_idx = len(vertices)
					vertices2indexes[new_vertex] = vtx_idx
					vertices.push_back(new_vertex)
					pass
				temp_indexes[temp_i] = vtx_idx
				temp_i += 1
			quads.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2],temp_indexes[3]]))
			# W
			temp_vertices = [
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, -offset/2+0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2, 0, -offset/2+0.5)
			]
			temp_i = 0
			for new_vertex in temp_vertices:
				if(new_vertex in vertices2indexes):
					vtx_idx = vertices2indexes[new_vertex]
					pass
				else:
					vtx_idx = len(vertices)
					vertices2indexes[new_vertex] = vtx_idx
					vertices.push_back(new_vertex)
					pass
				temp_indexes[temp_i] = vtx_idx
				temp_i += 1
			quads.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2],temp_indexes[3]]))
			
			# MID
			temp_vertices = [
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2+0.5, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2-0.5, 0, offset/2-0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, -offset/2+0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, -offset/2+0.5)
			]
			temp_i = 0
			pass
		elif(0 != tile_dif.x):
			temp_vertices = [
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2, 0, offset/2-0.5),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2, 0, -offset/2+0.5),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2, 0, -offset/2+0.5)
			]
		elif(0 != tile_dif.y):
			temp_vertices = [
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(-offset/2+0.5, 0, offset/2),
				(Vector3(pair[1].x, h_off, pair[1].y) * offset) + Vector3(offset/2-0.5, 0, offset/2),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(offset/2-0.5, 0, -offset/2),
				(Vector3(pair[0].x, h_off, pair[0].y) * offset) + Vector3(-offset/2+0.5, 0, -offset/2)
			]
			pass
		for new_vertex in temp_vertices:
			if(new_vertex in vertices2indexes):
				vtx_idx = vertices2indexes[new_vertex]
				pass
			else:
				vtx_idx = len(vertices)
				vertices2indexes[new_vertex] = vtx_idx
				vertices.push_back(new_vertex)
				pass
			temp_indexes[temp_i] = vtx_idx
			temp_i += 1
		tris.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2]]))
		tris.push_back(PackedInt32Array([temp_indexes[1],temp_indexes[3],temp_indexes[2]]))
		quads.push_back(PackedInt32Array([temp_indexes[0],temp_indexes[1],temp_indexes[2],temp_indexes[3]]))
		pass
			
		
	navigation_mesh.set_vertices(vertices)
	var temp:= PackedInt32Array([])
	for quad in quads:
		navigation_mesh.add_polygon(quad)
		
	navigation_mesh.add_polygon(temp)
	
	$NavigationRegion3D.navigation_mesh = navigation_mesh
		
		#NavigationServer3D.region_set_navigation_mesh(region_rid, navigation_mesh)
	pass
	
func setup_event_entities()->void:
	var col:Color
	for y in range(_texture_map_img.get_height()):
		for x in range(_texture_map_img.get_width()):
			col = _texture_map_img.get_pixel(x, y)
			if(col.r8 == 0):
				if(col == Color8(0, 0, 1)):
					player_spawn = position + Vector3(x*tile_size,0,y*tile_size)
				# key event
				elif(col.b8 == 2):
					if(col.g8 == 0):
						# find key
						var ev_p:Vector3 = position + Vector3(x*tile_size,0,y*tile_size)
						var element:Node3D = interaction_pckscn.instantiate()
						element.set_event_key()
						element.position = ev_p
						#_add_owned_child(element, ^"Events")
						add_child(element)
						pass
					elif(col.g8 == 1):
						# key hole
						var ev_p:Vector3 = position + Vector3(x*tile_size,0,y*tile_size)
						var element:Node3D = interaction_pckscn.instantiate()
						element.set_event_lock()
						element.position = ev_p
						#_add_owned_child(element, ^"Events")
						add_child(element)
						pass
	pass
	
func _mesh_add_arraymesh(data:Array, mesh:Array)->void:
	var idx_offset:int = data[0]
	var pos_offset:Vector3 = data[1]
	var arraymesh:Array = data[2]
	
	var array_vtx:PackedVector3Array = arraymesh[Mesh.ARRAY_VERTEX]
	var array_nrm:PackedVector3Array = arraymesh[Mesh.ARRAY_NORMAL]
	var array_uv:PackedVector2Array = arraymesh[Mesh.ARRAY_TEX_UV]
	var array_idx:PackedInt32Array = arraymesh[Mesh.ARRAY_INDEX]
	
	var array_vtx_old:PackedVector3Array = mesh[Mesh.ARRAY_VERTEX]
	for idx in range(array_vtx_old.size()):
		array_vtx.push_back(pos_offset + array_vtx_old[idx])
		pass
	var array_nrm_old:PackedVector3Array = mesh[Mesh.ARRAY_NORMAL]
	for vec in array_nrm_old:
		array_nrm.push_back(vec)
	var array_uv_old:PackedVector2Array = mesh[Mesh.ARRAY_TEX_UV]
	for uv in array_uv_old:
		array_uv.push_back(uv)
	var array_idx_old:PackedInt32Array = mesh[Mesh.ARRAY_INDEX]
	for idx in range(array_idx_old.size()):
		array_idx.push_back(array_idx_old[idx] + idx_offset)
		pass
	idx_offset = array_vtx.size()
	
	data[0] = idx_offset
	data[1] = pos_offset
	pass
	
func _add_owned_child(child: Node, target=null)->void:
	if(target!= null):
		get_node(target).add_child(child)
	else:
		add_child(child)
	child.owner = self
	pass
