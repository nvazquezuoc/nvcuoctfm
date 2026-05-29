extends Node3D

var spintween:Tween
@export
var remote:RemoteTransform3D
@export
var spinner:Node3D
var player:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = spinner.get_node(^"AnimationPlayer")
	spinner.get_node(^"AnimationPlayer").play(&"Death01")
	spintween = create_tween()
	spintween.loop_finished.connect(func(loop_count:int)->void:
		spinner.rotation_degrees.y = 0
		pass)
	spintween.set_loops()
	spintween.set_trans(Tween.TRANS_LINEAR)
	spintween.set_ease(Tween.EASE_IN)
	spintween.tween_property(spinner, ^"rotation_degrees:y", 360, 12.0)
	#set_process(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enable()->void:
	visible = true
	#set_process(true)
	player.play(&"Death01")
	player.advance(0)
	pass
	
func disable()->void:
	visible = false
	#set_process(false)
	pass
	
func grab_cam_A(cam:Camera3D=null)->void:
	var other_remote:RemoteTransform3D
	if(cam == null):
		cam = GlobalVariables.cam_A
		pass
	if(cam != null):
		if(cam.has_meta(&"remote")):
			other_remote = cam.get_meta(&"remote")
			other_remote.remote_path = ^""
			pass
		cam.set_meta(&"remote", remote)
		remote.remote_path = remote.get_path_to(cam)
		pass
	pass
