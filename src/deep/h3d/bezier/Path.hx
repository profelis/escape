package deep.h3d.bezier;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
@:final class Path
{

	public function new() 
	{
		items = [];
		allPoints = [];
		allLengths = [];
	}
	
	public function clone():Path {
		var res = new Path();
		res.items = items.copy();
		res.allPoints = allPoints.copy();
		res.allLengths = allLengths.copy();
		res.needUpdate = true;
		return res;
	}
	
	var items:Array<IParametric<Dynamic>>;
	var allPoints:Array<Array<Vector>>;
	var allLengths:Array<Float>;
	
	var points:Array<Vector>;
	
	var needUpdate:Bool = false;
	
	public var pointsNum(get, never):Int;
	public var segmentsNum(get, never):Int;
	
	public var length(default, null):Float = 0.0;
	
	public inline function get(pos:Int):IParametric<Dynamic> {
		return items[pos];
	}
	
	public inline function has(item:IParametric<Dynamic>):Bool {
		return Lambda.has(items, item);
	}
	
	public inline function add(item:IParametric<Dynamic>):Void {
		addAt(item, items.length);
	}
	
	public function addAt(item:IParametric<Dynamic>, pos:Int):Void {
		items.insert(pos, item);
		
		var p = item.getPoints();
		allPoints.insert(pos, p);
		var l = ParametricTools.getLength(p);
		allLengths.insert(pos, l);
		length += l;
		needUpdate = true;
	}
	
	public inline function remove(item:IParametric<Dynamic>) {
		removeAt(Lambda.indexOf(items, item));
	}
	
	public function removeAt(pos:Int):Void {
		length -= allLengths[pos];
		
		items.splice(pos, 1);
		allLengths.splice(pos, 1);
		allPoints.splice(pos, 1);
		
		needUpdate = true;
	}
	
	inline function update() {
		points = [];
		var last:Vector = null;
		for (ps in allPoints) {
			if (last != null && last.equals3(ps[0]))
				points = points.concat(ps.slice(1, ps.length));
			else
				points = points.concat(ps);
			last = points[points.length - 1];
		}
		needUpdate = false;
	}
	
	inline function get_pointsNum():Int {
		if (needUpdate) update();
		return points.length;
	}
	
	inline function get_segmentsNum():Int {
		if (needUpdate) update();
		return points.length - 1;
	}
	
	public inline function iterator():Iterator<IParametric<Dynamic>> {
		return items.iterator();
	}
	
	public inline function pointsIterator():Iterator<Vector> {
		if (needUpdate) update();
		return points.iterator();
	}
	
	public inline function segmentsIterator():Iterator<Line> {
		if (needUpdate) update();
		return ParametricTools.getSegments(points);
	}
	
}