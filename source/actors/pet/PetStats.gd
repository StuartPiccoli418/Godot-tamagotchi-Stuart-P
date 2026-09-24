extends Node

class_name PetStats

@onready var pet = get_parent()

signal hungerChanged(value)
signal happinessChanged(value)
signal hygieneChanged(value)
signal funChanged(value)
signal socialChanged(value)
signal tirednessChanged(value)
signal totalStatsChanged(value)

# Stats
var MAX_STAT = 100

var stats = ['happiness', 'hunger', 'hygiene', 'fun', 'social', 'tiredness']
@export var happiness: int = 40:
	set(new_value):
		happiness = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('happinessChanged', happiness)
		
@export var hunger: int = 50:
	set(new_value):
		hunger = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('hungerChanged', hunger)
		
@export var hygiene: int = 80:
	set(new_value):
		hygiene = clamp(new_value, 0, (MAX_STAT - min((pet.pet_actions.poop_counter * 10), MAX_STAT))) # Clamp hygiene from 0 to 100, but if there is poop, dont go higher than max  * poops * 10, also make sure it cant go below 0.
		update_total_stats()
		emit_signal('hygieneChanged', hygiene)
		
@export var fun: int = 40:
	set(new_value):
		fun = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('funChanged', fun)

@export var social: int = 40:
	set(new_value):
		social = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('socialChanged', social)
		
@export var tiredness: int = 40:
	set(new_value):
		tiredness = clamp(new_value, 0, MAX_STAT)
		update_total_stats()
		emit_signal('tirednessChanged', tiredness)
		
@export var total_stats: int:
	set(new_value):
		total_stats = new_value
		emit_signal('totalStatsChanged', total_stats)

var average_stats : int
var cumulative_avg_stats = 0.0
var update_stats_count = 0

func update_total_stats():
	total_stats = happiness + (MAX_STAT - hunger) + hygiene + fun + social + (MAX_STAT - tiredness) # minus 100 hunger and tiredness because they are negative.
	average_stats = round(total_stats / stats.size())
	
	cumulative_avg_stats += average_stats
	update_stats_count += 1
	
func get_overall_average_stats() -> float:
	if update_stats_count == 0:
		return 0
	return cumulative_avg_stats / update_stats_count

func reset_stats():
	reset_average_stat_tracking()
	reset_and_randomize_stats()
	
func reset_average_stat_tracking():
	cumulative_avg_stats = 0.0
	update_stats_count = 0
	# Update after reset to get a first snapshot
	update_total_stats()
	
func reset_and_randomize_stats():
	happiness = randi_range(1,8) * 2
	hunger = MAX_STAT - randi_range(1,8) * 2
	hygiene = randi_range(1,8) * 2
	fun = randi_range(1,8) * 2
	social = randi_range(1,8) * 2
	tiredness = MAX_STAT - randi_range(1,8) * 2
		
