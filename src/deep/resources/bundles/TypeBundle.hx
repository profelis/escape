package deep.resources.bundles;



class TypeBundle implements IResourceBundle {

    public var locale(default, null):String;
    public var bundleName(default, null):String;

    var content:Dynamic;
    var _keys:Array<String>;

    public function new(content:Class<Dynamic>, locale:String, bundleName:String) {
        this.locale = locale;
        this.bundleName = bundleName;
        this.content = Type.createInstance(content, []);
        _keys = Type.getInstanceFields(content);
    }

    public inline function keys():Iterator<String> { return _keys.iterator(); }
    public inline function values():Iterator<String> {
        var keys = this.keys();
        var current:String;
        return {
            hasNext : function () { return if (keys.hasNext()) { current = keys.next(); true; } else false; },
            next: function () return get(current)
        }
    }

    public inline function get(name:String):String { return Reflect.field(content, name); }
    public inline function exists(name:String):Bool { return _keys.indexOf(name) > -1; }

    public inline function toString():String { return Std.string(content); }
}
