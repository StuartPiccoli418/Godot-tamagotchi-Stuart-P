extends CanvasLayer

@onready var buttons_ui = get_tree().get_first_node_in_group("ButtonsUI")
@onready var anim_player = $AnimationPlayer

@onready var desktopPage = $ComputerPanel/Desktop
@onready var foodShopPage = $ComputerPanel/FoodShop
@onready var statsViewPage = $ComputerPanel/StatsView
@onready var ReviewsViewPage = $ComputerPanel/ReviewsView
@onready var backButton = $ComputerPanel/ComputerButtons/BackButton
@onready var roomExpandPage = $ComputerPanel/RoomExpandShop
var computer_active = false

@onready var pages = [desktopPage, foodShopPage, statsViewPage, ReviewsViewPage]
@onready var current_page: Control = desktopPage
# Called when the node enters the scene tree for the first time.
func _ready():
	buttons_ui.openComputer.connect(open_computer)
	backButton.visible = false
	
func open_computer():
	get_tree().paused = true
	self.visible = true
	anim_player.play("ZoomIn")

func _on_power_button_pressed():
	anim_player.play("ZoomOut")
	get_tree().paused = false
	await anim_player.animation_finished
	self.visible = false
	
# Switch Scene Page
func switch_page(page_to_show):
	page_to_show.visible = true
	if page_to_show.get("anim_player"):
		page_to_show.anim_player.play("ZoomIn")
		await page_to_show.anim_player.animation_finished
	if current_page.get("anim_player"):
		current_page.anim_player.play("ZoomOut")
		await current_page.anim_player.animation_finished
	backButton.visible = (page_to_show != desktopPage)
	current_page.visible = false
	current_page = page_to_show
		
func _on_shop_button_pressed():
	switch_page(foodShopPage)

func _on_back_button_pressed():
	switch_page(desktopPage)

func _on_stats_button_pressed():
	switch_page(statsViewPage)
	statsViewPage.update()

func _on_reviews_button_pressed():
	switch_page(ReviewsViewPage)
	ReviewsViewPage.update()

func _on_rooms_button_pressed():
	switch_page(roomExpandPage)
	roomExpandPage.update()
