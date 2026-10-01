extends Control

@onready var reviewContainer = $ScrollContainer/ReviewsContainer
@onready var anim_player = $AnimationPlayer
@onready var reviewThumbnail = preload("res://source/ui/review_thumbnail.tscn")
@onready var noReviewsLabel = $ScrollContainer/ReviewsContainer/Label

@onready var review_thumbnails: Array = []
var reviews: Array
var REVIEW_THUMBNAIL_NAME = 'ReviewThumbnail'
var REVIEW_CONTAINER_PATH = "ScrollContainer/ReviewsContainer"

# Called when the node enters the scene tree for the first time.
func _ready():
	update()

func update():
	if (reviews == Global.reviewsInfo):
		return
	reviews = Global.reviewsInfo
	check_for_new_reviews()
	noReviewsLabel.visible = reviews.size() == 0
	
func check_for_new_reviews():
	for review in reviews:
		var review_index = reviews.find(review)
		if !get_review_thumbnail_node(review_index):
			create_review_thumbnail(review, review_index)

func get_review_thumbnail_node(review_index):
	var node_name = REVIEW_THUMBNAIL_NAME + str(review_index)
	var node_path = REVIEW_CONTAINER_PATH + node_name
	if has_node(node_path):
		return get_node(node_path)
	else:
		return null
		
func create_review_thumbnail(review, num):
	var review_thumbnail = reviewThumbnail.instantiate()
	review_thumbnail.name = REVIEW_THUMBNAIL_NAME + str(num)
	reviewContainer.add_child(review_thumbnail)
	review_thumbnail.update(review)
	review_thumbnails.append(review_thumbnail)
