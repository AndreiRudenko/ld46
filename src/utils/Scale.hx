package utils;

import clay.Clay;
import clay.utils.ArrayTools;

class Scale {

	public var name(default, null):String;
	public var keys(default, null):Array<Int>;

	public function new(name:String, keys:Array<Int>) {
		this.name = name;
		this.keys = keys;
	}

	// hack
	public function getKeyFromScaleIdx(idx:Int):Int {
		var oct = Math.floor(idx / keys.length);
		var idx = idx % keys.length;
		return keys[idx] + 12 * oct;
	}

}
