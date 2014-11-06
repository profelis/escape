package deep.h3d.bezier;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Quadratic implements IParametric<Quadratic>
{
	public var start:Vector;
	public var control:Vector;
	public var end:Vector;
	
	static public var SEGMENTS = 25;
	
	public var segments:Int;
	
	public function new(?start:Vector, ?control:Vector, ?end:Vector, ?segments:Int) {
		this.start = start != null ? start : new Vector();
		this.control = control != null ? control : new Vector();
		this.end = end != null ? end : new Vector();
		this.segments = segments != null ? segments : SEGMENTS;
	}
	
	inline function calcPoint(time:Float, res:Vector):Void 
	{
		var t2 = 2 * (1 - time);

		res.x = start.x + time * (t2 * (control.x - start.x) + time * (end.x - start.x));
		res.y = start.y + time * (t2 * (control.y - start.y) + time * (end.y - start.y));
		res.z = start.z + time * (t2 * (control.z - start.z) + time * (end.z - start.z));
	}
	
	public function getPoints(from:Float = 0, to:Float = 1, ?segments:Int):Array<Vector> {
		if (segments == null) segments = this.segments;
		var d = (to - from) / segments;
		var res = [];
		segments ++;
		for (i in 0...segments) {
			var p = new Vector();
			calcPoint(from, p);
			res.push(p);
			from += d;
		}
		return res;
	}
	
	public function getPoint(time:Float, ?res:Vector):Vector {
		if (res == null) res = new Vector();
		calcPoint(time, res);
		return res;
	}
	
	inline function get_length():Float {
		return ParametricTools.getLength(getPoints());
	}
	
	public var length(get_length, null):Float;
	
	public inline function clone():Quadratic {
		return new Quadratic(start.clone(), control.clone(), end.clone(), segments);
	}
	
	public function toString() {
		return '{Quadratic: $start - $control - $end}';
	}
	
}