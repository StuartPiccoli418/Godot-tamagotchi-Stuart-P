extends Control

@onready var daysLabel = get_node("%DaysLabel")
@onready var hoursLabel = get_node("%HoursLabel")
@onready var minutesLabel = get_node("%MinutesLabel")
@onready var sprite = $Sprite2D
@onready var pet = get_tree().get_first_node_in_group("Pet")

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day:int, hour:int, minute:int)

var day: int
var hour: int
var minute: int

@export var INGAME_SPEED = 100.0
@export var INITIAL_HOUR = 12:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
var time = 0.0
var past_minute = -1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * INITIAL_HOUR * MINUTES_PER_HOUR
	pet.pet_actions.sleepingToggled.connect(sleep_toggled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	recalculate_time()

# func on_save_game(saved_data:Array[SavedData]):
	# var my_data = SavedTime.new()
	# my_data.time = time
	# saved_data.append(my_data)

# func on_load_game(saved_data:SavedData):
	# time = saved_data.time
		
func recalculate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	hour = int(current_day_minutes / MINUTES_PER_HOUR)
	minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if minute != past_minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)
		set_time()
		rotate_daytime_sprite(current_day_minutes)

func rotate_daytime_sprite(current_day_minutes):
	if current_day_minutes != 0:
		sprite.rotation_degrees = ((current_day_minutes / 360.0) * 90) + 160 # Temp # Set the rotation of the daytime sprite to the current minute, one day is one full rotation.
	
func set_time():
	daysLabel.text = 'Day'+ str(day+1)

	if minute <= 9 and hour <= 12:
				hoursLabel.text = str(hour) + ':' + "0" + str(minute) + 'PM'
				print(hour)
	if minute > 9 and hour <= 12:
				hoursLabel.text = str(hour) + ':' + str(minute) + 'PM'
				print(hour)
	if minute <= 9 and hour > 13:
				hoursLabel.text = str(hour) + ':' + "0" + str(minute) + 'AM'
				print(hour)
	if minute > 9 and hour > 13:
				hoursLabel.text = str(hour) + ':' + str(minute) + 'AM'
				print(hour)
			
func sleep_toggled(pet_state):
	if pet_state == Pet.PetState.SLEEPING:
		INGAME_SPEED = INGAME_SPEED * 2
	else:
		INGAME_SPEED = INGAME_SPEED / 2
