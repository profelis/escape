package deep.thx.promise;

import deep.tools.base.IDestructable;
import thx.promise.Promise;
import thx.Error;

class Deferred<T> implements IDestructable {

    public var promise(default, null):Promise<T>;

    var _resolve:T->Void;
    var _reject:Error->Void;

    public function new() {
        promise = Promise.create(function (a, b) {
            _resolve = a;
            _reject = b;
        });
    }

    public static function create<T>() return new Deferred<T>();

    public function resolve(value:T):Void {
        if (!destructed) {
            _resolve(value);
            destroy();
        } else throw "deferred destroyed";
    }

    public function reject(error:Error):Void {
        if (!destructed) {
            _reject(error);
            destroy();
        } else throw "deferred destroyed";
    }

    public function destroy(deep:Bool = true):Void {
        _resolve = null;
        _reject = null;
        destructed = true;
    }

    public var destructed(default, null):Bool = false;

}
