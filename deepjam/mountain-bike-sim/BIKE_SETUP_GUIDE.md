# Bisiklet Kontrol Sistemi Kurulum Rehberi

## 1. NODE HİYERARŞİSİ

Aşağıdaki node hiyerarşisini Godot editöründe oluşturmanız gerekmektedir:

```
BikeRoot (RigidBody3D)
├── BikeController.gd (script)
├── FrontWheel (Node3D)
│   └── RayCast3D
│       └── enabled = true
│       └── target_position = Vector3(0, -2, 0)
│       └── collision_mask = 1 (veya uygun layer)
├── RearWheel (Node3D)
│   └── RayCast3D
│       └── enabled = true
│       └── target_position = Vector3(0, -2, 0)
│       └── collision_mask = 1 (veya uygun layer)
├── Skeleton3D (sürücü skeleton'ı)
│   └── skeleton_modification_stack (SkeletonModificationStack3D)
│       └── enabled = true
├── IKTargets (Node3D)
│   ├── LeftFootTarget (Node3D)
│   ├── RightFootTarget (Node3D)
│   ├── LeftHandTarget (Node3D)
│   └── RightHandTarget (Node3D)
├── BikeIKController (Node3D)
│   └── BikeIKController.gd (script)
└── CameraRig (SpringArm3D)
    ├── Camera3D
	│   └── CameraController.gd (script) [Camera3D'e eklenebilir veya CameraRig'e]
    └── spring_length = 5.0 (veya istediğiniz mesafe)
```

**Not:** `BikeController.gd` scripti `BikeRoot` (RigidBody3D) node'una eklenmelidir.
**Not:** `BikeIKController.gd` scripti `BikeIKController` (Node3D) node'una eklenmelidir.
**Not:** `CameraController.gd` scripti `CameraRig` (SpringArm3D) veya `Camera3D` node'una eklenebilir.

---

## 2. GODOT EDITÖRÜNDE KURULUM ADIMLARI

### Adım 1: BikeRoot (RigidBody3D) Oluşturma

1. Scene'de root node'u seçin (veya yeni bir scene oluşturun)
2. **BikeRoot** adında bir **RigidBody3D** ekleyin
   - **ÖNEMLİ:** Node tipi mutlaka **RigidBody3D** olmalı, Node3D değil!
   - Eğer yanlışlıkla Node3D oluşturduysanız:
	 - Node'u seçin
	 - Inspector'da node tipi dropdown'ından **RigidBody3D** seçin
	 - Veya node'u silip yeni bir RigidBody3D oluşturun
3. `BikeController.gd` scriptini `BikeRoot` node'una ekleyin:
   - Node'u seçin
   - Inspector'da "Attach Script" butonuna tıklayın
   - `Scripts/BikeController.gd` dosyasını seçin
   - **Hata alırsanız:** Node tipinin RigidBody3D olduğundan emin olun!

### Adım 2: Tekerlekler ve RayCast'lar

1. **FrontWheel** adında bir **Node3D** ekleyin (BikeRoot'un child'ı olarak)
2. FrontWheel'in altına bir **RayCast3D** ekleyin
3. RayCast3D'yi seçin ve Inspector'da:
   - `enabled = true` yapın
   - `target_position = Vector3(0, -2, 0)` ayarlayın (2 metre aşağıya bakacak)
   - `collision_mask` değerini zemin layer'ınıza göre ayarlayın (genellikle 1)
4. Aynı işlemleri **RearWheel** için tekrarlayın

### Adım 3: Skeleton3D ve IK Hedefleri

1. **Skeleton3D** node'unu ekleyin (sürücü modeliniz varsa, onu import edin)
2. Skeleton3D'yi seçin ve Inspector'da:
   - `SkeletonModificationStack3D` oluşturun (yoksa)
   - Stack'i **enabled = true** yapın
3. **IKTargets** adında bir **Node3D** ekleyin
4. IKTargets'in altına şu node'ları ekleyin:
   - **LeftFootTarget** (Node3D)
   - **RightFootTarget** (Node3D)
   - **LeftHandTarget** (Node3D)
   - **RightHandTarget** (Node3D)

### Adım 4: IK Controller Script'i

1. **BikeIKController** adında bir **Node3D** ekleyin (BikeRoot'un child'ı)
2. `BikeIKController.gd` scriptini bu node'a ekleyin
3. Inspector'da şu export değişkenlerini ayarlayın:
   - `rider_skeleton`: Skeleton3D node'unu sürükleyip bırakın
   - `left_foot_target`, `right_foot_target`, `left_hand_target`, `right_hand_target`: İlgili node'ları atayın
   - **Bone isimlerini** skeleton'ınızdaki kemik isimlerine göre ayarlayın:
	 - Örnek: `left_thigh_bone = "thigh_L"` veya `"UpperLeg_L"` (skeleton'ınıza göre)
     - Örnek: `left_calf_bone = "calf_L"` veya `"LowerLeg_L"`
     - Örnek: `left_foot_bone = "foot_L"` veya `"Foot_L"`
     - Aynı şekilde sağ bacak ve kollar için de ayarlayın

### Adım 5: Kamera Sistemi

1. **CameraRig** adında bir **SpringArm3D** ekleyin (BikeRoot'un child'ı)
2. SpringArm3D'yi seçin ve Inspector'da:
   - `spring_length = 5.0` (veya istediğiniz mesafe)
   - `collision_mask` ayarlayın
3. CameraRig'in altına bir **Camera3D** ekleyin
4. `CameraController.gd` scriptini **CameraRig** node'una ekleyin (veya Camera3D'ye)
5. Inspector'da:
   - `spring_arm`: CameraRig node'unu atayın
   - `camera`: Camera3D node'unu atayın
   - `bike_controller`: BikeRoot (RigidBody3D) node'unu atayın

### Adım 6: BikeController Export Ayarları

1. **BikeRoot** node'unu seçin
2. Inspector'da `BikeController.gd` script ayarlarını kontrol edin:
   - `front_wheel`, `rear_wheel`, `ik_targets` gibi node referansları otomatik bulunacak
   - Eğer bulunamazsa, manuel olarak atayın
   - Fizik değerlerini (max_forward_force, brake_force, vb.) ihtiyacınıza göre ayarlayın

### Adım 7: RigidBody3D Fizik Ayarları

1. **BikeRoot** (RigidBody3D) node'unu seçin
2. Inspector'da:
   - `Mass`: 80-120 kg arası (bisiklet + sürücü)
   - `Gravity Scale`: 1.0
   - `Lock Rotation`: Kapalı (false) - bisiklet her yöne dönebilmeli
   - `Collision Layer` ve `Collision Mask` ayarlayın

### Adım 8: Collision Shape

1. BikeRoot'un altına bir **CollisionShape3D** ekleyin
2. CollisionShape3D'ye uygun bir shape atayın (CapsuleShape3D veya BoxShape3D)
3. Shape'i bisiklet boyutlarına göre ayarlayın

### Adım 9: Input Actions Kontrolü

1. Project Settings > Input Map'e gidin
2. Şu action'ların tanımlı olduğundan emin olun:
   - `bike_accelerate` (W tuşu)
   - `bike_brake` (S tuşu)
   - `bike_steer_left` (A tuşu)
   - `bike_steer_right` (D tuşu)

### Adım 10: Test ve Ayarlama

1. Scene'i çalıştırın
2. Bisiklet hareket etmiyorsa:
   - RayCast'ların `enabled = true` olduğundan emin olun
   - Collision mask'ların doğru ayarlandığından emin olun
   - Zemin'in collision layer'ının doğru olduğundan emin olun
3. IK çalışmıyorsa:
   - Skeleton3D'de modification stack'in `enabled = true` olduğundan emin olun
   - Bone isimlerinin doğru olduğundan emin olun
   - IK target node'larının pozisyonlarının doğru olduğundan emin olun
4. Kamera çalışmıyorsa:
   - CameraController'daki bike_controller referansının doğru olduğundan emin olun
   - SpringArm'ın collision mask'ının doğru olduğundan emin olun

---

## 3. ÖNEMLİ NOTLAR

### Bone İsimleri

Skeleton'ınızdaki kemik isimleri farklı olabilir. Godot'da skeleton'ı seçip "Skeleton" menüsünden "Edit Skeleton" ile kemik isimlerini görebilirsiniz. `BikeIKController.gd` scriptindeki export değişkenlerini bu isimlere göre ayarlayın.

### RayCast Ayarları

RayCast'ların `target_position` değeri, bisikletin yerden ne kadar yüksekte olduğuna göre ayarlanmalıdır. Eğer bisiklet yüksekse, `target_position.y` değerini daha negatif yapın (ör: -3.0).

### IK Target Pozisyonları

IK target'ların başlangıç pozisyonları, pedalların ve gidon tutamaklarının gerçek pozisyonlarına göre ayarlanmalıdır. Scene'de bu node'ları seçip pozisyonlarını manuel olarak ayarlayabilirsiniz.

### Fizik Değerleri

`BikeController.gd` scriptindeki fizik değerleri (max_forward_force, brake_force, vb.) bisikletin ağırlığına ve istediğiniz oynanış hissine göre ayarlanmalıdır. Daha ağır bisikletler için daha yüksek kuvvet değerleri gerekebilir.

---

## 4. SORUN GİDERME

### Bisiklet yere düşüyor
- RayCast'ların `enabled = true` olduğundan emin olun
- `ground_align_strength` ve `ground_align_torque` değerlerini artırın

### Bisiklet çok yavaş hızlanıyor
- `max_forward_force` değerini artırın
- `max_speed` değerini kontrol edin

### IK çalışmıyor
- Skeleton3D'de modification stack'in `enabled = true` olduğundan emin olun
- Bone isimlerinin doğru olduğundan emin olun
- Console'da hata mesajlarını kontrol edin

### Kamera FOV değişmiyor
- `CameraController.gd` scriptindeki `bike_controller` referansının doğru olduğundan emin olun
- `BikeController.gd` scriptindeki `get_speed()` fonksiyonunun çalıştığından emin olun

---

## 5. EK ÖZELLİKLER (İsteğe Bağlı)

### Gidon Rotasyonu

Gidon tutamaklarını dönüş girdisine göre döndürmek isterseniz, `BikeController.gd` scriptine ek bir fonksiyon ekleyebilirsiniz.

### Ses Efektleri

Bisiklet hızına göre ses efektleri eklemek için `BikeController.gd` scriptine AudioStreamPlayer3D ekleyebilirsiniz.

### Partikül Efektleri

Tekerleklerden çıkan toz partikülleri için `BikeController.gd` scriptine GPUParticles3D ekleyebilirsiniz.
