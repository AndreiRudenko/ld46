package objects;

import clay.Clay;
import clay.resources.Texture;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.utils.Color;
import clay.graphics.Sprite;
import core.WavetableOsc;
import utils.KeyUtils;

class FireFly {

	public var pos(get, never):Vector;
	public var size(get, set):Float;
	public var velocity:Vector;
	public var speed:Float;
	public var maxSpeed:Float;
	public var angle:Float;
	public var damping:Float;
	public var moveToCrystal:Bool = false;

	public var geometry:Sprite;
	public var geometryGlow:Sprite;

	var _geomAlpha:Float = 1;
	var _tweenAlpha:Float = 1;
	var _alphaTimer:Float = 0;
	var _alphaSpeed:Float = 1;
	var _alphaTweenSign:Int = 1;
	var _currentSpeed:Float = 0;

	public function new(x:Float, y:Float) {
		geometry = new Sprite();
		geometry.size.set(1,1);
		geometry.transform.rotation = 45;
		geometry.transform.pos.set(x,y);
		geometry.shader = Game.screenShader;
		Clay.layers.add(geometry, Layers.FOREGROUND);

		geometryGlow = new Sprite();
		geometryGlow.size.set(2,2);
		geometryGlow.transform.parent = geometry.transform;
		geometryGlow.color.a = Settings.FIREFLY_GLOW_ALPHA;
		Clay.layers.add(geometryGlow, Layers.BACKGROUND2);

		velocity = new Vector();
		maxSpeed = Settings.FIREFLY_MAX_SPEED;
		damping = Settings.FIREFLY_DAMPING;
		angle = 0;
		this.size = Clay.random.int(Settings.FIREFLY_SIZE_MIN, Settings.FIREFLY_SIZE_MAX);
		this.speed = Mathf.lerp(Settings.FIREFLY_SPEED_MAX, Settings.FIREFLY_SPEED_MIN, size / Settings.FIREFLY_SIZE_MAX);
		resetAlphaTimer();
	}

	function resetAlphaTimer() {
		_alphaTimer = Clay.random.float(Settings.FIREFLY_ALPHA_TWEEN_MIN, Settings.FIREFLY_ALPHA_TWEEN_MAX);
		_alphaSpeed = Clay.random.float(Settings.FIREFLY_ALPHA_TWEEN_SPEED_MIN, Settings.FIREFLY_ALPHA_TWEEN_SPEED_MAX);
		_alphaTweenSign = -_alphaTweenSign;
	}

	public function destroy() {
		geometry.drop();
		geometryGlow.drop();
		geometry = null;
		geometryGlow = null;
	}

	public function update(elapsed:Float) {
		_currentSpeed = Clay.random.float(speed);

		if(_alphaTimer > 0) {
			_alphaTimer -= elapsed;
			_tweenAlpha += _alphaTweenSign * (_alphaSpeed * elapsed);
			_tweenAlpha = Mathf.clamp(_tweenAlpha, Settings.FIREFLY_ALPHA_MIN, Settings.FIREFLY_ALPHA_MAX);
		} else {
			resetAlphaTimer();
		}

		if(moveToCrystal) {
			if(damping < Settings.FIREFLY_DAMPING_GLOW) {
				damping = Mathf.clampTop(damping + elapsed * Settings.FIREFLY_DAMPING_UP, Settings.FIREFLY_DAMPING_GLOW);
			}
		} else {
			if(damping > Settings.FIREFLY_DAMPING) {
				damping = Mathf.clampBottom(damping - elapsed * Settings.FIREFLY_DAMPING_DOWN, Settings.FIREFLY_DAMPING);
			}
		}
		
		var x = pos.x;
		var y = pos.y;
		var r = Mathf.radians(angle);
		var vx = Math.cos(r) * _currentSpeed;
		var vy = Math.sin(r) * _currentSpeed;
		velocity.addXY(vx, vy);
		velocity.multiplyScalar(damping);

		var vlen = velocity.length;

		if(vlen > maxSpeed) {
			velocity.divideScalar(vlen).multiplyScalar(maxSpeed);
		}

		pos.x += velocity.x * elapsed;
		pos.y += velocity.y * elapsed;

		angle = Clay.random.float(360);

		geometry.color.a = _geomAlpha * _tweenAlpha;
		geometryGlow.color.a = Settings.FIREFLY_GLOW_ALPHA * _tweenAlpha;
	}

	inline function get_pos() {
		return geometry.transform.pos;
	}

	inline function get_size() {
		return geometry.transform.scale.x;
	}

	inline function set_size(v:Float) {
		geometry.transform.scale.set(v,v);
		return v;
	}

}