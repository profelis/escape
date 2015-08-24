package deep.resources.bundles;

class MapResourceBundle implements IResourceBundle {

    public var locale(default, null):String;
    public var bundleName(default, null):String;

    var content(default, null):Map<String, String>;

    public function new(content:Map<String, String>, locale:String, bundleName:String) {
        this.locale = locale;
        this.bundleName = bundleName;
        this.content = content;
    }

    public inline function keys():Iterator<String> return content.keys();
    public inline function values():Iterator<String> return content.iterator();

    public function get(name:String):String { return content.get(name); }
    public function set(name:String, value:String):Void { content.set(name, value); }
    public function exists(name:String):Bool { return content.exists(name); }

    public function toString():String return content.toString();
}
