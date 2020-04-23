package utils;

import clay.Clay;
import clay.utils.Mathf;

class ColorHarmony {

	public var hues:Array<Int>;

	public var stepMin:Int = 0;
	public var currentType:HarmonyType;

	public function new() {
		hues = [];
		randomize();
	}

	public function randomize() {
		var htype = Clay.random.int(3);
		switch (htype) {
			case HarmonyType.ANALOGOUS: generateAnalogous();
			case HarmonyType.TETRADIC: generateTetradic();
			case HarmonyType.SPLIT_COMPLEMENTARY: generateComp();
		}
	}

	function generateAnalogous() {
		currentType = HarmonyType.ANALOGOUS;
		var hue = getRandomHue();
		hues[0] = hue;
		var step = Clay.random.int(stepMin, 45);
		step *= Clay.random.sign();
		for (i in 1...4) {
			hue = mod(hue + step);
			hues[i] = hue;
		}
	}

	function generateTetradic() {
		currentType = HarmonyType.TETRADIC;
		var hue = getRandomHue();
		var step = Clay.random.int(stepMin, 45);
		hues[0] = mod(hue - step);
		hues[1] = mod(hue + step);
		hues[2] = mod(hue + 180 - step);
		hues[3] = mod(hue + 180 + step);
	}

	function generateComp() {
		currentType = HarmonyType.SPLIT_COMPLEMENTARY;
		var hue = getRandomHue();
		var step = Clay.random.int(stepMin, 60);
		if(Clay.random.bool()) {
			hues[0] = mod(hue - step);
			hues[1] = mod(hue + step);
			hues[2] = mod(hue + 180);
			hues[3] = hues[2];
		} else {
			hues[0] = mod(hue + 180);
			hues[1] = hues[0];
			hues[2] = mod(hue - step);
			hues[3] = mod(hue + step);
		}
	}

	function getRandomHue() {
		return Clay.random.int(360);
	}

	function mod(v:Int):Int {
		return Mathf.mod(v, 360);
	}

}


enum abstract HarmonyType(Int) from Int to Int {
	var ANALOGOUS = 0;
	var TETRADIC = 1;
	var SPLIT_COMPLEMENTARY = 2;
}