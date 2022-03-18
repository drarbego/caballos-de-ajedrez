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

func move_to_tile(destination_tile):
	$Tween.interpolate_property(self, "position", self.position, destination_tile.position, 0.3)
	$Tween.start()

func set_tile(_tile):
	if self.tile:
		self.tile.consume_tile()

	self.tile = _tile

func can_move(from, to):
	for move in self.moves:
		if from + move == to:
			return true

	return false
