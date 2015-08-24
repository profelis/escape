package deep.resources.bundles;

class ReflectBundle implements IResourceBundle {

    public var locale(default, null):String;
    public var bundleName(default, null):String;

    var content:Dynamic;

    public function new(content:Dynamic, locale:String, bundleName:String) {
        this.locale = locale;
        this.bundleName = bundleName;
        this.content = content;
    }

    public inline function keys():Iterator<String> { return Reflect.fields(content).iterator(); }
    public inline function values():Iterator<String> {
        var keys = this.keys();
        var current:String;
        return {
            hasNext : function () { return if (keys.hasNext()) { current = keys.next(); true; } else false; },
            next: function () return get(current)
        }
    }

    public inline function get(name:String):String { return Reflect.field(content, name); }
    public inline function set(name:String, value:String):Void { Reflect.setField(content, name, value); }
    public inline function exists(name:String):Bool { return #if cpp Reflect.field(content, name) != null; #else Reflect.hasField(content, name); #end }

    public inline function toString():String { return Std.string(content); }
}
