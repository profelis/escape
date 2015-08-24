package deep.resources;

interface IResourceBundle {
    public var locale(default, null):String;
    public var bundleName(default, null):String;

    public function get(name:String):String;
    public function exists(name:String):Bool;

    public function keys():Iterator<String>;
    public function values():Iterator<String>;
}
