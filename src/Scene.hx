package ;

import clay.Clay;
import clay.resources.Texture;
import clay.graphics.shapes.Quad;
import clay.math.Vector;
import clay.utils.Color;
import clay.utils.Mathf;
import objects.Plant;
import objects.FireFly;
import objects.Crystal;

class Scene {

	public var colorTween:Float = 0;
	public var inTransition:Bool = false;
	public var plant:Plant;
	public var fireflies:Array<FireFly>;

	var bgGradient:Quad;

	var canGrow:Bool = true;

	public function new() {
		plant = new Plant(Clay.screen.mid.x, 480);
		fireflies = [];
		for (i in 0...Settings.FIREFLY_COUNT) {
			var x = Clay.random.int(Clay.screen.width);
			var y = Clay.random.int(Clay.screen.height);
			var ff = new FireFly(x, y);
			fireflies.push(ff);
		}

		bgGradient = new Quad(Clay.screen.width, Clay.screen.height);
		var c1 = getRandomColor0();
		var c2 = getRandomColor1();
		bgGradient.vertices[0].color = c1;
		bgGradient.vertices[1].color = c1;
		bgGradient.vertices[2].color = c2;
		bgGradient.vertices[3].color = c2;
		bgGradient.depth = 1;
		Clay.layers.add(bgGradient, Layers.BACKGROUND);
	}


	public function createFireFly(x:Float, y:Float) {
		var ff = new FireFly(x, y);
		fireflies.push(ff);
		return ff;
	}

	public function destroyFireFly(f:FireFly) {
		f.destroy();
		fireflies.remove(f);
	}

	public function getRandomFireFly():FireFly {
		return fireflies[Clay.random.int(fireflies.length)];
	}

	public function growCrystal(id:Int, state:Bool) {
		if(canGrow) {
			plant.growCrystal(id, state);
		}
	}

	public function nextCrystal() {
		if(!inTransition) {
			inTransition = true;
			canGrow = false;
			Game.colorHarmony.randomize();
			var ag = Game.audioGroup;

			var wasCrystals = plant.crystals.length > 0;
			if(wasCrystals) {
				plant.geometryGlow.visible = true;
				plant.geometryGlow.color.a = 0;
				plant.geometryGlow.transform.scale.set(Settings.PLANT_WIDTH, Settings.PLANT_HEIGHT);
			}
			Clay.tween.stop(ag);

			Clay.tween.object(ag)
			.to({volume: 0}, 2)
			.onUpdate(
				function() {
					if(wasCrystals) {
						plant.geometryGlow.color.a = Settings.PLANT_GLOW_ALPHA * (1-ag.volume);

						plant.geometryGlow.transform.scale.set(
							Mathf.lerp(8, Settings.PLANT_WIDTH, ag.volume), 
							Mathf.lerp(8, Settings.PLANT_HEIGHT, ag.volume)
						);
					}
					plant.size = ag.volume;
				}
			)
			.onComplete(
				function() {
					canGrow = true;

					if(wasCrystals) {
						plant.geometryGlow.visible = false;
						for (c in plant.crystals) {
							if(fireflies.length >= Settings.FIREFLY_COUNT_MAX) {
								destroyFireFly(getRandomFireFly());
							}
							createFireFly(c.geometry.point0.x, c.geometry.point0.y);
						}
					}

					plant.nextCrystal();
					plant.size = 1;
					ag.volume = 1;
					plant.alpha = 1;
					inTransition = false;
				}
			)
			.ease(clay.tween.easing.Quad.easeInOut)
			.start();

			var cid = Clay.random.bit();
			var c0 = getRandomColor0(cid);
			var c1 = getRandomColor1(1-cid);
			var vc0 = bgGradient.vertices[0].color;
			var vc1 = bgGradient.vertices[2].color;

			Clay.tween.stop(this);
			colorTween = 0;
			Clay.tween.object(this)
			.to({colorTween: 1}, 3)
			.onUpdate(
				function() {
					vc0.lerp(c0, colorTween);
					vc1.lerp(c1, colorTween);
				}
			)
			.onComplete(
				function() {
					vc0.copyFrom(c0);
					vc1.copyFrom(c1);
				}
			)
			.ease(clay.tween.easing.Expo.easeIn)
			.start();
		}
	}

	function getRandomColor0(id:Int = 0):Color {
		return new Color().setHSB(
			Game.colorHarmony.hues[2+id], 
			Clay.random.float(Settings.SKY_UP_SAT_MIN, Settings.SKY_UP_SAT_MAX), 
			Clay.random.float(Settings.SKY_UP_BRIGHTNESS_MIN, Settings.SKY_UP_BRIGHTNESS_MAX)
		);
	}

	function getRandomColor1(id:Int = 1):Color {
		return new Color().setHSB(
			Game.colorHarmony.hues[2+id], 
			Clay.random.float(Settings.SKY_DOWN_SAT_MIN, Settings.SKY_DOWN_SAT_MAX), 
			Clay.random.float(Settings.SKY_DOWN_BRIGHTNESS_MIN, Settings.SKY_DOWN_BRIGHTNESS_MAX)
		);
	}

	function moveFlyToCrystal(f:FireFly, elapsed:Float) {
		f.moveToCrystal = false;
		var d:Float;
		var dist = Math.POSITIVE_INFINITY;
		var nearest:Crystal = null;
		for (c in plant.crystals) {
			if(c.isGrowing) {
				d = f.pos.distance(c.geometry.point1);
				if(d < Settings.FIREFLY_IDLE_DISTANCE) {
					if(d < dist) {
						dist = d;
						nearest = c;
					}
				}
			}
		}
		if(nearest != null) {
			f.moveToCrystal = true;
			var w = Math.max(nearest.geometry.weight1, nearest.geometry.weight0);
			if(dist > w) {
				var r = f.pos.angle2D(nearest.geometry.point1);
				f.angle = Mathf.degrees(r);
			}
		}
	}

	function handleOffscreenFly(f:FireFly) {
		var hs = f.size/2;
		if(f.pos.x < -hs) {
			f.pos.x = Clay.screen.width + hs;
		}
		if(f.pos.x > Clay.screen.width + hs) {
			f.pos.x = -hs;
		}
		if(f.pos.y < -hs) {
			f.pos.y = Clay.screen.height + hs;
		}
		if(f.pos.y > Clay.screen.height + hs) {
			f.pos.y = -hs;
		}
	}

	public function update(elapsed:Float) {
		plant.update(elapsed);
		for (f in fireflies) {
			f.update(elapsed);
			handleOffscreenFly(f);
			moveFlyToCrystal(f, elapsed);
		}
	}

}