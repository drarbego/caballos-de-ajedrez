extends Node2D

class_name Piece


var tile = null
var consumes_tiles = true
export var moves := [Vector2.ZERO]

func init(_tile,  _consumes_tiles):
	self.tile = _tile
	$Particles2D.emitting = false
	self.consumes_tiles = _consumes_tiles

	return self

func move_to_tile(new_tile):
	$Tween.interpolate_property(self, "position", self.position, new_tile.position, 0.3)
	$Tween.start()

func set_tile(_tile):
	self.tile = _tile
	if self.consumes_tiles:
		self.tile.consume_tile()

func set_active(active):
	$Particles2D.emitting = active
	var animation_name = "active" if active else "idle"
	self.play_animation(animation_name)

func can_move(from, to):
	for move in self.moves:
		if from + move == to:
			return true

	return false

func play_animation(animation_name: String):
	pass
