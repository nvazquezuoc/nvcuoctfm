extends MeshInstance3D

@export
var code_idx:int = -1
var screen_code:int = 0
var label_node:Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	label_node = $Label3D
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
	update_screen_text()
	pass

func back_key_press()->void:
	screen_code = screen_code/10
	update_screen_text()
	
func ok_key_press()->void:
	print("The code is "+str(screen_code)+"!")
	pass
