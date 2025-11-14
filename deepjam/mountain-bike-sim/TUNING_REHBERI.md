# Bisiklet Kontrolcüsü - Tuning Rehberi

Bu rehber, bisiklet kontrolcüsünün ayarlarını optimize etmek için hangi parametrelerin değiştirilmesi gerektiğini açıklar.

## 🎯 Hızlanma & Frenleme

### Hızlanma Hissini Değiştirme

**Çok yavaş hızlanıyorsa:**
- `acceleration` değerini artırın (10.0 → 15.0)
- `acceleration_curve` değerini azaltın (0.35 → 0.25)
- `min_acceleration_ratio` değerini artırın (0.2 → 0.3)

**Çok hızlı hızlanıyorsa:**
- `acceleration` değerini azaltın (10.0 → 8.0)
- `acceleration_curve` değerini artırın (0.35 → 0.5)
- `min_acceleration_ratio` değerini azaltın (0.2 → 0.15)

**Maksimum hız çok düşük/yüksek:**
- `max_speed` değerini değiştirin (10.0 → istediğiniz değer)

### Frenleme Hissini Değiştirme

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

**Geri vites çok hızlı:**
- `reverse_acceleration` değerini azaltın (6.0 → 4.0)
- `max_reverse_speed` değerini azaltın (3.0 → 2.0)

---

## 🔄 Dönüş

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

**Yatış (lean) çok fazla/az:**
- `max_lean_angle_deg` değerini değiştirin (42.0 → istediğiniz değer)
- `lean_speed` değerini değiştirin (5.0 → istediğiniz değer)

---

## 🏔️ Eğimli Yüzeyler & Takılma

### Eğimli Yüzeylerde Davranış

**Eğimli yüzeylerde kayıyorsa:**
- `ground_align_force` değerini artırın (20.0 → 25.0)
- `ground_align_torque` değerini artırın (10.0 → 12.0)
- `ground_align_speed` değerini artırın (12.0 → 15.0)

**Zemin hizalaması çok yavaş:**
- `ground_align_speed` değerini artırın (12.0 → 15.0)

**Zemin hizalaması çok hızlı (sarsıntılı):**
- `ground_align_speed` değerini azaltın (12.0 → 8.0)
- `ground_align_force` değerini azaltın (20.0 → 15.0)
- `ground_align_torque` değerini azaltın (10.0 → 7.0)

### Takılma Önleme

**Hala takılıyorsa:**
- `collision_slide_factor` değerini artırın (0.99 → 0.995)
- `turn_slide_boost` değerini artırın (5.0 → 7.0)
- `min_velocity_boost` değerini artırın (4.0 → 6.0)

**Çok kaygan (duvarlara yapışmıyor):**
- `collision_slide_factor` değerini azaltın (0.99 → 0.95)
- `turn_slide_boost` değerini azaltın (5.0 → 3.0)

### Genel Stabilite

**Bisiklet çok sarsılıyor:**
- `linear_damping` değerini artırın (0.15 → 0.2)
- `angular_damping` değerini artırın (0.4 → 0.5)
- `ground_align_speed` değerini azaltın (12.0 → 8.0)
- `lean_speed` değerini azaltın (5.0 → 3.0)

**Bisiklet çok yavaş duruyor:**
- `linear_damping` değerini artırın (0.15 → 0.25)
- `friction` değerini artırın (0.12 → 0.18)

**Bisiklet çok hızlı duruyor:**
- `linear_damping` değerini azaltın (0.15 → 0.1)
- `friction` değerini azaltın (0.12 → 0.08)

---

## 📊 Önerilen Değer Aralıkları

### Hareket
- `max_speed`: 5.0 - 20.0
- `acceleration`: 5.0 - 20.0
- `brake_deceleration`: 5.0 - 20.0
- `acceleration_curve`: 0.2 - 0.6
- `friction`: 0.05 - 0.2

### Dönüş
- `turn_speed`: 2.0 - 8.0
- `low_speed_turn_factor`: 1.5 - 4.0
- `high_speed_turn_factor`: 0.2 - 0.8
- `max_lean_angle_deg`: 30.0 - 50.0
- `lean_speed`: 3.0 - 8.0

### Zemin ve Collision
- `collision_slide_factor`: 0.95 - 0.995
- `ground_align_force`: 15.0 - 30.0
- `ground_align_torque`: 7.0 - 15.0
- `ground_align_speed`: 8.0 - 18.0
- `turn_slide_boost`: 3.0 - 8.0
- `min_velocity_boost`: 3.0 - 7.0
- `linear_damping`: 0.1 - 0.3
- `angular_damping`: 0.3 - 0.6

---

## 💡 İpuçları

1. **Küçük adımlarla değiştirin:** Değerleri 0.5-1.0 arası adımlarla değiştirin
2. **Tek seferde bir parametre:** Bir parametreyi değiştirirken diğerlerini sabit tutun
3. **Test edin:** Her değişiklikten sonra oyunu test edin
4. **Not alın:** Hangi değerlerin iyi çalıştığını not alın
5. **Profilleme:** Godot'un profiler'ını kullanarak performansı kontrol edin

---

## 🔧 Hızlı Ayarlar

### Arcade Hissi (Daha Responsive)
```
turn_speed = 6.0
low_speed_turn_factor = 3.0
acceleration = 15.0
brake_deceleration = 15.0
```

### Gerçekçi Hissi (Daha Yumuşak)
```
turn_speed = 3.0
high_speed_turn_factor = 0.3
acceleration = 8.0
brake_deceleration = 8.0
linear_damping = 0.2
angular_damping = 0.5
```

### Takılma Önleme (Maksimum)
```
collision_slide_factor = 0.995
turn_slide_boost = 7.0
min_velocity_boost = 6.0
```

