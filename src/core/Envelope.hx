package core;

import clay.Clay;

class Envelope {

	public var active(default, null):Bool;
	public var amplitude(default, null):Float;

	var _sampleRate:Float;

	public function new() {
		active = false;
		amplitude = 0;
		_sampleRate = Clay.audio.sampleRate;
	}

	public function start() {
	}

	public function stop() {
	}

	public function reset() {}
	public function process() {}

}
