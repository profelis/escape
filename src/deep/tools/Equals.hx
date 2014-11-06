package deep.tools;

import Type;
/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

using Reflect;

class Equals
{

	public static function equal(a:Dynamic, b:Dynamic, maxDepth:Int = 10):Bool {
		if (maxDepth < 0) return false;
		
		if (a == b) return true;
		
		var type = Type.typeof(a);
		//trace(type);
		switch (type) {
			case TInt, TFloat, TBool: return false;
			case TFunction: return Reflect.compareMethods(a, b);
			case TEnum(t): 
				if (t != Type.getEnum(b)) return false;

				var a = Type.enumParameters(a);
				var b = Type.enumParameters(b);

				if (a.length != b.length) return false;
				for (i in 0...a.length) 
					if (!equal(a[i], b[i], maxDepth - 1)) return false;
				return true;

			case TNull: return false;
			case TObject: if(Std.is(a, Class)) return false;
			case TUnknown:
			case TClass(t):
				if (t == Array) {
					if (!Std.is(b, Array)) return false;
					if (a.length != b.length) return false;
					for (i in 0...a.length) 
						if (!equal(a[i], b[i], maxDepth - 1)) return false;
					return true;
				}	
		}
		// a is Object or Unknown or Class instance
		switch (Type.typeof(b)) {
			case TInt, TFloat, TBool, TFunction, TEnum(_), TNull: return false;
			case TObject: if(Std.is(b, Class)) return false;
			case TUnknown:
			case TClass(t): if (t == Array) return false;
		}
		
		var fields:Array<String> = a.fields();
		if (fields.length == b.fields().length) {
			if (fields.length == 0) return true;
			for (f in fields)
				if (!(b.hasField(f) && equal(a.field(f), b.field(f), maxDepth - 1)))
					return false;
			return true;
		}
		return false;
	}
	
}