 package deep.display;
import deep.events.StringDispatcher1;
import deep.events.Dispatcher;
import deep.tools.base.IDestructable;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.Lib;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

enum DragEventType {
	MOUSE_DOWN;
	MOUSE_UP;
	CLICK;
	DRAG_START;
	DRAG;
	DRAG_COMPLETE;
}
class DragController implements IDestructable {
	
	public var target(default, null):DisplayObject;
	
	public var dispatcher(default, null):EnumDispatcher1<MouseEvent>;
	
	public var dragging(default, null):Bool = false;
	
	public var dragDistance = 5.0;
	var mousePos: { x:Float, y:Float };
	
	public var enabled:Bool = true;
	
	public function new(target:DisplayObject) {
		this.target = target;
		dispatcher = new EnumDispatcher1<MouseEvent>();
		
		target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}
	
	function onMouseDown(e:MouseEvent) {
		if (!enabled) return;
		dragging = false;
		mousePos = { x:e.localX, y:e.localY };
		dispatcher.dispatch(MOUSE_DOWN, e);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, -100);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, -100);
	}
	
	function onMouseUp(e:MouseEvent) 
	{
		if (!enabled) return;
		if (dragging) dispatcher.dispatch(DRAG_COMPLETE, e);
		else dispatcher.dispatch(CLICK, e);
		dispatcher.dispatch(MOUSE_UP, e);
		dragging = false;
		
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}
	
	function onMouseMove(e:MouseEvent) 
	{
		if (!enabled) return;
		if (!dragging) {
			var dx = e.localX - mousePos.x;
			var dy = e.localY - mousePos.y;
			if ((dx * dx + dy * dy) > dragDistance) {
				dragging = true;
				dispatcher.dispatch(DRAG_START, e);
			}
		}
		else {
			dispatcher.dispatch(DRAG, e);
		}
	}
	
	public function destroy(deep = true) {
		destructed = true;
		
		dispatcher.destroy(deep);
		target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		target = null;
	}
	
	public var destructed(default, null):Bool = false;
}