extends VBoxContainer

var _input_list : Array = InputManager.create_empty()
@export var base_box:PackedScene
@export var dialogues:Array[String]
@export var dvbox:VBoxContainer
@export var audio_player:AudioStreamPlayer
@export var thundersound:AudioStream
var prev_msg:Control
var idx:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InputManager._instance.set_target(self)
	audio_player.stream = audio_player.stream
	$Button.pressed.connect(action)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if (_input_list[InputManager.Indexes.OK] == InputManager.States.JustPressed):
		action()
	pass
	
func action()->void:		
	if(dialogues.size() <= idx):
		prev_msg.skip_animation_or_say_next_line()
		MainGameNode.goto_main_menu()
		InputManager._instance.set_target(null)
		MainGameNode.play_sound(thundersound)
		return
		pass
	var new_message:Control = base_box.instantiate()
	new_message.audio_stream_player = audio_player
	if(is_instance_valid(prev_msg)):
		prev_msg.skip_animation_or_say_next_line()
	dvbox.add_child(new_message)
	new_message.visible = true
	new_message.send_text(dialogues[idx])
	prev_msg = new_message
	idx = idx + 1
	pass
