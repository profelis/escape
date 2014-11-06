package deep.h3d.bezier;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class PathBuilder
{

	var start:Vector;
	public var path(default, null):Path;
	
	public function new(start:Vector) 
	{
		this.start = start;
		path = new Path();
	}
	
	public function lineTo(end:Vector, ?segments:Int):PathBuilder {
		path.add(new Line(start, end, segments));
		start = end;
		return this;
	}
	
	public function quadraticTo(control:Vector, end:Vector, ?segments:Int):PathBuilder {
		path.add(new Quadratic(start, control, end, segments));
		start = end;
		return this;
	}
	
}