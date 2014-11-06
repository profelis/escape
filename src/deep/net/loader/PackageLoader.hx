package deep.net.loader;

import deep.events.Dispatcher;
import haxe.ds.StringMap.StringMap;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class PackageLoader extends StringDispatcher1<ILoader> implements IPackageLoader {

	public var parallelLoaderNum(default, set):Int = 5;
	
	function set_parallelLoaderNum(v:Int) {
		if (v < 1) v = 1;
		return parallelLoaderNum = v;
	}
	
	public function new(?id:String, ?params:Dynamic) 
	{
		super();
		this.id = id;
		this.params = params;
		
		ldrs = [];
		currentLdrs = [];
		completeLdrs = [];
	}
	
	var ldrs:Array<ILoader>;
	var currentLdrs:Array<ILoader>;
	var completeLdrs:Array<ILoader>;
	
	public var id(default, null):String;
	public var params(default, null):Dynamic;
	
	public var loading(default, null):Bool = false;
	
	var loaded:Int = 0;
	public var progress(default, null):Float = 0;
	public var size(default, null):Float = 0;
	
	public var errorsNum(default, null):Int = 0;
	
	public function load(?url:String, ?params:Dynamic):Void {
		if (url != null) {
			var ldr = Loaders.getLdr(url);
			#if debug if (ldr == null) throw 'can\'t find loader for "$url"'; #end
			ldr.init(url, params);
			addLoader(ldr);
		}
		else loadStep();
	}
	
	function loadStep():Void {
		if (ldrs.length == 0 && currentLdrs.length == 0) {
			loaded = Std.int(size);
			progress = 1;
			loading = false;
			dispatch(LoaderEventType.COMPLETE, this);
			return;
		}
		while (ldrs.length > 0 && currentLdrs.length < parallelLoaderNum) {
			var l = ldrs.shift();
			currentLdrs.push(l);
			loading = true;
			l.load();
		}
	}
	
	function onComplete(ldr:ILoader) {
		listenLdr(ldr, false);
		ldrs.remove(ldr);
		currentLdrs.remove(ldr);
		completeLdrs.push(ldr);
		dispatch(LoaderEventType.SUB_COMPLETE, ldr);
		onProgress();
		loadStep();
	}
	
	function onError(ldr:ILoader) {
		listenLdr(ldr, false);
		ldrs.remove(ldr);
		currentLdrs.remove(ldr);
		completeLdrs.push(ldr);
		errorsNum ++;
		dispatch(LoaderEventType.SUB_ERROR, ldr);
		onProgress();
		loadStep();
	}
	
	function onProgress(?ldr:ILoader) {
		size = completeLdrs.length + currentLdrs.length + ldrs.length;
		if (size != 0) {
			progress = completeLdrs.length;
			for (l in currentLdrs) progress += l.progress;
			progress /= size;
		} else progress = 0;
		
		dispatch(LoaderEventType.PROGRESS, this);
	}
	
	public function stop():Void {
		for (l in currentLdrs) {
			listenLdr(l, false);
			l.stop();
			completeLdrs.push(l);
		}
		currentLdrs = [];
		loading = false;
		onProgress();
	}
	
	public function unload():Void {
		for (l in currentLdrs) {
			listenLdr(l, false);
			l.unload();
		}
		for (l in completeLdrs) {
			l.unload();
		}
		completeLdrs = [];
		currentLdrs = [];
		loading = false;
		onProgress();
	}
	
	public function getLoader(id:String):ILoader {
		for (l in completeLdrs) if (l.id == id) return l;
		for (l in ldrs) if (l.id == id) return l;
		for (l in currentLdrs) if (l.id == id) return l;
		return null;
	}
	
	public function getSingleLoader<T>(id:String):ISingleLoader<T> {
		var l = getLoader(id);
		return Std.is(l, ISingleLoader) ? cast l : null;
	}
	
	public function addLoader(l:ILoader):Void {
		ldrs.push(l);
		listenLdr(l, true);
		if (loading) onProgress();
	}
	
	public function removeLoader(l:ILoader):Bool {
		var res = ldrs.remove(l);
		if (!res) res = currentLdrs.remove(l);
		if (res) listenLdr(l, false); else res = completeLdrs.remove(l);
		if (res && loading) onProgress();
		return res;
	}
	
	function listenLdr(l:ILoader, add:Bool) {
		l.listener(LoaderEventType.COMPLETE, onComplete, add);
		l.listener(LoaderEventType.PROGRESS, onProgress, add);
		l.listener(LoaderEventType.ERROR, onError, add);
	}
	
	public function getIds(complete = true, inProgress = false, notStarted = false):Array<String> {
		var res = [];
		if (complete) for (l in completeLdrs) res.push(l.id);
		if (inProgress) for (l in currentLdrs) res.push(l.id);
		if (notStarted) for (l in ldrs) res.push(l.id);
		return res;
	}
	
	override public function destroy(deep = true) {
		if (deep) unload(); else stop();
		for (l in ldrs) listenLdr(l, false);
		super.destroy(deep);
		if (deep) {
			for (l in currentLdrs) l.destroy(deep);
			for (l in completeLdrs) l.destroy(deep);
			for (l in ldrs) l.destroy(deep);
		}
		currentLdrs = null;
		completeLdrs = null;
		ldrs = null;
	}
}

class StreamLoader extends PackageLoader {
	
	public function new(?id:String, ?params:Dynamic) {
		super(id, params);
	}
	
	override public function addLoader(l:ILoader):Void 
	{
		super.addLoader(l);
		loadStep();
	}
}