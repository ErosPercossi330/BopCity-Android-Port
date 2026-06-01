package psychlua;

import flixel.util.FlxSave;
import openfl.utils.Assets;

#if mobile
import mobile.psychlua.Functions;
#end

//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//

class ExtraFunctions
{
	#if TOUCH_CONTROLS
	public static function varCheck(className:Dynamic, variable:String):String{
		return variable;
	}

	public static function classCheck(className:String):Dynamic
	{
		return Type.resolveClass(className);
	}

	public static function specialKeyCheck(keyName:String):Dynamic
	{
		var textfix:Array<String> = keyName.trim().split('.');
		var type:String = textfix[1].trim();
		var key:String = textfix[2].trim();
		var extraControl:Dynamic = null;

		//Custom return thing
		for (num in 1...31) {
			if (MusicBeatState.mobilec.newhbox != null) {
				//trace("Current Mode: Hitbox");
				var hitbox:Dynamic = Reflect.getProperty(MusicBeatState.mobilec.newhbox, 'buttonExtra' + num);
				if (key == Reflect.field(hitbox, 'returnedButton')) {
					//trace('button ${num} returned to ' + Reflect.field(hitbox, 'returnedButton'));
					if (Reflect.getProperty(hitbox, type)) {
						return true;
					}
				}
			}
		}

		for (num in 1...5){
			if (ClientPrefs.data.extraKeys >= num && key == Reflect.field(ClientPrefs, 'extraKeyReturn' + num)){
				if (MusicBeatState.mobilec.newhbox != null) {
					extraControl = Reflect.getProperty(MusicBeatState.mobilec.newhbox, 'buttonExtra' + num);
				}
				else if (MusicBeatState.mobilec.hbox != null)
					extraControl = Reflect.getProperty(MusicBeatState.mobilec.hbox, 'buttonExtra' + num);
				else
					extraControl = Reflect.getProperty(MusicBeatState.mobilec.vpad, 'buttonExtra' + num);
				if (Reflect.getProperty(extraControl, type))
					return true;
			}
		}
		return null;
	}

	//Used for other extra buttons
	public static function specialKeyCheckForOthers(key:String, type:String):Dynamic
	{
		//Custom return thing
		for (num in 1...31) {
			if (MusicBeatState.mobilec.newhbox != null) {
				//trace("Current Mode: Hitbox");
				var hitbox:Dynamic = Reflect.getProperty(MusicBeatState.mobilec.newhbox, 'buttonExtra' + num);
				if (key.toUpperCase() == Reflect.field(hitbox, 'returnedButton')) {
					//trace('button ${num} returned to ' + Reflect.field(hitbox, 'returnedButton'));
					if (Reflect.getProperty(hitbox, type)) {
						return true;
					}
				}
			}
		}

		if (MusicBeatState.mobilec.newhbox != null){
			var extraControl = MusicBeatState.mobilec.current;
			var Extra1:Bool = (MusicBeatState.mobilec.newhbox.buttonExtra1.returnedButton == null);
			var Extra2:Bool = (MusicBeatState.mobilec.newhbox.buttonExtra2.returnedButton == null);
			var Extra3:Bool = (MusicBeatState.mobilec.newhbox.buttonExtra3.returnedButton == null);
			var Extra4:Bool = (MusicBeatState.mobilec.newhbox.buttonExtra4.returnedButton == null);
			key = key.toUpperCase();

			if (key == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && Reflect.getProperty(extraControl.buttonExtra1, type) && Extra1)
				return true;
			if (key == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && Reflect.getProperty(extraControl.buttonExtra2, type) && Extra2)
				return true;
			if (key == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && Reflect.getProperty(extraControl.buttonExtra3, type) && Extra3)
				return true;
			if (key == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && Reflect.getProperty(extraControl.buttonExtra4, type) && Extra4)
				return true;
		} else {
			var extraControl = MusicBeatState.mobilec.current;
			if (key == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && Reflect.getProperty(extraControl.buttonExtra1, type))
				return true;
			if (key == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && Reflect.getProperty(extraControl.buttonExtra2, type))
				return true;
			if (key == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && Reflect.getProperty(extraControl.buttonExtra3, type))
				return true;
			if (key == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && Reflect.getProperty(extraControl.buttonExtra4, type))
				return true;
		}
		return null;
	}
	#end
	
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		
		// Keyboard & Gamepads
		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String) return FlxG.gamepads.anyJustPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String) return FlxG.gamepads.anyPressed(name));
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String) return FlxG.gamepads.anyJustReleased(name));

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String = '') {
			name = name.toLowerCase();
			#if TOUCH_CONTROLS
			var check:Dynamic;
			check = specialKeyCheckForOthers(name, "released");
			if (check != null) return check;
			#end
			var key:Bool = false;
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT_P;
				case 'down': return PlayState.instance.controls.NOTE_DOWN_P;
				case 'up': return PlayState.instance.controls.NOTE_UP_P;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT_P;
				default: return PlayState.instance.controls.justPressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String = '') {
			name = name.toLowerCase();
			#if TOUCH_CONTROLS
			var check:Dynamic;
			check = specialKeyCheckForOthers(name, "released");
			if (check != null) return check;
			#end
			var key:Bool = false;
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT;
				case 'down': return PlayState.instance.controls.NOTE_DOWN;
				case 'up': return PlayState.instance.controls.NOTE_UP;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT;
				default: return PlayState.instance.controls.pressed(name);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String = '') {
			name = name.toLowerCase();
			#if TOUCH_CONTROLS
			var check:Dynamic;
			check = specialKeyCheckForOthers(name, "released");
			if (check != null) return check;
			#end
			var key:Bool = false;
			switch(name) {
				case 'left': return PlayState.instance.controls.NOTE_LEFT_R;
				case 'down': return PlayState.instance.controls.NOTE_DOWN_R;
				case 'up': return PlayState.instance.controls.NOTE_UP_R;
				case 'right': return PlayState.instance.controls.NOTE_RIGHT_R;
				default: return PlayState.instance.controls.justReleased(name);
			}
			return false;
		});

		// Save data management
		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				// folder goes unused for flixel 5 users. @BeastlyGhost
				save.bind(name, CoolUtil.getSavePath() + '/' + folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			FunkinLua.luaTrace('initSaveData: Save file already initialized: ' + name);
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			FunkinLua.luaTrace('flushSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var saveData = PlayState.instance.modchartSaves.get(name).data;
				if(Reflect.hasField(saveData, field))
					return Reflect.field(saveData, field);
				else
					return defaultValue;
			}
			FunkinLua.luaTrace('getDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
			return defaultValue;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			FunkinLua.luaTrace('setDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "eraseSaveData", function(name:String)
		{
			if (PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).erase();
				return;
			}
			FunkinLua.luaTrace('eraseSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});

		// File management
		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if(absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!absolute)
					File.saveContent(Paths.mods(path), content);
				else
				#end
					File.saveContent(path, content);

				return true;
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if(FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if(Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});
		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if(FileSystem.exists(folder)) {
				for (folder in FileSystem.readDirectory(folder)) {
					if (!list.contains(folder)) {
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		// String tools
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String) {
			return str.trim();
		});

		// Randomization
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
	}
}