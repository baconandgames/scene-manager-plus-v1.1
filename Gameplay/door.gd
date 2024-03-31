class_name Door extends Area2D

## This class is not part of SceneManager, aside from the transition_type enum which is defined here
## and passed into the SceneManager class to tell the LoadingScreen what transition (read: animation)
## to play. This is one case where I failed to fully decouple game logic from the SceneManager class
## in this version. We're men, not machines. Gotta save some stuff for the next version :)

signal player_entered_door(door:Door,transition_type:String)

@export_enum("north","east","south","west") var entry_direction	## direction we're moving when entering door, defines zelda transition direction as well as direction we push the player. Will only ever be Vector2.UP/RIGHT/DOWN/LEFT
@export_enum("fade_to_black","fade_to_white","wipe_to_right","zelda","no_transition") var transition_type:String ## transitoin we want to use when moving through the door
@export var push_distance:int = 16	## how far into the room the player should be pushed upon entry
@export var path_to_new_scene:String	## scene we want to load when touchign this door
@export var entry_door_name:String	## name of the door we're entering through in the next room

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_entered_door.emit(self)
	
	# I don't LOVE this solution because the more "proper" rule of thumb is to signal up, call down
	# So I should probably have Gameplay listen for a signal from the doors requesting a level change
	# and then handle the SceneManager request from Gameplay. But this also works and it's simpler
	# so it's fine at this scale. Sometimes "it just works" is enough - pick your battles <3
	var gameplay_node:Gameplay = get_tree().get_nodes_in_group("gameplay")[0] as Gameplay
	var unload:Node = gameplay_node.current_level	# we're now responsible for tracking this 
	
	if transition_type == "zelda":
		SceneManager.swap_scenes_zelda(path_to_new_scene, gameplay_node.level_holder, unload, body.move_dir)
	else:
		SceneManager.swap_scenes(path_to_new_scene,gameplay_node.level_holder,unload,transition_type)
	queue_free()

# // UTILITY FUNCTIONS //
## returns the starting location of the player based on this door's location and the 
## entry_direction (the Vector towards the room)
func get_player_entry_vector() -> Vector2:
	var vector:Vector2 = Vector2.LEFT
	match entry_direction:
		0:
			vector = Vector2.UP
		1: 
			vector = Vector2.RIGHT
		2:
			vector = Vector2.DOWN
	return (vector * push_distance) + self.position

## inverts entry direction to determine the direction player would have been moving
## when they entered the room
func get_move_dir() -> Vector2:
	var dir:Vector2 = Vector2.RIGHT
	match entry_direction:
		0:
			dir = Vector2.DOWN
		1: 
			dir = Vector2.LEFT
		2:
			dir = Vector2.UP	
	return dir
