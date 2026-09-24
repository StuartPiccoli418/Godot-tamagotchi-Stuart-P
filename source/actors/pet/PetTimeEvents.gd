extends Node

@onready var pet = get_parent()
@onready var timeUI = get_tree().get_first_node_in_group("TimeUI")

# Stats interval before change, set in in-game minutes
const HUNGER_INTERVAL = 10
const HAPPINESS_INTERVAL = 15
const HYGINE_INTERVAL = 20
const FUN_INTERVAL = 10
const SOCIAL_INTERVAL = 20
const TIRED_INTERVAL = 30
const POOP_INTERVAL = 30
const XP_GAIN_INTERVAL = 10

func _ready():
	timeUI.time_tick.connect(process_time_events)

func process_time_events(_day, _hour, minute):
	if pet.state == pet.PetState.SLEEPING:
		pet.pet_stats.tiredness -= 1
		pet.pet_actions.reaction_popup('sick')
		if pet.pet_stats.tiredness == 0:
			pet.pet_actions.toggle_sleep()
	if minute % HUNGER_INTERVAL == 0:
		pet.pet_stats.hunger += 5
		pet.pet_actions.feed_counter -= 1
	if minute % HAPPINESS_INTERVAL == 0:
		pet.pet_stats.happiness -= 10
		pet.pet_actions.pet_counter -= 1
	if minute % int(max(HYGINE_INTERVAL - (HYGINE_INTERVAL * pet.pet_actions.poop_counter * 0.2), 5)) == 0: # Make hygiene interval shorter by 20% for each poop, dont go below max value (5)
		pet.pet_stats.hygiene -= 5
	if minute % FUN_INTERVAL == 0:
		pet.pet_stats.fun -= 5
	if minute % SOCIAL_INTERVAL == 0:
		pet.pet_stats.social -= 5
	if minute % TIRED_INTERVAL == 0 and pet.state != pet.PetState.SLEEPING:
		pet.pet_stats.tiredness += 10
	if minute % POOP_INTERVAL == 0:
		pet.pet_actions.random_poop_chance()
	if minute % XP_GAIN_INTERVAL == 0:
		pet.gain_xp_based_on_stats(pet.pet_stats.average_stats)
