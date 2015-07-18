package deep.net.loader;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class LoaderEventType {
	
	static public var COMPLETE(default, null) = "complete";
	static public var ERROR(default, null) = "error";
	static public var PROGRESS(default, null) = "progress";
	static public var STATUS(default, null) = "status";
	
	static public var SUB_COMPLETE(default, null) = "subComplete";
	static public var SUB_ERROR(default, null) = "subError";
}