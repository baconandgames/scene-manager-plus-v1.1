class_name Level extends Node2D

## This class is not part of [class SceneManager], it's just here to make the sample
## project do something. All levels (i.e. the game content) extend from this class. 
## You will note that because Levels "want" to pass data between them, they implement
## the optional methods [method get_data] and [method receive_data]

@export var player:Player
@export var doors:Array[Door]
var data:LevelDataHandoff

func _ready() -> void:
	player.disable()
	player.visible = false
	# This block is here to allow us to test current scene without needing the SceneManager to call these :) 
	if data == null: 
		init_scene()
		start_scene()
		

## When a class implements this, SceneManager.on_content_finished_loading will invoke it
## to receive this data and pass it to the next scene
func get_data():
	return data
	
## 1) emitted at the beginning of SceneManager.on_content_finished_loading
## When a class implements this, SceneManager.on_content_finished_loading will invoke it
## to insert data received from the previous scene into this one	
func receive_data(_data):
	# implementing class should do some basic checks to make sure it only acts on data it's prepared to accept
	# if previous scene sends data this scene doesn't need, simple logic as follows ensures no crash occurs
	# act only on the data you want to receive and process :) 
	if _data is LevelDataHandoff:
		data = _data
		# process data here if need be, for this we just need to receive it but only if it's of the correct data type
	else:
		# SceneManager is designed to allow data mismatches like this occur, because you wno't always know
		# which scene precedes or follows another. For example, this sample project passes data between
		# levels but not between a level and the start screen, or vice versa. But it's possible Start screen might
		# look for data from a different scene. So both incoming and outgoing scenes might implement get/receive_data
		# but you may not always want to process that data. This is way more explanation than you need for something
		# that's pretty much designed to work this way and fail silently when not in use :D
		push_warning("Level %s is receiving data it cannot process" % name)

## emitted in the middle of SceneManager.on_content_finished_loading, after this scene is added to the tree
## 2) I use this to initialize stuff (like player start location) before user regains control
func init_scene() -> void:
	init_player_location()

## emitted at the very end of SceneManager.on_content_finished_loading, after the transition has completed
## 3) Here I'm using it to return control to the user because everything is ready to go
func start_scene() -> void:
	player.enable()
	_connect_to_doors()

## put player in front of the correct door, facing the correct direction
func init_player_location() -> void:
	player.visible = true
#	var doors = find_children("*","Door")
	if data != null:
		for door in doors:
			if door.name == data.entry_door_name:
				player.position = door.get_player_entry_vector()
		player.orient(data.move_dir)

## signal emitted by Door, # disables doors and players, create handoff data to pass to the new scene (if new scene is a Level)
func _on_player_entered_door(door:Door) -> void:
	_disconnect_from_doors()
	player.disable()
	player.queue_free()
	data = LevelDataHandoff.new()
	data.entry_door_name = door.entry_door_name
	data.move_dir = door.get_move_dir()
	set_process(false)
		

## connects to all door signals in level
func _connect_to_doors() -> void:
	for door in doors:
		if not door.player_entered_door.is_connected(_on_player_entered_door):
			door.player_entered_door.connect(_on_player_entered_door)

## disconnect from all door signals in level			
func _disconnect_from_doors() -> void:
	for door in doors:
		if door.player_entered_door.is_connected(_on_player_entered_door):
			door.player_entered_door.disconnect(_on_player_entered_door)
			

