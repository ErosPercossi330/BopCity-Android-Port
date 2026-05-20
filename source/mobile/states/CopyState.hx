package mobile.states;

import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFLAssets;
import flixel.addons.util.FlxAsyncLoop;
import openfl.utils.ByteArray;
import haxe.io.Path;
import flixel.ui.FlxBar;
import flixel.ui.FlxBar.FlxBarFillDirection;
import sys.FileSystem;
import sys.io.File;
import haxe.crypto.Md5;
import openfl.system.System;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/*
 * Optimized CopyState with Content Validation and RAM Throttling
 */
class CopyState extends MusicBeatState
{
    private static final textFilesExtensions:Array<String> = ['ini', 'txt', 'xml', 'hxs', 'hx', 'lua', 'json', 'frag', 'vert'];
    public static final IGNORE_FOLDER_FILE_NAME:String = "ignore.txt";
    private static var directoriesToIgnore:Array<String> = [];
    public static var locatedFiles:Array<String> = [];
    public static var maxLoopTimes:Int = 0;

    public var loadingImage:FlxSprite;
    public var loadingBar:FlxBar;
    public var loadedText:FlxText;
    public var copyLoop:FlxAsyncLoop;

    private var _isPaused:Bool = false;
    var failedFilesStack:Array<String> = [];
    var failedFiles:Array<String> = [];
    var shouldCopy:Bool = false;
    var canUpdate:Bool = true;
    var loopTimes:Int = 0; 
    var ramLimit:Float = 1024 * 1024 * 700;

    override function create()
    {    
        if (maxLoopTimes <= 0)
        {
            MusicBeatState.switchState(new TitleState());
            return;
        }

        shouldCopy = true;

        add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d));

        loadingImage = new FlxSprite(0, 0, Paths.image('funkay'));
        loadingImage.setGraphicSize(0, FlxG.height);
        loadingImage.updateHitbox();
        loadingImage.screenCenter();
        add(loadingImage);

        loadingBar = new FlxBar(0, FlxG.height - 26, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 26);
        loadingBar.setRange(0, maxLoopTimes);
        add(loadingBar);

        loadedText = new FlxText(loadingBar.x, loadingBar.y + 4, FlxG.width, '', 16);
        loadedText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        add(loadedText);

        copyLoop = new FlxAsyncLoop(maxLoopTimes, copyAsset, 4);
        add(copyLoop);
        copyLoop.start();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (shouldCopy && copyLoop != null)
        {
            var currentMemory:Float = System.totalMemory;
            if (currentMemory > ramLimit || FlxG.drawFramerate < 20) {
                _isPaused = true;
            } else {
                _isPaused = false;
            }

            loadingBar.value = loopTimes;
            
            if (copyLoop.finished && canUpdate)
            {
                canUpdate = false;
                FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = () -> {
                    MusicBeatState.switchState(new TitleState());
                };
            }

            loadedText.text = (_isPaused ? "RAM LIMIT REACHED... " : "Updating Assets: ") + '$loopTimes/$maxLoopTimes';
        }
        super.update(elapsed);
    }

    public function copyAsset()
    {
        if (_isPaused) return;

        var file = locatedFiles[loopTimes];
        loopTimes++;
        
        var internalPath = getFile(file);
        var shouldWrite = false;

        if (!FileSystem.exists(file)) {
            shouldWrite = true;
        } else {
            try {
                var internalBytes = OpenFLAssets.getBytes(internalPath);
                var externalBytes = File.getBytes(file);
                if (Md5.encode(internalBytes.toString()) != Md5.encode(externalBytes.toString())) {
                    shouldWrite = true;
                }
            } catch(e) { shouldWrite = true; }
        }

        if (shouldWrite)
        {
            var directory = Path.directory(file);
            if (!FileSystem.exists(directory))
                StorageUtil.createDirectories(directory);
            
            try {
                if (textFilesExtensions.contains(Path.extension(file)))
                    createContentFromInternal(file);
                else
                    File.saveBytes(file, getFileBytes(internalPath));
            } catch (e:haxe.Exception) {
                failedFiles.push('${file} (Error: ${e.message})');
            }
        }
    }

    public static function checkExistingFiles():Bool
    {
        locatedFiles = [];
        directoriesToIgnore = [];
        
        var fullList:Array<String> = OpenFLAssets.list();
        var assets = fullList.filter(f -> f.startsWith('assets/') || f.startsWith('mods/') || f.startsWith('modpack/'));
        
        for (file in assets)
        {
            if (file.endsWith('/') || OpenFLAssets.isLocal(file, "DIR")) continue;

            if (file.endsWith(IGNORE_FOLDER_FILE_NAME))
                directoriesToIgnore.push(Path.directory(file));
            
            var skip = false;
            for (dir in directoriesToIgnore) {
                if (file.startsWith(dir)) skip = true;
            }
            if (skip) continue;

            if (FileSystem.exists(file)) {
                try {
                    var info = FileSystem.stat(file);
                    @:privateAccess
                    var internalSize:Int = 0;
                    var assetPath = getFile(file);
                    
                    if (LimeAssets.exists(assetPath)) {
                        var libraryName = assetPath.contains(":") ? assetPath.split(":")[0] : "default";
                        var symbolID = assetPath.contains(":") ? assetPath.split(":")[1] : assetPath;
                        var library = LimeAssets.getLibrary(libraryName);
                        
                        if (library != null) {
                            internalSize = library.exists(symbolID, "BINARY") ? library.size(symbolID) : -1;
                        }
                    }
                    if (internalSize != -1 && info.size == internalSize) {
                        continue;
                    }
                } catch(e:Dynamic) {
                }
            }

            locatedFiles.push(file);
        }

        maxLoopTimes = locatedFiles.length;
        return (maxLoopTimes <= 0);
    }

    public function createContentFromInternal(file:String) {
        try {
            var fileData:String = OpenFLAssets.getText(getFile(file));
            File.saveContent(file, fileData == null ? '' : fileData);
        } catch (e:haxe.Exception) {}
    }

    public function getFileBytes(file:String):ByteArray {
        var extension = Path.extension(file).toLowerCase();
        return (extension == 'ttf' || extension == 'otf') ? 
            ByteArray.fromFile(file) : OpenFLAssets.getBytes(file);
    }

    public static function getFile(file:String):String {
        if (OpenFLAssets.exists(file)) return file;
        @:privateAccess
        for (library in LimeAssets.libraries.keys()) {
            if (OpenFLAssets.exists('$library:$file') && library != 'default') return '$library:$file';
        }
        return file;
    }
}
