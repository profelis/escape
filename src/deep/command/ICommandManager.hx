package deep.command;
import bindx.IBindable;
import deep.math.Bits;
import deep.signal.Dispatcher;
import deep.tools.base.IDestructable;

/**
 * @author deep <system.grand@gmail.com>
 */

interface ICommandManager extends IBindable extends IDestructable {
    public function add(command:ICommand):Void;
    public function execute(command:ICommand):Void;
    
    public function undo():Void;
    public function redo():Void;
    
    @:bindable
    public var canUndo(get, never):Bool;
    
    @:bindable
    public var canRedo(get, never):Bool;
    
    public var depth(get, set):UInt;
    
    public function clear():Void;
}