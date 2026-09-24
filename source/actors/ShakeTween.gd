extends Node

@onready var sprite = get_parent().get_node("Sprite2D")

var x_max = 5
var r_max = 5
const STOP_THERSHOLD = 0.1
const TWEEN_DURATION = 0.05
const RECOVERY_FACTOR = 2.0/3
const TRANSITION_TYPE = Tween.TRANS_SINE

signal tween_completed


func start():
	var x = x_max
	var r = r_max
	while x > STOP_THERSHOLD:
		
		# left
		var tween = _tilt_left(x, r)
		await tween.finished
		x *= RECOVERY_FACTOR
		r *= RECOVERY_FACTOR
		
		_recenter()
		
		# right
		tween = _tilt_right(x, r)
		await tween.finished
		x *= RECOVERY_FACTOR
		r *= RECOVERY_FACTOR
		
		_recenter()
	emit_signal("tween_completed")
	
func _tilt_left(x, r):
	var tween = get_tree().create_tween()
	#position
	tween.tween_property(sprite, "position:x", -x, TWEEN_DURATION)
	#rotation
	r = r
	tween.tween_property(sprite, "rotation_degrees", r, TWEEN_DURATION)
	return tween
	
func _tilt_right(x, r):
	var tween = get_tree().create_tween()
	#position
	tween.tween_property(sprite, "position:x", x, TWEEN_DURATION)
	#rotation
	r = -r
	tween.tween_property(sprite, "rotation_degrees", r, TWEEN_DURATION)
	return tween
	
func _recenter():
	var tween = get_tree().create_tween()
	#position
	var host_x = sprite.position.x
	tween.tween_property(sprite, "position:x", host_x, TWEEN_DURATION)
	#rotation
	var host_r = sprite.rotation_degrees
	tween.tween_property(sprite, "rotation_degrees", host_r, TWEEN_DURATION)
	return tween
	
