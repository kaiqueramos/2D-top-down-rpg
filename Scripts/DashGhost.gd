extends Sprite2D

var tween : Tween

func _ready():
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	material.set_shader_parameter("flash_modifier", 0.5)
	material.set_shader_parameter("flash_color", Color("ffffff"))
	
	tween.tween_callback(queue_free)
