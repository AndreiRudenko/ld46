package;

class Settings {

	// plant
	public static var PLANT_WIDTH:Float = 200;
	public static var PLANT_HEIGHT:Float = 120;
	public static var PLANT_GLOW_ALPHA:Float = 0.5;

	public static var GROW_SPEED_MIN:Float = 10;
	public static var GROW_SPEED_MAX:Float = 30;

	public static var FALL_SPEED_MIN:Float = 2;
	public static var FALL_SPEED_MAX:Float = 7;

	public static var RNG_KEYS_RANGE:Int = 48;

	public static var WIDTH_START_MIN:Int = 96;
	public static var WIDTH_START_MAX:Int = 128;

	public static var WIDTH_END_MIN:Int = 16;
	public static var WIDTH_END_MAX:Int = 64;

	public static var LENGTH_MIN:Int = 180;
	public static var LENGTH_MAX:Int = 320;

	public static var SCALE_MIN:Float = 0.2;
	public static var SCALE_MAX:Float = 1.5;

	public static var GROW_SCALE_MIN:Float = 0.2;
	public static var GROW_SCALE_MAX:Float = 0.5;

	public static var RND_CRYSTAL_X:Float = 32;

	// crystal
	public static var CRYSTAL_OPACITY:Float = 1;
	public static var CRYSTAL_HUE_VARIANCE:Int = 24;
	public static var CRYSTAL_BOTTOM_CAPSCALE:Float = 0.333;
	public static var LIGHT_BEAM_SCALE:Float = 0.5;
	public static var OUTER_GEOM_DIST:Float = 16;
	public static var OUTER_GEOM_ALPHA:Float = 0.15;

	// firefly
	public static var FIREFLY_COUNT:Int = 10;
	public static var FIREFLY_COUNT_MAX:Int = 500;

	public static var FIREFLY_SIZE_MIN:Int = 4;
	public static var FIREFLY_SIZE_MAX:Int = 6;
	public static var FIREFLY_SPEED_MIN:Int = 10;
	public static var FIREFLY_SPEED_MAX:Int = 40;
	public static var FIREFLY_MAX_SPEED:Int = 128;
	public static var FIREFLY_MAX_SPEED_GLOW:Int = 128;

	public static var FIREFLY_DAMPING:Float = 0.8;
	public static var FIREFLY_DAMPING_GLOW:Float = 1;

	public static var FIREFLY_DAMPING_UP:Float = 0.1;
	public static var FIREFLY_DAMPING_DOWN:Float = 0.01;

	public static var FIREFLY_GLOW_ALPHA:Float = 0.5;
	public static var FIREFLY_IDLE_DISTANCE:Float = 256;

	public static var FIREFLY_ALPHA_MIN:Float = 0.2;
	public static var FIREFLY_ALPHA_MAX:Float = 0.8;

	public static var FIREFLY_ALPHA_TWEEN_MIN:Float = 0.5;
	public static var FIREFLY_ALPHA_TWEEN_MAX:Float = 3;

	public static var FIREFLY_ALPHA_TWEEN_SPEED_MIN:Float = 0.5;
	public static var FIREFLY_ALPHA_TWEEN_SPEED_MAX:Float = 1;

	// glow
	public static var BLUR_AMOUNT:Float = 4;
	public static var BLUR_OVERSIZE:Float = 64;
	public static var BLUR_RESOLUTION:Float = 0.5;

	public static var BLUR_ALPHA_MIN:Float = 0.15;
	public static var BLUR_ALPHA_MAX:Float = 0.3;

	public static var GLOW_UP_SPEED:Float = 8;
	public static var GLOW_DOWN_SPEED:Float = 1;

	public static var SCALEDOWN_VOLUME_MIN:Float = 0.5;
	public static var SCALEDOWN_VOLUME_MAX:Float = 0.8;

	// bg
	public static var SKY_UP_BRIGHTNESS_MIN:Float = 0.05;
	public static var SKY_UP_BRIGHTNESS_MAX:Float = 0.3;
	public static var SKY_DOWN_BRIGHTNESS_MIN:Float = 0.15;
	public static var SKY_DOWN_BRIGHTNESS_MAX:Float = 0.3;

	public static var SKY_UP_SAT_MIN:Float = 0.8;
	public static var SKY_UP_SAT_MAX:Float = 1;
	public static var SKY_DOWN_SAT_MIN:Float = 0.8;
	public static var SKY_DOWN_SAT_MAX:Float = 1;
	
	// menu
	public static var IDLE_TIME:Float = 30;

	// sound
	public static var PLAY_VOLUME:Float = 0.2;

	public static var VOICES_MAX:Int = 16;
	public static var EFFECTS_MAX:Int = 4;
	public static var KEYS_COUNT:Int = 10;

	public static var LFO_FREQ_BASE_MAX:Int = 2;
	public static var LFO_FREQ_MIN:Int = 1;
	public static var LFO_FREQ_MAX:Int = 5;

	public static var LFO_AMOUNT_BASE:Float = 0.3;

	public static var LFO_FREQ_SCALE_MIN:Float = 0.2;
	public static var LFO_FREQ_SCALE_MAX:Float = 0.8;

	public static var LFO_AMOUNT:Float = 0.6;
	public static var OSC_VOLUME_MIN:Float = 0.1;
	public static var OSC_VOLUME_MAX:Float = 1;
	public static var OSC_VOLUME_RND:Float = 0.8;
	public static var OSC_LFO_AMOUNT_RND:Float = 0.8;

	public static var HARMONICS_MIN:Int = 2; // 2
	public static var HARMONICS_MAX:Int = 6; // 6

	public static var HARMONIC_STEP_START:Int = 1;
	public static var HARMONIC_STEP_START_MAX:Int = 4;
	public static var HARMONIC_STEP:Int = 4;
	public static var HARMONIC_STEP_MAX:Int = 8;

	public static var ENVELOPE_RELEASE:Float = 0.5;
	public static var ENVELOPE_RELEASE_MAX:Float = 3;
	public static var ENVELOPE_SCALE:Float = 1.7;

	// reverb
	public static var ROOMSIZE_MIN:Float = 0.5; // 85
	public static var ROOMSIZE_MAX:Float = 0.99;

	public static var DAMPING_MIN:Float = 0.5;
	public static var DAMPING_MAX:Float = 2;

	public static var HICUT_MIN:Float = 100;
	public static var HICUT_MAX:Float = 1500;

	public static var PREDELAY_MIN:Float = 1;
	public static var PREDELAY_MAX:Float = 100;

	// filter
	public static var FILTER_MIN:Float = 200;
	public static var FILTER_MAX:Float = 3000;

}
