# Bisiklet Kontrol Sistemi Ayarlama Rehberi

Bu rehber, `BikeController.gd` scriptindeki değişkenleri nasıl ayarlayacağınızı açıklar.

---

## 🎮 DÜŞÜK HIZDA DÖNÜŞ HİSSİNİ AYARLAMA

Düşük hızlarda bisikletin ne kadar keskin döneceğini kontrol eden değişkenler:

### `low_speed_turn_factor` (Varsayılan: 2.0)
- **Ne yapar:** Düşük hızlarda (neredeyse dururken) dönüş gücünü çarpan olarak belirler
- **Daha keskin dönüş için:** Değeri artırın (örn: 3.0, 4.0)
- **Daha yumuşak dönüş için:** Değeri azaltın (örn: 1.5, 1.0)
- **Örnek:** 2.0 = düşük hızlarda 2 kat daha keskin dönüş

### `steer_torque` (Varsayılan: 5.0)
- **Ne yapar:** Temel dönüş torku (tüm hızlarda kullanılan temel değer)
- **Daha güçlü dönüş için:** Değeri artırın (örn: 7.0, 10.0)
- **Daha zayıf dönüş için:** Değeri azaltın (örn: 3.0, 2.0)
- **Not:** Bu değer, `low_speed_turn_factor` ve `high_speed_turn_factor` ile çarpılır

### `steer_speed` (Varsayılan: 3.0)
- **Ne yapar:** Dönüş girdisinin ne kadar hızlı tepki vereceğini belirler
- **Daha hızlı tepki için:** Değeri artırın (örn: 5.0, 8.0)
- **Daha yumuşak tepki için:** Değeri azaltın (örn: 2.0, 1.0)

---

## 🚀 YÜKSEK HIZDA STABİLİTE AYARLAMA

Yüksek hızlarda bisikletin ne kadar stabil (az "twitchy") olacağını kontrol eden değişkenler:

### `high_speed_turn_factor` (Varsayılan: 0.3)
- **Ne yapar:** Yüksek hızlarda dönüş gücünü çarpan olarak belirler
- **Daha stabil (daha az dönüş) için:** Değeri azaltın (örn: 0.2, 0.15)
- **Daha fazla dönüş için:** Değeri artırın (örn: 0.4, 0.5)
- **Örnek:** 0.3 = yüksek hızlarda %30 dönüş gücü (daha stabil)

### `max_speed` (Varsayılan: 15.0)
- **Ne yapar:** Bisikletin maksimum hızını belirler (m/s)
- **Not:** Bu değer, hız oranı hesaplamasında kullanılır
- **Yüksek hızlarda daha stabil his için:** `max_speed`'i artırın ve `high_speed_turn_factor`'ı azaltın

---

## ⬅️ GERİ VİTES AYARLARI

Geri vites (reverse) davranışını kontrol eden değişkenler:

### `reverse_speed_threshold` (Varsayılan: 0.3)
- **Ne yapar:** Bu hızın altındayken fren basılırsa, bisiklet geri vites moduna geçer (m/s)
- **Daha erken geri vites için:** Değeri artırın (örn: 0.5, 0.7)
- **Daha geç geri vites için:** Değeri azaltın (örn: 0.2, 0.1)
- **Örnek:** 0.3 = 0.3 m/s'nin altındayken geri vites aktif olur

### `max_reverse_speed` (Varsayılan: 2.0)
- **Ne yapar:** Geri vites modunda bisikletin ulaşabileceği maksimum hız (m/s)
- **Daha hızlı geri vites için:** Değeri artırın (örn: 3.0, 4.0)
- **Daha yavaş geri vites için:** Değeri azaltın (örn: 1.5, 1.0)

### `reverse_force` (Varsayılan: 300.0)
- **Ne yapar:** Geri vites modunda uygulanan kuvvet (Newton)
- **Daha güçlü geri vites için:** Değeri artırın (örn: 400.0, 500.0)
- **Daha zayıf geri vites için:** Değeri azaltın (örn: 200.0, 150.0)
- **Not:** Genellikle `max_forward_force`'dan daha düşük olmalı

---

## 📐 YATIŞ (LEAN) AYARLARI

Bisikletin dönüş sırasında ne kadar yatacağını kontrol eden değişkenler:

### `max_lean_angle_deg` (Varsayılan: 45.0)
- **Ne yapar:** Bisikletin maksimum yatış açısı (derece)
- **Daha fazla yatış için:** Değeri artırın (örn: 60.0, 75.0)
- **Daha az yatış için:** Değeri azaltın (örn: 30.0, 20.0)
- **Not:** Yüksek hızlarda yatış faktörü otomatik olarak artar

### `lean_speed` (Varsayılan: 5.0)
- **Ne yapar:** Yatışın ne kadar hızlı uygulanacağını belirler
- **Daha hızlı yatış için:** Değeri artırın (örn: 7.0, 10.0)
- **Daha yumuşak yatış için:** Değeri azaltın (örn: 3.0, 2.0)

---

## 🎯 HIZLI AYARLAMA ÖNERİLERİ

### Düşük Hızlarda Çok Keskin Dönüş İstiyorsanız:
```
low_speed_turn_factor = 3.0  (varsayılan: 2.0)
steer_torque = 6.0            (varsayılan: 5.0)
```

### Yüksek Hızlarda Çok Stabil İstiyorsanız:
```
high_speed_turn_factor = 0.2  (varsayılan: 0.3)
max_speed = 20.0              (varsayılan: 15.0)
```

### Geri Vites Daha Erken Aktif Olsun:
```
reverse_speed_threshold = 0.5  (varsayılan: 0.3)
```

### Geri Vites Daha Hızlı Olsun:
```
max_reverse_speed = 3.0        (varsayılan: 2.0)
reverse_force = 400.0          (varsayılan: 300.0)
```

### Daha Fazla Yatış İstiyorsanız:
```
max_lean_angle_deg = 60.0      (varsayılan: 45.0)
lean_speed = 7.0               (varsayılan: 5.0)
```

---

## 📊 DEĞİŞKEN ÖZET TABLOSU

| Değişken | Varsayılan | Düşük Hız Dönüş | Yüksek Hız Stabilite | Geri Vites |
|----------|------------|-----------------|---------------------|------------|
| `low_speed_turn_factor` | 2.0 | ✅ | ❌ | ❌ |
| `high_speed_turn_factor` | 0.3 | ❌ | ✅ | ❌ |
| `steer_torque` | 5.0 | ✅ | ✅ | ❌ |
| `steer_speed` | 3.0 | ✅ | ❌ | ❌ |
| `max_speed` | 15.0 | ❌ | ✅ | ❌ |
| `reverse_speed_threshold` | 0.3 | ❌ | ❌ | ✅ |
| `max_reverse_speed` | 2.0 | ❌ | ❌ | ✅ |
| `reverse_force` | 300.0 | ❌ | ❌ | ✅ |
| `max_lean_angle_deg` | 45.0 | ✅ | ✅ | ❌ |
| `lean_speed` | 5.0 | ✅ | ✅ | ❌ |

---

## 💡 İPUÇLARI

1. **Küçük değişiklikler yapın:** Değişkenleri büyük miktarlarda değiştirmek yerine, küçük adımlarla (0.1-0.5) test edin.

2. **Bir seferde bir değişken:** Birden fazla değişkeni aynı anda değiştirmek yerine, birini değiştirip test edin.

3. **Hız oranı:** Sistem, `speed / max_speed` oranını kullanarak düşük ve yüksek hız arasında otomatik interpolasyon yapar.

4. **Test senaryoları:** 
   - Düşük hız testi: Bisikleti durdurup yavaşça hareket ettirin
   - Yüksek hız testi: Maksimum hızda dönüş yapın
   - Geri vites testi: Durun ve fren basılı tutun

5. **Fizik gerçekçiliği:** Gerçek bisiklet fiziğini simüle etmek için, yüksek hızlarda dönüş faktörünü düşük tutun ve yatış açısını artırın.

