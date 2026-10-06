extends Node

class_name PetActions

@onready var pet = get_parent()
@onready var itemScene = preload("res://source/objects/itemScene.tscn")
@onready var reactionScene = preload("res://source/utility/reaction.tscn")
@onready var poopItem = preload("res://source/objects/poop.tscn")

@onready var inventoryUI = get_tree().get_first_node_in_group("InventoryUI")

# Counters
var feed_counter = 0
var pet_counter = 0
var poop_counter = 0

# counter limits
var feed_limit = 4
var pet_limit = 15

signal sleepingToggled(sleeping)
signal itemConsumed(item)

func _ready():
	inventoryUI.foodSelected.connect(feed)
	

func pet_action(action):
	if pet.state == pet.PetState.SLEEPING:
		if action == "sleep":
			toggle_sleep()
		return
	if pet.state != pet.PetState.IDLE:
		print('pet not idle')
		return
	match action:
		"feed":
			#feed()
			pass
		"love":
			petting()
		"clean":
			clean()
		"fun":
			play()
		"social":
			socialize()
		"sleep":
			toggle_sleep()

func feed(food_item):
	if pet.state in [pet.PetState.WALKING, pet.PetState.EATING]:
		print('pet cant eat now')
		return
	var food = spawn_food(food_item)
	pet.state = pet.PetState.EATING
	pet.anim_player.play("Eating")
	await pet.anim_player.animation_finished
	pet.state = pet.PetState.IDLE
	food.queue_free()
	random_poop_chance()
	emit_signal("itemConsumed", food_item)
	handle_food_reaction()
	
func spawn_food(food_item):
	var food = itemScene.instantiate()
	food.item = food_item
	pet.get_parent().add_child(food)
	food.position = Vector2(pet.global_position.x - 35, 340)
	food.bobble_anim()
	return food

func handle_food_reaction():
	feed_counter += 1
	if feed_counter > feed_limit or pet.pet_stats.hunger == 0:
		print('feed counter 4: puke')
		pet.pet_stats.happiness -= 15
		pet.pet_stats.tiredness -= 10
		reaction_popup('sad')
		return
	if feed_counter == feed_limit or pet.pet_stats.hunger < 10:
		reaction_popup('sick')
		pet.pet_stats.hunger -= 10
		pet.pet_stats.happiness -= 5
		pet.pet_stats.tiredness -= 5
		return
	reaction_popup('happy')
	pet.pet_stats.hunger += 25
	pet.pet_stats.happiness += 5
	pet.gain_experience(2)
	
func petting():
	pet_counter += 1
	if pet_counter > pet_limit:
		print('dont want pets now')
		reaction_popup('sick')
		pet.pet_stats.happiness -=5
		return
	if pet_counter == pet_limit:
		reaction_popup('sick')
		print('enough pets')
		pet.pet_stats.happiness +=3
		return
	reaction_popup('love')
	pet.pet_stats.happiness += 15
	pet.gain_experience(2)
	
func clean():
	if pet.pet_stats.hygiene > 90:
		pet.pet_stats.fun -= 10
		pet.pet_stats.happiness -= 5
	elif pet.pet_stats.hygiene > 70:
		pet.pet_stats.fun -= 5
	elif pet.pet_stats.hygiene < 30:
		pet.pet_stats.happiness += 5
	pet.pet_stats.hygiene += 10
	pet.gain_experience(1)

func play():
	pet.pet_stats.fun += 10
	pet.pet_stats.tiredness -= 5
	pet.gain_experience(1)
	
func socialize():
	pet.pet_stats.social += 10
	pet.pet_stats.tiredness -= 5
	pet.gain_experience(1)

func toggle_sleep():
	if pet.state in [pet.PetState.WALKING, pet.PetState.EATING]:
		return
	if pet.state == pet.PetState.SLEEPING:
		pet.state = pet.PetState.IDLE
	else:
		pet.state = pet.PetState.SLEEPING
	emit_signal("sleepingToggled", pet.state)
	
func random_poop_chance():
	if randi_range(1,3 + poop_counter) == 1:
		spawn_poop()
		
func spawn_poop():
	pet.pet_stats.hygiene -= 20
	poop_counter += 1
	var poop = poopItem.instantiate()
	pet.get_parent().add_child(poop)
	poop.poop_removed.connect(poop_removed)
	poop.position = Vector2(pet.global_position.x + randf_range(-200, 200), 355)

func poop_removed():
	poop_counter -= 1
	pet.pet_stats.happiness += 10
	pet.pet_stats.hygiene += 10
	
func reaction_popup(reaction):
	var reaction_instance = reactionScene.instantiate()
	pet.get_parent().add_child(reaction_instance)
	reaction_instance.position = Vector2(pet.global_position.x + randf() * 20 , pet.global_position.y - randf_range(50, 80))
	reaction_instance.set_reaction(reaction)
