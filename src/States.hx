package ;

class States {

	public var states:Map<String, State>;
	public var current(default, null):State;

	public function new() {
		states = new Map();
	}

	public function add(state:State) {
		if(states.exists(state.name)) {
			throw('state with name: ${state.name} already exists');
		}

		states.set(state.name, state);
	}

	public function remove(name:String):State {
		var state = states.get(name);

		if (state != null) {
			if (current == state) {
				current.onLeave();
				current = null;
			}
			states.remove(name);
		}

		return state;
	}

	public function set(name:String) {
		var state = states.get(name);

		if (state != null) {
			if (current != null) {
				current.onLeave();
			}
			state.onEnter();
			current = state;
		}
	}

}
