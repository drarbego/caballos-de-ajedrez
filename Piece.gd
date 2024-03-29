extends Node2D
class_name Piece

var ActiveMaterial = preload("res://materials/active.tres")
var SelectableMaterial = preload("res://materials/selectable.tres")

var tile = null
var board = null
export var moves := [Vector2.ZERO]
export var move_time := 0.5
export var attacks = false
export var TYPE = ""

# state
var is_moving = false

func init(_board, _tile):
	self.board = _board
	self.tile = _tile
	$Particles2D.emitting = false

	return self

func move_to_tile(new_tile):
	self.is_moving = true
	$AnimationPlayer.play("walk")
	$Tween.interpolate_property(self, "position", self.position, new_tile.position, move_time)
	$Tween.interpolate_callback(self,  move_time, "stop_moving", new_tile)
	$Tween.start()

func stop_moving(new_tile):
	self.is_moving = false
	$AnimationPlayer.play("idle")

	for content in new_tile.get_node("Content").get_children():
		content.on_piece_landed(self)

func set_tile(_tile):
	self.tile = _tile

func set_active(active):
	$Particles2D.set_process_material(ActiveMaterial)
	$Particles2D.amount = 25
	$Particles2D.emitting = active

func set_selectable(selectable):
	$Particles2D.set_process_material(SelectableMaterial)
	$Particles2D.amount = 50
	$Particles2D.emitting = selectable

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
