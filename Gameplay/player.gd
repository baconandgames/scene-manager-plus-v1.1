class_name Player extends CharacterBody2D

## Sample player controller - only included to demonstrate SceneManager. There's no logic here you need to review
## unless you're building something very similar to the sample project :)

@export var input_enabled:bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var move_dir:Vector2

const SPEED = 100.0

func _physics_process(_delta: float) -> void:
	if not input_enabled:
		return 
		
	move_dir = Vector2(Input.get_axis("ui_left", "ui_right"),Input.get_axis("ui_up", "ui_down"))
	orient(move_dir)
		
	if move_dir != Vector2.ZERO:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	
	if move_dir != Vector2.ZERO:
		var diagonal_dampening:float = 1
		if velocity.x != 0 and velocity.y != 0:
			diagonal_dampening = .7
		velocity.x = move_dir.x * SPEED * diagonal_dampening
		velocity.y = move_dir.y * SPEED * diagonal_dampening
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func orient(dir:Vector2) -> void:
	if dir.x:
		sprite.flip_h = dir.x < 0

func disable():
	input_enabled = false
	animation_player.play("idle")
	
func enable():
	input_enabled = true
	visible = true
