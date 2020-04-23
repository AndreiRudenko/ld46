package objects;

import clay.Clay;
import clay.resources.Texture;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.utils.Color;
import geometry.CrystalGeometry;
import core.WavetableOsc;
import utils.KeyUtils;

class Crystal {

	public var id:Int;
	public var geometry:CrystalGeometry;
	public var geometryBg2:CrystalGeometry;
	public var geometryOuter:CrystalGeometry;
	public var geometryBlur:CrystalGeometry;
	public var osc:WavetableOsc;
	public var angle:Float;
	public var length:Float = 8;
	public var growSpeed:Float = 2;
	public var fallSpeed:Float = 1;
	public var isGrowing(default, null):Bool = false;

	public var scale:Float = 0;

	public var maxLength:Float = 0;
	public var width:Float = 0;
	var _globalAlpha:Float = 1;

	var _plant:Plant;

	var _depthId:Int = 0;
	var _keyLerp:Float = 0;

	public function new(plant:Plant, scaleIdx:Int, x:Float, y:Float) {
		_plant = plant;
		id = scaleIdx;
		_keyLerp = id / Settings.KEYS_COUNT;
		var rh = _plant.radius/2;
		angle = _plant.angle + Clay.random.float(-rh, rh);
		growSpeed = Clay.random.float(Settings.GROW_SPEED_MIN, Settings.GROW_SPEED_MAX);
		fallSpeed = Clay.random.float(Settings.FALL_SPEED_MIN, Settings.FALL_SPEED_MAX);
		maxLength = Clay.random.float(_plant.lengthMin, _plant.lengthMax);

		_depthId = _plant.popDepth();

		geometry = new CrystalGeometry(x, y, x, y);
		geometry.color0 = _plant.color0.clone();
		geometry.color1 = new Color().setHSB(
			Mathf.mod(_plant.upperColorHue + Clay.random.int(-_plant.upperColorHueVariance, _plant.upperColorHueVariance), 360), 
			_plant.upperColorSat, 
			1
		);

		width = Mathf.lerp(_plant.widthStart, _plant.widthEnd, _keyLerp);
		geometry.weight0 = width;
		geometry.weight1 = width*_plant.scaleFactor;
		geometry.depth = _depthId;

		geometry.offset0 = Clay.random.float(-_plant.offset0, _plant.offset0);
		geometry.offset1 = Clay.random.float(-_plant.offset1, _plant.offset1);
		geometry.shader = Game.screenShader;

		Clay.layers.add(geometry, Layers.MAIN);

		geometryOuter = new CrystalGeometry(x, y, x, y);
		var goc = new Color(1,1,1,0.3);
		geometryOuter.color0 = goc;
		geometryOuter.color1 = goc.clone();
		geometryOuter.depth = _depthId - 0.5;
		geometryOuter.offset0 = geometry.offset0;
		geometryOuter.offset1 = geometry.offset1;
		geometryOuter.visible = false;
		Clay.layers.add(geometryOuter, Layers.MAIN);

		geometryBg2 = new CrystalGeometry(x, y, x, y);
		var goc = new Color(0,0,0,1);
		geometryBg2.color0 = goc;
		geometryBg2.color1 = goc;
		geometryBg2.depth = -1;
		geometryBg2.offset0 = geometry.offset0;
		geometryBg2.offset1 = geometry.offset1;
		Clay.layers.add(geometryBg2, Layers.MAIN);

		geometryBlur = new CrystalGeometry(x, y, x, y);
		geometryBlur.color0 = geometry.color0.clone();
		geometryBlur.color1 = geometry.color1.clone();
		geometryBlur.offset0 = geometry.offset0;
		geometryBlur.offset1 = geometry.offset1;
		Clay.layers.add(geometryBlur, Layers.BACKGROUND2);

		var key = _plant.scale.getKeyFromScaleIdx(scaleIdx);
		var freq = KeyUtils.getFreq(_plant.keyOffset + _plant.keyBase + key);
		osc = new WavetableOsc(freq, _plant.harmonics, _plant.envRelease);
		osc.setVolumes(_plant.volumes);
		osc.setLfoFreqs(_plant.lfoFreqs);
		osc.setLfoAmts(_plant.lfoAmts);
		osc.volumeRandomizeMult(_plant.volumeRnd);
		osc.lfoAmountRandomizeMult(_plant.lfoAmtRnd);
		osc.scaleVolume(_plant.scaleDownVolume);
		osc.scalelfoFreq(Mathf.lerp(_plant.lfoFreqScaleMin, 1, _keyLerp), 0);
		Game.audioGroup.add(osc);

		updateVolume();
		updateGeometry();
	}

	var outerLight:Float = 0;
	var outerLightBeam:Float = 0;

	public function update(elapsed:Float) {
		if(isGrowing) {
			if(length < maxLength) {
				length = Mathf.clampTop(length + growSpeed * elapsed, maxLength);
				if(outerLight < 1) {
					if(!geometryOuter.visible) {
						geometryOuter.visible = true;
					}
					outerLight += elapsed * Settings.GLOW_UP_SPEED;
					if(outerLight > 1) {
						outerLight = 1;
					}
				}
				updateVolume();
			}
			updateGeometry();

			if(outerLightBeam > 0) {
				outerLightBeam -= elapsed * _plant.envRelease;
			}
		} else {
			if(length > 0) {
				length = Mathf.clampBottom(length - fallSpeed * elapsed, 0);
				if(outerLight > 0) {
					outerLight -= elapsed * Settings.GLOW_DOWN_SPEED;
					if(outerLight < 0) {
						outerLight = 0;
						geometryOuter.visible = false;
					}
				}
				updateVolume();
				updateGeometry();
			} else {
				destroy();
			}
		}
	}

	public function destroy() {
		_plant.pushDepth(_depthId);
		_plant.removeCrystal(this);
		geometry.drop();
		geometryOuter.drop();
		// geometryBg.drop();
		geometryBg2.drop();
		geometryBlur.drop();
		osc.volume = 0;
		Game.audioGroup.remove(osc);
		_plant = null;
		geometry = null;
		geometryOuter = null;
		// geometryBg = null;
		geometryBg2 = null;
		geometryBlur = null;
		osc = null;
	}

	function getPan(x:Float):Float {
		return x / Clay.screen.width * 2 -1;
	}

	public function grow(state:Bool) {
		isGrowing = state;
		if(isGrowing) {
			outerLightBeam = 1;
			osc.envelope.start();
		} else {
			osc.envelope.stop();
		}
	}

	function updateVolume() {
		var v = length / _plant.volScalerLength;
		Mathf.clampTop(v, 1);
		osc.volume = v * Settings.PLAY_VOLUME;
		osc.pan = getPan(geometry.point1.x);
	}

	function updateGeometry() {
		var x = geometry.point0.x;
		var y = geometry.point0.y;
		var r = Mathf.radians(angle);
		var l = Mathf.clampTop(length*_plant.size+1, maxLength);
		geometry.point1.set(x + Math.cos(r) * l, y + Math.sin(r) * l);

		var sc = _plant.growScaleFactor;
		var w = Mathf.lerp(width * sc, width, l / maxLength);

		geometry.weight0 = w;
		geometry.weight1 = w*_plant.scaleFactor;

		var cs = Mathf.lerp(0.5, 2, l / maxLength);
		geometry.capScale0 = cs*Settings.CRYSTAL_BOTTOM_CAPSCALE;
		geometry.capScale1 = cs;

		_globalAlpha = Mathf.lerp(0, 1, l / 32);

		var pAlpha = _plant.alpha;
		var beam = outerLightBeam * Settings.LIGHT_BEAM_SCALE;

		geometry.color0.a = _globalAlpha * pAlpha;
		geometry.color1.a = _globalAlpha * pAlpha;

		geometryOuter.point0.copyFrom(geometry.point0);
		geometryOuter.point1.copyFrom(geometry.point1);
		geometryOuter.capScale0 = geometry.capScale0;
		geometryOuter.capScale1 = geometry.capScale1;
		geometryOuter.weight0 = geometry.weight0 + Settings.OUTER_GEOM_DIST;
		geometryOuter.weight1 = geometry.weight1 + Settings.OUTER_GEOM_DIST;

		var goa = outerLight * Settings.OUTER_GEOM_ALPHA * _globalAlpha * pAlpha;
		goa = Mathf.clampTop(goa + goa * beam, 1);
		geometryOuter.color0.a = 0.5 * goa;
		geometryOuter.color1.a = goa;

		geometryBg2.point0.copyFrom(geometry.point0);
		geometryBg2.point1.copyFrom(geometry.point1);
		geometryBg2.capScale0 = geometry.capScale0;
		geometryBg2.capScale1 = geometry.capScale1;
		geometryBg2.weight0 = geometry.weight0;
		geometryBg2.weight1 = geometry.weight1;
		geometryBg2.color0.a = 0.9 * _globalAlpha * pAlpha;
		geometryBg2.color1.a = 0.9 * _globalAlpha * pAlpha;

		geometryBlur.point0.copyFrom(geometry.point0);
		geometryBlur.point1.copyFrom(geometry.point1);
		geometryBlur.capScale0 = geometry.capScale0;
		geometryBlur.capScale1 = geometry.capScale1;
		geometryBlur.weight0 = geometry.weight0 + Settings.BLUR_OVERSIZE;
		geometryBlur.weight1 = geometry.weight1 + Settings.BLUR_OVERSIZE;

		var gba = Mathf.lerp(Settings.BLUR_ALPHA_MIN, Settings.BLUR_ALPHA_MAX, outerLight) * _globalAlpha * pAlpha;
		gba = Mathf.clampTop(gba + gba * beam, 1);
		geometryBlur.color0.a = gba;
		geometryBlur.color1.a = gba;
	}

}