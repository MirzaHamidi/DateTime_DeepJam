extends RigidBody3D

## Optimize edilmiş bisiklet kontrolcüsü (RigidBody3D)
## Smooth, responsive ve takılmayan sürüş mekaniği
##
## NOT: RigidBody3D kullanıldığı için gravity otomatik olarak uygulanır.
## gravity_scale değişkeni ile gravity kontrol edilir (varsayılan: 1.0)

# ============================================================================
# EXPORT AYARLARI
# ============================================================================

@export_group("Hareket Ayarları")
@export var max_speed: float = 16.0
@export var acceleration: float = 40.0
@export var brake_deceleration: float = 55.0
@export var reverse_speed_threshold: float = 0.5
@export var max_reverse_speed: float = 4.0
@export var reverse_acceleration: float = 18.0
@export var acceleration_curve: float = 0.25
@export var min_acceleration_ratio: float = 0.35
@export var friction: float = 0.08

@export_group("Dönüş Ayarları")
## Dönüş hızı (rad/s) - Bisiklet deneyimi için optimize edilmiş
## Yüksek değer = daha hızlı ve responsive dönüş
@export var turn_speed: float = 4.0

## Düşük hızlarda dönüş çarpanı
## Düşük hızlarda daha keskin dönüş için çarpan
@export var low_speed_turn_factor: float = 2.5

## Yüksek hızlarda dönüş çarpanı
## Yüksek hızlarda daha yumuşak dönüş için çarpan
@export var high_speed_turn_factor: float = 0.4

## GTA benzeri hissiyat için düşük hızlarda ekstra dönüş amplifikasyonu
@export var low_speed_turn_boost: float = 1.3

## GTA benzeri hissiyat için yüksek hızlarda dönüş sönümleme oranı
@export var high_speed_turn_damp: float = 0.55

## Velocity vektörünü yönlendirme gücü (ne kadar hızlı yüzünü gittiği yöne çevirir)
@export var velocity_turn_follow: float = 6.0

## Yaw istikrarı (aşırı sallanmayı azaltmak için)
@export var steering_stability: float = 3.5

## Maksimum yatış açısı (derece)
@export var max_lean_angle_deg: float = 42.0

## Yatış hızı - Bisiklet deneyimi için optimize edilmiş
@export var lean_speed: float = 5.0

@export_group("Zemin ve Collision")
## Collision sliding faktörü (0.0-1.0)
## Yüksek değer = daha fazla kayma (takılma önleme)
## Düşük değer = daha az kayma (daha stabil)
@export var collision_slide_factor: float = 0.99
@export var ground_align_speed: float = 12.0
@export var turn_slide_boost: float = 5.0
@export var min_velocity_boost: float = 4.0

## Yere hizalama kuvveti
@export var ground_align_force: float = 20.0

## Yere hizalama torku
@export var ground_align_torque: float = 10.0

## Linear damping (sürtünme)
@export var linear_damping: float = 0.15

## Angular damping (rotasyon sürtünmesi)
@export var angular_damping: float = 0.4

@export_group("Denge ve Stabilite")
## Yana kaymayı (lateral drift) azaltma oranı (0.0-1.0)
## Yüksek değer = daha az yana kayma (daha stabil)
## Düşük değer = daha fazla yana kayma (daha kaygan)
## Önerilen: 0.4-0.6 arası (dönüş hissi için)
@export var lateral_drift_kill: float = 0.5

## Dik durma kuvveti (upright strength)
## Bisikletin düşmesini önlemek için uygulanan tork gücü
@export var upright_strength: float = 6.0

## Dik durma damping (sallanmayı söndürme)
## Açısal hızı azaltarak salınımı önler
@export var upright_damping: float = 3.0

@export_group("Mouse Kontrolü")
@export var use_mouse_steering: bool = false
@export var mouse_steer_sensitivity: float = 0.01
@export var max_mouse_steer_value: float = 1.0
@export var mouse_steer_return_speed: float = 3.0

@export_group("Görsel")
@export var front_wheel_visual: Node3D = null
@export var max_steer_visual_angle_deg: float = 30.0
@export var visual_steer_lerp_speed: float = 8.0

@export_group("Pedal")
@export var pedal_radius: float = 0.15
@export var pedal_pivot_offset: Vector3 = Vector3(0.0, -0.3, 0.0)
@export var pedal_rotation_multiplier: float = 2.0

# ============================================================================
# NODE REFERANSLARI
# ============================================================================

@onready var front_wheel: Node3D = $FrontWheel
var front_wheel_visual_node: Node3D = null
@onready var rear_wheel: Node3D = $RearWheel
@onready var front_raycast: RayCast3D = $FrontWheel/RayCast3D
@onready var rear_raycast: RayCast3D = $RearWheel/RayCast3D
@onready var ik_targets: Node3D = $IKTargets
@onready var left_foot_target: Node3D = $IKTargets/LeftFootTarget
@onready var right_foot_target: Node3D = $IKTargets/RightFootTarget

# ============================================================================
# DEĞİŞKENLER
# ============================================================================

var speed: float = 0.0
var steer_input: float = 0.0
var pedal_rotation: float = 0.0
var mouse_steer_value: float = 0.0
var current_acceleration: float = 0.0
var current_brake_input: float = 0.0
var ground_normal: Vector3 = Vector3.UP
var is_on_ground: bool = false

# ============================================================================
# READY
# ============================================================================

func _ready() -> void:
	if front_raycast:
		front_raycast.enabled = true
		front_raycast.target_position = Vector3(0, -2.0, 0)
	
	if rear_raycast:
		rear_raycast.enabled = true
		rear_raycast.target_position = Vector3(0, -2.0, 0)
	
	# RigidBody3D ayarları
	# NOT: RigidBody3D otomatik olarak gravity uygular (gravity_scale ile kontrol edilir)
	gravity_scale = 1.0
	linear_damp = linear_damping
	angular_damp = angular_damping
	
	# Center of mass (daha stabil)
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, -0.25, 0.0)
	
	if front_wheel_visual != null:
		front_wheel_visual_node = front_wheel_visual
	elif front_wheel != null:
		front_wheel_visual_node = front_wheel
	
	if use_mouse_steering:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ============================================================================
# PHYSICS PROCESS
# ============================================================================

func _physics_process(delta: float) -> void:
	_read_input()
	
	if use_mouse_steering:
		_read_mouse_input()
	
	_update_ground_detection()
	_calculate_speed()
	
	# Yana kaymayı azalt (lateral drift kill) - yeni özellik
	_apply_lateral_drift_kill()
	
	_apply_movement(delta)
	_apply_steering(delta)
	_apply_lean(delta)
	
	# Dik durma (upright) - yeni özellik, zemin hizalamadan önce
	_keep_upright(delta)
	
	# ŞİMDİLİK KAPALI: önce temel sürüşü düzeltelim
	# _align_to_ground(delta)
	# _apply_collision_sliding(delta)
	
	_update_visual_steering(delta)
	_update_pedal_animation(delta)

# ============================================================================
# GİRDİ OKUMA
# ============================================================================

func _read_input() -> void:
	if use_mouse_steering:
		steer_input = mouse_steer_value
	else:
		# DOĞRUSU: left = bike_steer_left, right = bike_steer_right
		var steer_left: float = Input.get_action_strength("bike_steer_left")
		var steer_right: float = Input.get_action_strength("bike_steer_right")
		var raw_input: float = steer_right - steer_left   # sağ +, sol -
		
		var delta: float = get_physics_process_delta_time()
		steer_input = lerp(steer_input, raw_input, 1.0 - exp(-12.0 * delta))

func _read_mouse_input() -> void:
	mouse_steer_value = lerp(mouse_steer_value, 0.0, mouse_steer_return_speed * get_physics_process_delta_time())

func _unhandled_input(event: InputEvent) -> void:
	# R tuşu ile oyunu yeniden başlat
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		restart_game()
		return
	
	if not use_mouse_steering:
		return
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mouse_delta_x: float = event.relative.x
		var steer_delta: float = mouse_delta_x * mouse_steer_sensitivity
		mouse_steer_value += steer_delta
		mouse_steer_value = clamp(mouse_steer_value, -max_mouse_steer_value, max_mouse_steer_value)

# ============================================================================
# ZEMİN TESPİTİ
# ============================================================================

func _update_ground_detection() -> void:
	var has_ground: bool = false
	ground_normal = Vector3.UP
	is_on_ground = false
	
	if front_raycast and front_raycast.is_colliding():
		var front_normal: Vector3 = front_raycast.get_collision_normal()
		ground_normal += front_normal
		has_ground = true
		is_on_ground = true
	
	if rear_raycast and rear_raycast.is_colliding():
		var rear_normal: Vector3 = rear_raycast.get_collision_normal()
		ground_normal += rear_normal
		has_ground = true
		is_on_ground = true
	
	if has_ground:
		ground_normal = ground_normal.normalized()
	else:
		ground_normal = Vector3.UP

# ============================================================================
# HIZ HESAPLAMA
# ============================================================================

func _calculate_speed() -> void:
	var forward_dir: Vector3 = -transform.basis.z
	speed = linear_velocity.dot(forward_dir)

# ============================================================================
# HAREKET (HIZLANMA VE FRENLEME) - RIGIDBODY3D İÇİN
# ============================================================================
## Hızlanma, frenleme ve geri vites sistemini uygular
## 
## Tuning İpuçları:
## - Hızlanma hissi: `acceleration` ve `acceleration_curve` değiştirin
## - Frenleme hissi: `brake_deceleration` değiştirin
## - Geri vites: `reverse_speed_threshold` ve `reverse_acceleration` değiştirin

func _apply_movement(delta: float) -> void:
	var accelerate_input: float = Input.get_action_strength("bike_accelerate")
	var brake_input: float = Input.get_action_strength("bike_brake")
	
	# Smooth acceleration
	current_acceleration = lerp(current_acceleration, accelerate_input, 1.0 - exp(-15.0 * delta))
	
	# Smooth braking
	current_brake_input = lerp(current_brake_input, brake_input, 1.0 - exp(-12.0 * delta))
	
	# İleri yön
	var forward_dir: Vector3 = -transform.basis.z
	
	# Zemin normal'ine göre forward direction'ı ayarla
	if is_on_ground:
		forward_dir = forward_dir.slide(ground_normal).normalized()
		if forward_dir.length() < 0.1:
			forward_dir = -transform.basis.z
	
	# HIZLANMA
	if current_acceleration > 0.01:
		var speed_ratio: float = clamp(abs(speed) / max_speed, 0.0, 1.0)
		
		# Acceleration curve
		var acceleration_factor: float = lerp(1.0, 1.0 - speed_ratio, acceleration_curve)
		acceleration_factor = max(acceleration_factor, min_acceleration_ratio)
		
		# Hız sınırlama
		var speed_limit_factor: float = 1.0
		if abs(speed) > max_speed * 0.9:
			var excess_speed: float = (abs(speed) - max_speed * 0.9) / (max_speed * 0.1)
			speed_limit_factor = 1.0 - clamp(excess_speed * 5.0, 0.0, 1.0)
		
		# Hızlanma kuvveti (RigidBody3D için apply_central_force kullan)
		var acceleration_force: float = acceleration * current_acceleration * acceleration_factor * speed_limit_factor
		apply_central_force(forward_dir * acceleration_force)
	else:
		current_acceleration = lerp(current_acceleration, 0.0, 1.0 - exp(-15.0 * delta))
	
	# FRENLEME VE GERİ VİTES
	if current_brake_input > 0.01:
		# Hızlı gidiyorsak: klasik fren
		if speed > reverse_speed_threshold:
			var speed_factor_fwd: float = clamp(abs(speed) / max_speed, 0.5, 1.0)
			apply_central_force(-forward_dir * brake_deceleration * current_brake_input * speed_factor_fwd)
		# Geriye doğru fazla hız varsa: ileri yönlü fren
		elif speed < -reverse_speed_threshold:
			var speed_factor_back: float = clamp(abs(speed) / max_reverse_speed, 0.4, 1.0)
			apply_central_force(forward_dir * brake_deceleration * current_brake_input * speed_factor_back)
		else:
			# Eşik altında: önce hızı sıfıra çek
			if abs(speed) > 0.05:
				var sign_dir: float = sign(speed)
				apply_central_force(-forward_dir * brake_deceleration * current_brake_input * sign_dir)
			else:
				# İleri/geri bileşeni temizle
				linear_velocity -= forward_dir * speed
				speed = 0.0
			# Ardından geri vites
			var backward_dir: Vector3 = -forward_dir
			var reverse_speed: float = linear_velocity.dot(backward_dir)
			if reverse_speed < max_reverse_speed:
				apply_central_force(backward_dir * reverse_acceleration * current_brake_input)
	else:
		current_brake_input = lerp(current_brake_input, 0.0, 1.0 - exp(-12.0 * delta))
	
	# Hızı sınırla (ileri ve geri için)
	var forward_velocity: float = linear_velocity.dot(forward_dir)
	
	# İleri hız sınırı
	if forward_velocity > max_speed:
		linear_velocity -= forward_dir * (forward_velocity - max_speed)
	
	# Geri vites hız sınırı
	var backward_dir: Vector3 = -forward_dir
	var backward_velocity: float = linear_velocity.dot(backward_dir)
	if backward_velocity > max_reverse_speed:
		linear_velocity -= backward_dir * (backward_velocity - max_reverse_speed)
	
	# Doğal sürtünme (linear damping zaten var, ama ekstra kontrol için)
	if current_acceleration < 0.01 and current_brake_input < 0.01:
		# Linear velocity'yi yavaşça azalt
		linear_velocity = linear_velocity.lerp(Vector3.ZERO, friction * delta)

# ============================================================================
# DÖNÜŞ (STEERING) - RIGIDBODY3D İÇİN
# ============================================================================
## Hıza bağlı dönüş mekaniğini uygular
## 
## Tuning İpuçları:
## - Düşük hız dönüş hissi: `low_speed_turn_factor` artırın
## - Yüksek hız dönüş hissi: `high_speed_turn_factor` artırın
## - Genel dönüş hızı: `turn_speed` değiştirin

func _apply_steering(delta: float) -> void:
	if abs(steer_input) < 0.01:
		return
	
	# Hız oranını hesapla (0.0 = duruyor, 1.0 = maksimum hızda)
	var speed_ratio: float = clamp(abs(speed) / max_speed, 0.0, 1.0)
	var slow_bias: float = 1.0 - speed_ratio
	var fast_bias: float = speed_ratio
	
	# GTA benzeri hissiyat: düşük hızda agresif, yüksek hızda kontrollü
	var boosted_low: float = low_speed_turn_factor * (1.0 + low_speed_turn_boost * slow_bias)
	var damped_high: float = high_speed_turn_factor * lerp(1.0, high_speed_turn_damp, fast_bias)
	var turn_factor: float = boosted_low * slow_bias + damped_high * fast_bias
	
	# İstenen yaw (angular_velocity hedefi)
	var desired_yaw: float = steer_input * turn_speed * (slow_bias + fast_bias * high_speed_turn_damp)
	var yaw_error: float = desired_yaw - angular_velocity.y
	var stability_torque: float = yaw_error * steering_stability
	
	var turn_torque: float = steer_input * turn_speed * turn_factor + stability_torque
	apply_torque(Vector3.UP * turn_torque)
	
	# Velocity vektörünü yüzünün baktığı yöne çek (driftleri toparlar)
	var forward_dir: Vector3 = -transform.basis.z
	var target_velocity_dir: Vector3 = forward_dir.rotated(Vector3.UP, steer_input * slow_bias * 0.35)
	target_velocity_dir = target_velocity_dir.normalized()
	var velocity_mag: float = linear_velocity.length()
	var blended_velocity: Vector3 = target_velocity_dir * velocity_mag
	var follow_ratio: float = clamp(velocity_turn_follow * delta, 0.0, 1.0)
	linear_velocity = linear_velocity.lerp(blended_velocity, follow_ratio)
	
	# Ek olarak, düşük hızlarda tekerden yere daha fazla yan kuvvet gönder
	if abs(speed) > 0.5:
		var grip: float = clamp(1.0 - fast_bias * 0.5, 0.35, 1.0)
		var lateral_force: Vector3 = transform.basis.x * steer_input * abs(speed) * 0.35 * grip
		apply_central_force(lateral_force)

# ============================================================================
# YANA KAYMA ÖNLEME (LATERAL DRIFT KILL)
# ============================================================================
## Yana kaymayı (lateral drift) azaltır - bisiklet "kayık" hissetmesin
## Yeni kodun iyi özelliği: yana doğru hızı azaltarak daha stabil sürüş
func _apply_lateral_drift_kill() -> void:
	var right_dir: Vector3 = transform.basis.x
	var v_right: float = linear_velocity.dot(right_dir)
	
	# Yana kayma hızını azalt
	if abs(v_right) > 0.01:
		linear_velocity -= right_dir * v_right * lateral_drift_kill

# ============================================================================
# YATIŞ (LEAN) ############################$$$$$$$
# ============================================================================
## Dönüş yönüne göre bisikleti yatırır (roll efekti)
## 
## Tuning İpuçları:
## - Yatış miktarı: `max_lean_angle_deg` değiştirin
## - Yatış hızı: `lean_speed` değiştirin

func _apply_lean(delta: float) -> void:
	var euler: Vector3 = transform.basis.get_euler()
	
	if abs(steer_input) < 0.01:
		# input yoksa yavaşça düzelsin (roll → 0)
		var new_roll: float = lerp_angle(euler.z, 0.0, lean_speed * delta)
		euler.z = new_roll
		transform.basis = Basis.from_euler(euler)
		return
	
	var speed_ratio: float = clamp(abs(speed) / max_speed, 0.0, 1.0)
	var lean_factor: float = lerp(0.35, 1.0, speed_ratio)
	var target_lean: float = -steer_input * deg_to_rad(max_lean_angle_deg) * lean_factor
	
	var new_roll: float = lerp_angle(euler.z, target_lean, 1.0 - exp(-lean_speed * delta))
	euler.z = new_roll
	transform.basis = Basis.from_euler(euler)

# ============================================================================
# DİK DURMA (UPRIGHT) - RIGIDBODY3D İÇİN
# ============================================================================
## Bisikletin düşmesini önlemek için dik durma kuvveti uygular
## Yeni kodun iyi özelliği: basit ve etkili dik durma mekaniği
## 
## Tuning İpuçları:
## - Dik durma gücü: `upright_strength` değiştirin
## - Sallanma önleme: `upright_damping` değiştirin
func _keep_upright(delta: float) -> void:
	# Hedef yukarı yönü: yerdeysek ground_normal, havadaysak global UP
	var target_up: Vector3 = ground_normal if is_on_ground else Vector3.UP
	var up: Vector3 = transform.basis.y
	
	# Şu anki up ile hedef up arasındaki fark
	# cross → hangi eksende ne kadar eğik olduğumuzu verir
	var tilt_axis: Vector3 = up.cross(target_up)
	
	# Eğikliği azaltacak tork
	var corrective_torque: Vector3 = -tilt_axis * upright_strength
	# Açısal hızı da söndür (salınımı azaltmak için damping)
	corrective_torque -= angular_velocity * upright_damping
	
	# delta ile çarpıp tork uygula
	apply_torque_impulse(corrective_torque * delta)

# ============================================================================
# ZEMİN HİZALAMA - RIGIDBODY3D İÇİN
# ============================================================================
## RayCast ile tespit edilen zemin normal'ine göre bisikleti hizalar
## Eğimli yüzeylerde bisikletin zeminle uyumlu kalmasını sağlar
## 
## Tuning İpuçları:
## - Hizalama gücü: `ground_align_force` ve `ground_align_torque` değiştirin
## - Hizalama hızı: `ground_align_speed` değiştirin

func _align_to_ground(delta: float) -> void:
	if not is_on_ground:
		return
	
	var current_up: Vector3 = transform.basis.y
	var alignment_axis: Vector3 = current_up.cross(ground_normal)
	var alignment_angle: float = alignment_axis.length()
	
	if alignment_angle > 0.001:
		# Tork ile hizalama (RigidBody3D için)
		var alignment_torque: Vector3 = alignment_axis * ground_align_torque
		apply_torque(alignment_torque)
		
		# Kuvvet ile hizalama (ekstra stabilite için)
		var alignment_force: Vector3 = (ground_normal - current_up) * ground_align_force
		apply_central_force(alignment_force)

# ============================================================================
# COLLISION SLIDING - RIGIDBODY3D İÇİN
# ============================================================================
## Collision'lara çarptığında bisikletin kaymasını sağlar (takılma önleme)
## 
## Tuning İpuçları:
## - Kayma miktarı: `collision_slide_factor` değiştirin (0.95-0.99 arası önerilir)
## - Dönüş sırasında kayma: `turn_slide_boost` değiştirin
## - Takılma önleme: `min_velocity_boost` değiştirin

func _apply_collision_sliding(delta: float) -> void:
	# RigidBody3D'de collision detection için SpaceState kullan
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	# Bisikletin önünde, yanlarında ve arkasında collision kontrolü
	var forward_dir: Vector3 = -transform.basis.z
	var right_dir: Vector3 = transform.basis.x
	
	# Ön tarafta collision kontrolü
	var front_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + forward_dir * 1.5
	)
	front_query.exclude = [self.get_rid()]
	var front_result: Dictionary = space_state.intersect_ray(front_query)
	
	# Collision varsa, kayma kuvveti uygula
	if front_result:
		var collision_normal: Vector3 = front_result.get("normal", Vector3.UP)
		
		# Velocity'yi collision normal'ine göre kaydır
		var current_velocity: Vector3 = linear_velocity
		var slid_velocity: Vector3 = current_velocity.slide(collision_normal)
		
		# Linear velocity'yi güncelle
		linear_velocity = slid_velocity * collision_slide_factor
		
		# Takılma önleme: velocity çok küçükse ekstra kayma
		if linear_velocity.length() < 1.0:
			var new_forward: Vector3 = forward_dir.slide(collision_normal).normalized()
			if new_forward.length() > 0.1:
				apply_central_force(new_forward * min_velocity_boost * 10.0)
		
		# Dönüş sırasında özel kayma
		if abs(steer_input) > 0.1:
			var turn_direction: Vector3 = right_dir * steer_input
			var slide_direction: Vector3 = turn_direction.slide(collision_normal).normalized()
			if slide_direction.length() > 0.1:
				apply_central_force(slide_direction * abs(steer_input) * turn_slide_boost * 10.0)

# ============================================================================
# GÖRSEL DÖNÜŞ
# ============================================================================

func _update_visual_steering(delta: float) -> void:
	if front_wheel_visual_node == null:
		return
	
	var target_angle_deg: float = steer_input * max_steer_visual_angle_deg
	var target_angle_rad: float = deg_to_rad(target_angle_deg)
	
	var current_rotation: Vector3 = front_wheel_visual_node.rotation
	var current_y_rotation: float = current_rotation.y
	var new_y_rotation: float = lerp_angle(current_y_rotation, target_angle_rad, visual_steer_lerp_speed * delta)
	
	current_rotation.y = new_y_rotation
	front_wheel_visual_node.rotation = current_rotation

# ============================================================================
# PEDAL ANİMASYONU
# ============================================================================

func _update_pedal_animation(delta: float) -> void:
	var rotation_speed: float = speed * pedal_rotation_multiplier
	pedal_rotation += rotation_speed * delta
	pedal_rotation = fmod(pedal_rotation, TAU)
	
	var left_pedal_angle: float = pedal_rotation
	var right_pedal_angle: float = pedal_rotation + PI
	
	if left_foot_target:
		var left_offset: Vector3 = Vector3(
			cos(left_pedal_angle) * pedal_radius,
			sin(left_pedal_angle) * pedal_radius,
			0.0
		)
		left_foot_target.position = pedal_pivot_offset + left_offset
	
	if right_foot_target:
		var right_offset: Vector3 = Vector3(
			cos(right_pedal_angle) * pedal_radius,
			sin(right_pedal_angle) * pedal_radius,
			0.0
		)
		right_foot_target.position = pedal_pivot_offset + right_offset

# ============================================================================
# YARDIMCI FONKSİYONLAR
# ============================================================================

func get_speed() -> float:
	return speed

func get_steer_input() -> float:
	return steer_input

# ============================================================================
# OYUN YENİDEN BAŞLATMA
# ============================================================================

## R tuşuna basınca oyunu yeniden başlatır
## Mevcut sahneyi yeniden yükler
func restart_game() -> void:
	# Mevcut sahneyi yeniden yükle
	get_tree().reload_current_scene()
