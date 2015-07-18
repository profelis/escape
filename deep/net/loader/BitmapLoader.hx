package deep.net.loader;

import deep.net.loader.base.BaseImageLoader;
import flash.display.Bitmap;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class BitmapLoader extends BaseImageLoader<Bitmap> {
	
	public function new(?url:String, ?params:Dynamic, ?id:String) {
		super(url, params, id);
	}
	
	override function onComplete(_) {
		if (Std.is(ldr.content, Bitmap)) {
			data = cast ldr.content;
		}
		super.onComplete(_);
	}
	
	override public function destroy(deep = true) {
		if (data != null && data.bitmapData != null) data.bitmapData.dispose();
		super.destroy(deep);
	}
}