# Çelişkiler ve Hatalar - Analiz Raporu

## 1. Belge vs Kod Çelişkileri

### ✅ Doğru Olanlar:
- Belge RigidBody3D kullanıldığını söylüyor, kod da RigidBody3D kullanıyor ✓
- Tüm ana fonksiyonlar (`_apply_movement`, `_apply_steering`, `_apply_lean`, `_apply_collision_sliding`) mevcut ✓
- Export değişkenlerin çoğu kodda mevcut ✓

### ❌ Çelişkiler:

1. **`_apply_gravity` Fonksiyonu:**
   - Belge: `_apply_gravity(delta)` fonksiyonundan bahsediyor
   - Kod: Bu fonksiyon yok (RigidBody3D otomatik olarak gravity uygular)
   - **Açıklama:** RigidBody3D'de gravity otomatik uygulanır, ayrı bir fonksiyon gerekmez

2. **`floor_max_angle_deg` ve `floor_snap_distance`:**
   - Belge: Bu parametrelerin kullanıldığını varsayıyor
   - Kod: Export edilmiş ama hiç kullanılmıyor
   - **Açıklama:** Bunlar CharacterBody3D özellikleridir, RigidBody3D'de kullanılmaz

3. **`gravity` Export Değişkeni:**
   - Belge: `gravity: float = 9.8` parametresinden bahsediyor
   - Kod: Export edilmiş ama hiç kullanılmıyor
   - **Açıklama:** RigidBody3D'de `gravity_scale` kullanılır, `gravity` değeri değil

4. **Belge Kod Örnekleri:**
   - Belge: `apply_torque` kullanımı doğru ✓
   - Belge: `apply_central_force` kullanımı doğru ✓
   - Belge: Collision sliding örneği doğru ✓

## 2. Eksik Özellikler

### Belgede Bahsedilen Ama Kodda Olmayan:
1. **`_apply_gravity` fonksiyonu:** Gereksiz (RigidBody3D otomatik yapıyor)

### Kodda Olan Ama Belgede Eksik:
1. **Mouse steering sistemi:** Kodda var ama belgede detaylı açıklanmamış
2. **`use_mouse_steering` parametresi:** Belgede bahsedilmemiş

## 3. Hatalı / Eski Açıklamalar

1. **Versiyon Geçmişi:**
   - Belge: "Versiyon 8.0 - CharacterBody3D Migration" ve "Versiyon 9.0 - RigidBody3D Optimization" diyor
   - **Durum:** Bu doğru, geçmişte CharacterBody3D'ye geçilmiş sonra RigidBody3D'ye geri dönülmüş
   - **Sorun:** Belgede `floor_max_angle_deg` ve `floor_snap_distance` hala bahsediliyor ama bunlar RigidBody3D'de kullanılmıyor

2. **Gravity Açıklaması:**
   - Belge: `_apply_gravity` fonksiyonundan bahsediyor
   - **Gerçek:** RigidBody3D otomatik gravity uygular, ayrı fonksiyon gerekmez

3. **Zemin ve Collision Parametreleri:**
   - Belge: `floor_max_angle_deg` ve `floor_snap_distance` kullanıldığını varsayıyor
   - **Gerçek:** Bunlar RigidBody3D'de kullanılmaz, sadece CharacterBody3D'de geçerlidir

## 4. Düzeltme Önerileri

### Kod İçin:
1. ✅ `floor_max_angle_deg` ve `floor_snap_distance` export değişkenlerini kaldır
2. ✅ `gravity` export değişkenini kaldır (veya kullanılıyorsa `gravity_scale` ile ilişkilendir)
3. ✅ Türkçe yorumları güncelle ve daha açıklayıcı hale getir
4. ✅ Tüm export değişkenlerinin kullanıldığından emin ol

### Belge İçin:
1. ✅ `_apply_gravity` fonksiyonunu belgeden kaldır (veya "RigidBody3D otomatik uygular" notu ekle)
2. ✅ `floor_max_angle_deg` ve `floor_snap_distance` parametrelerini belgeden kaldır veya "CharacterBody3D için, RigidBody3D'de kullanılmaz" notu ekle
3. ✅ `gravity` parametresini belgeden kaldır veya "RigidBody3D'de `gravity_scale` kullanılır" notu ekle
4. ✅ Mouse steering sistemi için detaylı açıklama ekle

