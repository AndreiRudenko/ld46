package ;

class State {

	public var name (default, null):String;

	public function new(name:String) {
		this.name = name;
	}

	public function onEnter() {}
	public function onLeave() {}

}
