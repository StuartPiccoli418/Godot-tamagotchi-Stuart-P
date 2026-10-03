extends Resource

class_name petResource

enum AnimalType { Monkey, Capybara, Sunflower }

@export var animal: AnimalType
@export var texture: Texture2D
@export var name: String = 'Jeff'

func get_animal_type_name():
	return AnimalType.keys()[animal]
