package options;

import states.MainMenuState;
import backend.StageData;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', #if TOUCH_CONTROLS 'Mobile Controls' #else 'Controls' #end, 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'#if TOUCH_CONTROLS, 'Mobile Options'#end ];
	private var grpOptions:FlxTypedGroup<PapyrusText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String) {
		#if TOUCH_CONTROLS
	    persistentUpdate = false;
	    if (label != "Adjust Delay and Combo") removeMobilePad();
	    #end
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			#if TOUCH_CONTROLS
			case 'Mobile Controls':
    			openSubState(new MobileControlSelectSubState());
    		#end
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			#if (TOUCH_CONTROLS || mobile)
			case 'Mobile Options':
			    openSubState(new MobileOptionsSubState());
			#end
			case 'Adjust Delay and Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:PapyrusText;
	var selectorRight:PapyrusText;

	override function create() {
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.updateHitbox();
		bg.screenCenter();
		bg.alpha = 0.6;

		if (FlxG.random.bool(50)) bg.flipY = true;
		if (FlxG.random.bool(20)) bg.angle = 90;

		add(bg);

		grpOptions = new FlxTypedGroup<PapyrusText>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:PapyrusText = new PapyrusText(0, 0, options[i]);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new PapyrusText(0, 0, '>');
		add(selectorLeft);
		selectorRight = new PapyrusText(0, 0, '<');
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		#if TOUCH_CONTROLS
		addMobilePad("FULL", "A_B_C");
		#end
			
		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if TOUCH_CONTROLS
		removeMobilePad();
		persistentUpdate = true;
		#end
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P #if mobile || mobilePad.buttonUp.justPressed #end) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P #if mobile || mobilePad.buttonDown.justPressed #end) {
			changeSelection(1);
		}

		if (controls.BACK #if mobile || mobilePad.buttonB.justPressed #end) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		#if TOUCH_CONTROLS
		if (mobilePad.buttonC.justPressed) {
			removeMobilePad();
			persistentUpdate = false;
			openSubState(new MobileExtraControl());
		}
		#end
		else if (controls.ACCEPT #if mobile || mobilePad.buttonA.justPressed #end) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.sc = item.targetY == 0 ? 1.3 : 1;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}
