extends VBoxContainer

@export var box:PackedScene
@export var msg:String
@export var node:Node
@export var sound:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	if(not is_instance_valid(node)):
		node = box.instantiate()
		add_child(node)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func action()->void:
	MainGameNode.instance.simpleAudioPlayer.stream = sound
	node.clear_msg()
	node.send_text(msg)
	pass
