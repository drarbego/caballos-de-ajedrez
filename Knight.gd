extends PlayablePiece

func _ready():
    self.attacks = true

func on_clash(_piece):
    self.queue_free()

func play_animation(animation_name: String):
    $AnimationPlayer.play(animation_name)
