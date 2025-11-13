extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

@onready var cam: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $"Treadmill Running/AnimationPlayer"

# Mouse look
@export var mouse_sensitivity: float = 0.002
var yaw: float = 0.0      # Karakterin Y ekseni rotasyonu (sağa/sola bakma)
var pitch: float = 0.0    # Kameranın X ekseni rotasyonu (yukarı/aşağı bakma)

# Kamera shake ayarları
@export var shake_base_amount: float = 0.003    # Dururken çok hafif titreme
@export var shake_max_amount: float = 0.03      # Koşarken max titreme
@export var shake_speed: float = 8.0
@export var max_tilt_degrees: float = 5.0       # Sağa sola yatma miktarı
@export var max_shake_speed: float = 7.0        # Bu hızda shake maksimum olsun

var _shake_time: float = 0.0

func _ready() -> void:
	if cam:
		cam.fov = 110.0  # Geniş açı (GoPro hissi)
	# Başlangıç rotasyonunu kaydet
	yaw = rotation.y
	pitch = cam.rotation.x
	# Mouse'u ekrana kilitliyoruz
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	# ESC -> mouse toggle
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		return

	# Mouse movement only when cursor is captured
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity

		var max_pitch_rad: float = deg_to_rad(80.0)
		pitch = clamp(pitch, -max_pitch_rad, max_pitch_rad)



func _physics_process(delta: float) -> void:
	# Karakterin rotasyonunu mouse ile kontrol et
	rotation.y = yaw

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Hareket (senin orijinal kodun)
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		_set_running(true)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
		_set_running(false)
		


	move_and_slide()
	

	_update_camera_shake(delta)

func _set_running(is_running: bool) -> void:
	if anim_player == null:
		return

	if is_running:
		# Zaten aynı animasyonu oynatıyorsa tekrar play demeyelim, patlama olmasın
		if anim_player.current_animation != "Treadmill Running":
			anim_player.play("mixamo_com")
	else:
		# Elinde idle animasyonu varsa buraya geçiş yapabilirsin:
		# anim_player.play("Idle")
		anim_player.stop()

func _update_camera_shake(delta: float) -> void:
	if cam == null:
		return

	_shake_time += delta * shake_speed

	# Oyuncu hızına göre shake yoğunluğu
	var speed: float = velocity.length()
	var factor: float = clamp(speed / max_shake_speed, 0.0, 0.5)

	# Dururken az, hızlandıkça artan titreme
	var current_shake: float = lerp(shake_base_amount, shake_max_amount, factor)

	# Hafif pitch titremesi (yukarı-aşağı)
	var shake_pitch: float = sin(_shake_time * 1.2) * current_shake
	# Sağa sola yatma (Z ekseni – roll)
	var tilt: float = sin(_shake_time * 0.9) * deg_to_rad(max_tilt_degrees) * factor

	# Mouse pitch + shake birleşimi
	cam.rotation.x = pitch + shake_pitch
	# Y eksenine dokunmuyoruz, bakış yönün bozulmasın
	cam.rotation.y = 0.0
	cam.rotation.z = tilt
