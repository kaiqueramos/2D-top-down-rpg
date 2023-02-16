extends Node2D

var ghost_scene = preload("res://Scenes/dash_ghost.tscn")
var sprite : Sprite2D
var can_dash = true
var dash_delay

func start_dash(sprite : Sprite2D, duration, direction):
	self.sprite = sprite
	dash_delay = duration
	
	$DurationTimer.wait_time = duration
	$DurationTimer.start()
	$GhostTimer.start()
	
	instance_ghost()
	
	$DustTrail.restart()
	$DustTrail.emitting = true
	
	$DustBurst.rotation = (direction * -1).angle()
	$DustBurst.restart()
	$DustBurst.emitting = true
	

func instance_ghost():
	var ghost : Sprite2D = ghost_scene.instantiate()
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.texture = sprite.texture
	ghost.vframes = sprite.vframes
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.scale.x = sprite.scale.x
	ghost.scale.y = sprite.scale.y

func is_dashing():
	return !$DurationTimer.is_stopped()

func end_dash():
	$GhostTimer.stop()
	
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true
	

func _on_ghost_timer_timeout():
	instance_ghost()

func _on_duration_timer_timeout():
	end_dash()
