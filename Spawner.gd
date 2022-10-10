extends Enemy


class_name Spawner

const piece_type = preload("res://Hunter.tscn")
var MAX_STEPS = 3
var steps_left = MAX_STEPS

func spawn_piece():
	var tile = self.tile.get_neighbor_tile_at(Vector2.LEFT)
	if tile and self.steps_left == 0:
		var pos = tile.board_pos
		self.steps_left = self.MAX_STEPS
		return self.board.initialize_enemy(pos, self.piece_type)

	self.steps_left -= 1
	return null
