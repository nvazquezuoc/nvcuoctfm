class_name GlobalVariables

static var play_dic:Dictionary = {}
static var active_map:MapNode
static var rng = RandomNumberGenerator.new()
static var randiteri_list:Array[int] = []
static var randiterf_list:Array[float] = []
static var randiter_idx:int = 0
static var list_sizes:int = 100
static var cam_A:Camera3D
static var cam_B:Camera3D
static var last_code_idx:int = -1
static var active_run_seed:int = -1

static func _static_init() -> void:
	rng.randomize()
	pass

static func begin_vars()->void:
	play_dic = {
		&"keys" : 0,
		&"num_codes" : [],
		&"got_code" : [],
		&"totalpoints" : 0,
		&"tagpoints" : {}
	}
	
static func add_points(key:StringName, value:int=0)->void:
	play_dic[&"totalpoints"] += value
	if(not key in play_dic[&"tagpoints"]):
		play_dic[&"tagpoints"][key] = 0
	play_dic[&"tagpoints"][key] += value
	pass

static func get_numeric_idx()->int:
	var idx:int = -1
	var num_codes:Array = play_dic[&"num_codes"]
	idx = num_codes.size()
	last_code_idx = idx
	var new_code:int = randi_l(1, 9999)
	num_codes.push_back(new_code)
	play_dic[&"got_code"].push_back(false)
	#print(last_code_idx, " ", num_codes)
	return idx
	
static func grab_cam_A(remote:RemoteTransform3D=null)->void:
	var other_remote:RemoteTransform3D
	if(remote != null):
		if(cam_A.has_meta(&"remote")):
			other_remote = cam_A.get_meta(&"remote")
			other_remote.remote_path = ^""
			pass
		cam_A.set_meta(&"remote", remote)
		remote.remote_path = remote.get_path_to(cam_A)
		pass
	pass
	
static func grab_cam_B(remote:RemoteTransform3D=null)->void:
	var other_remote:RemoteTransform3D
	if(remote != null):
		if(cam_B.has_meta(&"remote")):
			if(is_instance_valid(cam_B.get_meta(&"remote"))):
				other_remote = cam_B.get_meta(&"remote")
				other_remote.remote_path = ^""
			pass
		cam_B.set_meta(&"remote", remote)
		remote.remote_path = remote.get_path_to(cam_B)
		pass
	pass
	
static func set_seed(val:int)->void:
	rng.seed = val
	
static func set_state(val:int)->void:
	rng.state = val
	
static func randi(min:int=0, max:int=999999)->int:
	return rng.randi_range(min, max)
	
static func randi_l(min:int=0, max:int=999999)->int:
	var result:int = 0
	if(0 != max):
		result = (randiteri_list[randiter_idx]) % (max+1 - min) + min
	randiter_idx = (randiter_idx + 1) % list_sizes
	return result
	
static func randf(min:float=0, max:float=999999)->float:
	return rng.randf_range(min, max)
	
static func randf_l(min:int=0, max:int=999999)->int:
	var result:float = ((randiteri_list[randiter_idx] - min) % max+1) + min + randiterf_list[randiter_idx]
	if(max < result):
		result = min + randiterf_list[randiter_idx]
	randiter_idx = (randiter_idx + 1) % list_sizes
	return result
	
static func randomize_rng(seed:int=-1)->void:
	if(-1 < seed):
		rng.seed = seed
		pass
	else:
		rng.randomize()
		rng.seed = randi()
	rng.state = 0
	randiter_idx = 0
	randiteri_list.resize(list_sizes)
	randiterf_list.resize(list_sizes)
	for idx in range(list_sizes):
		randiteri_list[idx] = rng.randi()
		randiterf_list[idx] = rng.randf_range(0.0, 1.0)
