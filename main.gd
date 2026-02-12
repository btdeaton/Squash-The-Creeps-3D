extends Node

@export var mob_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	load_high_score()
	$UserInterface/Retry.hide()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene
	var mob = mob_scene.instantiate()
	
	# Choose a random location on the SpawnPath
	# We store the reference to the SpawnLocation node
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# Give it a random offset
	mob_spawn_location.progress_ratio = randf()
	
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	# Spawn the mob by adding it to the main scene
	add_child(mob)
	
	# We connect the mob to the score label to update the score when one is squashed
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())
	

func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()

func _unhandled_input(event):
	if event.is_action_pressed('ui_accept') and $UserInterface/Retry.visible:
		# This restarts the current scene
		get_tree().reload_current_scene()
	

var high_score = 0
var save_path = "user://highscore.save"

func load_high_score():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		high_score = file.get_32()
	else:
		high_score = 0

func save_high_score():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_32(high_score)
