extends interactable_base

@export
var remote:RemoteTransform3D
var cam_size_org:float = 2.0
var cam_size_zoom:float = 0.5
@export var sound:AudioStream

func set_floor_number(number:int)->void:
	$elevator.set_floor_number(number)
	pass

func event(chr:NavigableCharacter)->bool:
	if(lock_interaction):
		lock_interaction.event(chr)
	else:
		#on_exit(chr)
		GameplayManager.instance.active_level.milisec_mapstart
		GlobalVariables.add_points(&"Time", 
		-(Time.get_ticks_msec() - GameplayManager.instance.active_level.milisec_mapstart)/ 1000)
		GlobalVariables.add_points(&"Levels completed", 100)
		var cam:Camera3D = GlobalVariables.cam_A
		InputManager._instance.set_target()
		GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
		grab_cam_A(cam)
		cam.size = cam_size_org
		remote.transform = $MarkerS.transform
		var elevator:Node3D = $elevator
		elevator.door_open(0.5)
		MainGameNode.play_sound(sound)
		
		var tween:Tween = create_tween()
		tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(remote, ^"transform", $MarkerS2.transform, 2.5)
		tween.parallel().tween_property(cam, ^"size", cam_size_zoom, 2.5)
		await tween.finished
		var timer:Timer = $Timer
		chr.disable(true)
		if(timer.is_stopped()):
			elevator.door_close(0.5)
			timer.start(0.5)
			await timer.timeout
			timer.stop()
		
		GameplayManager.instance.load_next()
		
	return false
	
func start_level_event(chr:NavigableCharacter, enemies:Array[NavigableCharacter])->void:
	var cam:Camera3D = GlobalVariables.cam_A
	InputManager._instance.set_target()
	cam.size = cam_size_zoom
	remote.transform = Transform3D($MarkerS2.transform)
	grab_cam_A(cam)
	var elevator:Node3D = $elevator
	elevator.door_open(0.5)
	
	var timer:Timer = $Timer
	if(timer.is_stopped()):
		elevator.door_close(0.5)
		timer.start(0.5)
		await timer.timeout
		timer.stop()
	chr.enable()
	for enemy in enemies:
		enemy.enable()
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(remote, ^"transform", $MarkerS.transform, 2.5)
	tween.parallel().tween_property(cam, ^"size", cam_size_org, 2.5)
	await tween.finished
	GameplayManager.instance.active_level.milisec_mapstart = Time.get_ticks_msec()
	chr.take_cam_control(cam)
	InputManager._instance.set_target(chr)
	on_exit(chr)
	pass

func grab_cam_A(cam:Camera3D=null)->void:
	var other_remote:RemoteTransform3D
	if(cam == null):
		cam = GlobalVariables.cam_A
		pass
	if(cam != null):
		if(cam.has_meta(&"remote")):
			if(is_instance_valid(cam.get_meta(&"remote"))):
				other_remote = cam.get_meta(&"remote")
				other_remote.remote_path = ^""
			pass
		cam.set_meta(&"remote", remote)
		remote.remote_path = remote.get_path_to(cam)
		pass
	pass
