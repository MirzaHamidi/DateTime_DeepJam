extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

# Signal'ler
signal bike_interaction_changed(can_interact: bool)  # Bisiklet etkileşimi değiştiğinde

@onready var cam: Camera3D = $Camera3D
@onready var anim_player: AnimationPlayer = $"Treadmill Running/AnimationPlayer"

# Bike referansı
@export var bike: Node3D = null  # Inspector'dan manuel olarak atanabilir
var bike_is_child: bool = false

# Bisiklet etkileşim ayarları
@export var bike_interact_distance: float = 1.5  # Bisiklete binme mesafesi (metre)
var can_interact_with_bike: bool = false  # Bisiklet görülebilir ve yakın mı?

# Mouse look
@export var mouse_sensitivity: float = 0.002
var yaw: float = 0.0      # Karakterin Y ekseni rotasyonu (sağa/sola bakma)
var pitch: float = 0.0    # Kameranın X ekseni rotasyonu (yukarı/aşağı bakma)

# Kamera shake ayarları
@export var shake_base_amount: float = 0.002    # Dururken çok hafif titreme
@export var shake_max_amount: float = 0.002      # Koşarken max titreme
@export var shake_speed: float = 9.0
@export var max_tilt_degrees: float = 1.0       # Sağa sola yatma miktarı
@export var max_shake_speed: float = 9.0        # Bu hızda shake maksimum olsun

var _shake_time: float = 0.0

func _find_bike_in_scene(node: Node) -> Node3D:
	# Recursive olarak "bike" adında node ara
	if node.name.to_lower() == "bike" and node is Node3D:
		return node as Node3D
	
	for child in node.get_children():
		var result = _find_bike_in_scene(child)
		if result:
			return result
	
	return null

func _ready() -> void:
	if cam:
		cam.fov = 130.0  # Geniş açı (GoPro hissi)
	# Başlangıç rotasyonunu kaydet
	yaw = rotation.y
	pitch = cam.rotation.x
	# Mouse'u ekrana kilitliyoruz
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Bike referansını al (farklı yöntemler dene)
	if bike == null:
		# Önce export variable'dan kontrol et, yoksa scene tree'de ara
		bike = get_node_or_null("../bike")
		if bike == null:
			# Scene tree'de "bike" adında node ara
			var scene_root = get_tree().current_scene
			if scene_root:
				bike = scene_root.get_node_or_null("bike")
				if bike == null:
					# Tüm child'ları kontrol et
					bike = _find_bike_in_scene(scene_root)
	
	if bike:
		print("[DEBUG] Bike bulundu! Path: ", bike.get_path())
		# Bike'ın başlangıçta child olup olmadığını kontrol et
		bike_is_child = (bike.get_parent() == self)
	else:
		print("[DEBUG] HATA: Bike bulunamadı! Scene tree'yi kontrol edin.")
		print("[DEBUG] Player path: ", get_path())
		print("[DEBUG] Scene root: ", get_tree().current_scene.get_path() if get_tree().current_scene else "null")


func _unhandled_input(event: InputEvent) -> void:
	# ESC -> mouse toggle
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		return
	
	# Interact action -> bike'ı player'ın child'ı yap/iptal et
	if Input.is_action_just_pressed("Interact"):
		print("[DEBUG] Interact tuşuna basıldı!")
		print("[DEBUG] bike_is_child: ", bike_is_child)
		print("[DEBUG] can_interact_with_bike: ", can_interact_with_bike)
		print("[DEBUG] bike != null: ", bike != null)
		if bike_is_child:
			# Bisikletten in (her zaman mümkün)
			print("[DEBUG] Bisikletten iniliyor...")
			_toggle_bike_attachment()
		elif can_interact_with_bike and bike != null:
			# Bisiklete bin (sadece görülebilir ve yakınsa)
			print("[DEBUG] Bisiklete biniliyor...")
			_toggle_bike_attachment()
		else:
			print("[DEBUG] Bisiklete binilemiyor! can_interact_with_bike: ", can_interact_with_bike, ", bike: ", bike)
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
	
	# Bisiklet etkileşim kontrolü
	_check_bike_interaction()

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

func _check_bike_interaction() -> void:
	# Bisiklet zaten child ise kontrol etme
	if bike_is_child or bike == null or cam == null:
		if bike_is_child:
			print("[DEBUG] Bisiklet zaten child, kontrol edilmiyor")
		if bike == null:
			print("[DEBUG] Bike null!")
		if cam == null:
			print("[DEBUG] Camera null!")
		can_interact_with_bike = false
		return
	
	# Mesafe kontrolü
	var distance_to_bike = global_position.distance_to(bike.global_position)
	var is_near_enough = distance_to_bike <= bike_interact_distance
	
	# Bisiklet kameranın görüş alanında mı? (kameraya bakıyor mu?)
	var is_bike_visible = false
	
	# Kameranın bakış yönü ile bisiklet arasındaki açıyı kontrol et
	var camera_forward = -cam.global_transform.basis.z
	var to_bike = (bike.global_position - cam.global_position)
	var distance_to_bike_from_cam = to_bike.length()
	
	if distance_to_bike_from_cam > 0:
		to_bike = to_bike.normalized()
		var dot_product = camera_forward.dot(to_bike)
		
		# 60 derece içinde mi? (cos(60) ≈ 0.5) - Daha geniş açı
		# Dot product pozitif ise kameranın önünde
		if dot_product > 0.5:
			is_bike_visible = true
			print("[DEBUG] Bisiklet kameranın görüş alanında! Dot: ", dot_product)
	
	var previous_state = can_interact_with_bike
	can_interact_with_bike = is_bike_visible and is_near_enough
	
	# Debug mesajları (her frame değil, sadece değişiklik olduğunda)
	if previous_state != can_interact_with_bike or Engine.get_process_frames() % 60 == 0:  # Her 60 frame'de bir
		# Dot product'ı tekrar hesapla (debug için)
		var debug_camera_forward = -cam.global_transform.basis.z
		var debug_to_bike = (bike.global_position - cam.global_position)
		var debug_dot_product = 0.0
		if debug_to_bike.length() > 0:
			debug_to_bike = debug_to_bike.normalized()
			debug_dot_product = debug_camera_forward.dot(debug_to_bike)
		
		print("[DEBUG] === Bisiklet Etkileşim Durumu ===")
		print("[DEBUG] Mesafe: ", distance_to_bike, "m (Limit: ", bike_interact_distance, "m)")
		print("[DEBUG] Yakın mı: ", is_near_enough)
		print("[DEBUG] Görünür mü: ", is_bike_visible)
		print("[DEBUG] Dot product (açı): ", debug_dot_product, " (0.5'ten büyük olmalı)")
		print("[DEBUG] Bisiklet path: ", bike.get_path() if bike else "null")
		print("[DEBUG] can_interact_with_bike: ", can_interact_with_bike)
		print("[DEBUG] ================================")
	
	# State değiştiyse signal gönder (cursor güncellemesi için)
	if previous_state != can_interact_with_bike:
		bike_interaction_changed.emit(can_interact_with_bike)

func _toggle_bike_attachment() -> void:
	print("[DEBUG] _toggle_bike_attachment çağrıldı")
	if bike == null:
		print("[DEBUG] HATA: Bike null, işlem iptal edildi!")
		return
	print("[DEBUG] Bike bulundu: ", bike.get_path())
	
	if bike_is_child:
		# Bike'ı player'dan ayır ve main scene'e geri ekle
		var main_scene = get_tree().current_scene
		var bike_global_pos = bike.global_position
		var bike_global_rotation = bike.global_rotation
		# Bisikletin mevcut scale'ini kaydet (local scale)
		var bike_current_scale = bike.scale
		
		# Bike'ı player'dan çıkar
		remove_child(bike)
		# Main scene'e ekle
		main_scene.add_child(bike)
		# Global pozisyonu koru
		bike.global_position = bike_global_pos
		bike.global_rotation = bike_global_rotation
		# Scale'i koru (main scene'in scale'i genelde (1,1,1) olduğu için değişmez)
		bike.scale = bike_current_scale
		
		bike_is_child = false
	else:
		# Bike'ı player'ın child'ı yap (bisiklete bin)
		var main_scene = get_tree().current_scene
		var bike_global_pos = bike.global_position
		var bike_global_rotation = bike.global_rotation
		# Bisikletin mevcut scale'ini kaydet (local scale)
		var bike_current_scale = bike.scale
		
		# Player'ı bisikletin pozisyonuna taşı (bisiklete bin)
		global_position = bike_global_pos
		
		# Bike'ı main scene'den çıkar
		main_scene.remove_child(bike)
		# Player'a ekle (bisiklet artık player'ın child'ı)
		add_child(bike)
		# Bisikleti player'ın altına yerleştir (local pozisyon)
		bike.position = Vector3(0, -1, 0)  # Player'ın altında (Y ekseninde aşağıda)
		bike.rotation = Vector3.ZERO  # Player ile aynı rotasyonda
		# Scale'i koru (player'ın scale'i genelde (1,1,1) olduğu için değişmez)
		bike.scale = bike_current_scale
		
		bike_is_child = true
