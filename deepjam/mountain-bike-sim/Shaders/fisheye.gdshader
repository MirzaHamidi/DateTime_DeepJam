shader_type canvas_item;

// Fisheye gücü (yumuşatıldı)
uniform float strength : hint_range(0.0, 1.0) = 0.45;

// Vignette gücü
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.0;

// Godot 4.5 screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // UV -1..1 aralığına
    vec2 uv = UV * 2.0 - 1.0;

    float r2 = dot(uv, uv);

    // Yumuşak fisheye eğrisi (r2 ile sınırlı)
    float k = 1.0 + strength * r2;

    uv /= k;

    // Ekran uv'sine geri dön
    uv = uv * 0.5 + 0.5;

    // Dışa taşma → siyah
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        COLOR = texture(SCREEN_TEXTURE, uv);
    }

    // --- VIGNETTE ---

    // 0..1 aralığında merkezden uzaklık
    float dist = distance(UV, vec2(0.5));

    // Merkeze yakın = 0, kenara doğru = 1
    float vignette = smoothstep(0.4, 0.9, dist);

    // Etkiyi ayarla
    vignette *= vignette_strength;

    // Kenarları karart (çoğalt)
    COLOR.rgb *= (1.0 - vignette);
}
