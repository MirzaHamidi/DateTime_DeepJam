# Bisiklet Kontrolcü Ayarlama Rehberi (CharacterBody3D)

Bu rehber, CharacterBody3D tabanlı bisiklet kontrolcüsünün ayarlarını nasıl optimize edeceğinizi açıklar.

## 📋 İçindekiler

1. [Hızlanma ve Frenleme Hissi](#hızlanma-ve-frenleme-hissi)
2. [Eğim ve Zemin İşleme](#eğim-ve-zemin-işleme)
3. [Collision ve Takılma Önleme](#collision-ve-takılma-önleme)
4. [Dönüş ve Yatış](#dönüş-ve-yatış)
5. [Genel Optimizasyon İpuçları](#genel-optimizasyon-ipuçları)

---

## 🚀 Hızlanma ve Frenleme Hissi

### Hızlanma Hissini Değiştirme

**`acceleration` (m/s²)**
- **Ne yapar:** Bisikletin ne kadar hızlı hızlanacağını belirler
- **Düşük değer (5-8):** Yavaş, gerçekçi hızlanma
- **Orta değer (10-15):** Dengeli, arcade tarzı hızlanma
- **Yüksek değer (18-25):** Çok hızlı, arcade hızlanma
- **Önerilen:** `12.0` (başlangıç değeri)

**`acceleration_curve` (0.0 - 1.0)**
- **Ne yapar:** Düşük hızlarda daha güçlü, yüksek hızlarda daha yumuşak hızlanma
- **0.0:** Sabit hızlanma (her hızda aynı)
- **0.5:** Dengeli eğri (önerilen)
- **1.0:** Tamamen hıza bağlı (yüksek hızlarda çok yavaş)
- **Önerilen:** `0.5`

**`min_acceleration_ratio` (0.0 - 1.0)**
- **Ne yapar:** Yüksek hızlarda bile minimum bu kadar hızlanma uygulanır
- **Düşük değer (0.1-0.2):** Yüksek hızlarda çok yavaş hızlanma
- **Yüksek değer (0.4-0.5):** Yüksek hızlarda da güçlü hızlanma
- **Önerilen:** `0.3`

### Frenleme Hissini Değiştirme

**`brake_deceleration` (m/s²)**
- **Ne yapar:** Bisikletin ne kadar hızlı yavaşlayacağını belirler
- **Düşük değer (10-15):** Yavaş frenleme
- **Orta değer (18-25):** Dengeli frenleme
- **Yüksek değer (30-40):** Çok güçlü frenleme
- **Önerilen:** `20.0`

**`reverse_acceleration` (m/s²)**
- **Ne yapar:** Geri vites modunda ne kadar hızlı geri gideceğini belirler
- **Düşük değer (2-3):** Yavaş geri vites
- **Yüksek değer (5-7):** Hızlı geri vites
- **Önerilen:** `4.0`

### Maksimum Hız

**`max_speed` (m/s)**
- **Ne yapar:** Bisikletin ulaşabileceği maksimum hız
- **Düşük değer (8-12):** Yavaş bisiklet
- **Orta değer (15-18):** Dengeli bisiklet
- **Yüksek değer (20-25):** Çok hızlı bisiklet
- **Önerilen:** `15.0`

---

## ⛰️ Eğim ve Zemin İşleme

### Eğimli Yüzeylerde Çalışma

**`floor_max_angle_deg` (derece)**
- **Ne yapar:** Bisikletin üzerinde durabileceği maksimum eğim açısı
- **Düşük değer (30-40):** Sadece düz yüzeylerde durabilir
- **Orta değer (45-55):** Orta eğimli yüzeylerde durabilir
- **Yüksek değer (60-70):** Çok dik yüzeylerde bile durabilir
- **Önerilen:** `50.0`
- **Not:** Bu açıdan daha dik yüzeylerde bisiklet kayar

**`floor_snap_distance` (metre)**
- **Ne yapar:** Bisikletin zemine "yapışması" için kullanılan mesafe
- **Düşük değer (0.1-0.15):** Sadece çok yakın zeminlerde snap yapar
- **Orta değer (0.2-0.25):** Dengeli snap mesafesi
- **Yüksek değer (0.3-0.4):** Uzak mesafelerden snap yapar
- **Önerilen:** `0.2`
- **Not:** Yüksek değerler, bisikletin havada "yapışmasına" neden olabilir

**`floor_snap_speed`**
- **Ne yapar:** Zemin snap'inin ne kadar hızlı olacağını belirler
- **Düşük değer (5-8):** Yavaş snap (daha smooth)
- **Yüksek değer (12-15):** Hızlı snap (daha responsive)
- **Önerilen:** `10.0`

**`ground_align_speed`**
- **Ne yapar:** Bisikletin zemine ne kadar hızlı hizalanacağını belirler
- **Düşük değer (5-7):** Yavaş hizalama (daha smooth)
- **Yüksek değer (10-12):** Hızlı hizalama (daha responsive)
- **Önerilen:** `8.0`

### Uneven Terrain (Düzensiz Zemin)

Eğer bisiklet küçük tümseklerde veya düzensiz zeminlerde sarsılıyorsa:

1. **`floor_snap_distance`** değerini artırın (0.25-0.3)
2. **`ground_align_speed`** değerini azaltın (5-6) - daha smooth hizalama
3. **`floor_snap_speed`** değerini azaltın (7-8) - daha smooth snap

---

## 🚧 Collision ve Takılma Önleme

### Takılmaları Önleme

**`collision_slide_factor` (0.0 - 1.0)**
- **Ne yapar:** Duvar veya engellere çarptığında ne kadar kayacağını belirler
- **0.0:** Hiç kaymaz (takılır) ❌
- **0.5-0.7:** Orta kayma
- **0.8-0.9:** Güçlü kayma (önerilen) ✅
- **1.0:** Tamamen kayar (çok kaygan)
- **Önerilen:** `0.8`
- **Not:** Bu, bisikletin duvarlara çarptığında takılmasını önler

### Collision Sliding Nasıl Çalışır?

1. **move_and_slide()** collision'ı tespit eder
2. **`_handle_collision_sliding()`** fonksiyonu çalışır
3. Velocity, collision normal'ine göre kaydırılır
4. Bisiklet duvar boyunca kayar, takılmaz

**Sorun Giderme:**
- **Hala takılıyorsa:** `collision_slide_factor` değerini artırın (0.85-0.9)
- **Çok kaygan:** `collision_slide_factor` değerini azaltın (0.7-0.75)

---

## 🎮 Dönüş ve Yatış

### Dönüş Hissini Değiştirme

**`turn_speed` (rad/s)**
- **Ne yapar:** Bisikletin ne kadar hızlı döneceğini belirler
- **Düşük değer (1.5-2.0):** Yavaş dönüş
- **Orta değer (2.5-3.0):** Dengeli dönüş
- **Yüksek değer (3.5-4.5):** Çok hızlı dönüş
- **Önerilen:** `2.5`

**`low_speed_turn_factor`**
- **Ne yapar:** Düşük hızlarda dönüş çarpanı
- **Düşük değer (1.0-1.2):** Düşük hızlarda yumuşak dönüş
- **Yüksek değer (1.8-2.2):** Düşük hızlarda keskin dönüş
- **Önerilen:** `1.5`

**`high_speed_turn_factor`**
- **Ne yapar:** Yüksek hızlarda dönüş çarpanı
- **Düşük değer (0.1-0.2):** Yüksek hızlarda çok yumuşak dönüş
- **Yüksek değer (0.3-0.4):** Yüksek hızlarda daha keskin dönüş
- **Önerilen:** `0.2`

### Yatış (Lean)

**`max_lean_angle_deg` (derece)**
- **Ne yapar:** Bisikletin dönüş sırasında ne kadar yatabileceğini belirler
- **Düşük değer (25-30):** Az yatış
- **Orta değer (35-40):** Dengeli yatış
- **Yüksek değer (45-50):** Çok fazla yatış
- **Önerilen:** `35.0`

**`lean_speed`**
- **Ne yapar:** Yatışın ne kadar hızlı olacağını belirler
- **Düşük değer (4-5):** Yavaş yatış
- **Yüksek değer (7-8):** Hızlı yatış
- **Önerilen:** `6.0`

---

## 💡 Genel Optimizasyon İpuçları

### Smooth Hareket İçin

1. **Hızlanma ve frenleme değerlerini dengeli tutun**
   - `acceleration` ve `brake_deceleration` arasında 1.5-2x fark olmalı
   - Örnek: `acceleration = 12.0`, `brake_deceleration = 20.0`

2. **Eğimli yüzeylerde sorun varsa:**
   - `floor_max_angle_deg` değerini artırın
   - `ground_align_speed` değerini azaltın (daha smooth)

3. **Takılmalar varsa:**
   - `collision_slide_factor` değerini artırın (0.85-0.9)
   - `floor_snap_distance` değerini kontrol edin

4. **Çok "floaty" (havada kalıyor) hissediyorsa:**
   - `gravity` değerini artırın (12-15)
   - `floor_snap_distance` değerini azaltın (0.15-0.18)

5. **Çok "stiff" (sert) hissediyorsa:**
   - `ground_align_speed` değerini azaltın
   - `floor_snap_speed` değerini azaltın

### Hız Profili Ayarlama

**Düşük hızlarda çok yavaş:**
- `acceleration` değerini artırın
- `min_acceleration_ratio` değerini artırın

**Yüksek hızlarda çok yavaş:**
- `acceleration_curve` değerini azaltın (0.3-0.4)
- `min_acceleration_ratio` değerini artırın

**Maksimum hıza çok hızlı ulaşıyor:**
- `acceleration` değerini azaltın
- `acceleration_curve` değerini artırın (0.6-0.7)

---

## 📊 Hızlı Referans Tablosu

| Değişken | Varsayılan | Düşük | Yüksek | Etki |
|----------|------------|-------|--------|------|
| `acceleration` | 12.0 | 8.0 | 20.0 | Hızlanma hızı |
| `brake_deceleration` | 20.0 | 15.0 | 35.0 | Frenleme gücü |
| `turn_speed` | 2.5 | 1.5 | 4.0 | Dönüş hızı |
| `floor_max_angle_deg` | 50.0 | 35.0 | 65.0 | Maksimum eğim |
| `collision_slide_factor` | 0.8 | 0.5 | 0.95 | Kayma gücü |
| `floor_snap_distance` | 0.2 | 0.1 | 0.3 | Snap mesafesi |
| `ground_align_speed` | 8.0 | 5.0 | 12.0 | Hizalama hızı |

---

## ✅ Test Checklist

- [ ] Düz zeminde smooth hareket ediyor mu?
- [ ] Eğimli yüzeylerde takılmıyor mu?
- [ ] Duvarlara çarptığında kayıyor mu?
- [ ] Havadan düşerken zemin üzerinde duruyor mu?
- [ ] Dönüşler responsive ama kontrollü mü?
- [ ] Hızlanma ve frenleme dengeli mi?
- [ ] Küçük tümseklerde sarsılmıyor mu?

---

## 🐛 Sorun Giderme

### Problem: Bisiklet takılıyor

**Çözüm:**
1. `collision_slide_factor` değerini artırın (0.85-0.9)
2. `floor_snap_distance` değerini kontrol edin
3. Collision shape'lerin doğru ayarlandığından emin olun

### Problem: Bisiklet eğimli yüzeylerde kayıyor

**Çözüm:**
1. `floor_max_angle_deg` değerini artırın (55-60)
2. `ground_align_speed` değerini artırın (10-12)
3. `floor_snap_distance` değerini artırın (0.25-0.3)

### Problem: Bisiklet çok "floaty" (havada kalıyor)

**Çözüm:**
1. `gravity` değerini artırın (12-15)
2. `floor_snap_distance` değerini azaltın (0.15-0.18)
3. `floor_snap_speed` değerini artırın (12-15)

### Problem: Bisiklet düzensiz zeminlerde sarsılıyor

**Çözüm:**
1. `ground_align_speed` değerini azaltın (5-6)
2. `floor_snap_speed` değerini azaltın (7-8)
3. `floor_snap_distance` değerini artırın (0.25-0.3)

---

## 📚 Ek Notlar

- **CharacterBody3D** kullanımı, RigidBody3D'ye göre daha kontrollü hareket sağlar
- **move_and_slide()** otomatik olarak collision'ları handle eder
- **Velocity manipülasyonu** ile smooth hareket sağlanır
- **Floor detection** otomatik olarak çalışır (is_on_floor())
- **Collision sliding** ile takılmalar önlenir

Bu ayarları kademeli olarak değiştirerek bisikletinizi istediğiniz gibi optimize edebilirsiniz!

