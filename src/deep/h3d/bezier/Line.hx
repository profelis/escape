package deep.h3d.bezier;
import h3d.FMath;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Line implements IParametric<Line>
{
	public var start:Vector;
	public var end:Vector;
	
	static public var SEGMENTS = 1;
	
	public var segments:Int;
	
	public function new(?start:Vector, ?end:Vector, ?segments:Int) 
	{
		this.start = start != null ? start : new Vector();
		this.end = end != null ? end : new Vector();
		this.segments = segments != null ? segments : SEGMENTS;
	}
	
	public var length(get, never):Float;
	
	inline function get_length():Float {
		return start.distance(end);
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
	
	inline function calcPoint(time:Float, res:Vector):Void {
		res.x = start.x + time * (end.x - start.x);
		res.y = start.y + time * (end.y - start.y);
		res.z = start.z + time * (end.z - start.z);
	}
	
	public inline function clone():Line {
		return new Line(start.clone(), end.clone(), segments);
	}
	
	public function toString() {
		return '{Line: $start - $end}';
	}
	
}