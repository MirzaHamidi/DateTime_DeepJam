extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const MAX_PITCH_RAD: float = deg_to_rad(80.0)
const BIKE_VISIBILITY_THRESHOLD: float = 0.5
const POSITION_CHANGE_THRESHOLD: float = 0.001
const DEBUG_UPDATE_INTERVAL: int = 60

# Signal'ler
signal bike_interaction_changed(can_interact: bool)

@onready var cam: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $"Treadmill Running/AnimationPlayer"

# Bike referansı
@export var bike: Node3D = null
var bike_is_child: bool = false

# Bisiklet etkileşim ayarları
@export var bike_interact_distance: float = 1.5
var can_interact_with_bike: bool = false

# Bisiklete binince bisikletin rotasyon ayarları
@export_group("Bisiklet Rotasyon Ayarları")
@export var bike_offset_rotation: Vector3 = Vector3.ZERO

# Mouse look
@export var mouse_sensitivity: float = 0.002
var yaw: float = 0.0
var pitch: float = 0.0

# Kamera shake ayarları
@export var shake_base_amount: float = 0.002
@export var shake_max_amount: float = 0.002
@export var shake_speed: float = 9.0
@export var max_tilt_degrees: float = 1.0
@export var max_shake_speed: float = 9.0

var _shake_time: float = 0.0
var _bike_rotation_rad: Vector3  # Cache'lenmiş rotasyon (radyana çevrilmiş)

func _toggle_collisions(bike_node: Node, disabled: bool) -> void:
	for child in bike_node.get_children():
		if child is CollisionShape3D:
			child.disabled = disabled
		elif child is CollisionObject3D and child.has_method("set_disabled"):
			child.set_disabled(disabled)
		_toggle_collisions(child, disabled)

func _find_bike_in_scene(node: Node) -> Node3D:
	if node.name.to_lower() == "bike" and node is Node3D:
		return node as Node3D
	for child in node.get_children():
		var result = _find_bike_in_scene(child)
		if result:
			return result
	return null

func _ready() -> void:
	if cam:
		cam.fov = 130.0
	yaw = rotation.y
	pitch = cam.rotation.x
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if bike == null:
		bike = get_node_or_null("../bike")
		if bike == null:
			var scene_root = get_tree().current_scene
			if scene_root:
				bike = scene_root.get_node_or_null("bike")
				if bike == null:
					bike = _find_bike_in_scene(scene_root)
	
	if bike:
		bike_is_child = (bike.get_parent() == self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
		return
	
	if Input.is_action_just_pressed("Interact"):
		if bike_is_child or (can_interact_with_bike and bike != null):
			_toggle_bike_attachment()
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -MAX_PITCH_RAD, MAX_PITCH_RAD)

func _physics_process(delta: float) -> void:
	rotation.y = yaw
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	
	if not bike_is_child:
		_check_bike_interaction()
	
	_update_camera_shake(delta)

func _set_running(is_running: bool) -> void:
	if anim_player == null:
		return
	
	if is_running:
		if anim_player.current_animation != "Treadmill Running":
			anim_player.play("mixamo_com")
	else:
		anim_player.stop()

func _update_camera_shake(delta: float) -> void:
	if cam == null:
		return
	
	_shake_time += delta * shake_speed
	var speed: float = velocity.length()
	var factor: float = clamp(speed / max_shake_speed, 0.0, 0.5)
	var current_shake: float = lerp(shake_base_amount, shake_max_amount, factor)
	
	cam.rotation.x = pitch + sin(_shake_time * 1.2) * current_shake
	cam.rotation.y = 0.0
	cam.rotation.z = sin(_shake_time * 0.9) * deg_to_rad(max_tilt_degrees) * factor

func _check_bike_interaction() -> void:
	if bike == null or cam == null:
		can_interact_with_bike = false
		return
	
	var distance_to_bike = global_position.distance_to(bike.global_position)
	if distance_to_bike > bike_interact_distance:
		can_interact_with_bike = false
		return
	
	var camera_forward = -cam.global_transform.basis.z
	var to_bike = (bike.global_position - cam.global_position)
	var distance_sq = to_bike.length_squared()
	
	if distance_sq > 0.0:
		to_bike = to_bike / sqrt(distance_sq)  # normalize() yerine manuel (daha hızlı)
		var dot_product = camera_forward.dot(to_bike)
		var previous_state = can_interact_with_bike
		can_interact_with_bike = dot_product > BIKE_VISIBILITY_THRESHOLD
		
		if previous_state != can_interact_with_bike:
			bike_interaction_changed.emit(can_interact_with_bike)
	else:
		can_interact_with_bike = false

func _toggle_bike_attachment() -> void:
	if bike == null:
		return
	
	if bike_is_child:
		# Bisikletten in
		var main_scene = get_tree().current_scene
		var bike_global_pos = bike.global_position
		var bike_global_rotation = bike.global_rotation
		var bike_current_scale = bike.scale
		
		remove_child(bike)
		main_scene.add_child(bike)
		bike.global_position = bike_global_pos
		bike.global_rotation = bike_global_rotation
		bike.scale = bike_current_scale
		_toggle_collisions(bike, false)
		bike_is_child = false
	else:
		# Bisiklete bin
		var main_scene = get_tree().current_scene
		var bike_global_pos = bike.global_position
		var bike_current_scale = bike.scale
		
		global_position = bike_global_pos
		
		# Yere indir
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			global_position + Vector3(0, 1, 0),
			global_position + Vector3(0, -10, 0)
		)
		query.exclude = [self.get_rid()]
		var result = space_state.intersect_ray(query)
		global_position.y = result.get("position", Vector3()).y + 0.5 if result else bike_global_pos.y
		
		velocity = Vector3.ZERO
		main_scene.remove_child(bike)
		add_child(bike)
		
		# Rotasyonu cache'le ve uygula
		_bike_rotation_rad = Vector3(
			deg_to_rad(bike_offset_rotation.x),
			deg_to_rad(bike_offset_rotation.y - 90),
			deg_to_rad(bike_offset_rotation.z)
		)
		bike.position = Vector3(0, -1, 0.3)
		bike.rotation = _bike_rotation_rad
		bike.scale = bike_current_scale
		_toggle_collisions(bike, true)
		bike_is_child = true
