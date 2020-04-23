package objects;

import clay.Clay;
import clay.resources.Texture;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.utils.Color;
import clay.utils.ArrayTools;
import clay.graphics.Mesh;
import clay.render.Vertex;
import utils.KeyUtils;
import utils.Scale;
import clay.utils.Log.*;
import clay.utils.IntRingBuffer;
using clay.utils.ArrayTools;

class Plant {

	public var crystals:Array<Crystal>;

	public var geometry:Mesh;
	public var geometryGlow:Mesh;

	public var x:Float ;
	public var y:Float ;
	public var radius:Float = 90;
	public var angle:Float = 270;


	public var keyBase:Int = 0;
	public var scale:Scale;

	public var keyOffset:Int = 0;
	public var harmonics:Array<Float>;

	// public var lengthTotal:Float = 0;
	public var volScalerLength:Float = 480;

	public var volumes:Array<Float>;
	public var lfoFreqs:Array<Float>;
	public var lfoAmts:Array<Float>;

	// random

	public var scaleFactor:Float = 0.7;
	public var growScaleFactor:Float = 0.25;

	public var widthStart:Float = 16;
	public var widthEnd:Float = 48;

	public var growSpeed:Float = 1;
	public var fallSpeed:Float = 1;

	public var lfoAmountBase:Float;
	public var lfoFreqBase:Float;

	public var lfoAmount:Float;
	public var lfoFreqMin:Float;
	public var lfoFreqMax:Float;
	public var lfoFreqScaleMin:Float;
	public var volumeRnd:Float;
	public var lfoAmtRnd:Float;

	public var color0:Color;
	public var harmonicsCount:Int = 0;

	public var offset0:Float = 0;
	public var offset1:Float = 0;

	public var lengthMin:Float = 240;
	public var lengthMax:Float = 320;
	public var randomX:Float = 0;
	public var scaleDownVolume:Float = 0;
	public var alpha:Float = 1;
	public var size:Float = 1;
	public var envRelease:Float = 1;

	public var upperColorHue:Int = 0;
	public var upperColorSat:Float = 1;
	public var upperColorHueVariance:Int = 0;

	public var isGrowing(default, null):Bool = false;

	var _depthIds:IntRingBuffer;
	var _depthsUsed:Int = 0;

	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		keyOffset = KeyUtils.getKeyId('A1');
		crystals = [];
		geometry = new Mesh(
			[
				new Vertex(new Vector(-0.5, 0)),
				new Vertex(new Vector(0, -0.5)),
				new Vertex(new Vector(0.5, 0)),
				new Vertex(new Vector(0, 0.5))
			],
			[0,1,2,0,2,3]
		);
		geometry.color.a = 0.2;
		geometry.transform.pos.set(x, y);
		geometry.transform.scale.set(Settings.PLANT_WIDTH, Settings.PLANT_HEIGHT);
		geometry.shader = Game.screenShader;
		geometry.depth = 999;
		Clay.layers.add(geometry, Layers.BACKGROUND);

		geometryGlow = new Mesh(
			[
				new Vertex(new Vector(-0.5, 0)),
				new Vertex(new Vector(0, -0.5)),
				new Vertex(new Vector(0.5, 0)),
				new Vertex(new Vector(0, 0.5))
			],
			[0,1,2,0,2,3]
		);
		geometryGlow.color.a = 1;
		geometryGlow.transform.pos.set(x, y);
		geometryGlow.transform.scale.set(Settings.PLANT_WIDTH, Settings.PLANT_HEIGHT);
		geometryGlow.shader = Game.screenShader;
		geometryGlow.visible = false;
		Clay.layers.add(geometryGlow, Layers.BACKGROUND2);

		randomize();
	}

	function randomize() {
		scale = Game.scales.scaleList[Clay.random.int(Game.scales.scaleList.length)];

		harmonicsCount = Clay.random.int(Settings.HARMONICS_MIN, Settings.HARMONICS_MAX);
		_depthIds = new IntRingBuffer(16);
		var depthArray = [];
		for (i in 0...16) {
			depthArray.push(i);
		}
		depthArray.shuffle();

		for (i in 0...16) {
			@:privateAccess _depthIds._buffer[i] = depthArray[i];
		}

		scaleFactor = Clay.random.float(Settings.SCALE_MIN, Settings.SCALE_MAX);
		growScaleFactor = Clay.random.float(Settings.GROW_SCALE_MIN, Settings.GROW_SCALE_MAX);
		var sflerp = Mathf.inverseLerp(Settings.SCALE_MAX, Settings.SCALE_MIN, scaleFactor);

		harmonics = [1];

		var harmonicStartStepMax = Math.floor(Mathf.lerp(Settings.HARMONIC_STEP_START, Settings.HARMONIC_STEP_START_MAX, sflerp));
		var harmonicStartStep = Clay.random.int(Settings.HARMONIC_STEP_START, harmonicStartStepMax);
		var harmonicStart = 2;
		var harmonicStep = Math.floor(Mathf.lerp(Settings.HARMONIC_STEP, Settings.HARMONIC_STEP_MAX, sflerp));
		for (i in 1...harmonicsCount) {
			var rh = Clay.random.int(harmonicStart, harmonicStart+harmonicStep);
			harmonicStart = rh+harmonicStartStep;
			harmonicStartStep = Clay.random.int(Settings.HARMONIC_STEP_START, harmonicStartStepMax);
			harmonics.push(rh);
		}

		volumes = [1];

		for (i in 1...harmonicsCount) {
			volumes.push(Clay.random.float(Settings.OSC_VOLUME_MIN, Settings.OSC_VOLUME_MAX));
		}

		envRelease = Clay.random.float(Settings.ENVELOPE_RELEASE, Settings.ENVELOPE_RELEASE_MAX);
		
		widthStart = Clay.random.float(Settings.WIDTH_START_MIN, Settings.WIDTH_START_MAX);
		widthEnd = Clay.random.float(Settings.WIDTH_END_MIN, Settings.WIDTH_END_MAX);

		lfoAmount = Clay.random.float(Settings.LFO_AMOUNT);

		lfoFreqMin = Clay.random.float(Settings.LFO_FREQ_MIN, Settings.LFO_FREQ_MAX);
		lfoFreqMax = Clay.random.float(lfoFreqMin, Settings.LFO_FREQ_MAX);
		lfoFreqScaleMin = Clay.random.float(Settings.LFO_FREQ_SCALE_MIN, Settings.LFO_FREQ_SCALE_MAX);

		lfoAmountBase = Clay.random.float(Settings.LFO_AMOUNT_BASE);
		var lfbm = lfoFreqMin > Settings.LFO_FREQ_BASE_MAX ? Settings.LFO_FREQ_BASE_MAX : lfoFreqMin;
		lfoFreqBase = Clay.random.float(lfbm);

		volumeRnd = Clay.random.float(Settings.OSC_VOLUME_RND, 1);
		lfoAmtRnd = Clay.random.float(Settings.OSC_LFO_AMOUNT_RND, 1);

		offset0 = Clay.random.float(-0.5, 0.5);
		offset1 = Clay.random.float(-0.5, 0.5);

		var maxWidth = Math.max(widthStart*scaleFactor, widthStart);
		keyBase = Math.floor(Mathf.lerp(0, Settings.RNG_KEYS_RANGE, 1 - maxWidth / (Settings.WIDTH_START_MAX*Settings.SCALE_MAX)));

		lengthMin = Clay.random.float(Settings.LENGTH_MIN, Settings.LENGTH_MAX);
		lengthMax = Clay.random.float(Settings.LENGTH_MIN, Settings.LENGTH_MAX);
		randomX = Clay.random.float(Settings.RND_CRYSTAL_X);

		scaleDownVolume = Clay.random.float(Settings.SCALEDOWN_VOLUME_MIN, Settings.SCALEDOWN_VOLUME_MAX);

		lfoFreqs = [lfoFreqBase];
		lfoAmts = [lfoAmountBase];

		for (i in 1...harmonicsCount) {
			lfoFreqs.push(Clay.random.float(lfoFreqMin, lfoFreqMax));
			lfoAmts.push(Clay.random.float(lfoAmount));
		}

		var cid = Clay.random.bit();
		color0 = new Color().setHSB(Game.colorHarmony.hues[cid], Clay.random.getFloat(), 1);
		upperColorHue = Game.colorHarmony.hues[1-cid];
		upperColorSat = Clay.random.getFloat();
		upperColorHueVariance = Clay.random.int(Settings.CRYSTAL_HUE_VARIANCE);


		Game.reverb.damping = Clay.random.float(Settings.DAMPING_MIN, Settings.DAMPING_MAX);
		Game.reverb.roomSize = Clay.random.float(Settings.ROOMSIZE_MIN, Settings.ROOMSIZE_MAX);
		Game.reverb.highCut = Clay.random.float(Settings.HICUT_MIN, Settings.HICUT_MAX);
		// Game.reverb.preDelay = Clay.random.float(Settings.PREDELAY_MIN, Settings.PREDELAY_MAX);
		Game.filter.freq = Clay.random.float(Settings.FILTER_MIN, Settings.FILTER_MAX);

	}

	public function nextCrystal() {
		empty();
		randomize();
	}

	public function getLargestCrystal():Crystal {
		var len = 0.0;
		var largest:Crystal = null;
		for (c in crystals) {
			if(c.length > len) {
				len = c.length;
				largest = c;
			}
		}
		return largest;
	}

	@:noCompletion public function popDepth():Int {
		if(_depthsUsed >= 16) {
			throw("Out of textures, max allowed " + 16);
		}

		++_depthsUsed;
		return _depthIds.pop();
	}

	@:noCompletion public function pushDepth(id:Int) {
		--_depthsUsed;
		_depthIds.push(id);
	}

	public function empty() {
		var toRemove:Array<Crystal> = [];

		for (c in crystals) {
			toRemove.push(c);
			c.grow(false);
		}

		for (c in toRemove) {
			c.destroy();
		}
	}

	public inline function getCrystal(id:Int):Crystal {
		var ret:Crystal = null;
		for (c in crystals) {
			if(c.id == id) {
				ret = c;
				break; 
			}
		}
		return ret;
	}

	public function growCrystal(id:Int, state:Bool) {
		var c = getCrystal(id);
		if(c == null) {
			if(state) {
				c = createCrystal(id);
				crystals.push(c);
				c.grow(state);
			}
		} else {
			c.grow(state);
		}
	}

	public function stopGrowingAll() {
		for (c in crystals) {
			c.grow(false);
		}
	}

	public function removeCrystal(crystal:Crystal) {
		if(!crystals.remove(crystal)) {
			log('cant remove crystal ${crystal.id}, already removed?');
		}
	}

	public function update(elapsed:Float) {
		isGrowing = false;
		for (c in crystals) {
			c.update(elapsed);
			if(c.isGrowing) {
				isGrowing = true;
			}
		}
	}

	function createCrystal(id:Int) {
		var x = Clay.random.float(Clay.screen.mid.x - randomX, Clay.screen.mid.x + randomX);
		var c = new Crystal(this, id, x, y);
		return c;
	}

}
