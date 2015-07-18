package deep.net.loader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface IPackageLoader extends ILoader {
	
	public var parallelLoaderNum(default, set):Int;
	
	public function getLoader(id:String):ILoader;
	public function getSingleLoader<T>(id:String):ISingleLoader<T>;
	
	public function addLoader(l:ILoader):Void;
	public function removeLoader(l:ILoader):Bool;
	
	public function getIds(complete:Bool = true, inProgress:Bool = false, notStarted:Bool = false):Array<String>;
}