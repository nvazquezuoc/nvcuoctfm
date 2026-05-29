extends interactable_base

@onready var input_reciever:Controlable_base = $Node
@onready var farsant:Node3D = $farsant
@onready var animation_player:AnimationPlayer = $farsant/AnimationPlayer
@onready var remote:RemoteTransform3D = $remote
var is_using:bool = false
var new_facing:int = 1
var cam_size_org:float = 2.0
var cam_size_zoom:float = 0.5
var stored:interactable_base

func _ready()->void:
	super()
	farsant.visible = false
	animation_player.play(&"Crouch_Fwd")
	input_reciever.interactable_element = self
	
	if(stored.is_touchable):
		stored.get_node(^"body").input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				stored.event(input_reciever.other_controlable))
	
	if(lock_interaction.is_touchable):
		lock_interaction.get_node(^"body").input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				lock_interaction.event(input_reciever.other_controlable))
	pass

func add_secondary_interaction(other:interactable_base)->void:
	if(stored == null):
		stored = other
		stored.parent_interaction = self
		points_of_interest[0].add_child(stored)
	else:
		lock_interaction = other
		other.parent_interaction = self
		points_of_interest[1].add_child(other)
	pass
	
func disable_secondary_interaction()->void:
	if($door.visible):
		$door.visible = false
	else:
		stored.visible = false
	pass

func event(chr:NavigableCharacter)->bool:
	if(lock_interaction):
		#lock_interaction.event(chr)
		if(not is_using):
			is_using = true
			input_reciever.other_controlable = chr
			InputManager._instance.set_target(input_reciever)
			#GlobalVariables.grab_cam_A(remote)
			GlobalVariables.grab_cam_B(remote)
			GameplayManager.instance.send_map_texture(null)
			var tween:Tween = create_tween()
			tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(remote, ^"transform", $MarkerS2.transform, 2.5)
			tween.parallel().tween_property(GlobalVariables.cam_B, ^"size", cam_size_zoom, 2.5)
			await tween.finished
		else:
			if($door.visible):
				is_using = false
				#var tween:Tween = create_tween()
				#tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
				#tween.tween_property(remote, ^"transform", $MarkerS.transform, 2.5)
				 #tween.parallel().tween_property(GlobalVariables.cam_A, ^"size", cam_size_org, 2.5)
				#await tween.finished
				#chr.take_cam_control(GlobalVariables.cam_A)
				GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
				InputManager._instance.set_target(chr)
			else:
				is_using = true
				lock_interaction = null
	elif(is_using):
		is_using = false
		GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
		InputManager._instance.set_target(chr)
		pass
	elif(stored):
		if(not is_using):
			is_using = true
			#stored = null
			input_reciever.other_controlable = chr
			InputManager._instance.set_target(input_reciever)
			GameplayManager.instance.send_map_texture()
			GlobalVariables.grab_cam_B(remote)
			var tween:Tween = create_tween()
			tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(remote, ^"transform", $MarkerS2.transform, 2.5)
			tween.parallel().tween_property(GlobalVariables.cam_B, ^"size", cam_size_zoom, 2.5)
			await tween.finished
		else:
			print("jaja")
			
	super(chr)
	return false
