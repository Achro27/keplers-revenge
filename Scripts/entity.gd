extends RigidBody2D

@export var ID = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$Sprite2D.hframes = $Sprite2D.texture. set this up later
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.region_rect = Rect2i(0, ID * 64, 64, 64)
