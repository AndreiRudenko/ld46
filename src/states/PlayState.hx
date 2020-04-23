package states;

import clay.Clay;
import clay.input.Key;
import clay.events.AppEvent;
import clay.events.MouseEvent;
import clay.events.KeyEvent;
import clay.graphics.shapes.Quad;
import clay.graphics.Text;
import clay.utils.Color;
import clay.utils.Align;

class PlayState extends State {

	var title:Text;
	var titleBg:Text;
	var author:Text;
	var press:Text;

	var _idleTimer = 0.0;
	var _titleBgAlpha = 0.5;
	var _authorAlpha = 0.3;
	var _pressAlpha = 0.3;
	var _titleVisible:Bool = false;

	public function new() {
		super('play');
	}

	override function onEnter() {
		listenEvents();

		title = new Text(Clay.resources.font('Lato-Bold.ttf'));
		title.align = Align.CENTER;
		title.text = 'Crystalium';
		title.transform.pos.set(Clay.screen.mid.x, 128);
		title.fontSize = 64;
		Clay.layers.add(title, Layers.MAIN);

		titleBg = new Text(Clay.resources.font('Lato-Bold.ttf'));
		titleBg.align = Align.CENTER;
		titleBg.text = 'Crystalium';
		titleBg.transform.pos.copyFrom(title.transform.pos);
		titleBg.fontSize = 64;
		titleBg.color.a = _titleBgAlpha;
		Clay.layers.add(titleBg, Layers.BACKGROUND2);

		author = new Text(Clay.resources.font('Lato-Regular.ttf'));
		author.align = Align.CENTER;
		author.text = 'by Andrei Rudenko';
		author.transform.pos.set(Clay.screen.mid.x, title.transform.pos.y + 72);
		author.fontSize = 20;
		author.color.a = _authorAlpha;
		Clay.layers.add(author, Layers.MAIN);

		press = new Text(Clay.resources.font('Lato-Italic.ttf'));
		press.align = Align.CENTER;
		press.text = 'press numbers to play or space to next crystal';
		press.transform.pos.set(Clay.screen.mid.x, Clay.screen.height - 48);
		press.fontSize = 18;
		press.color.a = _pressAlpha;
		Clay.layers.add(press, Layers.MAIN);

		title.visible = false;
		titleBg.visible = false;
		author.visible = false;
		press.visible = false;
		resetIdleTimer();
		showTitle();

		if(!Game.scene.inTransition) {
			Game.scene.inTransition = true;
			var overlay = Game.overlay;
			Clay.tween.stop(overlay.color);

			overlay.visible = true;
			overlay.color.a = 1;
			Clay.tween.object(overlay.color)
			.to({a: 0}, 2)
			.onComplete(
				function() {
					overlay.visible = false;
					Game.scene.inTransition = false;
				}
			)
			.ease(clay.tween.easing.Quart.easeOut)
			.start();
		}
	}

	function showTitle() {
		if(!_titleVisible) {
			_titleVisible = true;

			Clay.tween.stop(title.color);

			title.visible = true;
			titleBg.visible = true;
			author.visible = true;
			press.visible = true;

			title.color.a = 0;
			titleBg.color.a = 0;
			author.color.a = 0;
			press.color.a = 0;

			Clay.tween.object(title.color)
			.to({a: 1}, 3)
			.onUpdate(
				function() {
					titleBg.color.a = _titleBgAlpha * title.color.a;
					author.color.a = _authorAlpha * title.color.a;
					press.color.a = _pressAlpha * title.color.a;
				}
			)
			.onComplete(
				function() {
				}
			)
			.ease(clay.tween.easing.Quart.easeIn)
			.start();
		}
	}

	function hideTitle() {
		if(_titleVisible) {
			_titleVisible = false;
			resetIdleTimer();
			Clay.tween.stop(title.color);

			Clay.tween.object(title.color)
			.to({a: 0}, 3)
			.onUpdate(
				function() {
					titleBg.color.a = _titleBgAlpha * title.color.a;
					author.color.a = _authorAlpha * title.color.a;
					press.color.a = _pressAlpha * title.color.a;
				}
			)
			.onComplete(
				function() {
					title.visible = false;
					titleBg.visible = false;
					author.visible = false;
					press.visible = false;
				}
			)
			.ease(clay.tween.easing.Quart.easeOut)
			.start();
		}
	}

	override function onLeave() {
		unlistenEvents();
	}

	function listenEvents() {
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(KeyEvent.KEY_UP, onKeyUp);
		Clay.on(AppEvent.UPDATE, update);
	}

	function unlistenEvents() {
		Clay.off(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.off(KeyEvent.KEY_UP, onKeyUp);
		Clay.off(AppEvent.UPDATE, update);
	}

	function onKeyDown(e:KeyEvent) {
		hideTitle();
		playFromKey(e.key);
	}

	function onKeyUp(e:KeyEvent) {
		stopFromKey(e.key);
		if(e.key == Key.SPACE || e.key == Key.RETURN) {
			Game.scene.nextCrystal();
		}
	}

	function playFromKey(key:Int) {
		switch (key) {
			case Key.NUMPAD0 | Key.ZERO: Game.scene.growCrystal(0, true);
			case Key.NUMPAD1 | Key.ONE: Game.scene.growCrystal(1, true);
			case Key.NUMPAD2 | Key.TWO: Game.scene.growCrystal(2, true);
			case Key.NUMPAD3 | Key.THREE: Game.scene.growCrystal(3, true);
			case Key.NUMPAD4 | Key.FOUR: Game.scene.growCrystal(4, true);
			case Key.NUMPAD5 | Key.FIVE: Game.scene.growCrystal(5, true);
			case Key.NUMPAD6 | Key.SIX: Game.scene.growCrystal(6, true);

			case Key.NUMPAD7 | Key.SEVEN: Game.scene.growCrystal(7, true);
			case Key.NUMPAD8 | Key.EIGHT: Game.scene.growCrystal(8, true);
			case Key.NUMPAD9 | Key.NINE: Game.scene.growCrystal(9, true);
			case _:
		}
	}

	function stopFromKey(key:Int) {
		switch (key) {
			case Key.NUMPAD0 | Key.ZERO: Game.scene.growCrystal(0, false);
			case Key.NUMPAD1 | Key.ONE: Game.scene.growCrystal(1, false);
			case Key.NUMPAD2 | Key.TWO: Game.scene.growCrystal(2, false);
			case Key.NUMPAD3 | Key.THREE: Game.scene.growCrystal(3, false);
			case Key.NUMPAD4 | Key.FOUR: Game.scene.growCrystal(4, false);
			case Key.NUMPAD5 | Key.FIVE: Game.scene.growCrystal(5, false);
			case Key.NUMPAD6 | Key.SIX: Game.scene.growCrystal(6, false);

			case Key.NUMPAD7 | Key.SEVEN: Game.scene.growCrystal(7, false);
			case Key.NUMPAD8 | Key.EIGHT: Game.scene.growCrystal(8, false);
			case Key.NUMPAD9 | Key.NINE: Game.scene.growCrystal(9, false);
			case _:
		}
	}

	function resetIdleTimer() {
		_idleTimer = Settings.IDLE_TIME;
	}

	function update(elapsed:Float) {
		Game.scene.update(elapsed);

		if(!_titleVisible) {
			if(!Game.scene.plant.isGrowing) {
				if(_idleTimer > 0) {
					_idleTimer -= elapsed;
				} else {
					showTitle();
				}
			} else {
				resetIdleTimer();
			}
		}

	}

}
