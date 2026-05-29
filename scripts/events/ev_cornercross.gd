extends interactable_base

enum CARDINALS {
	NONE=-1,
	N,E,S,W,
	MAX,
}

var connections:Array[bool] = [false,false,false,false,]
var default_view_X:CARDINALS = CARDINALS.N
var default_view_Z:CARDINALS = CARDINALS.E
var is_cross:bool = false
@onready var spots:Array[Node3D] = [$SpotN, $SpotE, $SpotS, $SpotW]

func event(chr:NavigableCharacter)->bool:
	if(is_cross):
		var card:NavigableCharacter.CARDINALS = NavigableCharacter.CARDINALS.N
		if(connections[1] and connections[3]):
			if(chr.cam_cardinal == default_view_X):
				card = NavigableCharacter.CARDINALS.E
			pass
		if(card != chr.cam_cardinal):
			#chr.spin_to(card)
			chr.is_ai = true
			chr.set_movement_target(global_position)
			chr.spin_to(card)
			await chr.destination_reached
			chr.is_ai = false
		pass
	return false

func on_enter(chr:NavigableCharacter)->void:
	super(chr)
	var card:NavigableCharacter.CARDINALS = NavigableCharacter.CARDINALS.N
	var spot_idx:int = -1
	if(is_cross):
		if(connections[0] and connections[2]):
			if(chr.cam_cardinal == default_view_X):
				card = NavigableCharacter.CARDINALS.E
			pass
		if(card != chr.cam_cardinal):
			#chr.spin_to(card)
			chr.is_ai = true
			chr.set_movement_target(global_position)
			chr.spin_to(card)
			await chr.destination_reached
			chr.spin_to(card)
			chr.is_ai = false
	else:
		if(chr.cam_cardinal == default_view_X):
			card = NavigableCharacter.CARDINALS.E
			spot_idx = chr.CARDINALS.N
			if(connections[2]):
				spot_idx = chr.CARDINALS.S
			pass
		else:
			card = NavigableCharacter.CARDINALS.N
			spot_idx = chr.CARDINALS.E
			if(connections[3]):
				spot_idx = chr.CARDINALS.W
			pass
		chr.is_ai = true
		chr.set_movement_target(spots[spot_idx].global_position)
		chr.spin_to(card)
		await chr.destination_reached
		chr.spin_to(card)
		chr.is_ai = false
	pass

func set_connections(new_connections:Array[bool])->void:
	connections.assign(new_connections)
	var total_connections = 0
	
	for c in connections:
		if(c):
			total_connections += 1
	
	is_cross = (total_connections == 3)
	pass
