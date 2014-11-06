package deep.net.loader.base;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class BaseImageLoader<T:DisplayObject> extends BaseSingleLoader<T> {
	
	var ldr:Loader;
	
	/**
	 * 
	 * @param	?url
	 * @param	?params {context:{LoaderContext object}}
	 */
	override public function load(?url:String, ?params:Dynamic):Void {
		super.load(url, params);
		ldr = new Loader();
		ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
		ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
		ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		var context = null;
		if (params != null) {
			if (Reflect.hasField(params, "context"))
				context = Reflect.field(context, "context");
		}
		if (context == null) context = new LoaderContext(true);
		ldr.load(new URLRequest(this.url), context);
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
			ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
			ldr.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			ldr.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
			ldr.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		}
	}
	
	override public function unload():Void {
		if (ldr != null) {
			try { 
				#if flash10 ldr.unloadAndStop(); #else ldr.unload(); #end
			} catch (e:Dynamic) { } // burn, Abode, burn
		}
		super.unload();
	}
	
	override public function stop():Void {
		if (!loading) return;
		if (ldr != null) {
			free();
			try { ldr.close(); } catch (e:Dynamic) { }
		}
		super.stop();
	}
	
	override public function destroy(deep:Bool = true) {
		if (deep) unload();
		super.destroy(deep);
	}
}