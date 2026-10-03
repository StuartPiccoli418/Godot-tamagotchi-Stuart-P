extends Node

var is_stay_over_processing = false
@export var guest_pet_resources: Array[petResource]
@export var stay_duration_hours: int  # Duration in hours


@onready var petIntroductionUI = preload("res://source/ui/pet_introduction_ui.tscn")
@onready var petOutroUI = preload("res://source/ui/pet_outro_ui.tscn")
@onready var reviews_json_path = "res://source/data/reviews.json"
@onready var timeUI = get_tree().get_first_node_in_group("TimeUI")
@onready var _pet = get_parent().get_node("Pet")
@onready var roomManager = get_tree().get_root().get_node("MainScene/RoomManager")
@onready var roomScene = get_parent()

var current_guest_pet_resource = null
var pet_introduction_ui = null
var pet_outro_ui = null
var HOURS_PER_DAY = 24
var pet_exit_time = { "day": 0, "hour": 0, "minute": 0 }
var pet_introduced = false
var reviews_data: Dictionary = {}

func _ready():
	await get_tree().create_timer(1).timeout
	reviews_data = load_json_file(reviews_json_path)
	if reviews_data.is_empty():
		push_error("Failed to load reviews data.")
		return
		
	timeUI.time_tick.connect(check_if_stay_over)
	if !pet_introduced:
		introduce_guest_pet()

func get_pet_manager_save_data():
	var my_data = SavedPetManager.new()
	my_data.pet_resource = current_guest_pet_resource
	my_data.pet_exit_time = pet_exit_time
	my_data.stay_duration_hours = stay_duration_hours
	my_data.pet_introduced = pet_introduced
	return my_data

func update_to_save_data(saved_data:SavedData):
	current_guest_pet_resource = saved_data.pet_resource
	pet_exit_time = saved_data.pet_exit_time
	stay_duration_hours = saved_data.stay_duration_hours
	pet_introduced = saved_data.pet_introduced
	
	
func load_json_file(file_path: String):
	if FileAccess.file_exists(file_path):
		var data_file = FileAccess.open(file_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading file")
	else:
		print("File dosen't exist")


func check_if_stay_over(day, hour, minute):
	if not pet_introduced:
		return

	if is_stay_over_processing:
		return

	var current_total_minutes = day * 1440 + hour * 60 + minute
	var exit_total_minutes = (
		pet_exit_time.day * 1440
		+ pet_exit_time.hour * 60
		+ pet_exit_time.minute
	)

	if current_total_minutes >= exit_total_minutes:
		print("EXPIRATION TRIGGERED: ", current_guest_pet_resource.name)

		# Lock immediately, before starting the transition.
		is_stay_over_processing = true
		_stay_over()

func set_pet_exit_time():
	var current_total_minutes = (timeUI.day * 1440+ timeUI.hour * 60 + timeUI.minute)

	var exit_total_minutes = current_total_minutes + stay_duration_hours * 60

	pet_exit_time.day = int(exit_total_minutes / 1440)
	pet_exit_time.hour = int((exit_total_minutes % 1440) / 60)
	pet_exit_time.minute = exit_total_minutes % 60
	

func introduce_guest_pet():
	print("INTRO: function started")

	while roomManager.queue_processing:
		await get_tree().create_timer(1.0).timeout

	roomManager.queue_processing = true

	if guest_pet_resources.is_empty():
		push_error("GuestPetManager: No pet resources assigned!")
		roomManager.queue_processing = false
		return

	print("Total guest pet resources: ", guest_pet_resources.size())

	for i in range(guest_pet_resources.size()):
		var pet_resource = guest_pet_resources[i]
		if pet_resource == null:
			print("Pet index ", i, " is EMPTY")
		else:
			print("Pet index ", i, ": ", pet_resource.name)

	var selected_index = randi_range(0, guest_pet_resources.size() - 1)
	current_guest_pet_resource = guest_pet_resources[selected_index]

	print("Selected index: ", selected_index)
	print("Selected pet: ", current_guest_pet_resource.name)

	stay_duration_hours = randi_range(1, 12)
	set_pet_exit_time()

	await show_pet_intro(current_guest_pet_resource)

	_pet.resource = current_guest_pet_resource
	_pet.pet_stats.reset_stats()
	await _pet.walk_into_scene()

	pet_introduced = true
	roomManager.queue_processing = false
	Global.add_visitor_to_array(_pet.resource.get_animal_type_name())

func show_pet_intro(pet_data):
	print("SHOW INTRO UI: ", get_instance_id())

	roomManager.switch_to_room(roomScene)

	var pet_details = {
		"image": pet_data.texture,
		"name": pet_data.name,
		"animal": pet_data.get_animal_type_name(),
		"days": int(stay_duration_hours / HOURS_PER_DAY),
		"hours": stay_duration_hours % HOURS_PER_DAY
	}

	pet_introduction_ui = petIntroductionUI.instantiate()
	get_tree().get_root().add_child.call_deferred(pet_introduction_ui)

	await pet_introduction_ui.ready
	pet_introduction_ui.set_pet_info(pet_details)
	
func close_existing_pet_ui():
	if is_instance_valid(pet_introduction_ui):
		pet_introduction_ui.queue_free()
		pet_introduction_ui = null

	if is_instance_valid(pet_outro_ui):
		pet_outro_ui.queue_free()
		pet_outro_ui = null

func show_pet_outro(pet_details):
	roomManager.switch_to_room(roomScene)
	pet_outro_ui = petOutroUI.instantiate()
	get_tree().get_root().add_child(pet_outro_ui)
	pet_outro_ui.set_pet_info(pet_details)
	await pet_outro_ui.tree_exited
	
	
func _stay_over():
	print("STAY OVER: Started")

	while roomManager.queue_processing:
		await get_tree().create_timer(0.1).timeout

	is_stay_over_processing = true
	print("STAY OVER: Started")

	while roomManager.queue_processing:
		print("STAY OVER: Waiting for room lock")
		await get_tree().create_timer(0.1).timeout

	roomManager.queue_processing = true
	print("STAY OVER: Queue locked")

	var pet_stay_details = get_pet_stay_details(
		current_guest_pet_resource
	)
	Global.reviewsInfo.append(pet_stay_details)
	print("STAY OVER: Details collected")

	await show_pet_outro(pet_stay_details)
	print("STAY OVER: Outro closed")

	await _pet.walk_out_of_scene()
	print("STAY OVER: Old pet walked out")

	pet_introduced = false
	roomManager.queue_processing = false

	print("STAY OVER: Introducing next guest")

	await introduce_guest_pet()

	print("STAY OVER: Next guest finished entering")
	is_stay_over_processing = false
	print("STAY OVER: Transition complete")

func get_pet_stay_details(pet_data):
	var average_stats = _pet.pet_stats.get_overall_average_stats()
	var star_rating = get_star_rating(average_stats)
	var review = evaluate_care(star_rating)
	var coin_amount = calculate_coins_reward(star_rating)
	
	var pet_details = {
		"image": pet_data.texture,
		"name": pet_data.name,
		"animal": pet_data.get_animal_type_name(),
		"days": int(stay_duration_hours / HOURS_PER_DAY),
		"hours": stay_duration_hours % HOURS_PER_DAY,
		"stats": round(average_stats),
		"review": review,
		"star_rating": star_rating,
		"coins": coin_amount
	}
	return pet_details
	
func evaluate_care(rating: int) -> String:
	var all_rating_reviews = reviews_data[str(rating)]
	return all_rating_reviews[randi() % all_rating_reviews.size()]

func get_star_rating(average_stats):
	# Get 1 star rating per 20% stat
	return int(average_stats/ 20) + 1
	
func calculate_coins_reward(star_rating):
	# Gain more or less coins based on star rating. Median is 3 stars.
	var precentage_per_star = 25
	var reward =  int(stay_duration_hours * (1 + (star_rating-3) * precentage_per_star/ 100))
	return reward
