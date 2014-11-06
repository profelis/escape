package deep.inject;

import deep.reflect.ClassTools;
import haxe.ds.ObjectMap;
import haxe.rtti.Meta;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Injector  {
	
	static public function simpleBuilder(ref:Class<Dynamic>, args:Array<Dynamic>):Void->Dynamic {
		return function () return Type.createInstance(ref, args);
	}
	
	static function __init__() InjectorMacros.build()
	
	static public inline var INJECT = "inject";
	static public inline var INJECT_TYPE = "injectType";
	static public inline var INJECT_PROPERTY = "injectProperty";
	static public inline var INJECT_METHOD = "injectMethod";
	static public inline var POST_INJECT = "postInject";
	
	public function new() {
		injects = new Map();
	}
	
	public function destroy(deep = true)
	{
		if (deep) for (i in injects) for (m in i) m.destroy();
		injects = null;
	}
	
	var injects:Map<String, Map<Null<String>, InjectMethod>>;
	
	public function map(ref:Class<Dynamic>, ?value:Dynamic, ?valueRef:Class<Dynamic>, ?valueBuilder:Void->Dynamic, ?singleton:Bool = false, ?name:String):Void
	{
		var m:InjectMethod = if (value != null) new InjectValue(value);
		else if (valueRef != null) new InjectType(valueRef);
		else if (valueBuilder != null) new InjectValueBuilder(valueBuilder);
		else new InjectType(ref);
		
		m.init(ClassTools.getClassName(ref), singleton, name);
		#if debug m.check(); #end
		
		var map = injects.get(m.ref);
		if (map == null) injects.set(m.ref, map = new Map());
		map.set(name, m);
	}
	
	public function unmap(?refName:String, ?ref:Class<Dynamic>, ?name:String):Bool
	{
		if (refName == null) refName = ClassTools.getClassName(ref);
		var map = injects.get(refName);
		if (map == null) return false;
		var i = map.get(name);
		if (i != null)
		{
			i.destroy();
			map.remove(name);
			if (!map.iterator().hasNext()) injects.remove(refName);
			return true;
		}
		return false;
	}
	
	public function has(?refName:String, ?ref:Class<Dynamic>, ?name:String):Bool
	{
		if (ref == null) ref = ClassTools.resolveClass(refName);
		while (ref != null)
		{
			var map = injects.get(ClassTools.getClassName(ref));
			if (map != null && map.exists(name)) return true;
			ref = Type.getSuperClass(ref);
		}
		return false;
	}
	
	public function get(?refName:String, ?ref:Class<Dynamic>, ?name:String):Dynamic
	{
		if (ref == null) ref = ClassTools.resolveClass(refName);
		while (ref != null)
		{
			var map = injects.get(ClassTools.getClassName(ref));
			if (map != null && map.exists(name)) return map.get(name).build();
			ref = Type.getSuperClass(ref);
		}
		return null;
	}
	
	public function injectInto(value:Dynamic):Dynamic
	{
		var postInject = new Array<String>();
		var ref = Type.getClass(value);
		var fs = getDeepMeta(ref);
		for (n in Reflect.fields(fs))
		{
			if (n == "_") continue;
			var m = Reflect.field(fs, n);
			if (Reflect.hasField(m, POST_INJECT) && Reflect.isFunction(Reflect.field(value, n)))
			{
				postInject.push(n);
				continue;
			}
			if (!Reflect.hasField(m, INJECT)) continue;
			var inj:Array<String> = Reflect.field(m, INJECT);
			var name = inj != null ? inj[0] : null;
			if (Reflect.hasField(m, INJECT_TYPE))
			{
				var types:Array<Dynamic> = Reflect.field(m, INJECT_TYPE);
				var type:String = types[0];
				#if debug
				if (types[1] != 1 && !has(type, name))
					throw 'can\'t inject ${type} into field $n';
				#end
				Reflect.setField(value, n, get(type, name));
			}
			else if (Reflect.hasField(m, INJECT_PROPERTY))
			{
				var types:Array<Dynamic> = Reflect.field(m, INJECT_PROPERTY);
				var type:String = types[0];
				#if debug
				if (types[1] != 1 && !has(type, name))
					throw 'can\'t inject ${type} into property $n';
				#end
				Reflect.setProperty(value, n, get(type, name));
			}
			else if (Reflect.hasField(m, INJECT_METHOD))
			{
				var types:Array<Dynamic> = Reflect.field(m, INJECT_METHOD);
				
				var items:Array<Dynamic> = [];
				var i = 0;
				while(i < types.length >>> 1)
				{
					if (inj != null && inj.length > i) name = inj[i];
					var type:String = types[2*i++];
					#if debug
					if (types[i*2+1] != 1 && !has(type, name))
						throw 'can\'t inject $type into method $n';
					#end
					items.push(get(type, name));
				}
				Reflect.callMethod(value, Reflect.field(value, n), items);
			}
			else
			{
				throw "something wrong, 'inject' metadata are empty";
			}
		}
		for (n in postInject)
			Reflect.callMethod(value, Reflect.field(value, n), []);
		
		return value;
	}
	
	function getDeepMeta(ref:Class<Dynamic>):Dynamic<Dynamic<Array<Dynamic>>>
	{
		var fs = Meta.getFields(ref);
		var pRef = Type.getSuperClass(ref);
		while (pRef != null) {
			var f = Meta.getFields(pRef);
			for (n in Reflect.fields(f)) {
				if (n != "_" && !Reflect.hasField(fs, n))
					Reflect.setField(fs, n, Reflect.field(f, n));
			}
			pRef = Type.getSuperClass(pRef);
		}
		return fs;
	}
	
	public function build<T>(ref:Class<T>):T
	{
		var fs = getDeepMeta(ref);
		var items:Array<Dynamic> = [];
		if (Reflect.hasField(fs, "_"))
		{
			var m = Reflect.field(fs, "_");
			if (Reflect.hasField(m, INJECT))
			{
				var inj:Array<String> = Reflect.field(m, INJECT);
				var name = inj != null ? inj[0] : null;
				var types:Array<Dynamic> = Reflect.field(m, INJECT_METHOD);
				var i = 0;
				while(i < types.length >>> 1)
				{
					if (inj != null && inj.length > i) name = inj[i];
					var type:String = types[2*i++];
					#if debug
					if (types[i*2+1] != 1 && !has(type, name))
						throw 'can\'t inject $type into ctor';
					#end
					items.push(get(type, name));
				}
			}
		}
		var res = Type.createInstance(ref, items);
		return injectInto(res);
	}
}

private class InjectMethod
{
	public var ref:String;
	public var name:Null<String>;
	public var singleton:Bool;
	
	inline public function init(ref:String, singleton:Bool, name:String)
	{
		this.ref = ref;
		this.name = name;
		this.singleton = singleton;
	}
	
	public function build():Dynamic
	{
		throw "not implemented";
		return null;
	}
	
	public function check() throw "not inmplemented";
	
	public function destroy():Void throw "not implemented";
}

private class InjectValue extends InjectMethod
{
	var value:Dynamic;
	public function new(value:Dynamic) this.value = value
	
	override public function build():Dynamic
	{
		return value;
	}
	
	override public function check()
	{
		if (singleton) throw "value injector can't be singleton";
		if (!Std.is(value, ClassTools.resolveClass(ref)))
			throw 'Can\'t inject $value as $ref';
	}
	
	override public function destroy():Void value = null;
}

private class InjectType extends InjectValue
{
	var valueRef:Class<Dynamic>;
	public function new(valueRef:Class<Dynamic>)
	{
		super(null);
		this.valueRef = valueRef;
	}
	
	override public function build():Dynamic 
	{
		if (!singleton) return Type.createInstance(valueRef, []);
		
		if (value == null) value = Type.createInstance(value, []);
		return value;
	}
	
	override public function check()
		if (!Std.is(Type.createEmptyInstance(valueRef), ClassTools.resolveClass(ref)))
			throw 'Can\'t inject $valueRef as $ref'
	
	override public function destroy():Void 
	{
		super.destroy();
		valueRef = null;
	}
}

private class InjectValueBuilder extends InjectValue
{
	var builder:Void->Dynamic;
	public function new(builder:Void->Dynamic)
	{
		super(null);
		this.builder = builder;
	}
	
	override public function build():Dynamic 
	{
		if (!singleton) return builder();
		
		if (value == null) value = builder();
		return value;
	}
	
	override public function check()
		if (!Std.is(builder(), ClassTools.resolveClass(ref)))
			throw 'Can\'t inject $builder as $ref';
	
	override public function destroy():Void 
	{
		super.destroy();
		builder = null;
	}
}