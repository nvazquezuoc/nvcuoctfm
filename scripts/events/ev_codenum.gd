extends interactable_base

@export
var code_idx:int = -1
var screen_code:int = 0
var label_node:Label3D
var remote:RemoteTransform3D
@onready var input_reciever:Controlable_base = $Node
var cam_size_org:float = 2.0
var cam_size_zoom:float = 0.5
var is_using:bool = false
@export var keysound:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	super()
	input_reciever.interactable_element = self
	pass

func _start() -> void:
	set_process(false)
	label_node = $Label3D
	remote = $MarkerS2/RemoteTransform3D
	$key0/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(0))
	$key1/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(1))
	$key2/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(2))
	$key3/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(3))
	$key4/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(4))
	$key5/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(5))
	$key6/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(6))
	$key7/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(7))
	$key8/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(8))
	$key9/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			num_key_press(9))
	$keyBack/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			back_key_press())
	$keyEnter/StaticBody3D.input_event.connect(func(_camera, event, _position, _normal, _shape_idx)->void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ok_key_press())
	code_idx = GlobalVariables.get_numeric_idx()
	
func on_enter(chr:NavigableCharacter)->void:
	if(GlobalVariables.play_dic[&"got_code"][code_idx]):
		GameplayManager.instance.put_text("The code is "+str(GlobalVariables.play_dic[&"num_codes"][code_idx]))
	else:
		GameplayManager.instance.put_text("You don't know the code!")
		pass
	pass

func event(chr:NavigableCharacter):
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
		pass
	
func update_screen_text()->void:
	var new_text:String = ""
	if(0 < screen_code):
		if(screen_code < 1000):
			new_text += "0"
		if(screen_code < 100):
			new_text += "0"
		if(screen_code < 10):
			new_text += "0"
		if(screen_code < 1):
			new_text += "0"
		new_text += str(screen_code)
	else:
		new_text = "0000"
	label_node.text = new_text
	pass
	
func num_key_press(val:int=-1)->void:
	screen_code = (screen_code*10+val) % 10000
	MainGameNode.play_sound(keysound)
	update_screen_text()
	pass

func back_key_press()->void:
	screen_code = screen_code/10
	MainGameNode.play_sound(keysound)
	update_screen_text()
	
func ok_key_press()->void:
	MainGameNode.play_sound(keysound)
	if(screen_code == GlobalVariables.play_dic[&"num_codes"][code_idx]):
		parent_interaction.disable_secondary_interaction()
		parent_interaction.event(input_reciever.other_controlable)
		GlobalVariables.add_points(&"Complete passwords", 30)
		pass
	pass
	
func prepare()->void:
	_start()
