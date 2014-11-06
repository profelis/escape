package deep.net.loader;

import flash.display.DisplayObject;
import deep.net.loader.base.BaseImageLoader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class DisplayObjectLoader extends BaseImageLoader<DisplayObject> {
	
	public function new(?url:String, ?params:Dynamic, ?id:String) {
		super(url, params, id);
	}
	
	override function onComplete(_) {
		try {
			data = cast(ldr.content, DisplayObject);
		}
		catch (e:Dynamic) {
			data = ldr;
		}
		
		super.onComplete(_);
	}
}