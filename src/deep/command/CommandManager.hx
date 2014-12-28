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
    
    public function new() {
        clear();
    }

    public function clear() {
        undoStack = [];
        redoStack = [];
    }
    
    public function execute(command:ICommand):Void {
        var prevCanUndo = canUndo;
        var prevCanRedo = canRedo;
        
        undoStack.push(command);
        
        limitDepth(undoStack, depth);
        limitDepth(redoStack, 0);
        
        command.execute();
        
        if (prevCanUndo != this.canUndo)
            Bind.notify(this.canUndo, prevCanUndo, !prevCanUndo);
    }
    
    public function undo():Void {
        if (!canUndo) throw "can't undo";
        var prevCanUndo = canUndo;
        var prevCanRedo = canRedo;
        
        var command = undoStack.pop();
        redoStack.push(command);
        limitDepth(redoStack, depth);
        
        command.undo();
        
        if (prevCanUndo != this.canUndo)
            Bind.notify(this.canUndo, prevCanUndo, !prevCanUndo);
            
        if (prevCanRedo != this.canRedo)
            Bind.notify(this.canRedo, prevCanRedo, !prevCanRedo);
    }
    
    public function redo():Void {
        if (!canRedo) throw "can't redo";
        var prevCanUndo = canUndo;
        var prevCanRedo = canRedo;
        
        var command = redoStack.pop();
        undoStack.push(command);
        limitDepth(undoStack, depth);
        
        command.redo();
        
        if (prevCanUndo != this.canUndo)
            Bind.notify(this.canUndo, prevCanUndo, !prevCanUndo);
            
        if (prevCanRedo != this.canRedo)
            Bind.notify(this.canRedo, prevCanRedo, !prevCanRedo);
    }
    
    inline function get_canUndo() {
        return undoStack.length > 0;
    }
    
    inline function get_canRedo() {
        return redoStack.length > 0;
    }
    
    function set_depth(value:Int):Int {
        depth = value;
        limitDepth(undoStack, depth);
        limitDepth(redoStack, depth);
        return value;
    }
    
    inline function get_depth():Int {
        return depth;
    }
    
    inline function limitDepth(stack:Array<ICommand>, depth:Int):Void {
        var n:Int = stack.length - depth;
        while (--n > 0) {
            var cmd = stack.shift();
            if (cmd != null) cmd.destroy();
        }
    }
}