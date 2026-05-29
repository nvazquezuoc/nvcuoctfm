extends NavigableCharacter

class_name EnemyBase

var _brain:EnemyBrain = EnemyBrain.new()
@export var area_close:Area3D
@export var timer:Timer
@export var cry:AudioStream
var is_attacking:bool = false

func _ready() -> void:
	super()
	destination_reached.connect(_on_destination_reached)
	area_close.body_entered.connect(attack)
	pass
	
func disable(with_colisions:bool = false)->void:
	super(with_colisions)
	is_ai = false
	
func enable()->void:
	super()
	_brain.level_start_setup()
	is_ai = true
	await _on_destination_reached()
	pass
	
func _on_destination_reached()->void:
	if(timer.is_stopped() and is_ai):
		timer.start(1)
		await timer.timeout
		timer.stop()
		if(model_pivot.visible):
			set_movement_target(_brain.get_new_destination())
	pass
	
func attack(body:Node3D)->void:
	if(is_instance_of(body, NavigableCharacter)):
		var chr:NavigableCharacter = body
		if(body.is_player):
			MainGameNode.play_sound(cry)
			animation_player.play(&"Zombie_Scratch")
			is_attacking = true
			#var orgr:Vector3 = model_pivot.rotation
			#model_pivot.look_at(body.position)
			turn_to((body.position - position))
			timer.start(0.8)
			await timer.timeout
			timer.stop()
			#model_pivot.rotation = orgr
			is_attacking = false
			if((body.position - position).length() < 1.15):
				GlobalVariables.add_points(&"Defeated", -50)
				GameplayManager.instance.event_defeat()
		pass
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#animation_tree.set(&"parameters/blend_position", velocity.length())
	if(is_attacking):
		return
		
	if(is_ai):
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
			#animation_tree.set(&"parameters/blend_position", velocity.length())
			animation_player.play(&"Zombie_Walk_Fwd")
			return
		if _agent.is_navigation_finished():
			#position = _agent.target_position
			destination_reached.emit()
			#animation_tree.set(&"parameters/blend_position", 0)
			animation_player.play(&"Zombie_Idle")
			return

		var next_path_position: Vector3 = _agent.get_next_path_position()
		var new_velocity: Vector3 = position.direction_to(next_path_position) * SPEED
		if _agent.avoidance_enabled:
			_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
		_push_away_rigid_bodies()
		
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		#animation_tree.set(&"parameters/blend_position", velocity.length())
		animation_player.play(&"Zombie_Walk_Fwd")
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	_push_away_rigid_bodies()
	move_and_slide()
	#animation_tree.set(&"parameters/blend_position", velocity.length())
	if(velocity.length() == 0):
		animation_player.play(&"Zombie_Idle")
	else:
		animation_player.play(&"Zombie_Walk_Fwd")
