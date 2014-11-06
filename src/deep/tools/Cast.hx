package deep.tools;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Cast
{

	static public inline function as<T>(a:Dynamic, c:Class<T>) {
		return Std.is(a, c) ? cast a : null;
	}
}