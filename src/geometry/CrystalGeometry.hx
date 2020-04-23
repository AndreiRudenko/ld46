package geometry;

import clay.math.VectorCallback;
import clay.math.Vector;
import clay.utils.Color;
import clay.render.Vertex;
import clay.render.Camera;
import clay.graphics.Mesh;
import clay.utils.Log.*;

class CrystalGeometry extends Mesh {

	public var point0(get, set):VectorCallback;
	public var point1(get, set):VectorCallback;

	public var color0(default, set):Color;
	public var color1(default, set):Color;

	public var weight0(get, set):Float;
	public var weight1(get, set):Float;

	public var offset0(get, set):Float;
	public var offset1(get, set):Float;

	public var capScale0(get, set):Float;
	public var capScale1(get, set):Float;

	var _weight0:Float;
	var _weight1:Float;
	var _offset0:Float;
	var _offset1:Float;
	var _capScale0:Float;
	var _capScale1:Float;
	var _tmp:Vector;

	var _point0:VectorCallback;
	var _point1:VectorCallback;

	public function new(point0x:Float = 0, point0y:Float = 0, point1x:Float = 0, point1y:Float = 0) {
		_point0 = new VectorCallback(point0x, point0y);
		_point1 = new VectorCallback(point1x, point1y);
		_tmp = new Vector();

		_point0.listen(updateLineGeomListener);
		_point1.listen(updateLineGeomListener);

		var vertices = [
			new Vertex(new Vector(), new Vector(0, 0)),
			new Vertex(new Vector(), new Vector(1, 0)),
			new Vertex(new Vector(), new Vector(1, 1)),
			new Vertex(new Vector(), new Vector(0, 1)),
			new Vertex(new Vector(), new Vector(0, 0.5)),
			new Vertex(new Vector(), new Vector(1, 0.5))
		];
		
		var indices = [
			0, 1, 2, 0, 2, 3, 
			0, 3, 4, 1, 5, 2
		];

		super(vertices, indices, null);

		color0 = new Color();
		color1 = new Color();

		weight0 = 1;
		weight1 = 1;
		offset0 = 0;
		offset1 = 0;
		capScale0 = 1;
		capScale1 = 1;
	}

	function updateLineGeomListener(v:Vector) {
		updateLineGeom();
	}

	inline function updateLineGeom() {
		if (point0.y == point1.y) {
			_tmp.set(0, -1);
		} else {
			_tmp.set(1, -(point1.x - point0.x) / (point1.y - point0.y));
		}
		_tmp.normalize();

		var of0 = (offset0 + 1) / 2;
		var of1 = (offset1 + 1) / 2;

		vertices[0].pos.set(point0.x + _tmp.x * of0* _weight0, point0.y + _tmp.y * (1 - of0)* _weight0);
		vertices[1].pos.set(point1.x + _tmp.x * of1* _weight1, point1.y + _tmp.y * (1 - of1)* _weight1);
		vertices[2].pos.set(point1.x - _tmp.x * of1* _weight1, point1.y - _tmp.y * (1 - of1)* _weight1);
		vertices[3].pos.set(point0.x - _tmp.x * of0* _weight0, point0.y - _tmp.y * (1 - of0)* _weight0);

		var r = point0.angle2D(point1);
		vertices[4].pos.set(point0.x - Math.cos(r) * (_weight0 / 2 * _capScale0), point0.y - Math.sin(r) * (_weight0 / 2 * _capScale0));
		vertices[5].pos.set(point1.x + Math.cos(r) * (_weight1 / 2 * _capScale1), point1.y + Math.sin(r) * (_weight1 / 2 * _capScale1));
	}

	inline function get_point0():VectorCallback {
		return _point0;
	}

	function set_point0(v:VectorCallback):VectorCallback {
		_point0.listen(null);

		_point0 = v;

		_point0.listen(updateLineGeomListener);
		updateLineGeom();

		return _point0;
	}

	inline function get_point1():VectorCallback {
		return _point1;
	}

	function set_point1(v:VectorCallback):VectorCallback {
		_point1.listen(null);

		_point1 = v;

		_point1.listen(updateLineGeomListener);
		updateLineGeom();

		return _point1;
	}

	inline function get_weight0():Float {
		return _weight0;
	}

	function set_weight0(v:Float):Float {
		_weight0 = v;

		updateLineGeom();

		return _weight0;
	}

	inline function get_weight1():Float {
		return _weight1;
	}

	function set_weight1(v:Float):Float {
		_weight1 = v;

		updateLineGeom();

		return _weight1;
	}

	inline function get_offset0():Float {
		return _offset0;
	}

	function set_offset0(v:Float):Float {
		_offset0 = v;

		updateLineGeom();

		return _offset0;
	}

	inline function get_offset1():Float {
		return _offset1;
	}

	function set_offset1(v:Float):Float {
		_offset1 = v;

		updateLineGeom();

		return _offset1;
	}

	inline function get_capScale0():Float {
		return _capScale0;
	}

	function set_capScale0(v:Float):Float {
		_capScale0 = v;

		updateLineGeom();

		return _capScale0;
	}

	inline function get_capScale1():Float {
		return _capScale1;
	}

	function set_capScale1(v:Float):Float {
		_capScale1 = v;

		updateLineGeom();

		return _capScale1;
	}

	function set_color0(_c:Color):Color {
		color0 = _c;

		vertices[0].color = color0;
		vertices[3].color = color0;
		vertices[4].color = color0;

		return color0;
	}

	function set_color1(_c:Color):Color {
		color1 = _c;

		vertices[1].color = color1;
		vertices[2].color = color1;
		vertices[5].color = color1;

		return color1;
	}

}
