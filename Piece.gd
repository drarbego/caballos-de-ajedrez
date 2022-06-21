extends Node2D

class_name Piece


var tile = null
var consumes_tiles = true
var board = null
export var moves := [Vector2.ZERO]
export var move_time := 0.5
export var attacks = false

# state
var is_moving = false

func init(_board, _tile,  _consumes_tiles):
	self.board = _board
	self.tile = _tile
	$Particles2D.emitting = false
	self.consumes_tiles = _consumes_tiles

	return self

func move_to_tile(new_tile):
	self.is_moving = true
	$AnimationPlayer.play("walk")
	$Tween.interpolate_property(self, "position", self.position, new_tile.position, move_time)
	$Tween.interpolate_callback(self,  move_time, "stop_moving")
	$Tween.start()

func stop_moving():
	self.is_moving = false
	$AnimationPlayer.play("idle")

func set_tile(_tile):
	self.tile = _tile
	if self.consumes_tiles:
		self.tile.consume_tile()

func set_active(active):
	$Particles2D.emitting = active
	print("set active")

func can_move(to):
	if not self.tile:
		return false

	var from = self.tile.board_pos
	for move in self.moves:
		if from + move == to:
			return true

	return false

func on_clash(piece):
	pass
