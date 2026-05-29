extends interactable_base

@onready var input_reciever:Controlable_base = $Node
@onready var table_top:Node3D = $tabletop
@onready var table_bot:Node3D = $tablebot
@onready var farsant:Node3D = $farsant
@onready var animation_player:AnimationPlayer = $farsant/AnimationPlayer
@onready var remote:RemoteTransform3D = $remote
var cam_size_org:float = 2.0
var cam_size_zoom:float = 0.5
var is_hidden_inside:bool = false
var new_facing:int = 1
var is_using:bool = false

func _ready()->void:
	super()
	farsant.visible = false
	animation_player.play(&"Crouch_Fwd")
	input_reciever.interactable_element = self
	if(lock_interaction.is_touchable):
		lock_interaction.get_node(^"body").input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				lock_interaction.event(input_reciever.other_controlable))
	pass

func event(chr:NavigableCharacter)->bool:
	if(lock_interaction):
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
			#lock_interaction = null
		#lock_interaction.event(chr)
		else:
			is_using = false
			GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
			InputManager._instance.set_target(chr)
	else:
		if(is_using):
			is_using = false
			GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
			InputManager._instance.set_target(chr)
			pass
		elif(is_hidden_inside):
			farsant.position = table_bot.position
			farsant.rotation_degrees.y = 0
			farsant.visible = true
			animation_player.play(&"Crouch_Fwd")
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN)

			tween.tween_property(farsant, ^"position:z",
					 0, 1.0).set_custom_interpolator(clamp.bind(0.0,1.0))
			await tween.finished
			farsant.visible = false
			
			chr.is_ai = false
			chr.enable()
			InputManager._instance.set_target(chr)
			is_hidden_inside = false
			pass
		else:
			new_facing = 1
			if(chr.model_pivot.transform.basis.z.dot(chr.position - interaction_node.position) < 0):
				new_facing = -1
			chr.facing_direction = new_facing
			chr.set_movement_target(self.global_position)
			await chr.destination_reached
			chr.disable()
			input_reciever.other_controlable = chr
			InputManager._instance.set_target(input_reciever)
			farsant.position = Vector3(0, 0, 0)
			farsant.rotation_degrees.y = 180
			farsant.visible = true
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN)

			tween.tween_property(farsant, ^"position:z",
					 table_bot.position.z, 1.0).set_custom_interpolator(clamp.bind(0.0,1.0))
			await tween.finished
			animation_player.play(&"Crouch_Idle")
			is_hidden_inside = true
	super(chr)
	return false
