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
	var _capacity:Int = 16;
	public var capacity(get, set):Int;

	public dynamic function canRemove(item:T) return true;
	
	public function new(builder:Void -> T, ?destructor:T -> Void, ?freeAction:T -> Void) {
		this.builder = builder;
		this.destructor = destructor;
		this.freeAction = freeAction;
		items = [];
	}
	
	public inline function get():T {
        return if (items.length > 0) items.pop(); else builder();
	}
	
	public inline function free(item:T):Void {
		if (items.indexOf(item) > -1) {
            if (freeAction != null) freeAction(item);
            if (items.length < _capacity) items.push(item);
        }
	}

	function update() {
		if (items.length <= _capacity) return;
		var i = 0;
		var p = 0;
		while (i++ < items.length && items.length > _capacity) {
			var item = items[p];
			if (canRemove(item)) {
				if (destructor != null) destructor(item);
			} else p++;
		}
	}
	
	public var length(get, never):Int;
	
	inline function get_length():Int return items.length;
	
	public var destructed(default, null):Bool = false;
	
	public function destroy(deep:Bool = true):Void {
		if (deep) {
			if (destructor != null)
				for (i in items) if (canRemove(i)) destructor(i);
		}
		items = null;
		builder = null;
		freeAction = null;
		destructor = null;
		destructed = true;
	}

	inline function set_capacity(v:Int):Int {
		_capacity = v;
		update();
		return _capacity;
	}

	inline function get_capacity():Int return _capacity;
}