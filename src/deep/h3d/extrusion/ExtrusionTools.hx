package deep.h3d.extrusion;
import deep.h3d.bezier.Line;
import h3d.FMath;
import h3d.prim.Point;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class ExtrusionTools
{
	static public inline function toPoint(v:Vector):Point {
		return new Point(v.x, v.y, v.z);
	}
	
	static public function getLineAngles(l:Line, x = true, y = true, z = true):Vector {
		var m = l.length;
		var res = new Vector();
		if (x) res.x = Math.asin((l.end.x - l.start.x) / m);
		if (y) res.y = Math.asin((l.end.y - l.start.y) / m);
		if (z) res.z = Math.asin((l.end.z - l.start.z) / m);
		return res;
	}
	
}

enum PathTextureType {
	FILL;
}

enum LatheTextureType {
	FILL;
	SEGMENT;
}