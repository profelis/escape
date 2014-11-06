package deep.net.loader;

import deep.events.ISlotMachine.IDispatcher;
import deep.tools.base.IDestructable;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
interface ILoader extends IDestructable extends IDispatcher < String, ILoader->Void > {
	
	public var id(default, null):String;
	public var params(default, null):Dynamic;
	public var loading(default, null):Bool;
	public var progress(default, null):Float;
	public var size(default, null):Float;
	
	public function load(?url:String, ?params:Dynamic):Void;
	public function stop():Void;
	public function unload():Void;
}