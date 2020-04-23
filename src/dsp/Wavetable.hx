package dsp;

import clay.Clay;
import kha.arrays.Float32Array;
import utils.KeyUtils;

class Wavetable {

	public static final wavetableLength:Int = 2048;

	public var table:Float32Array;
	public var frequency:Float = 440; // A4
	public var amplitude:Float = 1;
	public var sampleRate:Int;

	var _frameCount:Int = 0;

	public function new(?table:Float32Array, ?sampleRate:Int) {
		this.table = table != null ? table : new Float32Array(wavetableLength);
		this.sampleRate = sampleRate != null ? sampleRate : Clay.audio.sampleRate;
		generateSine();
		var keyId = KeyUtils.getKeyId('A4');
		frequency = KeyUtils.getFreq(keyId);
		trace(frequency);
	}

	function generateSine() {
		var len = table.length;
		var time = len / sampleRate;
		var hz = 1 / time;
		for (i in 0...len) {
			table[i] = sin(i * hz / sampleRate);
		}
	}

	inline function sin(step:Float) {
		return Math.sin(Math.PI * 2 * step);
	}

	public function process(data:Float32Array, bufferSamples:Int) {
		var frameOffset = _frameCount * bufferSamples;
		var tableLen = table.length;
		var step = tableLen * frequency / sampleRate / 2; // 2 ?
		var offset;
		var signal;

		var i = 0;
		while(i < bufferSamples) {
			offset = Math.round((frameOffset + i) * step);
			signal = table[offset % tableLen] * amplitude;
			data[i] += signal;
			data[i+1] += signal;
			i +=2;
		}
		_frameCount++;
	}

}