package deep.resources;

class ResourceBundle {

    public var locale(default, null):String;
    public var bundleName(default, null):String;

    public var content(default, null):Map<String, String>;

    public function new(locale:String, bundleName:String) {
        this.locale = locale;
        this.bundleName = bundleName;

        this.content = new Map();
    }

    public inline function iterator():Iterator<String> return content.keys();

    public inline function values():Iterator<String> return content.iterator();

    public function toString():String return content.toString();
}
