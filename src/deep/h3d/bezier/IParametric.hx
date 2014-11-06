package deep.h3d.bezier;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface IParametric<T>
{
	var start:Vector;
	var end:Vector;
	
	var segments:Int;
	
	function getPoint(time:Float, ?res:Vector):Vector;
	
	function getPoints(from:Float = 0, to:Float = 1, ?segments:Int):Array<Vector>;
	
	var length(get, never):Float;
	
	function clone():T;	
}