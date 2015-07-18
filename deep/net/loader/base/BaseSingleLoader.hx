package deep.net.loader.base;

import deep.events.Dispatcher.DispatcherKeyType;
import deep.net.loader.ILoader;
import deep.events.Dispatcher.Dispatcher1;
import deep.net.loader.LoaderEventType;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class BaseSingleLoader<T> extends Dispatcher1<ILoader> implements ISingleLoader<T> {
	
	public var id(default, null):String;
	
	public var params(default, null):Dynamic;
	
	function new(?url:String, ?params:Dynamic, ?id:String) {
		super(DKString);
		this.url = url;
		this.params = params;
		this.id = id != null ? id : url;
	}
	
	public function init(?url:String, ?params:Dynamic):Void {
		this.url = url;
		this.params = params;
	}
	
	public var url(default, null):String;
	
	public var loading(default, null):Bool = false;
	public var status(default, null):Null<Int> = null;
	
	public var data:T;
	
	public function load(?url:String, ?params:Dynamic):Void {
		if (loading) unload();
		
		if (url != null) this.url = url;
		if (id == null) id = this.url;
		if (params != null) this.params = params;
		data = null;
		loading = true;
	}
	
	public function stop():Void {
		if (!loading) return;
		loading = false;
	}
	
	public function unload():Void {
		stop();
	}
	
	function onStatus(e:HTTPStatusEvent) {
		status = e.status;
		dispatch(LoaderEventType.STATUS, this);
	}
	
	function onProgress(e:ProgressEvent) {
		size = e.bytesTotal;
		progress = size == 0 || size != size ? 0 : e.bytesLoaded / size;
		dispatch(LoaderEventType.PROGRESS, this);
	}
	
	public var progress(default, null):Float = 0;
	public var size(default, null):Float = 0;
	
	override public function destroy(deep = true) {
		stop();
		params = null;
		data = null;
		super.destroy(deep);
	}
}

class SingleLoaderDecorator<T, K> extends BaseSingleLoader<K> {

	var ldr:ISingleLoader<T>;
	
	function new(ldr:ISingleLoader<T>) {
		this.ldr = ldr;
		super(ldr.url, ldr.params, ldr.id);
		
		listenLdr(true);
	}
	
	override public function load(?url:String, ?params:Dynamic):Void {
		super.load(url, params);
		ldr.load(url, params);
		this.url = ldr.url;
		this.params = ldr.params;
		this.loading = ldr.loading;
	}
	
	override public function stop():Void {
		if (!loading) return;
		super.stop();
		listenLdr(false);
		ldr.stop();
		loading = ldr.loading;
	}
	
	override public function unload():Void {
		super.unload();
		listenLdr(false);
		ldr.unload();
		loading = ldr.loading;
	}
	
	function onComplete(l:ILoader) {
		status = ldr.status;
		progress = ldr.progress;
		size = ldr.size;
		loading = ldr.loading;
		listenLdr(false);
		dispatch(data != null ? LoaderEventType.COMPLETE : LoaderEventType.ERROR, this);
	}
	
	function onError(l:ILoader) {
		status = ldr.status;
		progress = ldr.progress;
		size = ldr.size;
		loading = ldr.loading;
		listenLdr(false);
		dispatch(LoaderEventType.ERROR, this);
	}
	
	function onChildProgress(l:ILoader) {
		progress = ldr.progress;
		size = ldr.size;
		dispatch(LoaderEventType.PROGRESS, this);
	}
	
	function onChildStatus(l:ILoader) {
		status = ldr.status;
		dispatch(LoaderEventType.STATUS, this);
	}
	
	function listenLdr(add:Bool) {
		if (ldr != null) {
			ldr.listener(LoaderEventType.COMPLETE, onComplete, add);
			ldr.listener(LoaderEventType.PROGRESS, onChildProgress, add);
			ldr.listener(LoaderEventType.ERROR, onError, add);
			ldr.listener(LoaderEventType.STATUS, onChildStatus, add);
		}
	}
	
	override public function destroy(deep = true) {
		super.destroy(deep);
		ldr.destroy(deep);
		ldr = null;
	}
}

class ReformLoader<T, K> extends SingleLoaderDecorator<T, K> {

	var reform:T->K;
	
	public function new(ldr:ISingleLoader<T>, reform:T->K) {
		super(ldr);
		this.reform = reform;
	}
	
	override function onComplete(l:ILoader) {
		data = reform(ldr.data);
		super.onComplete(l);
	}
	
	override public function destroy(deep = true) {
		super.destroy(deep);
		reform = null;
	}
}