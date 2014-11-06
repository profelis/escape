package deep.tools;
import deep.tools.base.IDestructable;
import haxe.ds.ObjectMap;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class ObjectCache<K, V> implements IDestructable {

	var keys:Array<K>;
	var items:Array<V>;
	
	public var size(default, set):Int;
	
	function set_size(v) {
		if (v < 0) v = 0;
		size = v;
		update();
		return v;
	}
	
	public dynamic function canRemove(item:V):Bool return true;
	
	public function new(size = 10) {
		keys = [];
		items = [];
		
		this.size = size;
	}
	
	public function set(k:K, v:V) {
		remove(k);
		keys.push(k);
		items.push(v);
		update();
	}
	
	public inline function has(k:K) {
		return Lambda.has(items, k);
	}
	
	public inline function remove(k:K) {
		var pos = Lambda.indexOf(keys, k);
		if (pos >= 0) {
			keys.splice(pos, 1);
			items.splice(pos, 1);
		}
	}
	
	public function get(k:K) {
		return items[Lambda.indexOf(keys, k)];
	}
	
	function update() {
		if (keys.length > size) {
			var i = 0;
			var p = 0;
			while (i++ < keys.length && keys.length > size) {
				var k = keys[p];
				if (canRemove(get(k))) {
					keys.splice(p, 1);
					items.splice(p, 1);
				} else p++;
			}
		}
	}
	
	public var destructed(default, null):Void = false;
	
	public function destroy(deep:Bool = true):Void {
		if (deep) {
			for (i in items) {
				if (Std.is(i, IDestructable)) i.destroy();
			}
		}
		items = [];
		keys = [];
		destructed = true;
	}
	
}