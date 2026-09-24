extends Control

@onready var happinessBar = get_node("%HappinessBar")
@onready var hungerBar = get_node("%HungerBar")
@onready var hygieneBar = get_node("%HygieneBar")
@onready var funBar = get_node("%FunBar")
@onready var socialBar = get_node("%SocialBar")
@onready var tirednessBar = get_node("%TirednessBar")

# Debug
@onready var statsTotalLabel = get_node("%StatsTotal")
@onready var statsAverageLabel = get_node("%StatsAverage")

@onready var labelHappiness = get_node("%BarLabelHappiness")
@onready var labelHunger = get_node("%BarLabelHunger")
@onready var labelHygiene = get_node("%BarLabelHygiene")
@onready var labelFun = get_node("%BarLabelFun")
@onready var labelSocial = get_node("%BarLabelSocial")
@onready var labelTiredness = get_node("%BarLabelTiredness")

var pet: Node = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var room_manager = get_parent().get_node("RoomManager")
	room_manager.ActivePetChanged.connect(update_pet)
	if pet:
		await pet.ready
		connect_pet_signals()
		update()


func update_pet(new_pet: Node):
	if pet:
		disconnect_pet_signals()
	pet = new_pet
	connect_pet_signals()
	update()

func connect_pet_signals():
	pet.pet_stats.hungerChanged.connect(update_hunger)
	pet.pet_stats.happinessChanged.connect(update_happiness)
	pet.pet_stats.hygieneChanged.connect(update_hygiene)
	pet.pet_stats.funChanged.connect(update_fun)
	pet.pet_stats.socialChanged.connect(update_social)
	pet.pet_stats.tirednessChanged.connect(update_tiredness)
	pet.pet_stats.totalStatsChanged.connect(update_stats_total)

func disconnect_pet_signals():
	pet.pet_stats.hungerChanged.disconnect(update_hunger)
	pet.pet_stats.happinessChanged.disconnect(update_happiness)
	pet.pet_stats.hygieneChanged.disconnect(update_hygiene)
	pet.pet_stats.funChanged.disconnect(update_fun)
	pet.pet_stats.socialChanged.disconnect(update_social)
	pet.pet_stats.tirednessChanged.disconnect(update_tiredness)
	pet.pet_stats.totalStatsChanged.disconnect(update_stats_total)
	
func update():
	update_hunger(pet.pet_stats.hunger)
	update_happiness(pet.pet_stats.happiness)
	update_hygiene(pet.pet_stats.hygiene)
	update_fun(pet.pet_stats.fun)
	update_social(pet.pet_stats.social)
	update_tiredness(pet.pet_stats.tiredness)
	update_stats_total(pet.pet_stats.total_stats)
	
func update_hunger(value):
	hungerBar.value = max(1, value)
	labelHunger.text = str(value) + '%'
	
func update_happiness(value):
	happinessBar.value = max(1, value)
	labelHappiness.text = str(value) + '%'
	
func update_hygiene(value):
	hygieneBar.value = max(1, value)
	labelHygiene.text = str(value) + '%'
	
func update_fun(value):
	funBar.value = max(1, value)
	labelFun.text = str(value) + '%'
	
func update_social(value):
	socialBar.value = max(1, value)
	labelSocial.text = str(value) + '%'
	
func update_tiredness(value):
	tirednessBar.value = max(1, value)
	labelTiredness.text = str(value) + '%'
	
func update_stats_total(value):
	statsTotalLabel.text = 'total:' + str(value)
	update_stats_average(value)
	
func update_stats_average(value):
	statsAverageLabel.text = 'average:' + str(value / 6)
