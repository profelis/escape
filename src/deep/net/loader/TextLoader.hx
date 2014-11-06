package deep.net.loader;

import deep.net.loader.base.BaseDataLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class TextLoader extends BaseDataLoader<String> {

	public function new(?url:String, ?params:Dynamic, ?id:String) {
		super(url, params, id);
	}
	
	override public function load(?url:String, ?params:Dynamic):Void {
		super.load(url, params);
		ldr.dataFormat = URLLoaderDataFormat.TEXT;
		ldr.load(new URLRequest(this.url));
	}
	
	override function onComplete(_) {
		if (Std.is(ldr.data, String)) data = cast ldr.data;
		super.onComplete(_);
	}
}