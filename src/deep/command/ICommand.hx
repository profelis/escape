package deep.command;
import deep.tools.base.IDestructable;

/**
 * @author deep <system.grand@gmail.com>
 */

interface ICommand extends IDestructable {
    public function execute():Void;
    public function undo():Void;
    public function redo():Void;
}