package core;

import clay.Clay;
import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.audio.AudioChannel;
import clay.audio.AudioGroup;
import clay.audio.Audio;
import clay.utils.Mathf;
import utils.KeyUtils;
import core.AR;

class WavetableOsc extends AudioChannel {

	public static final wavetableLength:Int = 2048;
	public var oscs:Array<OscData>;
	public var amplitude:Float = 1;
	public var envelope:AR;
	public var envelopeAmount:Float;

	var _cache:Float32Array;
	var _wave:Float32Array;
	var harmonics:Array<Float>;
	var _frameCount:Int = 0;
	var sampleRate:Int;

	public function new(baseFreq:Float, harmonics:Array<Float>, envRelease:Float) {
		super();
		sampleRate = Clay.audio.sampleRate;
		_cache = new Float32Array(512);
		_wave = new Float32Array(wavetableLength);
		envelope = new AR(0.01, envRelease);
		envelopeAmount = Settings.ENVELOPE_SCALE;
		oscs = [];
		this.harmonics = harmonics.copy();
		for (h in this.harmonics) {
			var hInt = Math.floor(h);
			var f = baseFreq*hInt;
			var od = new OscData(f, sampleRate);
			od.cents = Math.round(100 * (h-hInt));
			oscs.push(od);
		}
		generateWavetable();
	}

	public function volumeRandomizeMult(amount:Float, from:Int = 1) {
		for (i in from...oscs.length) {
			oscs[i].volume *= Clay.random.float(amount, 2-amount);
		}
	}

	public function lfoAmountRandomizeMult(amount:Float, from:Int = 1) {
		for (i in from...oscs.length) {
			oscs[i].lfoAmount *= Clay.random.float(amount, 2-amount);
		}
	}

	public function scalelfoFreq(amount:Float, from:Int = 1) {
		for (i in from...oscs.length) {
			oscs[i].lfoFreq *= amount;
		}
	}

	public function scaleVolume(amount:Float, from:Int = 1) {
		for (i in from...oscs.length) {
			oscs[i].volume *= amount;
		}
	}

	public function setVolumes(v:Array<Float>) {
		for (i in 0...oscs.length) {
			oscs[i].volume = v[i];
		}
	}

	public function setLfoFreqs(v:Array<Float>) {
		for (i in 0...oscs.length) {
			oscs[i].lfoFreq = v[i];
		}
	}

	public function setLfoAmts(v:Array<Float>) {
		for (i in 0...oscs.length) {
			oscs[i].lfoAmount = v[i];
		}
	}

	function generateWavetable() {
		var len = _wave.length;
		var time = len / sampleRate;
		var hz = 1 / time;
		for (i in 0...len) {
			_wave[i] = sin(i * hz / sampleRate);
		}
	}

	inline function sin(step:Float) {
		return Math.sin(Math.PI * 2 * step);
	}

	override function process(data:Float32Array, bufferSamples:Int) {
		if (_cache.length < bufferSamples) {
			_cache = new Float32Array(bufferSamples);
		}

		var bufferIdx = 0;
		while (bufferIdx < bufferSamples) {
			_cache[bufferIdx++] = 0;
		}

		var frameOffset = _frameCount * bufferSamples;
		var wtlen = _wave.length;
		var step;
		var offset;
		var signal;
		var od;

		var wavesCount = oscs.length;
		var waveIdx;

		bufferIdx = 0;
		while(bufferIdx < bufferSamples) {
			signal = 0.0;
			waveIdx = 0;
			while(waveIdx < wavesCount) {
				od = oscs[waveIdx];
				od.process();
				step = wtlen * od.frequency / sampleRate / 2; // 2 ?
				offset = fastRound((frameOffset + bufferIdx) * step);
				signal += _wave[offset % wtlen] * (od.volume * od.amplitude);
				waveIdx++;
			}
			if(envelope.active) {
				envelope.process();
				signal += signal * envelope.amplitude * envelopeAmount; 
			}
			_cache[bufferIdx] += signal;
			_cache[bufferIdx+1] += signal;
			bufferIdx +=2;
		}
		_frameCount++;

		processEffects(_cache, bufferSamples);

		var bufferIdx = 0;
		while(bufferIdx < bufferSamples) {
			data[bufferIdx] += _cache[bufferIdx] * _volume * _l * amplitude;
			data[bufferIdx+1] += _cache[bufferIdx+1] * _volume * _r * amplitude;
			bufferIdx +=2;
		}
	}

	inline function fastRound(n:Float):Int {
		#if js
		return untyped __js__("{0} + 0.5 << 0", n);
		#else
		return Math.round(n);
		#end
	}

}

class OscData {

	public var volume:Float = 1;
	public var amplitude(default, null):Float = 1;
	public var baseFreq(default, set):Float;
	public var frequency(default, null):Float;
	public var semitones(default, set):Int;
	public var cents(default, set):Int;

	public var lfoAmount(default, set):Float = 0;
	public var lfoFreq(default, set):Float;

	var _rate:Float = 0;
	var _phase:Float = 0;
	var _sampleRate:Int;

	public function new(baseFreq:Float, sampleRate:Int) {
		this.baseFreq = baseFreq;
		_sampleRate = sampleRate;
		this.frequency = baseFreq;
		semitones = 0;
		cents = 0;
		lfoFreq = 10;
	}

	public function process() {
		if(lfoAmount > 0 && lfoFreq > 0) {
			_phase += _rate;
			if(_phase > 2) {
				_phase -= 4;
			}
			amplitude = 1 - ((1 - _phase * (2 - Math.abs(_phase))) * 0.5) * lfoAmount;
		}
	}

	function calcFreq() {
		var tuning = Math.pow(2.0, (semitones + cents * 0.01) / 12.0);
		frequency = baseFreq * tuning;
	}

	function set_baseFreq(v:Float) {
		baseFreq = v;
		calcFreq();
		return baseFreq;
	}

	function set_semitones(v:Int) {
		semitones = v;
		calcFreq();
		return semitones;
	}

	function set_cents(v:Int) {
		cents = v;
		calcFreq();
		return cents;
	}

	function set_lfoAmount(v:Float) {
		lfoAmount = v;
		if(lfoAmount <= 0) {
			amplitude = 1;
		}
		return lfoAmount;
	}

	function set_lfoFreq(v:Float) {
		lfoFreq = v;
		_rate = 4 * (lfoFreq / _sampleRate);
		return lfoFreq;
	}

}