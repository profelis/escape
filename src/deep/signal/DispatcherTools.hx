package deep.signal;

class DispatcherTools {

#if (flash || openfl)

    public static function mapNil(ed:flash.events.IEventDispatcher, eventTypes:Map<String, Int>):Dispatcher<thx.Nil> {
    	var res = Dispatcher.create();
		for (eventType in eventTypes.keys()) {
	    	ed.addEventListener(eventType, function (e:flash.events.Event) {
	    		res.notify(thx.Nil.nil, eventTypes.get(e.type));
	    	});
	    }
    	return res;
    }

    public static function map<TOut>(ed:flash.events.IEventDispatcher, eventTypes:Map<String, Int>, handler:flash.events.Event->TOut):Dispatcher<TOut> {
    	var res = Dispatcher.create();
		attach(ed, res, eventTypes, handler);
    	return res;
    }

    public static function mapAsync<TOut>(ed:flash.events.IEventDispatcher, eventTypes:Iterable<String>, handler:flash.events.Event->(TOut->Int->Void)->Void):Dispatcher<TOut> {
    	var res = Dispatcher.create();
    	attachAsync(ed, res, eventTypes, handler);
    	return res;
    }

    public static function attach<TOut>(ed:flash.events.IEventDispatcher, dispatcher:Dispatcher<TOut>, eventTypes:Map<String, Int>, handler:flash.events.Event->TOut):flash.events.IEventDispatcher {
    	for (eventType in eventTypes.keys()) {
	    	ed.addEventListener(eventType, function (e:flash.events.Event) {
	    		dispatcher.notify(handler(e), eventTypes.get(e.type));
	    	});
	    }
	    return ed;
    }

    public static function attachAsync<TOut>(ed:flash.events.IEventDispatcher, dispatcher:Dispatcher<TOut>, eventTypes:Iterable<String>, handler:flash.events.Event->(TOut->Int->Void)->Void):flash.events.IEventDispatcher {
    	for (eventType in eventTypes) {
	    	ed.addEventListener(eventType, handler.bind(_, dispatcher.notify));
	    }
	    return ed;
    }

#end
}
