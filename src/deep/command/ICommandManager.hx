package deep.command;
import bindx.IBindable;
import deep.math.Bits;
import deep.signal.Dispatcher;

/**
 * @author deep <system.grand@gmail.com>
 */

interface ICommandManager extends IBindable
{
    public function execute(command:ICommand):Void;
    
    public function undo():Void;
    public function redo():Void;
    
    @:bindable(force = true)
    public var canUndo(get, never):Bool;
    
    @:bindable(force = true)
    public var canRedo(get, never):Bool;
    
    public var depth(get, set):UInt;
    
    public function clear():Void;
}