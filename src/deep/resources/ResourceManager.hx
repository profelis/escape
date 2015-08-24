package deep.resources;

import bindx.IBindable;
import bindx.Bind;

class ResourceManager implements IBindable {

    var bundles:Map<String, Map<String, IResourceBundle>>;

    public var locales:Array<String> = ["en_US"];

    public function new() {
        bundles = new Map();
    }

    inline function getOrCreateBundles(locale:String):Map<String, IResourceBundle> {
        var res = bundles.get(locale);
        if (res == null) bundles.set(locale, res = new Map());
        return res;
    }

    public function addBundle(bundle:IResourceBundle):Void {
        var res = getOrCreateBundles(bundle.locale);
        res.set(bundle.bundleName, bundle);
    }

    public inline function getBundles(locale:String):Iterator<IResourceBundle> {
        var res = bundles.get(locale);
        return res == null ? null : res.iterator();
    }

    public function update() {
        Bind.notify(this.getRawData);
        Bind.notify(this.getString);
    }

    @:bindable public function getRawData(bundleName:String, resourceName:String, locale:String = null) {
        if (locale != null) {
            var bundles = bundles.get(locale);
            if (bundles == null) return null;
            var bundle = bundles.get(bundleName);
            return bundle != null ? bundle.get(resourceName) : null;
        }
        for (locale in locales) {
            var bundles = bundles.get(locale);
            if (bundles == null) continue;
            var bundle = bundles.get(bundleName);
            if (bundle != null && bundle.exists(resourceName)) return bundle.get(resourceName);
        }
        return null;
    }

    @:bindable public inline function getString(bundleName:String, resourceName:String, params:Map<String, String> = null, locale:String = null):String {
        var res = getRawData(bundleName, resourceName, locale);
        return res == null ? null : params != null ? replaceParams(res, params) : res;
    }

    inline function replaceParams(str:String, params:Map<String, String>) {
        var args = str.split("@@");
        for (i in 0...args.length) {
            var s = args[i];
            for (name in params.keys()) {
                s = StringTools.replace(s, '@$name', params.get(name));
            }
            args[i] = s;
        }
        return args.join("@");
    }
}
