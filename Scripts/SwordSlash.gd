extends Node2D

func start_slash_right():
	$ParticleRight.restart()
	$ParticleRight.emitting = true

func start_slash_left():
	$ParticleLeft.restart()
	$ParticleLeft.emitting = true

func start_slash_up():
	$ParticleUp.restart()
	$ParticleUp.emitting = true
	
func start_slash_down():
	$ParticleDown.restart()
	$ParticleDown.emitting = true
