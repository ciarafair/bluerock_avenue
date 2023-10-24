shader_type canvas_item;

uniform bool overlay = false;
uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.25;
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.3;
uniform vec2 resolution = vec2(640.0, 480.0);
uniform bool pixelate = true;
uniform float brightness : hint_range(0.0, 2.0) = 1.4; // Adjust the range as needed
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Function definitions for random, noise, warp, border, and vignette go here...

void fragment()
{
    vec2 uv = overlay ? SCREEN_UV : UV;
    vec2 text_uv = uv;

    // Pixelate the texture based on the given resolution.
    if (pixelate)
    {
        text_uv = ceil(uv * resolution) / resolution;
    }

    vec4 text = texture(SCREEN_TEXTURE, text_uv); // Sample the texture

    // Apply the grille effect
    float r = text.r;
    float g = text.g;
    float b = text.b;

    if (grille_opacity > 0.0)
    {
        float g_r = smoothstep(0.85, 0.95, abs(sin(uv.x * (resolution.x * 3.14159265))));
        r = mix(r, r * g_r, grille_opacity);

        float g_g = smoothstep(0.85, 0.95, abs(sin(1.05 + uv.x * (resolution.x * 3.14159265))));
        g = mix(g, g * g_g, grille_opacity);

        float b_b = smoothstep(0.85, 0.95, abs(sin(2.1 + uv.x * (resolution.x * 3.14159265))));
        b = mix(b, b * b_b, grille_opacity);
    }

    // Apply the grille to the texture's color channels and apply Brightness.
    text.r = clamp(r * brightness, 0.0, 1.0);
    text.g = clamp(g * brightness, 0.0, 1.0);
    text.b = clamp(b * brightness, 0.0, 1.0);

    // Apply the scanlines effect
    float scanlines = 0.5;
    if (scanlines_opacity > 0.0)
    {
        scanlines = smoothstep(scanlines_width, scanlines_width + 0.5, abs(sin(uv.y * (resolution.y * 3.14159265))));
        text.rgb = mix(text.rgb, text.rgb * vec3(scanlines), scanlines_opacity);
    }

    COLOR = text;
}