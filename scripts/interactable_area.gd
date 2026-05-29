extends Node3D

@onready
var Area:Area3D = $Area3D
@onready var pickupkey = $pickup_key
@onready var lock = $use_key
@export var active_event:interactable_base= null
var is_enabled:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		Area.body_entered.connect(_body_enters)
		Area.body_exited.connect(_body_exits)
	set_process(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _body_enters(body:Node3D)->void:
	if(is_instance_of(body, NavigableCharacter) and is_enabled):
		var chr:NavigableCharacter = body as NavigableCharacter
		if(chr.is_player):
			active_event.on_enter(chr)
			#print("player entered!")
			pass
		pass
	pass
	
func _body_exits(body:Node3D)->void:
	if(is_instance_of(body, NavigableCharacter)):
		var chr:NavigableCharacter = body as NavigableCharacter
		if(chr.is_player):
			active_event.on_exit(chr)
			if(chr.interactable_element == self):
				active_event.on_exit(chr)
				#print("player exited")
			pass
		pass
	pass

func call_event(chr:NavigableCharacter)->void:
	if(active_event.event(chr)):
		chr.interactable_element = null
		for tri in Area.body_entered.get_connections():
			Area.body_entered.disconnect(tri["callable"])
		for tri in Area.body_exited.get_connections():
			Area.body_exited.disconnect(tri["callable"])
	pass
	
func disable_event(chr:NavigableCharacter)->void:
	chr.interactable_element = null
	GameplayManager.instance.set_interaction_icon(null)
	active_event.visible = false
	is_enabled = false
	pass
	
func set_active_event(new_event:interactable_base=null)->void:
	active_event = new_event
	new_event.interaction_node = self
	add_child(new_event)
	pass
	
func set_event_key()->void:
	await self.ready
	pickupkey.visible = true
	active_event = pickupkey
	pass
	
func set_event_lock()->void:
	await self.ready
	lock.visible = true
	active_event = lock
	pass
