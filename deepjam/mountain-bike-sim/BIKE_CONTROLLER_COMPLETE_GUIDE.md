# Bisiklet Kontrolcüsü - Tam Dokümantasyon

Bu dokümantasyon, 3D bisiklet simülasyonu için geliştirilen tüm sistemleri, özellikleri ve ayarları kapsamlı bir şekilde açıklar.

## 📋 İçindekiler

1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Sistem Mimarisi](#sistem-mimarisi)
3. [Scriptler ve Özellikler](#scriptler-ve-özellikler)
4. [Kurulum Rehberi](#kurulum-rehberi)
5. [Kullanım Kılavuzu](#kullanım-kılavuzu)
6. [Ayarlar ve Parametreler](#ayarlar-ve-parametreler)
7. [Tuning Rehberi](#tuning-rehberi)
8. [Sorun Giderme](#sorun-giderme)
9. [Geliştirme Geçmişi](#geliştirme-geçmişi)

---

## 🎯 Proje Genel Bakış

### Proje Amacı
Gerçekçi ama arcade-friendly bir 3D bisiklet kontrolcüsü geliştirmek. Sistem, RigidBody3D tabanlı fizik kullanarak smooth, responsive ve takılmayan bir sürüş deneyimi sunar.

### Teknik Özellikler
- **Engine:** Godot 4.5.1
- **Dil:** GDScript (tam tip güvenli)
- **Fizik:** RigidBody3D
- **IK Sistemi:** SkeletonModification3DTwoBoneIK
- **Kamera:** SpringArm3D + Camera3D

### Ana Özellikler
- ✅ Hızlanma/frenleme sistemi
- ✅ Hıza bağlı dönüş mekaniği
- ✅ Yatış (lean) efekti
- ✅ Geri vites
- ✅ Zemin hizalama
- ✅ Collision sliding (takılma önleme)
- ✅ IK sistemi (rider animasyonu)
- ✅ Pedal animasyonu
- ✅ Görsel gidon dönüşü
- ✅ Kamera sistemi (FOV, tilt, shake, bob)
- ✅ Mouse ve klavye kontrolü

---

## 🏗️ Sistem Mimarisi

### Node Hiyerarşisi

```
BikeRoot (RigidBody3D)
├── BikeController.gd (Ana kontrol scripti)
├── Mesh/Bike Model (Görsel model)
├── FrontWheel (Node3D)
│   ├── CollisionShape3D (SphereShape3D) x2
│   └── RayCast3D (Zemin tespiti)
├── RearWheel (Node3D)
│   ├── CollisionShape3D (SphereShape3D) x2
│   └── RayCast3D (Zemin tespiti)
├── IKTargets (Node3D)
│   ├── LeftFootTarget (Node3D)
│   ├── RightFootTarget (Node3D)
│   ├── LeftHandTarget (Node3D)
│   └── RightHandTarget (Node3D)
├── Skeleton3D (Rider)
│   └── SkeletonModificationStack3D
│       ├── LeftLegIK (TwoBoneIK)
│       ├── RightLegIK (TwoBoneIK)
│       ├── LeftArmIK (TwoBoneIK)
│       └── RightArmIK (TwoBoneIK)
└── CameraRig (SpringArm3D)
	└── Camera3D
		└── CameraController.gd
```

### Script Yapısı

1. **BikeController.gd** - Ana bisiklet kontrolü
2. **BikeIKController.gd** - IK sistemi yönetimi
3. **CameraController.gd** - Kamera kontrolü

---

## 📜 Scriptler ve Özellikler

### 1. BikeController.gd

#### Ana Fonksiyonlar

**Hareket Sistemi:**
- `_apply_movement(delta)` - Hızlanma, frenleme ve geri vites
- `_apply_steering(delta)` - Hıza bağlı dönüş mekaniği
- `_apply_lean(delta)` - Yatış (roll) efekti
- `_apply_gravity(delta)` - Yerçekimi uygulama

**Zemin ve Collision:**
- `_update_ground_detection()` - RayCast ile zemin normal tespiti
- `_align_to_ground(delta)` - Zemin normal'ine hizalama
- `_apply_collision_sliding(delta)` - Collision sliding (takılma önleme)

**Görsel:**
- `_update_visual_steering(delta)` - Görsel gidon dönüşü
- `_update_pedal_animation(delta)` - Pedal animasyonu

**Yardımcı:**
- `_calculate_speed()` - Hız hesaplama
- `_read_input()` - Girdi okuma
- `restart_game()` - Oyunu yeniden başlatma (R tuşu)

#### Önemli Özellikler

**Hıza Bağlı Dönüş:**
- Düşük hızlarda daha keskin dönüş (`low_speed_turn_factor`)
- Yüksek hızlarda daha yumuşak dönüş (`high_speed_turn_factor`)
- Hız oranına göre otomatik interpolasyon

**Collision Sliding:**
- Duvarlara çarptığında kayma
- Dönüş sırasında özel kayma mekaniği
- Takılma önleme sistemi

**Geri Vites:**
- Düşük hızlarda (threshold altında) fren basınca geri vites
- Ayrı geri vites hız sınırlaması
- Smooth geçiş

### 2. BikeIKController.gd

#### Özellikler
- TwoBoneIK sistemi ile rider animasyonu
- Ayaklar pedallara, eller gidona bağlı
- Otomatik IK target güncelleme

### 3. CameraController.gd

#### Özellikler
- Hıza bağlı FOV değişimi
- Dönüş girdisine göre kamera tilt
- Camera shake (hıza bağlı)
- Camera bob (hıza bağlı)
- Look-ahead efekti
- Smooth interpolation

---

## 🛠️ Kurulum Rehberi

### 1. Node Yapısı

1. **BikeRoot oluştur:**
   - Node tipi: `RigidBody3D`
   - İsim: `BikeRoot`
   - `BikeController.gd` script'ini ekle

2. **Tekerlekler:**
   - `FrontWheel` (Node3D) oluştur
   - `RearWheel` (Node3D) oluştur
   - Her birine 2 adet `CollisionShape3D` (SphereShape3D) ekle
   - Her birine `RayCast3D` ekle (aşağı doğru yönlendir)

3. **IK Targets:**
   - `IKTargets` (Node3D) oluştur
   - İçine `LeftFootTarget`, `RightFootTarget`, `LeftHandTarget`, `RightHandTarget` ekle

4. **Skeleton:**
   - Rider için `Skeleton3D` ekle
   - `SkeletonModificationStack3D` ekle
   - `BikeIKController.gd` script'ini ekle

5. **Kamera:**
   - `CameraRig` (SpringArm3D) ekle
   - İçine `Camera3D` ekle
   - `CameraController.gd` script'ini ekle

### 2. Input Actions

Project Settings → Input Map'te şu action'ları oluştur:
- `bike_accelerate` (W veya Space)
- `bike_brake` (S)
- `bike_steer_left` (A)
- `bike_steer_right` (D)

### 3. Script Atamaları

- `BikeController.gd` → BikeRoot (RigidBody3D)
- `BikeIKController.gd` → Skeleton3D
- `CameraController.gd` → Camera3D

---

## 🎮 Kullanım Kılavuzu

### Kontroller

**Klavye:**
- **W / Space:** Hızlan
- **S:** Fren / Geri vites (düşük hızlarda)
- **A:** Sola dön
- **D:** Sağa dön
- **R:** Oyunu yeniden başlat

**Mouse (opsiyonel):**
- Mouse horizontal hareketi ile dönüş
- ESC ile mouse modunu değiştir

### Temel Kullanım

1. **Hızlanma:** W tuşuna basılı tut
2. **Frenleme:** S tuşuna basılı tut
3. **Dönüş:** A/D tuşları ile sağa/sola dön
4. **Geri Vites:** Düşük hızlarda (0.3 m/s altı) S tuşuna bas

---

## ⚙️ Ayarlar ve Parametreler

### Hareket Ayarları

| Parametre | Varsayılan | Açıklama |
|-----------|------------|----------|
| `max_speed` | 10.0 | Maksimum hız (m/s) |
| `acceleration` | 10.0 | Hızlanma (m/s²) |
| `brake_deceleration` | 10.0 | Frenleme (m/s²) |
| `reverse_speed_threshold` | 0.3 | Geri vites hız eşiği |
| `max_reverse_speed` | 3.0 | Maksimum geri vites hızı |
| `reverse_acceleration` | 6.0 | Geri vites hızlanması |
| `acceleration_curve` | 0.35 | Hızlanma eğrisi (0-1) |
| `min_acceleration_ratio` | 0.2 | Minimum hızlanma oranı |
| `friction` | 0.12 | Doğal sürtünme |

### Dönüş Ayarları

| Parametre | Varsayılan | Açıklama |
|-----------|------------|----------|
| `turn_speed` | 4.0 | Dönüş hızı (rad/s) |
| `low_speed_turn_factor` | 2.5 | Düşük hızlarda dönüş çarpanı |
| `high_speed_turn_factor` | 0.4 | Yüksek hızlarda dönüş çarpanı |
| `max_lean_angle_deg` | 42.0 | Maksimum yatış açısı |
| `lean_speed` | 5.0 | Yatış hızı |

### Zemin ve Collision

| Parametre | Varsayılan | Açıklama |
|-----------|------------|----------|
| `floor_max_angle_deg` | 60.0 | Maksimum zemin açısı |
| `floor_snap_distance` | 0.3 | Zemin snap mesafesi |
| `collision_slide_factor` | 0.99 | Collision kayma faktörü |
| `ground_align_speed` | 12.0 | Zemin hizalama hızı |
| `turn_slide_boost` | 5.0 | Dönüş kayma gücü |
| `min_velocity_boost` | 4.0 | Minimum velocity boost |
| `ground_align_force` | 20.0 | Zemin hizalama kuvveti |
| `ground_align_torque` | 10.0 | Zemin hizalama torku |
| `linear_damping` | 0.15 | Linear damping |
| `angular_damping` | 0.4 | Angular damping |

---

## 🎛️ Tuning Rehberi

### Dönüş Hissini Değiştirme

**Çok yavaş dönüyorsa:**
- `turn_speed` değerini artırın (4.0 → 6.0)
- `low_speed_turn_factor` değerini artırın (2.5 → 3.0)

**Çok hızlı/twitchy dönüyorsa:**
- `turn_speed` değerini azaltın (4.0 → 3.0)
- `high_speed_turn_factor` değerini azaltın (0.4 → 0.3)

**Düşük hızlarda çok keskin:**
- `low_speed_turn_factor` değerini azaltın (2.5 → 2.0)

**Yüksek hızlarda çok yumuşak:**
- `high_speed_turn_factor` değerini artırın (0.4 → 0.5)

### Hızlanma/Frenleme Hissini Değiştirme

**Çok yavaş hızlanıyorsa:**
- `acceleration` değerini artırın (10.0 → 15.0)
- `acceleration_curve` değerini azaltın (0.35 → 0.25)

**Çok hızlı hızlanıyorsa:**
- `acceleration` değerini azaltın (10.0 → 8.0)
- `acceleration_curve` değerini artırın (0.35 → 0.5)

**Frenleme çok güçsüz:**
- `brake_deceleration` değerini artırın (10.0 → 15.0)

**Frenleme çok güçlü:**
- `brake_deceleration` değerini azaltın (10.0 → 8.0)

### Geri Vites Ayarlama

**Geri vites çalışmıyorsa:**
- `reverse_speed_threshold` değerini artırın (0.3 → 0.5)
- `reverse_acceleration` değerini artırın (6.0 → 8.0)

**Geri vites çok yavaş:**
- `reverse_acceleration` değerini artırın (6.0 → 10.0)
- `max_reverse_speed` değerini artırın (3.0 → 4.0)

### Takılmaları Önleme

**Hala takılıyorsa:**
- `collision_slide_factor` değerini artırın (0.99 → 0.995)
- `turn_slide_boost` değerini artırın (5.0 → 7.0)
- `min_velocity_boost` değerini artırın (4.0 → 6.0)

**Çok kaygan:**
- `collision_slide_factor` değerini azaltın (0.99 → 0.95)
- `turn_slide_boost` değerini azaltın (5.0 → 3.0)

### Zemin ve Eğim Ayarları

**Eğimli yüzeylerde kayıyorsa:**
- `floor_max_angle_deg` değerini artırın (60.0 → 65.0)
- `ground_align_force` değerini artırın (20.0 → 25.0)
- `ground_align_torque` değerini artırın (10.0 → 12.0)

**Zemin hizalaması çok yavaş:**
- `ground_align_speed` değerini artırın (12.0 → 15.0)

---

## 🐛 Sorun Giderme

### Problem: Bisiklet takılıyor

**Çözümler:**
1. `collision_slide_factor` değerini artırın (0.99)
2. `turn_slide_boost` değerini artırın (5.0 → 7.0)
3. Collision shape'lerin boyutlarını kontrol edin
4. `min_velocity_boost` değerini artırın

### Problem: Sağa sola tam dönemiyor

**Çözümler:**
1. `turn_speed` değerini artırın (4.0 → 6.0)
2. `low_speed_turn_factor` değerini artırın (2.5 → 3.0)
3. `high_speed_turn_factor` değerini artırın (0.4 → 0.5)

### Problem: Geri vites çalışmıyor

**Çözümler:**
1. `reverse_speed_threshold` değerini artırın (0.3 → 0.5)
2. `reverse_acceleration` değerini artırın (6.0 → 8.0)
3. Geri vites kodunda `speed <= 0.01` kontrolünü kontrol edin

### Problem: Bisiklet çok sarsılıyor

**Çözümler:**
1. `linear_damping` değerini artırın (0.15 → 0.2)
2. `angular_damping` değerini artırın (0.4 → 0.5)
3. `ground_align_speed` değerini azaltın (12.0 → 8.0)
4. `lean_speed` değerini azaltın (5.0 → 3.0)

### Problem: Eğimli yüzeylerde kayıyor

**Çözümler:**
1. `floor_max_angle_deg` değerini artırın (60.0 → 65.0)
2. `ground_align_force` değerini artırın (20.0 → 25.0)
3. `ground_align_torque` değerini artırın (10.0 → 12.0)
4. RayCast'ların doğru yönlendirildiğinden emin olun

### Problem: Collision detection çalışmıyor

**Çözümler:**
1. Collision layers/masks'i kontrol edin
2. CollisionShape3D'lerin doğru ayarlandığından emin olun
3. `_apply_collision_sliding()` fonksiyonunun çağrıldığından emin olun

---

## 📚 Geliştirme Geçmişi

### Versiyon 1.0 - İlk Implementasyon
- Temel hareket sistemi
- Dönüş mekaniği
- Yatış efekti
- Zemin hizalama
- IK sistemi
- Pedal animasyonu

### Versiyon 2.0 - Speed-Dependent Steering
- Hıza bağlı dönüş faktörleri
- Düşük/yüksek hız dönüş ayarları
- Smooth interpolation

### Versiyon 3.0 - Reverse Braking
- Geri vites sistemi
- Düşük hızlarda geri hareket
- Reverse speed threshold

### Versiyon 4.0 - Visual Steering
- Görsel gidon dönüşü
- FrontWheel visual rotation
- Smooth visual interpolation

### Versiyon 5.0 - Camera Polish
- Camera shake (hıza bağlı)
- Camera bob (hıza bağlı)
- Look-ahead efekti
- Smooth camera follow
- FOV adjustment

### Versiyon 6.0 - Input System
- Mouse steering desteği
- A/D tuş kontrolü
- Input smoothing

### Versiyon 7.0 - Collision System
- Collision sliding
- Takılma önleme
- Dönüş sırasında özel kayma

### Versiyon 8.0 - CharacterBody3D Migration
- CharacterBody3D'ye geçiş
- move_and_slide() implementasyonu
- Floor detection sistemi

### Versiyon 9.0 - RigidBody3D Optimization
- RigidBody3D'ye geri dönüş
- Optimize edilmiş fizik
- Gelişmiş collision handling

### Versiyon 10.0 - Final Polish
- Tüm ayarların optimize edilmesi
- Dönüş mekaniği iyileştirmeleri
- Geri vites düzeltmeleri
- Lateral force eklenmesi
- Restart game fonksiyonu

---

## 💡 İpuçları ve Best Practices

### 1. Ayarlama Stratejisi
- Değerleri küçük adımlarla değiştirin (0.5-1.0 arası)
- Her değişiklikten sonra test edin
- Bir parametreyi değiştirirken diğerlerini sabit tutun

### 2. Performance
- RayCast'ları optimize edin (mesafe ayarları)
- Collision detection'ı sınırlayın
- Gereksiz hesaplamalardan kaçının

### 3. Debugging
- `print()` ile hız ve dönüş değerlerini kontrol edin
- Godot'un Debug menüsünden collision shapes'ları görselleştirin
- RayCast'ların doğru çalıştığını kontrol edin

### 4. Testing
- Farklı zemin tiplerinde test edin (düz, eğimli, düzensiz)
- Farklı hızlarda test edin
- Collision senaryolarını test edin

---

## 📖 Kod Örnekleri

### Hız Hesaplama
```gdscript
func _calculate_speed() -> void:
	var forward_dir: Vector3 = -transform.basis.z
	speed = linear_velocity.dot(forward_dir)
```

### Dönüş Uygulama
```gdscript
func _apply_steering(delta: float) -> void:
	var speed_ratio: float = clamp(abs(speed) / max_speed, 0.0, 1.0)
	var turn_factor: float = lerp(low_speed_turn_factor, high_speed_turn_factor, speed_ratio)
	var turn_torque: float = steer_input * turn_speed * turn_factor
	apply_torque(Vector3.UP * turn_torque)
```

### Collision Sliding
```gdscript
func _apply_collision_sliding(delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var forward_dir: Vector3 = -transform.basis.z
	var front_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + forward_dir * 1.5
	)
	front_query.exclude = [self.get_rid()]
	var front_result: Dictionary = space_state.intersect_ray(front_query)
	
	if front_result:
		var collision_normal: Vector3 = front_result.get("normal", Vector3.UP)
		var slid_velocity: Vector3 = linear_velocity.slide(collision_normal)
		linear_velocity = slid_velocity * collision_slide_factor
```

---

## 🎯 Sonuç

Bu bisiklet kontrolcüsü, gerçekçi ama arcade-friendly bir sürüş deneyimi sunmak için tasarlanmıştır. Tüm özellikler optimize edilmiş ve test edilmiştir. Ayarları ihtiyacınıza göre değiştirerek istediğiniz sürüş hissini elde edebilirsiniz.

### Destek
Sorun yaşarsanız:
1. Bu dokümantasyonu kontrol edin
2. Sorun giderme bölümüne bakın
3. Ayarları optimize edin
4. Kod yorumlarını okuyun

### Güncellemeler
Sistem sürekli geliştirilmektedir. Yeni özellikler ve iyileştirmeler için scriptleri kontrol edin.

---

**Son Güncelleme:** Versiyon 10.0  
**Godot Versiyonu:** 4.5.1  
**Dil:** GDScript (Typed)
