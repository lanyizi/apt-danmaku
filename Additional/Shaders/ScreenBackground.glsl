// https://www.shadertoy.com/view/4s33zf

// "Over the Moon" by Martijn Steinrucken aka BigWings - 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
// Facebook: https://www.facebook.com/groups/theartofcode
//
// Music: A Miserable Heart - Marek Iwaszkiewicz
// Soundcloud: https://soundcloud.com/shyprince/a-miserable-heart-piano
//
// I made a video tutorial about this effect which you can see here:
// https://youtu.be/LLZPnh_LK8c

#define PI 3.1415
#define S(x,y,z) smoothstep(x,y,z)
#define B(x,y,z,b) S(x, x+b, z)*S(y+b, y, z)
#define saturate(x) clamp(x,0.,1.)

#define MOD3 vec3(.1031,.11369,.13787)

#define MOONPOS vec2(1.3, .8)

//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float hash11(float p) {
    // From Dave Hoskins
	vec3 p3  = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

//  1 out, 2 in...
float hash12(vec2 p) {
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float remap(float a, float b, float c, float d, float t) {
	return ((t-a) / (b-a)) * (d-c) + c;
}

float within(float a, float b, float t) {
	return (t-a) / (b-a);
}

float skewbox(vec2 uv, vec3 top, vec3 bottom, float blur) {
	float y = within(top.z, bottom.z, uv.y);
    float left = mix(top.x, bottom.x, y);
    float right = mix(top.y, bottom.y, y);

    float horizontal = B(left, right, uv.x, blur);
    float vertical = B(bottom.z, top.z, uv.y, blur);
    return horizontal*vertical;
}

vec4 pine(vec2 uv, vec2 p, float s, float focus) {

	uv.x -= .5;
    float c = skewbox(uv, vec3(.0, .0, 1.), vec3(-.14, .14, .65), focus);
    c += skewbox(uv, vec3(-.10, .10, .65), vec3(-.18, .18, .43), focus);
    c += skewbox(uv, vec3(-.13, .13, .43), vec3(-.22, .22, .2), focus);
    float trunk = skewbox(uv, vec3(-.04, .04, .2), vec3(-.04, .04, -.1), focus);
    c += trunk;

    vec4 col = mix(vec4(.9,1.,.8,0.), vec4(1.,1.,1.,0), trunk);
    col.a = c;

    float shadow = skewbox(uv.yx, vec3(.6, .65, .13), vec3(.65, .65, -.1), focus);
    shadow += skewbox(uv.yx, vec3(.43, .43, .13), vec3(.36, .43, -.2), focus);
    shadow += skewbox(uv.yx, vec3(.15, .2, .08), vec3(.17, .2, -.08), focus);

    col.rgb = mix(col.rgb, col.rgb*.8, shadow);

    return col;
}

float getheight(float x) {
    return sin(x) + sin(x*2.234+.123)*.5 + sin(x*4.45+2.2345)*.25;
}

vec4 landscape(vec2 uv, float d, float p, float f, float a, float y, float seed, float focus) {

    //d = fract(d * 2.) / 2.;
    // y = 1 - (1 - d) * 0.6;
    y = .525 - .6 + .6 * d;

	uv *= d;
    float x = uv.x*PI*f+p;
    float c = getheight(x)*a+y;

    float b = floor(x*5.)/5.+.1;
    float h =  getheight(b)*a+y;

    float e = fwidth(uv.y);

    vec4 col = vec4(S(c+e, c-e, uv.y));
    //col.rgb *= mix(0.9, 1., abs(uv.y-c)*20.);

    x *= 5.;
    float id = floor(x);
    float n = hash11(id+seed);

    x = fract(x);

    y = (uv.y - h)*mix(5., 3., n)*3.5;
    float treeHeight = (.05/d) * mix(1.4, .7, n);
    y = within(h, h+treeHeight, uv.y);
    x += (n-.5)*.6;
    vec4 pineCol = pine(vec2(x, y/d), vec2(0.), 1., focus+d*.1);
    //col += pineCol;
    col.rgb = mix(col.rgb, pineCol.rgb, pineCol.a);
    col.a = max(col.a, pineCol.a);

    return saturate(col);
}

vec4 gradient(vec2 uv) {

	float c = 1.-length(MOONPOS-uv)/1.4;

    vec4 col = vec4(c);

    return col * vec4(.1, .1, .2, 1);
}

float circ(vec2 uv, vec2 pos, float radius, float blur) {
	float dist = length(uv-pos);
    return S(radius+blur, radius-blur, dist);
}

vec4 moon(vec2 uv) {
   	float c = circ(uv, MOONPOS, .07, .001);

    float light = c * 1.-circ(uv, MOONPOS+vec2(.03), .07, .001);

    vec4 col = saturate(vec4(light, light, light, c));
    col.rgb *=.5;

    return col;
}

vec4 moonglow(vec2 uv, float foreground) {

   	float c = circ(uv, MOONPOS, .1, .2);

    vec4 col = vec4(c);
    col.rgb *=.2;

    return col;
}

float stars(vec2 uv, float t) {
    t*=3.;

    float n1 = hash12(uv*10000.);
    float n2 = hash12(uv*11234.);
    float alpha1 = pow(n1, 20.);
    float alpha2 = pow(n2, 20.);

    float twinkle = sin((uv.x-t+cos(uv.y*20.+t))*10.);
    twinkle *= cos((uv.y*.234-t*3.24+sin(uv.x*12.3+t*.243))*7.34);
    twinkle = (twinkle + 1.)/2.;
    return alpha1 * alpha2 * twinkle;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float t = iTime*.05;

    vec2 bgUV = uv*vec2(iResolution.x/iResolution.y, 1.);
    vec4 col = gradient(bgUV);
    vec4 moonCol = moon(bgUV);
    col.rgb += moonCol.rgb;
    col += stars(uv, t) * (1. - moonCol.a);

    float dist = .10;
    float height = -.01;
    float amplitude = .02;

    vec4 trees = vec4(0.);
    t = iTime * .5;
    float seed = floor(t);
    float bx = t * 0.5 + sin(t * .5);
    dist = 1. + fract(1. - (t - seed)) * .1;
    for (float j = 0.; j <= 10.; ++j) {
        float i = 10. - dist * 10.;
        float x = bx + seed;
        float focus = /* pow(dist - .3, 2.) * .3 */ .0;
        float fade = saturate(10. - abs(dist - .5) * 20.);
        vec4 layer = landscape(uv, dist, x, 3., amplitude, .55, seed, focus);
    	layer.rgb *= mix(vec3(.1, .1, .06), vec3(.1, .12, .3)+gradient(uv).x, 1.-i/10.);
        trees = mix(trees, layer, layer.a * fade);
        dist -= .1;
        --seed;
    }

    /*
    dist = 1. + fract(1. - t);
    float seed = floor(-t * 10.);
    float i = 0.;
    vec4 trees = vec4(0.);

    while (dist > 0.) {
        i = 10. - 10. * dist;
        vec4 layer = landscape(uv, dist, +i, 3., amplitude, .55, seed, .01);
    	layer.rgb *= mix(vec3(.1, .1, .2), vec3(.3)+gradient(uv).x, 1.-i/10.);
        trees = mix(trees, layer, layer.a);
        dist -= .1;
        ++i;
        seed += 1.;
    }
    dist += 1.;*/
    /*while (dist > .1) {
        vec4 layer = landscape(uv, dist, +i, 3., amplitude, .55, +i, .01);
    	layer.rgb *= mix(vec3(.1, .1, .2), vec3(.3)+gradient(uv).x, 1.-i/10.);
        trees = mix(trees, layer, layer.a);
        dist -= .1;
        ++i;
    }*/
    col = mix(col, trees, trees.a);

    col += moonglow(bgUV, 1.) * .5;
    col = saturate(col);

    //vec4 foreground = landscape(uv, .02, t, 3., .0, -0.04, 1., .1);
    //foreground.rgb *= vec3(.1, .1, .2)*.5;

    //col = mix(col, foreground, foreground.a);

    fragColor = vec4(col);
}