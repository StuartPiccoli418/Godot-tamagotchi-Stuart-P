extends Node

const SAVE_GAME_PATH := "user://savedgame.tres"

@onready var roomManager = get_parent().get_node("RoomManager")
@onready var timeUI = get_parent().get_node("TimeUI")

func _ready():
	verify_save_directory("user://")
	if FileAccess.file_exists(SAVE_GAME_PATH):
		load_game()
	else:
		print('no save file, starting fresh.')
		
func verify_save_directory(path: String) -> void:
	var dir_path = path.get_base_dir()
	var dir = DirAccess.open(dir_path)
		
	if dir == null:
		print("Failed to open directory: %s" % dir_path)
		return
		
	if dir.dir_exists(dir_path):
		print("Directory exists: %s" % dir_path)
	else:
		var result = dir.make_dir_recursive(dir_path)
		if result != OK:
			print("Failed to create directory: %s" % dir_path)
		else:
			print("Directory created: %s" % dir_path)
		
func save_game():
	if roomManager.queue_processing:
		print("cannot save now")
		return
	var saved_game: SavedGame = SavedGame.new()
	
	var saved_data:Array[SavedData] = []
	get_tree().call_group("SaveGroup", "on_save_game", saved_data)
	saved_game.saved_data = saved_data
	ResourceSaver.save(saved_game, SAVE_GAME_PATH)

func load_game():
	var saved_game:SavedGame = SafeResourceLoader.load(SAVE_GAME_PATH) as SavedGame
	if saved_game == null:
		print("Failed to load saved game.")
		return
		
	for saved_data in saved_game.saved_data:
		if saved_data is SavedRoomInfo:
			roomManager.on_load_game(saved_data)
		elif saved_data is SavedTime:
			timeUI.on_load_game(saved_data)
		elif saved_data is SavedGlobal:
			Global.on_load_game(saved_data)

	
func _on_button_pressed():
	save_game()


func _on_button_2_pressed():
	load_game()

func _on_timer_timeout():
	save_game()
