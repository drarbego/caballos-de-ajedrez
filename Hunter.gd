extends Enemy

func on_clash(_piece):
    self.queue_free()
