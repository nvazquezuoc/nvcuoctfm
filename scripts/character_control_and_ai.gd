extends CharacterBody3D

class_name NavigableCharacter

enum CARDINALS {
	NONE=-1,
	N,E,S,W,
	MAX,
}

const SPEED = 1.0
const JUMP_VELOCITY = 4.5
const SPIN_SPEED = 0.3

var _input_list:Array = InputManager.create_empty()
var animation_player:AnimationPlayer
var animation_tree:AnimationTree
var animation_list_names:PackedStringArray
var animation_idx:int = 0
var facing_direction:int = 0

var cam_cardinal:CARDINALS = CARDINALS.N
@onready var model_pivot:Node3D = $"exported-model2"
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var transform_cam:RemoteTransform3D = $RemoteTransform3D
@onready var marker_cam:Array[Node3D] = [
	$MarkerS, $MarkerE, $MarkerN, $MarkerW
]

var interactable_element:Variant = null

var transform_list:Array[Array] = [
	[Transform3D().rotated(Vector3(0,1,0), PI/2), Transform3D().rotated(Vector3(0,1,0), -PI/2)],
	[Transform3D(), Transform3D().rotated(Vector3(0,1,0), PI)],
	[Transform3D().rotated(Vector3(0,1,0), 3*PI/2), Transform3D().rotated(Vector3(0,1,0), -3*PI/2)],
	[Transform3D().rotated(Vector3(0,1,0), PI), Transform3D()],
]
@export var is_ai:bool = false
@export var is_player:bool = false
@export var player_cam:Camera3D

signal destination_reached

func _ready() -> void:
	_agent.velocity_computed.connect(_on_velocity_computed)
	animation_player = model_pivot.get_node(^"AnimationPlayer")
	animation_list_names = animation_player.get_animation_list()
	set_animation(&"Idle")
	facing_direction = 1
	model_pivot.rotation.y = PI/2
	animation_tree = model_pivot.get_node(^"AnimationTree")
	if(player_cam):
		transform_cam.remote_path = transform_cam.get_path_to(player_cam)
	pass
	
func disable()->void:
	set_physics_process(false)
	pass
	
func enable()->void:
	set_physics_process(true)
	pass
	
func set_animation(animation:StringName)->void:
	animation_player.play(animation)
	pass

func spin_to(to:CARDINALS=CARDINALS.NONE)->void:
	if(to == CARDINALS.NONE):
		to = (cam_cardinal + 1) % CARDINALS.MAX
	var prev_dir:int = facing_direction
	facing_direction = 0
	cam_cardinal = to
	var tween = create_tween()
	tween.tween_property(transform_cam, ^"transform", marker_cam[cam_cardinal].transform, SPIN_SPEED)
	var tween2 = create_tween()
	if(prev_dir < 0):
		tween2.tween_property(model_pivot, ^"transform", transform_list[cam_cardinal][1], SPIN_SPEED)
	else:
		tween2.tween_property(model_pivot, ^"transform", transform_list[cam_cardinal][0], SPIN_SPEED)
	await tween.finished
	facing_direction = prev_dir
	pass

# CC0/public domain/use for whatever you want no need to credit
# Still, creator of the function: @majikayogames
# Call this function directly before move_and_slide() on your CharacterBody3D script
func _push_away_rigid_bodies():
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

func set_movement_target(movement_target: Vector3)->void:
	$NavigationAgent3D.set_target_position(movement_target)
	await _agent.path_changed
	pass

func turn_to(direction:Vector3)->void:
	if(0 < direction.length()):
		var yaw := atan2(direction.x,direction.z)
		yaw = lerp_angle(model_pivot.rotation.y, yaw, 0.25)
		model_pivot.rotation.y = yaw
	pass
	
func _on_velocity_computed(safe_velocity: Vector3):
	turn_to(safe_velocity)
	velocity = safe_velocity
	move_and_slide()

func _physics_process(delta: float) -> void:
	# Add the gravity.
		
	if(is_ai):
		# Do not query when the map has never synchronized and is empty.
		if NavigationServer3D.map_get_iteration_id(_agent.get_navigation_map()) == 0:
			animation_tree.set(&"parameters/blend_position", velocity.length())
			return
		if _agent.is_navigation_finished():
			destination_reached.emit()
			animation_tree.set(&"parameters/blend_position", velocity.length())
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
			
		animation_tree.set(&"parameters/blend_position", velocity.length())
		return

	# Handle jump.
	if (_input_list[InputManager.Indexes.OK] == InputManager.States.JustPressed) and is_on_floor():
		if(is_instance_valid(interactable_element)):
			interactable_element.call_event(self)
		#if(facing_direction != 0):
		#	await spin_to()
		#	pass

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(_input_list[InputManager.Indexes.AXIS1], _input_list[InputManager.Indexes.AXIS2])
	var direction := (transform_cam.basis * Vector3(input_dir.x, 0, 0)).normalized() * SPEED
	
	match facing_direction:
		1:
			if(0 < _input_list[InputManager.Indexes.AXIS1]):
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			elif(_input_list[InputManager.Indexes.AXIS1] < 0):
				facing_direction = 0
				var tween = create_tween()
				tween.tween_property(model_pivot, ^"transform", transform_list[cam_cardinal][1], SPIN_SPEED)
				await tween.finished
				facing_direction = -1
		-1:
			if(0 < _input_list[InputManager.Indexes.AXIS1]):
				facing_direction = 0
				var tween = create_tween()
				tween.tween_property(model_pivot, ^"transform", transform_list[cam_cardinal][0], SPIN_SPEED)
				await tween.finished
				facing_direction = 1
			elif(_input_list[InputManager.Indexes.AXIS1] < 0):
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
	
	if(not _input_list[InputManager.Indexes.AXIS1]):
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if((_input_list[InputManager.Indexes.CANCEL] == InputManager.States.JustPressed)):
		animation_idx = (animation_idx +1 ) % animation_list_names.size()
		set_animation(animation_list_names[animation_idx])
		pass
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	_push_away_rigid_bodies()
	move_and_slide()
	animation_tree.set(&"parameters/blend_position", velocity.length())
