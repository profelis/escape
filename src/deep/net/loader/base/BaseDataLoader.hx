package deep.net.loader.base;

import deep.net.loader.LoaderEventType;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class BaseDataLoader<T> extends BaseSingleLoader<T>
{
	var ldr:URLLoader;
	
	override public function load(?url:String, ?params:Dynamic):Void {
		super.load(url, params);
		ldr = new URLLoader();
		ldr.addEventListener(Event.COMPLETE, onComplete);
		ldr.addEventListener(IOErrorEvent.IO_ERROR, onError);
		ldr.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
		ldr.addEventListener(ProgressEvent.PROGRESS, onProgress);
	}
	
	function onComplete(_) {
		if (data != null) progress = 1;
		loading = false;
		dispatch(data != null ? LoaderEventType.COMPLETE : LoaderEventType.ERROR, this);
		free();
		ldr = null;
	}
	
	function onError(_) {
		data = null;
		loading = false;
		dispatch(LoaderEventType.ERROR, this);
		free();
		ldr = null;
	}
	
	function free() {
		if (ldr != null) {
			ldr.removeEventListener(Event.COMPLETE, onComplete);
			ldr.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			ldr.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			ldr.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		}
	}
	
	override public function stop():Void {
		if (!loading) return;
		if (ldr != null) {
			free();
			try { ldr.close(); } catch (e:Dynamic) { }
		}
		super.stop();
		ldr = null;
	}
}
