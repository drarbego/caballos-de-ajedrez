extends Node2D


var tile = null

var moves = [
	Vector2(2, 1),
	Vector2(1, 2),
	Vector2(-2, 1),
	Vector2(-1, 2),
	Vector2(2, -1),
	Vector2(1, -2),
	Vector2(-2, -1),
	Vector2(-1, -2),
]

func set_tile(_tile):
	self.tile = _tile

func can_move(from, to):
	for move in self.moves:
		if from + move == to:
			return true

	return false
