package hxmake.test.flash;

import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;
import hxmake.cli.Platform;
import hxmake.cli.CL;

class RunFlashPlayer extends RunTask {

    public var swfPath:Null<String>;

    public function new(?swfPath:String) {
        super();
        this.swfPath = swfPath;
    }

    override public function configure() {
        if(swfPath == null) {
            fail('Specify "swfPath" for RunFlashPlayer task');
        }

        switch (CL.platform) {
            case Platform.LINUX:
                set("xvfb-run", ["flash/flashplayerdebugger", swfPath]);
                retryUntilZero = 8;
            case Platform.MAC:
                set("flash/Flash Player Debugger.app/Contents/MacOS/Flash Player Debugger", [FileSystem.fullPath(swfPath)]);
            case Platform.WINDOWS:
                set("flash\\flashplayer.exe", [FileSystem.fullPath(swfPath)]);
            case _:
                throw "unsupported platform";
        }
    }

    override function execute() {
        super.execute();
        Sys.println(File.getContent(getFlashLog()));
    }

    // https://helpx.adobe.com/flash-player/kb/configure-debugger-version-flash-player.html
    static function getFlashLog() {
        return switch (CL.platform) {
            case Platform.LINUX:
                Path.join([Sys.getEnv("HOME"), ".macromedia/Flash_Player/Logs/flashlog.txt"]);
            case Platform.MAC:
                Path.join([Sys.getEnv("HOME"), "Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt"]);
            case Platform.WINDOWS:
                Path.join([Sys.getEnv("APPDATA"), "Macromedia", "Flash Player", "Logs", "flashlog.txt"]);
            case _:
                throw "unsupported system";
        }
    }
}
