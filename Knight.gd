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

func init(_tile, color):
	self.tile = _tile
	$Sprite.modulate = color
	$Particles2D.emitting = false

	return self

# func _ready():
# 	if self.tile:
# 		self.tile.consume_tile()

func move_to_tile(tile):
	$Tween.interpolate_property(self, "position", self.position, tile.position, 0.3)
	$Tween.start()

func set_tile(_tile):
	self.tile = _tile
	self.tile.consume_tile()

func set_active(active):
	$Particles2D.emitting = active

func can_move(from, to):
	for move in self.moves:
		if from + move == to:
			return true

	return false
