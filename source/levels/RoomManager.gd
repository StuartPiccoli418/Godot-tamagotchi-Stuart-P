extends Node

@onready var room_toggle_button = $Button
@onready var roomContainer = get_parent().get_node("RoomContainer")
@onready var roomScene = preload("res://source/levels/room.tscn")
# For checking if a pet is currently leaving or exiting its room, is there to avoid 2 animals entering or exiting at the same time. Used in PetGuestManager.
var queue_processing = false

var current_room: Node = null
var rooms: Array = []
var current_pet: Node = null

signal ActivePetChanged(pet)
func _ready():
	# Get all rooms inside the RoomContainer
	rooms = roomContainer.get_children()
	# Initially show the first room
	if rooms.size() > 0:
		switch_to_room(rooms[0])
	if rooms.size() >= 1:
		room_toggle_button.visible = false

func on_save_game(saved_data:Array[SavedData]):
	var my_data = SavedRoomInfo.new()
	my_data.current_room_index = rooms.find(current_room)
	my_data.total_rooms = rooms.size()
	for room in rooms:
		var pet_manager = room.get_node("GuestPetManager")
		var pet = room.get_node("Pet")
		my_data.pets_manager_info.append(pet_manager.get_pet_manager_save_data())
		my_data.pets_info.append(pet.get_pet_save_data())
	saved_data.append(my_data)

func on_before_load_game():
	pass

func on_load_game(saved_data:SavedData):
	while saved_data.total_rooms > rooms.size():
		add_room()
	
	for i in range(saved_data.pets_info.size()):
		var room = rooms[i]
		var pet_manager = room.get_node("GuestPetManager")
		var pet = room.get_node("Pet")
		pet_manager.update_to_save_data(saved_data.pets_manager_info[i])
		pet.update_to_save_data(saved_data.pets_info[i])
		
	
func switch_to_room(room: Node):
	if current_room:
		current_room.visible = false
	current_room = room
	current_room.visible = true
	update_active_pet()

func switch_to_room_by_index(index: int):
	if index >= 0 and index < rooms.size():
		switch_to_room(rooms[index])

func update_active_pet():
	if current_room:
		# Assuming each room has a child node named "Pet" representing the pet
		current_pet = current_room.get_node("Pet")
		ActivePetChanged.emit(current_pet)

func _on_button_pressed():
	var current_room_index = rooms.find(current_room)
	var next_room_index: int
	if current_room_index == rooms.size() - 1:
		next_room_index = 0
	else:
		next_room_index = current_room_index + 1
	switch_to_room_by_index(next_room_index)

func room_purchased():
	add_room()
	
func add_room():
	var room = roomScene.instantiate()
	room.name = 'Room' + str(rooms.size() + 1)
	rooms.append(room)
	roomContainer.add_child(room)
	if !room_toggle_button.visible:
		room_toggle_button.visible = true
