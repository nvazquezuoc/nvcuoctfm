extends Control


const LETTER_TIME:float = 0.04
const PUNCTUATION_TIME:float = 0.3

@export var dialogue:Array[String]
@export var label:Label
@export var audio_stream_player:AudioStreamPlayer 
@export var message_base:Control
var prev_msg:Control

var tween:Tween
var dialogue_index:int = 0

func _ready() -> void:
	pass

func skip_animation_or_say_next_line():
	if tween and tween.is_running():
		tween.kill()
		label.visible_characters = -1
	else:
		say(dialogue[dialogue_index])
		dialogue_index += 1 % dialogue.size()

func say(text:String):
	if tween: tween.kill()
	tween = create_tween()
	
	label.text = text
	label.visible_characters = 0
	
	var index:= 0
	var last_punct_index:= 0
	var text_length:= label.text.length()
	
	for letter in label.text:
		index+=1

		# only add a MethodTweener at punctuations or end of string
		if not(letter in [".", "?", "!", ","] or index == text_length): 
			continue
		
		# reveal letters between the last punctuation and the current one
		var duration = (index-last_punct_index) * LETTER_TIME
		tween.tween_method(_reveal_char, last_punct_index, index, duration)
		
		# wait a bit after commas and punctuation
		if letter == ",": tween.tween_interval(PUNCTUATION_TIME/2.0)
		else: tween.tween_interval(PUNCTUATION_TIME)
		
		last_punct_index = index

# method called every frame by the MethodTweener
func _reveal_char(v:int):
	if label.visible_characters==v:return
	label.visible_characters = v
	if(is_instance_valid(audio_stream_player)):
		audio_stream_player.play()
		
func _input(event)->void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#skip_animation_or_say_next_line()
		var messagebox:Control = message_base.duplicate()
		if(is_instance_valid(prev_msg)):
			prev_msg.skip_animation_or_say_next_line()
		$VBoxContainer.add_child(messagebox)
		messagebox.visible = true
		messagebox.send_text(dialogue[dialogue_index])
		prev_msg = messagebox
		dialogue_index = (dialogue_index + 1) % dialogue.size()
		pass
