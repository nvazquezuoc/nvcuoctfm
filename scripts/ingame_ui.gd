extends VBoxContainer

@export
var lbl_keys:Label
@export
var interaction_icon:TextureRect
@export
var lbl_text:Label
@export
var uimap_texture:TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(func()->void:
		$SpinBox.value = 0
		pass)
	$btn_end.pressed.connect(func()->void:
		MainGameNode.instance.save_data.add_score($SpinBox.value,0)
		$"../../Game".load_next()
		pass)
	pass # Replace with function body.
	
func update_keys()->void:
	lbl_keys.text = str(GlobalVariables.play_dic[&"keys"]) + " x"
	pass
	
func set_interaction_icon(icon:Texture=null)->void:
	interaction_icon.texture = icon
	pass
	
func put_text(text:String="")->void:
	lbl_text.text = text
	pass
	
func send_map_texture(new_texture:Texture)->void:
	uimap_texture.texture = new_texture
	pass
