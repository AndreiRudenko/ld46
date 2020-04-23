package ;

import clay.Clay;
import clay.utils.ArrayTools;
import utils.Scale;
import utils.ScaleTypes;

class Scales {

	public var scaleList(default, null):Array<Scale>;

	public function new() {
		createScales();
	}

	public function get(name:String):Scale {
		for (s in scaleList) {
			if(s.name == name) {
				return s;
			}
		}
		return null;
	}

	function createScales() {
		scaleList = [
			new Scale('MAJOR', ScaleTypes.MAJOR),
			new Scale('MAJOR PENTA', ScaleTypes.MAJOR_PENTATONIC),
			new Scale('MINOR', ScaleTypes.MINOR),
			new Scale('MINOR MEL', ScaleTypes.MELODIC_MINOR),
			new Scale('MINOR HARM', ScaleTypes.HARMONIC_MINOR),
			new Scale('MINOR BLUES', ScaleTypes.MINOR_BLUES),
			new Scale('MINOR PENTA', ScaleTypes.MINOR_PENTATONIC),
			new Scale('MINOR HUNG', ScaleTypes.HUNGARIAN_MINOR),
			new Scale('MINOR GYPSY', ScaleTypes.MINOR_GYPSY),
			new Scale('IONIAN', ScaleTypes.IONIAN),
			new Scale('AEOLIAN', ScaleTypes.AEOLIAN),
			new Scale('AEOLIAN ION', ScaleTypes.ION_AEOL),
			new Scale('DORIAN', ScaleTypes.DORIAN),
			new Scale('MIXOLYDIAN', ScaleTypes.MIXOLYDIAN),
			new Scale('LYDIAN', ScaleTypes.LYDIAN),
			new Scale('PHRYGIAN', ScaleTypes.PHRYGIAN),
			new Scale('LOCRIAN', ScaleTypes.LOCRIAN),
			new Scale('LOCRIAN SUPER', ScaleTypes.SUPER_LOCRIAN),
			new Scale('DIMINISHED', ScaleTypes.DIMINISHED),
			new Scale('WHOLE HALF', ScaleTypes.WHOLE_HALF),
			new Scale('WHOLE TONE', ScaleTypes.WHOLE_TONE),
			new Scale('BHAIRAV', ScaleTypes.BHAIRAV),
			new Scale('HIROJOSHI', ScaleTypes.HIROJOSHI),
			new Scale('IN SEN', ScaleTypes.IN_SEN),
			new Scale('IWATO', ScaleTypes.IWATO),
			new Scale('KUMOI', ScaleTypes.KUMOI),
			new Scale('PELOG', ScaleTypes.PELOG),
			new Scale('SPANISH', ScaleTypes.SPANISH),
		];
	}
}


