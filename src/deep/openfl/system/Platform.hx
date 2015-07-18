package deep.openfl.system;
class Platform {

    static public function name():String {
        return #if android
        "android"
        #elseif ios
        "ios"
        #elseif mac
        "mac"
        #elseif windows
        "windows"
        #elseif neko
        "neko"
        #elseif js
        "js"
        #elseif flash
        "flash"
        #else
        "unknown"
        #end;
    }
}
