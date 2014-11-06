package deep.net.loader;
import haxe.io.Path;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class Loaders {
	
	static var ldrs:Map<String, Class<ISingleLoader<Dynamic>>>;
	
	static function __init__() {
		ldrs = new Map();
	}
	public static function supportAll() {
		
		registerLoader(["jpg", "png", "jpeg", "gif"], BitmapLoader);
		registerLoader("swf", DisplayObjectLoader);
		registerLoader("txt", TextLoader);
		registerLoader("json", JsonLoader);
		registerLoader("xml", XMLLoader);
		registerLoader(["dat", "amf", "ttf"], ByteArrayLoader);
	}
	
	static public function registerLoader(?ext:String, ?exts:Array<String>, ldrRef:Class<ISingleLoader<Dynamic>>) {
		if (ext != null) ldrs.set(ext, ldrRef);
		if (exts != null) for (e in exts) ldrs.set(e, ldrRef);
	}
	
	static public function unregisterLoader(?ext:String, ?exts:Array<String>) {
		if (ext != null) ldrs.remove(ext);
		if (exts != null) for (e in exts) ldrs.remove(e);
	}
	
	static public function getLdr(url:String):ISingleLoader<Dynamic> {
		var ref = ldrs.get(new Path(url).ext);
		return ref != null ? Type.createInstance(ref, []) : null;
	}
}