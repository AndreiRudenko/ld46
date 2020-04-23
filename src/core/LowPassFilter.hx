package core;

import clay.Clay;
import clay.utils.Mathf;
import clay.audio.Sound;
import clay.audio.Audio;
import clay.audio.AudioEffect;
import kha.arrays.Float32Array;

// First Order Digital LowPass Filter from FreeVerb3

class LowPassFilter extends AudioEffect {

	public var freq(default, set):Float;
	
	var maxFreq:Int = 22050;

	var y1:Float = 0;
	var a2:Float = 0;
	var b1:Float = 0;
	var b2:Float = 0;

	var sampleRate:Int;

	public function new(freq:Float, sampleRate:Int) {
		super();
		this.sampleRate = sampleRate;
		this.freq = freq;
	}

	override function process(samples:Int, buffer:Float32Array, sampleRate:Int) {
		var i = 0;
		while(i < samples) {
			buffer[i] = processFilter(buffer[i]);
			buffer[i+1] = processFilter(buffer[i+1]);

			i+=2;
		}
	}

	inline function processFilter(input:Float):Float {
		var output = input * b1 + y1;
		y1 = output * a2 + input * b2;
			
		return output;
	}

	function set_freq(v:Float):Float {
		freq = Mathf.clamp(v, 0, maxFreq);
		calcCoef(freq);
		return freq;
	}

	inline function calcCoef(freq:Float) {
		a2 = Math.exp(-1 * Math.PI * freq / (sampleRate / 2));
		b1 = 1.0;
		b2 = 0.1;

		var norm = (1 - a2) / (b1 + b2);
		b1 *= norm;
		b2 *= norm;
	}

}
