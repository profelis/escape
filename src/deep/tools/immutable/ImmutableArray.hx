package deep.tools.immutable;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
abstract ImmutableArray<T>(Array<T>) from Array<T>
{

	@:arrayAccess public inline function arrayAccess(key:Int):T {
        return this[key];
    }
	
	public inline function iterator():Iterator<T> {
		return this.iterator();
	}
	
	public inline function copy():Array<T> {
		return this.copy();
	}
	
}