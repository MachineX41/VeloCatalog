#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uCornerRadius;
uniform float uBlur;
uniform float uDispersion;
uniform sampler2D uTexture;

out vec4 fragColor;

vec4 sampleTex(vec2 uv) {
  return texture(uTexture, clamp(uv, 0.0, 1.0));
}

vec4 sampleBlur(vec2 uv, float radius) {
  vec4 color = sampleTex(uv);
  if (radius <= 0.001) {
    return color;
  }
  vec2 texel = radius / uResolution;
  color += sampleTex(uv + vec2(texel.x, 0.0));
  color += sampleTex(uv - vec2(texel.x, 0.0));
  color += sampleTex(uv + vec2(0.0, texel.y));
  color += sampleTex(uv - vec2(0.0, texel.y));
  color += sampleTex(uv + texel);
  color += sampleTex(uv - texel);
  return color / 6.0;
}

float sdRoundBox(vec2 p, vec2 halfSize, float r) {
  vec2 q = abs(p) - halfSize + vec2(r);
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;
  vec2 halfSize = uResolution * 0.5;
  float radius = min(uCornerRadius, min(halfSize.x, halfSize.y));
  vec2 p = fragCoord - halfSize;

  float sdf = sdRoundBox(p, halfSize, radius);
  float lensMask = 1.0 - smoothstep(-1.0, 1.0, sdf);
  float rim = smoothstep(3.0, 0.0, abs(sdf)) * (1.0 - smoothstep(-10.0, -3.0, sdf));

  vec2 delta = uv - vec2(0.5);
  float dist = length(delta * vec2(uResolution.x / uResolution.y, 1.0));
  vec2 dir = dist > 0.001 ? normalize(delta) : vec2(0.0, 0.0);
  float disp = uDispersion * dist * lensMask;

  vec4 base = sampleBlur(uv, uBlur);
  vec4 shiftedR = sampleBlur(uv + dir * disp, uBlur * 0.45);
  vec4 shiftedB = sampleBlur(uv - dir * disp, uBlur * 0.45);
  vec3 refracted = mix(base.rgb, vec3(shiftedR.r, base.g, shiftedB.b), 0.35);

  vec3 glass = mix(base.rgb, refracted, 0.22 * lensMask);
  glass = mix(glass, vec3(1.0), 0.32 * lensMask);
  glass = glass * 0.92 + vec3(0.14);
  glass += rim * 0.08;

  float alpha = 0.80 * lensMask;
  fragColor = vec4(glass, alpha);
}
