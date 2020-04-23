package;

import clay.Clay;

class Main {
	
	public static function main() {
		Clay.init(
			{
				title: 'crystalium',
				width: 960,
				height: 640,
				window: {
					resizable: false
				}
			}, 
			onReady
		);
	}

	static function onReady() {
		new Game();
	}

}
