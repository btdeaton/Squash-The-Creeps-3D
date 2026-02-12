extends Label

var score = 0
var high_score = 0
const SAVE_PATH = "user://savegame.cfg"

func _ready():
	load_high_score()
	update_text()

func _on_mob_squashed():
	score += 1
	# Check if we beat the high score
	if score > high_score:
		high_score = score
		save_high_score()
	
	update_text()

func update_text():
	text = "Score: %s\nBest: %s" % [score, high_score]

func save_high_score():
	var config = ConfigFile.new()
	# Store the high_score variable in a section called "Game"
	config.set_value("Game", "high_score", high_score)
	config.save(SAVE_PATH)

func load_high_score():
	var config = ConfigFile.new()
	# Load data from the file
	var err = config.load(SAVE_PATH)
	
	# If the file loaded successfully, retrieve the high score
	if err == OK:
		high_score = config.get_value("Game", "high_score", 0)
