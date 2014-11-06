package deep.net.loader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface ISingleLoader<T> extends ILoader {
	
	public var data(default, null):T;
	public var url(default, null):String;
	public var status(default, null):Null<Int>;
	
	public function init(?url:String, ?params:Dynamic):Void;
}
