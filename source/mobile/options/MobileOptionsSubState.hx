package mobile.options;

#if desktop
import backend.Discord.DiscordClient;
#end
import openfl.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import backend.Controls;
import options.BaseOptionsMenu;
import options.Option;
import openfl.Lib;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import mobile.backend.StorageUtil;

class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL", "EXTERNAL_OBB", "EXTERNAL_MEDIA"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end

	var HitboxTypes:Array<String>;

	public function new()
	{
		#if android
		storageTypes = storageTypes.concat(externalPaths); //SD Card
		#end
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; 
		
		#if TOUCH_CONTROLS
		HitboxTypes = mergeAllTextsNamed('mobile/Hitbox/HitboxModes/hitboxModeList.txt');
		#end

		var option:Option = null;

		#if TOUCH_CONTROLS
		option = new Option('MobilePad Alpha:',
			'Changes MobilePad Alpha -cool feature',
			'mobilePadAlpha',
			'percent');
		option.defaultValue = 0.6;
		option.scrollSpeed = 1.6;
		option.minValue = 0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = () ->
		{
			if(mobilePad != null) mobilePad.alpha = curOption.getValue();
		};
		addOption(option);

		option = new Option('Extra Controls',
			"Allow Extra Controls",
			'extraKeys',
			'float');
		option.defaultValue = 2;
		option.scrollSpeed = 1.6;
		option.minValue = 0;
		option.maxValue = 4;
		option.changeValue = 1;
		option.decimals = 1;
		addOption(option);

		option = new Option('Extra Control Location:',
			"Choose Extra Control Location",
			'hitboxLocation',
			'string',
			['Bottom', 'Top', 'Middle']);
		option.defaultValue = 'Bottom';
		addOption(option);

		if(HitboxTypes == null) HitboxTypes = [];
		if(!HitboxTypes.contains("New")) HitboxTypes.insert(0, "New");
		if(!HitboxTypes.contains("Classic")) HitboxTypes.insert(0, "Classic");
		
		option = new Option('Hitbox Mode:',
			"Choose your Hitbox Style! -mariomaster",
			'hitboxmode',
			'string',
			HitboxTypes);
		option.defaultValue = 'New';
		addOption(option);

		option = new Option('Hitbox Design:',
			"Choose how your hitbox should look like.",
			'hitboxtype',
			'string',
			['Gradient', 'No Gradient' , 'No Gradient (Old)']);
		option.defaultValue = 'Gradient';
		addOption(option);

		option = new Option('Hitbox Hint',
			'Hitbox Hint -I hate this',
			'hitboxhint',
			'bool');
		option.defaultValue = false;
		addOption(option);

		option = new Option('Hitbox Opacity', 
			'Changes hitbox opacity -omg',
			'hitboxalpha',
			'float');
		option.defaultValue = 0.7;
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		#end

		#if mobile
		option = new Option('Wide Screen Mode',
			'If checked, The game will stretch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
			'wideScreen',
			'bool');
		option.defaultValue = false;
		option.onChange = () -> FlxG.scaleMode = new MobileScaleMode();
		addOption(option);
		#end

		#if android
		option = new Option('Storage Type',
			'Which folder Psych Engine should use?',
			'storageType',
			'string',
			storageTypes);
		option.defaultValue = storageTypes[0];
		addOption(option);
		#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
	}
	#end

	override public function destroy() {
		super.destroy();

		#if android
		if (ClientPrefs.data.storageType != lastStorageType) {
			onStorageChange();
			ClientPrefs.saveSettings();
			CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
			lime.system.System.exit(0);
		}
		#end
	}

	#if TOUCH_CONTROLS
	function resetMobilePad()
	{
		removeMobilePad();
	}
	#end

	inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String = null, allowDuplicates:Bool = false)
	{
		if(defaultDirectory == null) defaultDirectory = Paths.getSharedPath();
		defaultDirectory = defaultDirectory.trim();
		if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
		if(!defaultDirectory.startsWith('assets/')) defaultDirectory = 'assets/$defaultDirectory';
		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);
		var defaultPath:String = defaultDirectory + path;
		if(paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}
		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}

	static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		#if sys
		if(FileSystem.exists(path + fileToFind))
		#end
			foldersToCheck.push(path + fileToFind);

		#if MODS_ALLOWED
		if(mods)
		{
			// Global mods first
			for(mod in Mods.getGlobalMods())
			{
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
			}

			// Then "mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(Paths.mods(fileToFind));

			// And lastly, the loaded mod's folder (Converted to unified 0.7+ Mods backend references)
			if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			{
				var folder:String = Paths.mods(Mods.currentModDirectory + '/' + fileToFind);
				if(FileSystem.exists(folder) && !foldersToCheck.contains(folder)) foldersToCheck.push(folder);
			}
		}
		#end
		return foldersToCheck;
	}
}
