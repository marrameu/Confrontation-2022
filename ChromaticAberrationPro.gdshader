shader_type canvas_item;

uniform float intensity;

// Given a vec2 in [-1,+1], generate a texture coord in [0,+1]
vec2 barrelDistortion( vec2 p, vec2 amt )
{
    p = 2.0 * p - 1.0;

    /*
    const float maxBarrelPower = 5.0;
	//note: http://glsl.heroku.com/e#3290.7 , copied from Little Grasshopper
    float theta  = atan(p.y, p.x);
    vec2 radius = vec2( length(p) );
    radius = pow(radius, 1.0 + maxBarrelPower * amt);
    p.x = radius.x * cos(theta);
    p.y = radius.y * sin(theta);

	/*/
    // much faster version
    //const float maxBarrelPower = 5.0;
    //float radius = length(p);
    float maxBarrelPower = sqrt(5.0);
    float radius = dot(p,p); //faster but doesn't match above accurately
    p *= pow(vec2(radius), maxBarrelPower * amt);
	/* */

    return p * 0.5 + 0.5;
}

//note: from https://www.shadertoy.com/view/MlSXR3
vec2 brownConradyDistortion(vec2 uv, float scalar)
{
// AH!!!    uv = uv * 2.0 - 1.0;
    uv = (uv - 0.5 ) * 2.0;
    
    if( true )
    {
        // positive values of K1 give barrel distortion, negative give pincushion
        float barrelDistortion1 = -0.02 * scalar; // K1 in text books
        float barrelDistortion2 = 0.0 * scalar; // K2 in text books

        float r2 = dot(uv,uv);
        uv *= 1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2;
        //uv *= 1.0 + barrelDistortion1 * r2;
    }
    
    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here
//    return uv * 0.5 + 0.5;
   return (uv / 2.0) + 0.5;
}

void fragment() {
	
	vec2 uv = COLOR.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
    
    float maxDistort = 4.0;

    float scalar = 1.0 * intensity;
//    vec4 colourScalar = vec4(2.0, 1.5, 1.0, 1.0);
    vec4 colourScalar = vec4(700.0, 560.0, 490.0, 1.0);	// Based on the true wavelengths of red, green, blue light.
    colourScalar /= max(max(colourScalar.x, colourScalar.y), colourScalar.z);
    colourScalar *= 2.0;
    
    colourScalar *= scalar;
    
    vec4 sourceCol = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);

    const float numTaps = 8.0;
    
    
    COLOR = vec4( 0.0 );
    for( float tap = 0.0; tap < numTaps; tap += 1.0 )
    {
        COLOR.r += texture(SCREEN_TEXTURE, brownConradyDistortion(SCREEN_UV, colourScalar.r)).r;
        COLOR.g += texture(SCREEN_TEXTURE, brownConradyDistortion(SCREEN_UV, colourScalar.g)).g;
        COLOR.b += texture(SCREEN_TEXTURE, brownConradyDistortion(SCREEN_UV, colourScalar.b)).b;
        
        colourScalar *= 0.99;
    }
    
    COLOR /= numTaps;
  
    COLOR.a = 1.0;
	
	}