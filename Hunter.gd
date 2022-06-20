extends Enemy

func on_clash(_piece):
	if self.tile:
		self.tile.set_piece(null)
	self.queue_free()
