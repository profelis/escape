package deep.signal;

import thx.promise.Future;

private class ListenerData<T> {
    public var type:Int = 0;
    public var listener:Listener<T>;

    public function new(listener:Listener<T>) {
        this.listener = listener;
    }
}

typedef Listener<T> = T->Int->Void;

class Dispatcher<T> {

    var listeners:Array<ListenerData<T>>;
    var lockListeners:Bool;

    public function new() {
        clear();
    }

    inline function getListenerPos(o:Listener<T>):Int {
        var pos = -1;
        for (i in 0...listeners.length) {
            var od = listeners[i];
            if (Reflect.compareMethods(od.listener, o)) {
                pos = i;
                break;
            }
        }
        return pos;
    }

    public function attach(o:Listener<T>, type:Int = 0, force = false):Int {
        var pos = getListenerPos(o);
        var od;
        if (pos == -1) {
            unlockListeners();
            listeners.push(od = new ListenerData(o));
        } else {
            od = listeners[pos];
        }
        if (type == 0)
            od.type = -1;
        else
            od.type = force ? type : od.type | type;

        return od.type;
    }

    public function clear() {
        lockListeners = false;
        listeners = [];
    }

    public function detach(o:Listener<T>, type:Int = 0):Null<Int> {
        var pos = getListenerPos(o);
        if (pos > -1) {
            if (type == 0) {
                unlockListeners();
                listeners.splice(pos, 1);
                return null;
            }
            var od = listeners[pos];
            od.type &= ~type;
            if (od.type == 0) {
                unlockListeners();
                listeners.splice(pos, 1);
                return null;
            }
            return od.type;
        }
        return null;
    }

    public inline function listen(attach:Bool, o:Listener<T>, type:Int = 0, force = false):Null<Int> {
        return if (attach) this.attach(o, type, force) else this.detach(o, type);
    }

    public function getListenerType(o:Listener<T>):Null<Int> {
        var pos = getListenerPos(o);
        return pos > -1 ? listeners[pos].type : null;
    }

    public function hasListener(?o:Listener<T>, ?type:Int = null):Bool {
        if (type == null && o == null) {
            return listeners.length > 0;
        }
        if (type == null) {
            return getListenerPos(o) > -1;
        }
        if (o == null) {
            for (od in listeners) {
                if (od.type & type != 0) {
                    return true;
                }
            }
        }

        var pos = getListenerPos(o);
        return pos > -1 && listeners[pos].type & type != 0;
    }

    inline function unlockListeners() {
        if (lockListeners) {
            listeners = listeners.copy();
            lockListeners = false;
        }
    }

    public function notify(data:T, type:Int = 0):Void {
        lockListeners = true;
        if (type == 0) type = -1;
        var ls = listeners;
        for (i in 0...ls.length) {
            var od = ls[i];
            if (od.type & type != 0) {
                od.listener(data, type);
            }
        }
        lockListeners = false;
    }

    static public function create<T>():Dispatcher<T> {
        return new Dispatcher<T>();
    }

    public function map<TOut>(handler:T->TOut):Dispatcher<TOut> {
        var d = Dispatcher.create();
        attach(function (data, type) d.notify(handler(data), type));
        return d;
    }

    public function mapAsync<TOut>(handler:T->Int->(TOut->Int->Void)->Void):Dispatcher<TOut> {
        var d = Dispatcher.create();
        attach(handler.bind(_, _, d.notify));
        return d;
    }

    static public function flatMap<T>(dispatcher:Dispatcher<Dispatcher<T>>):Dispatcher<T> {
        var res = Dispatcher.create();
        dispatcher.attach(function (data, type) data.attach(res.notify, type));
        return res;
    }

    #if thx.promise
    public function future(type:Int = 0):Future<T> {
        var listener = null;
        return Future.create(function (handler) {
            attach(listener = function (data, type) {
                detach(listener);
                handler(data);
            }, type);
        });
    }

    public inline function mapFuture<TOut>(handler:T->Future<TOut>, type:Int = 0):Future<TOut> {
        return Future.flatMap(map(handler).future(type));
    }
    #end

    public function destroy(deep:Bool = true):Void {
        lockListeners = false;
        listeners = null;
        destructed = true;
    }

    public var destructed(default, null):Bool = false;
}