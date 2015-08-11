package deep.display;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class DisplayObjectTools
{

	static public function isChildOf(c:DisplayObject, ?parent:DisplayObjectContainer, ?parents:Array<DisplayObjectContainer>):DisplayObjectContainer {
		if (c.parent == null) return null;
		if (parents == null) parents = [parent];
		var tp = c.parent;
		
		for (p in parents) {
			var t = tp;
			while (t != null && t != tp) t = t.parent;
			if (t == tp) return p;
		}
		return null;
	}

	static public function removeFromParent(c:DisplayObject):Bool {
		if (c.parent == null) return false;
		c.parent.removeChild(c);
		return true;
	}
	
}