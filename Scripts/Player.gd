extends Node2D

@export var move_speed = 200.0
@export var life = 5
@export var damage = 1
@export var dash_force = 1000.0
var player_dead = false
var motion = Vector2()
var can_attack = true

func _ready():
	$Sprite2D/AttackArea/SideAttackCollision.disabled = true

func _physics_process(delta):
	
#	Aplicando movimentação ao personagem
	motion.x = Input.get_axis("left", "right") * move_speed * delta
	motion.y = Input.get_axis("up", "down") * move_speed * delta
	
	if Input.is_action_just_pressed("dash"):
		$Dash.start_dash($Sprite2D, 0.15, get_move_direction())

	move_speed = dash_force if $Dash.is_dashing() else 200.0
	
#	Funções primordiais
	attack()
	flip()
	animate()
	
#	Aplico movimento ao player.
#	Não existe uma física, pois é um jogo top down, então basta alterar a posição.
	if !Global.player_dead:
		position += motion
		position.normalized()
	
func get_move_direction():
	return Vector2(
		int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
		int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	)

func flip():
#	Mudo a direção do personagem baseado no motion.x
	if motion && !Global.player_dead:
		if motion.x > 0:
			$Sprite2D.flip_h = false
			$Sprite2D/AttackArea/SideAttackCollision.position.x = abs($Sprite2D/AttackArea/SideAttackCollision.position.x)
		else:
			$Sprite2D.flip_h = true
			if $Sprite2D/AttackArea/SideAttackCollision.position.x > 0:
					$Sprite2D/AttackArea/SideAttackCollision.position.x = -$Sprite2D/AttackArea/SideAttackCollision.position.x

func animate():
#	Inverto o motion.y pois o mesmo é invertido nesse contexto
#	Só posso mudá-lo agora, pois a variável fica no contexto da função
	var normalized_motion = motion
	normalized_motion.y = -normalized_motion.y
	
#	Passo para a animação de blend position a minha posição já editada, para que a animação adequada seja aplicada
	$AnimationTree.set("parameters/Movement/blend_position", normalized_motion)

func attack():
	var move_direction = get_move_direction()
#	Verifico se o botão de ataque está pressionado e se posso atacar
	if Input.is_action_just_pressed("attack") && can_attack:
		var direction
		
		if move_direction == Vector2.ZERO:
			direction = get_global_mouse_position()
			
			var diff = direction - position
			if abs(diff.x) > abs(diff.y):
				if diff.x > 0:
					$AnimationTree.set("parameters/OneShotSideAttack/request", true)
					$Sprite2D.flip_h = false
					$Sprite2D/AttackArea/SideAttackCollision.position.x = abs($Sprite2D/AttackArea/SideAttackCollision.position.x)
					$SwordSlash.start_slash_right()
					
				else:
					$Sprite2D.flip_h = true
					$AnimationTree.set("parameters/OneShotSideAttack/request", true)
					$SwordSlash.start_slash_left()
					if $Sprite2D/AttackArea/SideAttackCollision.position.x > 0:
						$Sprite2D/AttackArea/SideAttackCollision.position.x = -$Sprite2D/AttackArea/SideAttackCollision.position.x
			else:
				if diff.y > 0:
					$AnimationTree.set("parameters/OneShotDownAttack/request", true)
					$SwordSlash.start_slash_down()
				else:
					$AnimationTree.set("parameters/OneShotUpAttack/request", true)
					$SwordSlash.start_slash_up()
		else:
			direction = move_direction
			if direction.x > direction.y:
				if direction.x > 0:
					$AnimationTree.set("parameters/OneShotSideAttack/request", true)
					$Sprite2D.flip_h = false
					$Sprite2D/AttackArea/SideAttackCollision.position.x = abs($Sprite2D/AttackArea/SideAttackCollision.position.x)
					$SwordSlash.start_slash_right()
				else:
					$AnimationTree.set("parameters/OneShotUpAttack/request", true)
					$SwordSlash.start_slash_up()
			else:
				if direction.y > 0:
					$AnimationTree.set("parameters/OneShotDownAttack/request", true)
					$SwordSlash.start_slash_down()
				else:
					$Sprite2D.flip_h = true
					$AnimationTree.set("parameters/OneShotSideAttack/request", true)
					$SwordSlash.start_slash_left()
					if $Sprite2D/AttackArea/SideAttackCollision.position.x > 0:
						$Sprite2D/AttackArea/SideAttackCollision.position.x = -$Sprite2D/AttackArea/SideAttackCollision.position.x
#	Verifico se existe alguma animação de ataque acontecendo no momento
	if $AnimationTree.get("parameters/OneShotDownAttack/active") || $AnimationTree.get("parameters/OneShotUpAttack/active") || $AnimationTree.get("parameters/OneShotSideAttack/active"):
#		Se houver, não deixo o personagem se mover
		motion = Vector2()
#		E não deixo atacar novamente
		can_attack = false
	
#	Se não houver, tudo ocorre normalmente
	else:
		can_attack = true
	
func take_damage(min, max, mob : CharacterBody2D):
	var damage = randi_range(min, max)
	life -= damage
	
	if life > 0:
		var player_motion = position.direction_to(mob.position) * 2000 * get_physics_process_delta_time()
		position -= player_motion
		
		$Sprite2D.material.set_shader_parameter("flash_modifier", 0.7)
		$Sprite2D.material.set_shader_parameter("flash_color", Color("a84e24"))
		
		var damage_timer = Timer.new()
		damage_timer.wait_time = 0.25
		damage_timer.one_shot = true
		
		add_child(damage_timer)
		damage_timer.start()
		
		damage_timer.connect("timeout", _on_damage_timer_timeout)
	else:
		die()
	
func die():
	$AnimationTree.set("parameters/DeathTransition/transition_request", "Death")
	Global.player_dead = true
	
func _on_attack_area_body_entered(body):
	if body.is_in_group("mob") && can_attack:
		body.take_damage()
		
func _on_damage_timer_timeout():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

