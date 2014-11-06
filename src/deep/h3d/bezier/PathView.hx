package deep.h3d.bezier;
import h3d.scene.Object;
import h3d.scene.RenderContext;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class PathView extends Object {
	
	public var path:Path;
	public var color:UInt;
	public var depth:Bool;
	
	public function new(?parent, path:Path, color:UInt = 0xFFFF0000, depth = false) {
		super(parent);
		this.path = path;
		this.color = color;
		this.depth = depth;
	}
	
	override private function draw(ctx:RenderContext):Void 
	{
		var it = path.pointsIterator();
		if (!it.hasNext()) return;
		
		var start = it.next().clone();
		start.transform(absPos);
		while (it.hasNext()) {
			var p = it.next().clone();
			p.transform(absPos);
			ctx.engine.lineP(start, p, color, depth);
			start = p;
		}
	}
}