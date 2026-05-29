extends interactable_base

var is_using:bool = false
var remote:RemoteTransform3D
@onready var input_reciever:Controlable_base = $Node
var cam_size_org:float = 2.0
var cam_size_zoom:float = 0.5
@export var sound:AudioStream

func _ready() -> void:
	remote = $MarkerS2/RemoteTransform3D
	$body.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if(0 < GlobalVariables.play_dic[&"keys"]):
				#print("enough keys")
				GameplayManager.instance.add_keys(-1)
				parent_interaction.disable_secondary_interaction()
				parent_interaction.event(input_reciever.other_controlable)
				GlobalVariables.add_points(&"Open Locks", 20)
				MainGameNode.play_sound(sound))
	pass

func on_enter(chr:NavigableCharacter)->void:
	if(0 < GlobalVariables.play_dic[&"keys"]):
		GameplayManager.instance.put_text("You have a key!")
	else:
		#print("Not enough keys!")
		pass
	pass

func event(chr:NavigableCharacter)->bool:
	#print("interacted")
	if(not is_using):
		is_using = true
		input_reciever.other_controlable = chr
		InputManager._instance.set_target(input_reciever)
		input_reciever.interactable_element = self
		#GlobalVariables.grab_cam_A(remote)
		GlobalVariables.grab_cam_B(remote)
		remote.transform = Transform3D($Marker3D.transform)
		GameplayManager.instance.send_map_texture(null)
		var tween:Tween = create_tween()
		tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(remote, ^"transform", $MarkerS2.transform, 2.5)
		tween.parallel().tween_property(GlobalVariables.cam_B, ^"size", cam_size_zoom, 2.5)
		await tween.finished
	else:
		is_using = false
		GameplayManager.instance.send_map_texture(GameplayManager.instance.active_level.texture_map)
		InputManager._instance.set_target(input_reciever.other_controlable)
	if(0 < GlobalVariables.play_dic[&"keys"] and false):
		#print("enough keys")
		GameplayManager.instance.add_keys(-1)
		parent_interaction.disable_secondary_interaction()
		parent_interaction.event(chr)
		GlobalVariables.add_points(&"Open Locks", 20)
		return true
	else:
		#print("Not enough keys!")
		return false
