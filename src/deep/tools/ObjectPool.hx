package deep.tools;

import deep.tools.base.IDestructable;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class ObjectPool<T> implements IDestructable {

	var items:Array<T>;
	var builder:Void -> T;
	var destructor:T -> Void;
	var freeAction:T -> Void;
	
	public function new(builder:Void -> T, ?destructor:T -> Void, ?freeAction:T -> Void) {
		this.builder = builder;
		this.destructor = destructor;
		this.freeAction = freeAction;
		items = [];
	}
	
	public inline function get():T {
        return if (items.length > 0) items.shift(); else builder();
	}
	
	public inline function free(item:T):Void {
		if (items.indexOf(item) > -1) {
            if (freeAction != null) freeAction(item);
            items.push(item);
        }
	}
	
	public var length(get, never):Int;
	
	inline function get_length():Int return items.length;
	
	public var destructed(default, null):Bool = false;
	
	public function destroy(deep:Bool = true):Void {
		if (deep) {
			if (destructor != null)
				for (i in items) destructor(i);
		}
		items = null;
		builder = null;
		freeAction = null;
		destructor = null;
		destructed = true;
	}
	
}