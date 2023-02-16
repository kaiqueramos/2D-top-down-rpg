extends Control

@onready var life_bar_progress = $MarginContainer/VBoxContainer/LifeBar/LifeBarProgress
@onready var stamina_bar_progress = $MarginContainer/VBoxContainer/StaminaBar/StaminaBarProgress

func _ready():
	life_bar_progress.value = Global.player_life
	stamina_bar_progress.value = Global.player_stamina

func update_life(amount):
	life_bar_progress.value += amount
	Global.

func update_stamina(amount):
	stamina_bar_progress.value += amount

func _on_player_life_damage(amount):
	update_life(-amount)
