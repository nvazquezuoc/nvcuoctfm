@tool
extends interactable_base

enum CARDINALS {
	NONE=-1,
	N,E,S,W,
	MAX,
}

@onready var AreaN:Area3D = $AreaN
@onready var AreaS:Area3D = $AreaS
@onready var AreaW:Area3D = $AreaW
@onready var AreaE:Area3D = $AreaE
@export var connections:Array[bool] = [false,false,false,false,]
@export var default_view_X:CARDINALS = CARDINALS.N
@export var default_view_Z:CARDINALS = CARDINALS.E
var is_ready:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	is_ready = true
	if not Engine.is_editor_hint():
		set_connections(connections)
	pass # Replace with function body.
	
func set_connections(new_connections)->void:
	if(not is_ready):
		await ready
	
	for area in [AreaN, AreaS, AreaW, AreaE]:
		for con in area.body_entered.get_connections():
			AreaN.body_entered.disconnect(con["callable"])
			
	connections = new_connections
	
	var total_connections:int = 0
	for val in connections:
		if(val):
			total_connections += 1
	
	if((connections[CARDINALS.N] and (connections[CARDINALS.E] or connections[CARDINALS.W])) or
		(connections[CARDINALS.S] and (connections[CARDINALS.E] or connections[CARDINALS.W]))):
			if(total_connections < 3):
				if(connections[CARDINALS.S]):
					AreaN.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							match body.cam_cardinal:
								CARDINALS.E:
									if(body.facing_direction < 0):
										body.spin_to(default_view_X)
									pass
								CARDINALS.W:
									if(0 < body.facing_direction):
										body.spin_to(default_view_X)
									pass
						pass)
				if(connections[CARDINALS.N]):
					AreaS.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							match body.cam_cardinal:
								CARDINALS.E:
									if(0 < body.facing_direction):
										body.spin_to(default_view_X)
									pass
								CARDINALS.W:
									if(body.facing_direction < 0):
										body.spin_to(default_view_X)
									pass
						pass)
				if(connections[CARDINALS.W]):
					AreaE.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							match body.cam_cardinal:
								CARDINALS.N:
									if(0 < body.facing_direction):
										body.spin_to(default_view_Z)
									pass
								CARDINALS.S:
									if(body.facing_direction < 0):
										body.spin_to(default_view_Z)
									pass
						pass)
				if(connections[CARDINALS.E]):
					AreaW.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							match body.cam_cardinal:
								CARDINALS.N:
									if(body.facing_direction < 0):
										body.spin_to(default_view_Z)
									pass
								CARDINALS.S:
									if(0 < body.facing_direction):
										body.spin_to(default_view_Z)
									pass
						pass)
			if(total_connections == 3):
				if(not connections[CARDINALS.S]):
					AreaN.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter and
						body.cam_cardinal != default_view_X):
							body.is_ai = true
							body.set_movement_target($SpotE.global_position)
							body.spin_to(default_view_X)
							await body.destination_reached
							body.spin_to(default_view_X)
							body.is_ai = false
						pass)
				if(not connections[CARDINALS.N]):
					AreaS.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							if(body.cam_cardinal != CARDINALS.N):
								body.spin_to(default_view_X)
						pass)
				if(not connections[CARDINALS.E]):
					AreaW.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							if(body.cam_cardinal != CARDINALS.E):
								body.spin_to(default_view_Z)
						pass)
				if(not connections[CARDINALS.W]):
					AreaE.body_entered.connect(func(body:Node3D)->void:
						if(body is NavigableCharacter):
							if(body.cam_cardinal != CARDINALS.E):
								body.spin_to(default_view_Z)
						pass)
				pass
			if(total_connections == 4):
				pass
	pass
