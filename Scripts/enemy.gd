extends CharacterBody2D

@export var attack_delay = 2.0
@export var move_speed = 100.0
@export var life = 2
@export var damage = 1
var motion = Vector2.ZERO
var player_to_follow : CharacterBody2D = null
var player_to_attack : CharacterBody2D = null
var can_move = true
var walk_animation_done = true

func _physics_process(delta):
	
	motion = Vector2.ZERO
	if player_to_follow && can_move && !Global.player_dead:
		motion = position.direction_to(player_to_follow.position) * move_speed * delta
	
	animation()
	flip()
	
	position += motion
	move_and_slide()
	
func animation():
	$AnimationTree.set("parameters/Movement/blend_position", motion)

func flip():
	if motion.x > 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
		
func attack():
	if !Global.player_dead:
		$AnimationTree.set("parameters/OneShotAttack/request", true)
		player_to_attack.take_damage(damage, damage, self)
	
func take_damage(min, max):
	$AnimationTree.set("parameters/OneShotHit/request", true)
	
	var damage = randi_range(min, max)
	life -= damage
	
	if life > 0:
		flash()
		motion = position.direction_to(player_to_follow.position) * 5000 * get_physics_process_delta_time()
		position -= motion
		move_and_slide()
	else:
		die()
	
func die():
	$AnimationTree.set("parameters/TransitionDeath/transition_request", "Death")
	
func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
	$FlashTimer.start()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_to_follow = body
	
func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_to_follow = null

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") && !Global.player_dead:
		can_move = false
		player_to_attack = body
		$AttackTimer.wait_time = attack_delay
		$AttackTimer.autostart = true
		$AttackTimer.start()
	
func _on_attack_area_body_exited(body):
	if body.is_in_group("player"):
		can_move = true
		$AttackTimer.stop()
		$AttackTimer.autostart = false
		
func _on_attack_timer_timeout():
	attack()

func _on_take_damage_area_area_entered(area):
	if area.is_in_group("player_damage_area"):
		take_damage(1, 1)

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()

func _on_flash_timer_timeout():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)
