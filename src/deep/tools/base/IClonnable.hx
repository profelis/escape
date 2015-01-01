package deep.tools.base;

/**
 * @author deep <system.grand@gmail.com>
 */

interface IClonnable<T> {
    public function clone(target:T = null):T;
}