package;

import kha.Shaders;

import clay.Clay;
import clay.render.Camera;
import clay.audio.AudioGroup;
import clay.audio.effects.Reverb;
import clay.render.Shader;
import clay.graphics.shapes.Quad;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.utils.Color;
import clay.resources.Texture;
import clay.math.Vector;
import clay.utils.Log.*;
import utils.KeyUtils;
import utils.ColorHarmony;
import kha.math.FastVector2;
import core.LowPassFilter;

class Game {

	public static var states:States;
	public static var uiCamera:Camera;
	public static var glowCamera:Camera;
	public static var mainCamera:Camera;
	public static var audioGroup:AudioGroup;
	public static var mainGroup:AudioGroup;
	public static var scene:Scene;
	public static var scales:Scales;
	public static var colorHarmony:ColorHarmony;
	public static var reverb:Reverb;
	public static var filter:LowPassFilter;
	public static var overlay:Quad;
	public static var screenShader:Shader;

	var _blurShader:Shader;
	var _bufferShadowA:Texture;
	var _bufferShadowB:Texture;
	var _blurDirection:FastVector2 = new FastVector2();
	var _tmpVec:Vector = new Vector();

	public function new() {
		Clay.resources.loadAll(
			[
				'Lato-Bold.ttf',
				'Lato-Regular.ttf',
				'Lato-Italic.ttf'
			], 
			ready
		);
	}

	function ready() {

		scales = new Scales();
		colorHarmony = new ColorHarmony();
		initShaders();
		initCameras();
		initAudioGroup();
		setupDebug();

		overlay = new Quad(Clay.screen.width, Clay.screen.height);
		overlay.color = new Color(0,0,0,1);
		overlay.visible = false;
		Clay.layers.add(overlay, Layers.TOP);

		scene = new Scene();

		initStates();
		states.set('play');
	}

	function initStates() {
		states = new States();
		states.add(new states.PlayState());
	}

	function initAudioGroup() {
		audioGroup = new AudioGroup(Settings.VOICES_MAX);
		mainGroup = new AudioGroup(Settings.VOICES_MAX);

		filter = new LowPassFilter(200, Clay.audio.sampleRate);
		mainGroup.addEffect(filter);

		reverb = new Reverb({
			wet: 0.3,
			dry: 1,
			preDelay: 10,
			width: 0.6,
			highCut: 500,
			lowCut: 0,
			damping: 1.0,
			roomSize: 0.97,
			frozen: false,
		});
		mainGroup.addEffect(reverb);

		var limiter = new clay.audio.effects.Compressor(6, -8, 0.1, 0.5, 8, 0.1, 5);
		mainGroup.addEffect(limiter);

		mainGroup.add(audioGroup);
		Clay.audio.add(mainGroup);
	}

	function initShaders() {
		var shaderTextured = Clay.renderer.shaders.get('textured');
		screenShader = new Shader(shaderTextured.pipeline.inputLayout, Shaders.textured_vert, Shaders.textured_frag);
		screenShader.setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceColor, BlendOperation.Add, BlendFactor.BlendZero, BlendFactor.BlendOne);
		screenShader.compile();
		Clay.renderer.registerShader("screen", screenShader);

		var shaderTextured = Clay.renderer.shaders.get('textured');
		_blurShader = new Shader(shaderTextured.pipeline.inputLayout, Shaders.textured_vert, Shaders.blur_frag);
		_blurShader.setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		_blurShader.compile();
		Clay.renderer.registerShader("blur", _blurShader);
	}

	function initCameras() {
		Clay.camera.hideAll();
		Clay.camera.show(Layers.BACKGROUND);
		glowCamera = Clay.cameras.create('glowCamera');
		glowCamera.hideAll();
		glowCamera.show(Layers.BACKGROUND2);
		glowCamera.show(Layers.TOP);
		glowCamera.shader = screenShader;


		mainCamera = Clay.cameras.create('mainCamera');
		mainCamera.hideAll();
		mainCamera.show(Layers.MAIN);
		mainCamera.show(Layers.FOREGROUND);
		mainCamera.show(Layers.TOP);

		uiCamera = Clay.cameras.create('uiCamera');
		uiCamera.hideAll();
		uiCamera.show(Layers.UI);

		initBlur();
	}

	function initBlur() {
		var w = Clay.screen.width;
		var h = Clay.screen.height;
		var blurResolution = Settings.BLUR_RESOLUTION;
		_bufferShadowB = Texture.createRenderTarget(Std.int(w*blurResolution), Std.int(h*blurResolution));
		_bufferShadowB.id = 'bufferShadowB';
		_bufferShadowB.ref();
		Clay.resources.add(_bufferShadowB);

		_bufferShadowA = Texture.createRenderTarget(Std.int(w*blurResolution), Std.int(h*blurResolution));
		_bufferShadowA.id = 'bufferShadowA';
		_bufferShadowA.ref();
		Clay.resources.add(_bufferShadowA);

		glowCamera.onRenderTexture = function(source, dest) {
			var blur = Settings.BLUR_AMOUNT * blurResolution;

			_tmpVec.set(blurResolution, blurResolution);
			Clay.renderer.ctx.blit(source, _bufferShadowA, Clay.renderer.shaderTextured, _tmpVec);

			// horisontal blur pass
			_blurDirection.x = 1;
			_blurDirection.y = 0;
			_blurShader.setVector2('dir', _blurDirection);
			_blurShader.setFloat('blur', blur / _bufferShadowB.width);
			Clay.renderer.ctx.blit(_bufferShadowA, _bufferShadowB, _blurShader);

			// vertical blur pass
			_blurDirection.x = 0;
			_blurDirection.y = 1;
			_blurShader.setVector2('dir', _blurDirection);
			_blurShader.setFloat('blur', blur / _bufferShadowA.height);
			_tmpVec.set(1/blurResolution, 1/blurResolution);
			Clay.renderer.ctx.blit(_bufferShadowB, dest, _blurShader, _tmpVec);
		}

	}

	function setupDebug() {
		#if !no_debug_console
		Clay.debug.addView(new debug.SamplesDebugView(Clay.debug));
		#end
	}

}
