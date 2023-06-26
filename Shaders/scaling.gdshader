shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec2 px_per_tx = TEXTURE_PIXEL_SIZE / SCREEN_PIXEL_SIZE;
	vec2 tx = UV/TEXTURE_PIXEL_SIZE;
	vec2 txOffset = clamp(fract(tx) * px_per_tx,0.0,0.5) - clamp((1.0 - fract(tx))*px_per_tx,0.0,0.5);
	vec2 uv = (floor(tx) + 0.5 + txOffset) * TEXTURE_PIXEL_SIZE;
	COLOR = texture(TEXTURE,uv);
}
