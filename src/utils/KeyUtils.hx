package utils;


class KeyUtils {

	public static final keyNames:Array<String> = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

	static inline var _baseFreq:Float = 27.5; // A0
	static var _d12thRootOf2:Float = Math.pow(2.0, 1.0 / 12.0);
	static var _keyFreq:Array<Float> = [
		for (key in 3...108) {
			_baseFreq * Math.pow(_d12thRootOf2, key);
		}
	];

	public static function getFreq(key:Int):Float {
		return _keyFreq[key];
	}

	public static function getName(key:Int):String {
		return keyNames[key % 12] + '${Math.floor(key / 12)}';
	}

	public static function getKeyId(name:String):Int {
		var keyName:String = '';
		var keyOctave:Int = 0;
		var keyLen:Int = 1;

		if(name.charCodeAt(1) == '#'.code) {
			keyLen = 2;
		}

		keyName = name.substr(0, keyLen);
		keyOctave = Std.parseInt(name.substr(keyLen, name.length)) - 1; // TODO: -1 ?

		var keyId:Int = keyNames.indexOf(keyName);

		if(keyId == -1) {
			trace('Unknown key ${name}');
		}

		return keyId + (12 * (keyOctave));
	}

}
