package core;

import clay.Clay;

// https://www.earlevel.com/main/2013/06/03/envelope-generators-adsr-code/

class AR extends Envelope {

	public var attack(get, set):Float;
	public var release(get, set):Float;

	var _attack:Float;
	var _release:Float;

	var _attackBase:Float;
	var _releaseBase:Float;

	var _attackCoef:Float;
	var _releaseCoef:Float;

		// small number such as 0.0001 to 0.01 for mostly-exponential, large numbers like 100 for virtually linear
	var _targetRatioA:Float;
	var _targetRatioR:Float;

	var _state:ARState;

	public function new(attack:Float, release:Float) {
		super();

		_state = ARState.IDLE;

		_targetRatioA = 0.3;
		_targetRatioR = 0.01; // 0.0001

		_attack = attack;
		_release = release;

		_attackBase = 0;
		_releaseBase = 0;

		_attackCoef = 0;
		_releaseCoef = 0;

		this.attack = attack;
		this.release = release;
	}

	override function start() {
		active = true;
		// amplitude = 0;
		_state = ARState.ATTACK;
	}

	override function stop() {
		// if(_state != ) {
			
		// }
		// _state = ARState.RELEASE;
	}

	override function reset() {
		stop();
		amplitude = 0;
		active = false;
		_state = ARState.IDLE;
	}

	override function process() {
		if(active) {
			switch (_state) {
				case ARState.ATTACK:
					amplitude = _attackBase + amplitude * _attackCoef;
					if (amplitude >= 1) {
						amplitude = 1;
						_state = ARState.RELEASE;
					}
				case ARState.RELEASE:
					amplitude = _releaseBase + amplitude * _releaseCoef;
					if (amplitude <= 0) {
						amplitude = 0;
						_state = ARState.IDLE;
						active = false;
					}
				case _:
			}
		}
	}

	inline function get_attack():Float {
		return _attack;
	}

	function set_attack(v:Float):Float {
		_attack = v;
		_attackCoef = calcCoef(_attack * _sampleRate, _targetRatioA);
		_attackBase = (1.0 + _targetRatioA) * (1.0 - _attackCoef);
		return _attack;
	}

	inline function get_release():Float {
		return _release;
	}

	function set_release(v:Float):Float {
		_release = v;
		_releaseCoef = calcCoef(_release * _sampleRate, _targetRatioR);
		_releaseBase = -_targetRatioR * (1.0 - _releaseCoef);
		return _release;
	}

	inline function calcCoef(rate:Float, targetRatio:Float) {
		return (rate <= 0) ? 0.0 : Math.exp(-Math.log((1.0 + targetRatio) / targetRatio) / rate);
	}

}

enum abstract ARState(Int) {
	var IDLE;
	// var PRE_ATTACK; // hack to remove clicks
	var ATTACK;
	var RELEASE;
}