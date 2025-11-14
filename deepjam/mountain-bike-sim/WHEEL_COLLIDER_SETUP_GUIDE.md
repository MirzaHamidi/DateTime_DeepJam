# Tekerlek Collider Kurulum Rehberi

Bu rehber, bisiklet tekerleklerinin collider'larını doğru şekilde ayarlamak ve takılmaları azaltmak için gereken adımları açıklar.

## 📋 İçindekiler

1. [Tekerlek Collider Yapısı](#tekerlek-collider-yapısı)
2. [Collider Ayarları](#collider-ayarları)
3. [Takılmaları Azaltma İpuçları](#takılmaları-azaltma-ipuçları)
4. [Fizik Ayarları](#fizik-ayarları)
5. [Sorun Giderme](#sorun-giderme)

---

## 🎯 Tekerlek Collider Yapısı

### Önerilen Yapı

```
BikeRoot (RigidBody3D)
├── FrontWheel (Node3D)
│   ├── CollisionShape3D (SphereShape3D)  ← Ön tekerlek collider 1
│   ├── CollisionShape3D (SphereShape3D)  ← Ön tekerlek collider 2
│   └── RayCast3D
└── RearWheel (Node3D)
    ├── CollisionShape3D (SphereShape3D)   ← Arka tekerlek collider 1
    ├── CollisionShape3D (SphereShape3D)   ← Arka tekerlek collider 2
    └── RayCast3D
```

### Collider Konumlandırma

- **Sphere Collider'lar:** Tekerleklerin her iki yanında (sol ve sağ) konumlandırılmalı
- **Yarıçap:** Tekerlek yarıçapına yakın olmalı (genellikle 0.3 - 0.5 metre)
- **Yükseklik:** Tekerlek merkezinde, yere yakın olmalı
- **Mesafe:** İki collider arasında yeterli mesafe olmalı (takılmaları azaltır)

---

## ⚙️ Collider Ayarları

### Godot Editor'da Ayarlama

1. **CollisionShape3D Seçin:**
   - FrontWheel veya RearWheel içindeki CollisionShape3D'yi seçin

2. **Shape Ayarları:**
   - **Shape:** `SphereShape3D` seçin
   - **Radius:** Tekerlek yarıçapına göre ayarlayın (0.3 - 0.5 m)

3. **Position (Lokal):**
   - Sol collider: `(-0.2, 0, 0)` veya benzeri
   - Sağ collider: `(0.2, 0, 0)` veya benzeri
   - Yükseklik: `(0, -0.1, 0)` veya yere göre ayarlayın

### PhysicsMaterial Kullanımı (Önerilen)

1. **Yeni PhysicsMaterial Oluştur:**
   - Project panel'de sağ tık → New Resource → PhysicsMaterial
   - İsim: `WheelMaterial`

2. **PhysicsMaterial Ayarları:**
   - **Friction:** `0.2` (düşük sürtünme, takılmaları azaltır)
   - **Bounce:** `0.05` (minimal zıplama)
   - **Absorb:** `0.0` (varsayılan)

3. **CollisionShape3D'ye Atama:**
   - CollisionShape3D seçin
   - Inspector'da "Material" alanına `WheelMaterial`'ı sürükleyin

---

## 🔧 Takılmaları Azaltma İpuçları

### 1. Collider Boyutları

- **Çok Büyük Collider:** Takılmalara neden olur
- **Çok Küçük Collider:** Yere temas etmeyebilir
- **Önerilen:** Tekerlek yarıçapının %80-90'ı

### 2. Collider Konumlandırma

- **Yükseklik:** Tekerlek merkezinde, yere yakın
- **Yatay Mesafe:** İki collider arasında yeterli mesafe (0.3 - 0.5 m)
- **Dikey Hizalama:** Tekerleklerin alt kısmında, yere temas edecek şekilde

### 3. Collision Layers ve Masks

- **Collision Layer:** Bisiklet için ayrı bir layer kullanın
- **Collision Mask:** Sadece zemin (ground) ile çarpışmalı
- **Diğer Objeler:** Bisiklet collider'ları diğer objelerle çarpışmamalı (opsiyonel)

### 4. RigidBody3D Ayarları

BikeController scripti otomatik olarak şu ayarları yapar:
- **Linear Damping:** `0.1` (stabil hareket)
- **Angular Damping:** `0.3` (az sarsılma)
- **Center of Mass:** `(0, -0.2, 0)` (daha stabil)

---

## 🎮 Fizik Ayarları (BikeController.gd)

### Export Değişkenleri

Script'te şu ayarları bulabilirsiniz:

```gdscript
@export_group("Tekerlek Collider Ayarları")
@export var wheel_friction: float = 0.2        # Sürtünme (düşük = kaygan)
@export var wheel_bounce: float = 0.05         # Zıplama (düşük = stabil)
@export var wheel_suspension_force: float = 100.0  # Yere yapışma kuvveti
@export var wheel_suspension_distance: float = 0.2  # Suspension mesafesi
```

### Ayarlama Önerileri

1. **Takılmalar Varsa:**
   - `wheel_friction` değerini düşürün (0.1 - 0.15)
   - `wheel_suspension_force` değerini artırın (150 - 200)
   - `wheel_suspension_distance` değerini artırın (0.3 - 0.4)

2. **Çok Kaygan İse:**
   - `wheel_friction` değerini artırın (0.25 - 0.3)
   - `wheel_suspension_force` değerini azaltın (50 - 80)

3. **Zıplama Varsa:**
   - `wheel_bounce` değerini azaltın (0.0 - 0.02)
   - `wheel_suspension_force` değerini artırın

---

## 🐛 Sorun Giderme

### Problem: Bisiklet Takılıyor

**Çözümler:**
1. Collider boyutlarını küçültün
2. Collider'ları tekerlek merkezinden biraz yukarı taşıyın
3. `wheel_friction` değerini düşürün (0.1 - 0.15)
4. `wheel_suspension_force` değerini artırın (150 - 200)
5. Collision layers/masks'i kontrol edin

### Problem: Bisiklet Yere Temas Etmiyor

**Çözümler:**
1. Collider boyutlarını büyütün
2. Collider'ları aşağı taşıyın
3. RayCast3D'lerin `target_position`'ını kontrol edin (aşağı doğru olmalı)
4. `wheel_suspension_distance` değerini artırın (0.3 - 0.4)

### Problem: Bisiklet Çok Zıplıyor

**Çözümler:**
1. `wheel_bounce` değerini azaltın (0.0 - 0.02)
2. `wheel_suspension_force` değerini artırın
3. RigidBody3D'nin `angular_damp` değerini artırın (0.4 - 0.5)
4. Collider'ların PhysicsMaterial'ında `Bounce` değerini kontrol edin

### Problem: Bisiklet Çok Kaygan

**Çözümler:**
1. `wheel_friction` değerini artırın (0.25 - 0.3)
2. PhysicsMaterial'da `Friction` değerini artırın
3. `wheel_suspension_force` değerini azaltın

---

## 📝 Örnek Collider Konfigürasyonu

### Ön Tekerlek (FrontWheel)

```
FrontWheel (Node3D)
├── CollisionShape3D (Sol)
│   ├── Position: (-0.25, -0.1, 0)
│   ├── Shape: SphereShape3D
│   ├── Radius: 0.35
│   └── Material: WheelMaterial
└── CollisionShape3D (Sağ)
    ├── Position: (0.25, -0.1, 0)
    ├── Shape: SphereShape3D
    ├── Radius: 0.35
    └── Material: WheelMaterial
```

### Arka Tekerlek (RearWheel)

```
RearWheel (Node3D)
├── CollisionShape3D (Sol)
│   ├── Position: (-0.25, -0.1, 0)
│   ├── Shape: SphereShape3D
│   ├── Radius: 0.35
│   └── Material: WheelMaterial
└── CollisionShape3D (Sağ)
    ├── Position: (0.25, -0.1, 0)
    ├── Shape: SphereShape3D
    ├── Radius: 0.35
    └── Material: WheelMaterial
```

---

## ✅ Kontrol Listesi

- [ ] Her tekerlekte 2 adet SphereShape3D collider var
- [ ] Collider'lar tekerlek merkezinde, yere yakın konumlandırılmış
- [ ] Collider'lar arasında yeterli mesafe var (0.3 - 0.5 m)
- [ ] PhysicsMaterial oluşturulmuş ve atanmış
- [ ] PhysicsMaterial'da Friction = 0.2, Bounce = 0.05
- [ ] RayCast3D'ler aşağı doğru yönlendirilmiş
- [ ] BikeController scripti doğru ayarlanmış
- [ ] Collision layers/masks doğru ayarlanmış

---

## 💡 İpuçları

1. **Test Edin:** Her değişiklikten sonra oyunu test edin
2. **Kademeli Ayarlama:** Değerleri küçük adımlarla değiştirin
3. **Fizik Simülasyonu:** Godot editor'da "Play" butonuna basarak test edin
4. **Debug Görünümü:** Collision shapes'ları görselleştirmek için "Debug" menüsünden "Visible Collision Shapes" seçeneğini açın

---

## 📚 Ek Kaynaklar

- [Godot PhysicsMaterial Dokümantasyonu](https://docs.godotengine.org/en/stable/classes/class_physicsmaterial.html)
- [RigidBody3D Dokümantasyonu](https://docs.godotengine.org/en/stable/classes/class_rigidbody3d.html)
- [CollisionShape3D Dokümantasyonu](https://docs.godotengine.org/en/stable/classes/class_collisionshape3d.html)

