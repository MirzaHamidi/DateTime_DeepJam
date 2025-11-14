extends Node3D

## Bisiklet kamerası kontrol scripti
## Bu script, SpringArm ile bisikleti takip eder, hıza göre FOV değişimi ve 
## dönüş girdisine göre kamera yatışı sağlar.

# ============================================================================
# EXPORT AYARLARI
# ============================================================================

@export_group("Kamera Referansları")
## SpringArm3D node'u (kamera parent'ı)
@export var spring_arm: SpringArm3D = null

## Camera3D node'u
@export var camera: Camera3D = null

@export_group("FOV Ayarları")
## Başlangıç FOV değeri (derece)
@export var base_fov: float = 75.0

## Maksimum FOV değeri (hızlıyken)
@export var max_fov: float = 90.0

## FOV değişim hızı (ne kadar hızlı değişir)
@export var fov_change_speed: float = 2.0

## FOV değişimi için gereken maksimum hız (m/s)
@export var max_speed_for_fov: float = 15.0

@export_group("Kamera Yatışı (Tilt)")
## Maksimum yatış açısı (derece)
@export var max_tilt_angle: float = 15.0

## Yatış değişim hızı (ne kadar hızlı yatırır)
@export var tilt_change_speed: float = 5.0

@export_group("Kamera Sallanma (Shake)")
## Kamera sallanma aktif mi?
@export var enable_camera_shake: bool = true

## Hıza göre sallanma miktarı (maksimum)
## Hızlandıkça kamera daha fazla sallanır
@export var shake_amount_max: float = 0.05

## Sallanma hızı (ne kadar hızlı sallanır)
@export var shake_speed: float = 15.0

## Sallanma için minimum hız (m/s)
## Bu hızın altında sallanma olmaz
@export var shake_min_speed: float = 2.0

@export_group("Kamera Bob (Hareket Sallanması)")
## Kamera bob aktif mi? (bisiklet hareket ederken hafif sallanma)
@export var enable_camera_bob: bool = true

## Bob miktarı (ne kadar sallanacak)
@export var bob_amount: float = 0.1

## Bob hızı (ne kadar hızlı sallanacak)
@export var bob_speed: float = 8.0

@export_group("Bisiklet Referansı")
## BikeController referansı (hız ve dönüş bilgisi için)
@export var bike_controller: RigidBody3D = null

@export_group("Kamera Takip Ayarları")
## SpringArm'ın bisikleti takip etme hızı (pozisyon)
## Yüksek değer = daha hızlı takip (daha "snappy")
## Düşük değer = daha yumuşak takip (daha "smooth")
@export var follow_speed: float = 8.0

## Kamera rotasyon takip hızı
## Bisiklet döndükçe kameranın ne kadar hızlı döneceğini belirler
@export var rotation_follow_speed: float = 6.0

## Kamera offset (bisiklet merkezinden ne kadar yukarı/ileri)
## X = sağ/sol, Y = yukarı/aşağı, Z = ileri/geri
## Örnek: Vector3(0, 2, 3) = 2 birim yukarı, 3 birim ileri
@export var camera_offset: Vector3 = Vector3(0.0, 2.0, 3.0)

## Hıza göre offset değişimi
## Hızlandıkça kameranın ne kadar ileriye/yukarıya kayacağını belirler
## Y = yukarı offset artışı, Z = ileri offset artışı
@export var speed_offset_multiplier: Vector3 = Vector3(0.0, 0.5, 1.5)

## SpringArm uzunluğu (kameranın bisikletten ne kadar uzakta olacağı)
## Bu değer, SpringArm'ın spring_length özelliğine uygulanır
@export var spring_length: float = 5.0

## Hıza göre SpringArm uzunluğu artışı
## Hızlandıkça kameranın ne kadar uzaklaşacağını belirler
@export var speed_spring_length_multiplier: float = 2.0

## Look ahead (ileriye bakma) mesafesi
## Hızlandıkça kameranın ne kadar ileriye bakacağını belirler
@export var look_ahead_distance: float = 3.0

## Look ahead hızı (ne kadar hızlı ileriye bakacak)
@export var look_ahead_speed: float = 4.0

## Mouse ile kamera kontrolü aktif mi?
## true = mouse ile kamera döner, false = otomatik takip
@export var use_mouse_look: bool = true

## Mouse kamera hassasiyeti
## Yüksek değer = mouse hareketi daha fazla kamera dönüşü yapar
## Düşük değer = mouse hareketi daha az kamera dönüşü yapar
@export var mouse_look_sensitivity: float = 0.002

## Kamera yaw açısı (mouse ile kontrol edilir)
var camera_yaw: float = 0.0

# ============================================================================
# NODE REFERANSLARI
# ============================================================================

## BikeController node referansı (script metodlarına erişim için)
## Not: bike_controller node'u zaten BikeController.gd script'ine sahip,
## bu yüzden metodları direkt node üzerinden çağırabiliriz

# ============================================================================
# DEĞİŞKENLER
# ============================================================================

## Mevcut FOV değeri
var current_fov: float = 75.0

## Mevcut yatış açısı (radyan)
var current_tilt: float = 0.0

## Önceki frame'deki bisiklet pozisyonu (smooth takip için)
var previous_bike_position: Vector3 = Vector3.ZERO

## Önceki frame'deki bisiklet rotasyonu (smooth takip için)
var previous_bike_rotation: float = 0.0

## Kamera sallanma zamanı (shake için)
var shake_time: float = 0.0

## Kamera bob zamanı (bob için)
var bob_time: float = 0.0

## Mevcut look ahead offset (ileriye bakma için)
var current_look_ahead: float = 0.0

## Mevcut hız (sallanma ve bob için)
var current_speed: float = 0.0

# ============================================================================
# READY
# ============================================================================

func _ready() -> void:
	# SpringArm ve Camera referanslarını bul
	if spring_arm == null:
		spring_arm = get_node_or_null("../CameraRig")
		if spring_arm == null:
			spring_arm = get_parent() as SpringArm3D
	
	if camera == null and spring_arm:
		camera = spring_arm.get_node_or_null("Camera3D")
	
	if camera == null:
		push_error("CameraController: Camera3D bulunamadı!")
		return
	
	# BikeController referansını bul
	if bike_controller == null:
		bike_controller = get_node_or_null("..")
		if bike_controller == null:
			bike_controller = get_node_or_null("../..")
	
	# BikeController node'u zaten BikeController.gd script'ine sahip olmalı
	# Metodları direkt node üzerinden çağıracağız
	
	# Başlangıç FOV'u ayarla
	current_fov = base_fov
	if camera:
		camera.fov = base_fov
	
	# SpringArm ayarlarını yapılandır
	if spring_arm:
		spring_arm.spring_length = spring_length
		# SpringArm collision ayarları (kameranın duvarlardan geçmemesi için)
		spring_arm.collision_mask = 1  # Varsayılan collision layer
		spring_arm.margin = 0.01  # Collision margin (küçük bir boşluk)
		# Not: SpringArm3D otomatik olarak parent node'unu (BikeRoot) takip eder
		# Eğer SpringArm BikeRoot'un child'ı değilse, manuel takip yapacağız
	
	# İlk pozisyonu kaydet
	if bike_controller:
		previous_bike_position = bike_controller.global_position
		previous_bike_rotation = bike_controller.rotation.y
		camera_yaw = bike_controller.rotation.y
		
		# SpringArm'ın başlangıç pozisyonunu ayarla
		if spring_arm:
			# SpringArm'ın parent'ı BikeRoot olduğu için lokal pozisyon kullan
			var offset_rotated: Vector3 = Vector3(
				camera_offset.x * cos(camera_yaw) - camera_offset.z * sin(camera_yaw),
				camera_offset.y,
				camera_offset.x * sin(camera_yaw) + camera_offset.z * cos(camera_yaw)
			)
			spring_arm.position = offset_rotated
			spring_arm.rotation.y = camera_yaw
	
	# Mouse modunu ayarla (eğer mouse kontrolü aktifse)
	if use_mouse_look:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ============================================================================
# PROCESS
# ============================================================================

func _process(delta: float) -> void:
	if camera == null:
		return
	
	# Bisiklet referansı yoksa çık
	if bike_controller == null:
		return
	
	# Mouse girdisi okuma (eğer mouse kontrolü aktifse)
	if use_mouse_look:
		_read_mouse_look_input()
	
	# Hız ve dönüş bilgisini al
	var speed: float = 0.0
	var steer_input: float = 0.0
	
	# BikeController node'undan metodları çağır
	# Not: bike_controller node'u BikeController.gd script'ine sahip olduğu için
	# get_speed() ve get_steer_input() metodları direkt node üzerinden çağrılabilir
	if bike_controller.has_method("get_speed"):
		speed = bike_controller.get_speed()
	if bike_controller.has_method("get_steer_input"):
		steer_input = bike_controller.get_steer_input()
	
	# Mevcut hızı kaydet (diğer sistemler için)
	current_speed = speed
	
	# SpringArm'ı bisikleti takip ettir
	_update_camera_follow(delta, speed)
	
	# FOV güncelle
	_update_fov(delta, speed)
	
	# Kamera yatışı güncelle
	_update_tilt(delta, steer_input)
	
	# Kamera sallanma (shake)
	if enable_camera_shake:
		_update_camera_shake(delta, speed)
	
	# Kamera bob (hareket sallanması)
	if enable_camera_bob:
		_update_camera_bob(delta, speed)

# ============================================================================
# MOUSE LOOK GİRDİSİ
# ============================================================================

## Mouse hareketini okur ve kamera yaw açısını günceller
## Mouse horizontal hareketi → kamera rotasyonu
func _read_mouse_look_input() -> void:
	# Mouse hareket event'ini kontrol et
	# Not: _unhandled_input kullanmak daha iyi olabilir, ama şimdilik bu şekilde
	# Mouse hareketini al (Input.get_last_mouse_velocity() kullanabiliriz ama
	# daha iyi kontrol için InputEventMouseMotion kullanmalıyız)
	
	# ESC tuşu ile mouse modunu değiştir
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Mouse hareket event'ini işler (unhandled_input'tan çağrılır)
func _unhandled_input(event: InputEvent) -> void:
	if not use_mouse_look:
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Mouse horizontal hareketi (X ekseni)
		# Pozitif = sağa, negatif = sola
		var mouse_delta_x: float = event.relative.x
		
		# Mouse hareketini kamera yaw açısına çevir
		# mouse_look_sensitivity: ne kadar hassas olacağını belirler
		camera_yaw -= mouse_delta_x * mouse_look_sensitivity
		
		# Yaw açısını 0-360 derece aralığında tut (opsiyonel)
		# camera_yaw = fmod(camera_yaw, TAU)

# ============================================================================
# KAMERA TAKİP
# ============================================================================

## SpringArm'ı bisikleti smooth bir şekilde takip ettirir
## Bisiklet hareket ettikçe kamera da onu takip eder
func _update_camera_follow(delta: float, speed: float) -> void:
	if bike_controller == null or spring_arm == null:
		return
	
	# Kullanılacak rotasyon: mouse look aktifse camera_yaw, değilse bisiklet rotasyonu
	var target_rotation: float
	if use_mouse_look:
		target_rotation = camera_yaw
	else:
		var bike_rotation: float = bike_controller.rotation.y
		var current_rot_y: float = spring_arm.rotation.y
		target_rotation = lerp_angle(current_rot_y, bike_rotation, rotation_follow_speed * delta)
		camera_yaw = target_rotation  # Senkronize tut
	
	# Hıza göre offset hesapla (hızlandıkça kameranın pozisyonu değişir)
	var speed_ratio: float = clamp(abs(speed) / max_speed_for_fov, 0.0, 1.0)
	var dynamic_offset: Vector3 = camera_offset + (speed_offset_multiplier * speed_ratio)
	
	# Offset'i hedef rotasyona göre döndür
	# Bu sayede kamera her zaman bisikletin arkasında kalır
	var offset_rotated: Vector3 = Vector3(
		dynamic_offset.x * cos(target_rotation) - dynamic_offset.z * sin(target_rotation),
		dynamic_offset.y,
		dynamic_offset.x * sin(target_rotation) + dynamic_offset.z * cos(target_rotation)
	)
	
	# Look ahead (ileriye bakma) - hızlandıkça kameranın ileriye bakması
	var target_look_ahead: float = look_ahead_distance * speed_ratio
	current_look_ahead = lerp(current_look_ahead, target_look_ahead, look_ahead_speed * delta)
	
	# Look ahead'i offset'e ekle (ileri yönde)
	var forward_dir: Vector3 = Vector3(
		-sin(target_rotation),
		0.0,
		-cos(target_rotation)
	)
	offset_rotated += forward_dir * current_look_ahead
	
	# SpringArm'ın pozisyonunu smooth bir şekilde güncelle
	# Exponential smoothing kullan (daha profesyonel görünüm)
	var current_offset: Vector3 = spring_arm.position
	var new_offset: Vector3 = lerp(current_offset, offset_rotated, 1.0 - exp(-follow_speed * delta))
	spring_arm.position = new_offset
	
	# Hıza göre SpringArm uzunluğunu ayarla (hızlandıkça kameranın uzaklaşması)
	var target_spring_length: float = spring_length + (speed_spring_length_multiplier * speed_ratio)
	var current_spring_length: float = spring_arm.spring_length
	spring_arm.spring_length = lerp(current_spring_length, target_spring_length, 2.0 * delta)
	
	# SpringArm'ın rotasyonunu güncelle (sadece Y ekseni - yaw)
	# Smooth rotasyon için exponential smoothing
	var spring_rotation: Vector3 = spring_arm.rotation
	var current_rot: float = spring_rotation.y
	var new_rot: float = lerp_angle(current_rot, target_rotation, 1.0 - exp(-rotation_follow_speed * delta))
	spring_rotation.y = new_rot
	spring_arm.rotation = spring_rotation

# ============================================================================
# FOV GÜNCELLEME
# ============================================================================

## Hıza göre FOV'u günceller
## Hız arttıkça FOV artar (daha geniş görüş açısı, "hız hissi")
## Smooth ease-in-out curve kullanarak daha profesyonel bir geçiş sağlar
func _update_fov(delta: float, speed: float) -> void:
	# Hız oranını hesapla (0.0 - 1.0 arası)
	var speed_ratio: float = clamp(abs(speed) / max_speed_for_fov, 0.0, 1.0)
	
	# Smooth curve uygula (ease-in-out benzeri)
	# Bu sayede FOV değişimi daha doğal görünür
	var eased_ratio: float = speed_ratio * speed_ratio * (3.0 - 2.0 * speed_ratio)  # Smoothstep
	
	# Hedef FOV'u hesapla (hız arttıkça artar)
	var target_fov: float = lerp(base_fov, max_fov, eased_ratio)
	
	# Exponential smoothing ile FOV'u güncelle (daha smooth geçiş)
	# exp(-fov_change_speed * delta) kullanarak frame-rate bağımsız smooth interpolasyon
	current_fov = lerp(current_fov, target_fov, 1.0 - exp(-fov_change_speed * delta))
	
	# Kameraya uygula
	camera.fov = current_fov

# ============================================================================
# KAMERA YATIŞI
# ============================================================================

## Dönüş girdisine göre kamerayı yatırır
## Dönüş yönüne göre kamera hafifçe yatırılır (daha dinamik his)
## Exponential smoothing kullanarak daha profesyonel bir geçiş sağlar
func _update_tilt(delta: float, steer_input: float) -> void:
	# Hedef yatış açısını hesapla (dönüş yönüne göre)
	# Pozitif steer_input = sağa dönüş = pozitif yatış (sağa yat)
	var target_tilt: float = -steer_input * deg_to_rad(max_tilt_angle)
	
	# Exponential smoothing ile yatışı güncelle (daha smooth geçiş)
	# lerp_angle: açı interpolasyonu (0-360 derece döngüsünü dikkate alır)
	# exp(-tilt_change_speed * delta): frame-rate bağımsız smooth interpolasyon
	current_tilt = lerp_angle(current_tilt, target_tilt, 1.0 - exp(-tilt_change_speed * delta))
	
	# SpringArm'ın rotasyonunu güncelle
	# Not: Z ekseni etrafında rotasyon (roll) uyguluyoruz
	if spring_arm:
		var current_rotation: Vector3 = spring_arm.rotation
		current_rotation.z = current_tilt
		spring_arm.rotation = current_rotation
	else:
		# SpringArm yoksa direkt kameraya uygula
		var current_rotation: Vector3 = camera.rotation
		current_rotation.z = current_tilt
		camera.rotation = current_rotation

# ============================================================================
# YARDIMCI FONKSİYONLAR
# ============================================================================

## Mevcut FOV değerini döndürür
func get_current_fov() -> float:
	return current_fov

## Mevcut yatış açısını döndürür (radyan)
func get_current_tilt() -> float:
	return current_tilt

# ============================================================================
# KAMERA SALLANMA (SHAKE)
# ============================================================================

## Hıza göre kamera sallanması (shake) uygular
## Hızlandıkça kamera daha fazla sallanır (gerçekçi efekt)
func _update_camera_shake(delta: float, speed: float) -> void:
	if camera == null:
		return
	
	# Sallanma zamanını güncelle
	shake_time += delta * shake_speed
	
	# Hız oranını hesapla (minimum hızın üstünde olmalı)
	var speed_ratio: float = 0.0
	if abs(speed) > shake_min_speed:
		speed_ratio = clamp((abs(speed) - shake_min_speed) / max_speed_for_fov, 0.0, 1.0)
	
	# Sallanma miktarını hesapla (hıza göre)
	var shake_amount: float = shake_amount_max * speed_ratio
	
	# Perlin noise benzeri sallanma (sin/cos kullanarak)
	# Farklı frekanslarda sin/cos kullanarak daha doğal görünüm
	var shake_x: float = sin(shake_time * 1.3) * shake_amount
	var shake_y: float = cos(shake_time * 0.9) * shake_amount
	var shake_z: float = sin(shake_time * 1.7) * shake_amount * 0.5
	
	# Shake'i kameraya uygula (X ve Z eksenleri)
	# Y ekseni bob tarafından yönetilecek
	var current_pos: Vector3 = camera.position
	current_pos.x = shake_x
	current_pos.z = shake_z
	# Y'yi koru (bob tarafından ayarlanacak)
	camera.position = current_pos

# ============================================================================
# KAMERA BOB (HAREKET SALLANMASI)
# ============================================================================

## Bisiklet hareket ederken hafif kamera bob (yukarı-aşağı sallanma)
## Bu, bisiklet sürerken doğal bir sallanma efekti sağlar
func _update_camera_bob(delta: float, speed: float) -> void:
	if camera == null:
		return
	
	# Sadece hareket halindeyken bob uygula
	if abs(speed) < 0.5:
		bob_time = 0.0
		# Bob'u sıfırla (sadece Y eksenini)
		var current_pos: Vector3 = camera.position
		current_pos.y = 0.0
		camera.position = current_pos
		return
	
	# Bob zamanını güncelle (hıza göre)
	bob_time += delta * bob_speed * clamp(abs(speed) / max_speed_for_fov, 0.3, 1.0)
	
	# Bob miktarını hesapla (hıza göre)
	var speed_factor: float = clamp(abs(speed) / max_speed_for_fov, 0.0, 1.0)
	var current_bob: float = sin(bob_time) * bob_amount * speed_factor
	
	# Bob'u kameraya uygula (Y ekseni - yukarı/aşağı)
	# Mevcut shake pozisyonunu koru (X ve Z), sadece Y'yi güncelle
	var current_pos: Vector3 = camera.position
	
	# Shake'in Y bileşenini hesapla (eğer shake aktifse)
	var shake_y: float = 0.0
	if enable_camera_shake:
		var speed_ratio: float = 0.0
		if abs(speed) > shake_min_speed:
			speed_ratio = clamp((abs(speed) - shake_min_speed) / max_speed_for_fov, 0.0, 1.0)
		var shake_amount: float = shake_amount_max * speed_ratio
		shake_y = cos(shake_time * 0.9) * shake_amount
	
	# Y eksenini shake + bob olarak birleştir
	current_pos.y = shake_y + current_bob
	camera.position = current_pos
