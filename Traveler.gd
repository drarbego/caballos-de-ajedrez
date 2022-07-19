extends PlayablePiece


func play_animation(animation_name: String):
    $AnimationPlayer.play(animation_name)

func on_clash(_piece):
    self.board.game_over()
