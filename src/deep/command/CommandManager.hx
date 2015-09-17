package deep.command;
import bindx.Bind;
import bindx.IBindable;
import deep.command.ICommand;
import haxe.ds.GenericStack;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class CommandManager implements ICommandManager
{
    var undoStack:Array<ICommand>;
    var redoStack:Array<ICommand>;

    @:isVar public var depth(get, set):UInt = 20;
    
    @:bindable(force = true)
    public var canUndo(get, never):Bool;
    
    @:bindable(force = true)
    public var canRedo(get, never):Bool;
    
    var prevCanUndo:Bool;
    var prevCanRedo:Bool;
    
    public function new() {
        undoStack = [];
        redoStack = [];
    }

    public function clear() {
        limitDepth(undoStack, 0);
        limitDepth(redoStack, 0);
    }
    
    inline function storeState() {
        prevCanRedo = canRedo;
        prevCanUndo = canUndo;
    }
    
    inline function notifyUpdate() {
        if (prevCanUndo != this.canUndo)
            Bind.notify(this.canUndo, prevCanUndo, !prevCanUndo);
            
        if (prevCanRedo != this.canRedo)
            Bind.notify(this.canRedo, prevCanRedo, !prevCanRedo);
    }
    
    public function execute(command:ICommand):Void {
        internalAdd(command);
        limitDepth(redoStack, 0);
        command.execute();
        notifyUpdate();
    }
    
    public function add(command:ICommand):Void {
        internalAdd(command);
        notifyUpdate();
    }
    
    inline function internalAdd(command:ICommand):Void {
        storeState();
        
        undoStack.push(command);
        limitDepth(undoStack, depth);
    }
    
    public function undo():Void {
        if (!canUndo) throw "can't undo";
        storeState();
        
        var command = undoStack.pop();
        redoStack.push(command);
        limitDepth(redoStack, depth);
        command.undo();
        
        notifyUpdate();
    }
    
    public function redo():Void {
        if (!canRedo) throw "can't redo";
        storeState();
        
        var command = redoStack.pop();
        undoStack.push(command);
        limitDepth(undoStack, depth);
        command.redo();
        
        notifyUpdate();
    }
    
    inline function get_canUndo() {
        return undoStack.length > 0;
    }
    
    inline function get_canRedo() {
        return redoStack.length > 0;
    }
    
    function set_depth(value:Int):Int {
        depth = value;
        if (value < 1) storeState();
        limitDepth(undoStack, depth);
        limitDepth(redoStack, depth);
        if (value < 1) notifyUpdate();
        return value;
    }
    
    inline function get_depth():Int {
        return depth;
    }
    
    inline function limitDepth(stack:Array<ICommand>, depth:Int):Void {
        var n:Int = stack.length - depth;
        while (n-- > 0) {
            var cmd = stack.shift();
            if (cmd != null) cmd.destroy();
        }
    }
    
    public function destroy(deep:Bool = true):Void {
        destructed = true;
        limitDepth(undoStack, 0);
        limitDepth(redoStack, 0);
        undoStack = null;
        redoStack = null;
    }
    
    public var destructed(default, null):Bool = false;
}