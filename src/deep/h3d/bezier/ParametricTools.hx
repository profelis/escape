package deep.h3d.bezier;
import flash.Vector.Vector;
import h3d.FMath;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class ParametricTools
{

	static public function getLength(points:Array<Vector>):Float {
		#if debug
		if (points.length < 2) throw "points.length < 2";
		#end
		
		var start = points[0];
		var res = 0.0;
		for (i in 1...points.length) {
			var p = points[i];
			res += start.distance(p);
			start = p;
		}
		return res;
	}
	
	static public inline function getSegments(points:Array<Vector>):Iterator<Line> {
		return new SegmentIterator(points);
	}
}

private class SegmentIterator {
	var points:Array<Vector>;
	var prev:Vector;
	var line:Line;
	var cursor:Int;
	
	public function new(points:Array<Vector>) {
		this.points = points;
		prev = points.length > 0 ? points[0] : null;
		if (prev != null) line = new Line();
		cursor = 1;
	}
	
	public inline function hasNext():Bool {
		return cursor < points.length;
	}
	
	public inline function next():Line {
		line.start = prev;
		line.end = prev = points[cursor++];
		return line;
	}
}