extends Node3D

@onready
var number_label:Label3D = $Label3D
@onready
var door_l:Node3D = $doorL
@onready
var door_r:Node3D = $doorR

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	pass # Replace with function body.
	
func set_floor_number(number:int)->void:
	var new_text:String = ""
	if(0 < number):
		if(number < 100):
			new_text += "0"
		if(number < 10):
			new_text += "0"
		if(number < 1):
			new_text += "0"
		new_text += str(number)
	else:
		new_text = "000"
	$Label3D.text = new_text
	pass
func door_open(time:float=1)->void:
	if(time < 0.1):
		door_l.position.x = 0.5
		door_r.position.x = -0.5
		pass
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_OUT_IN)
		tween.tween_property(door_l, ^"position:x", 0.5, time)
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_EXPO)
		tween2.set_ease(Tween.EASE_OUT_IN)
		tween2.tween_property(door_r, ^"position:x", -0.5, time)
		pass
	pass
func door_close(time:float=1)->void:
	if(time < 0.1):
		door_l.position.x = 0
		door_r.position.x = 0
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_OUT_IN)
		tween.tween_property(door_l, ^"position:x", 0, time)
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_EXPO)
		tween2.set_ease(Tween.EASE_OUT_IN)
		tween2.tween_property(door_r, ^"position:x", -0, time)
		pass
	pass
