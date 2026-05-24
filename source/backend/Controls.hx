package backend;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;

class Controls
{
	//Keeping same use cases on stuff for it to be easier to understand/use
	//I'd have removed it but this makes it a lot less annoying to use in my opinion

	//You do NOT have to create these variables/getters for adding new keys,
	//but you will instead have to use:
	//   controls.justPressed("ui_up")   instead of   controls.UI_UP

	//Dumb but easily usable code, or Smart but complicated? Your choice.
	//Also idk how to use macros they're weird as fuck lol

	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up');
	private function get_NOTE_DOWN_P() return justPressed('note_down');
	private function get_NOTE_LEFT_P() return justPressed('note_left');
	private function get_NOTE_RIGHT_P() return justPressed('note_right');

	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up');
	private function get_NOTE_DOWN() return pressed('note_down');
	private function get_NOTE_LEFT() return pressed('note_left');
	private function get_NOTE_RIGHT() return pressed('note_right');

	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up');
	private function get_NOTE_DOWN_R() return justReleased('note_down');
	private function get_NOTE_LEFT_R() return justReleased('note_left');
	private function get_NOTE_RIGHT_R() return justReleased('note_right');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');

	//Gamepad & Keyboard stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;

	#if TOUCH_CONTROLS
	public var trackedInputsUI:Array<FlxActionInput> = [];
	public var trackedInputsNOTES:Array<FlxActionInput> = [];

	public function addButtonNOTES(actionName:String, button:Dynamic, state:FlxInputState):Void
	{
		if (button == null) return;
		
		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedInputsNOTES.push(input);
		var action = digitalActions.get(actionName);
		if (action != null) action.add(input);
	}

	public function addButtonUI(actionName:String, button:Dynamic, state:FlxInputState):Void
	{
		if (button == null) return;

		var input:FlxActionInputDigitalIFlxInput = new FlxActionInputDigitalIFlxInput(button, state);
		trackedInputsUI.push(input);
		
		var action = digitalActions.get(actionName);
		if (action != null) action.add(input);
	}
	
	public function addHitboxNOTES(actionName:String, button:Dynamic, state:FlxInputState):Void
	{
		if (button == null) return;

		var input = new FlxActionInputDigitalIFlxInput(button, state);
		trackedInputsNOTES.push(input);
		
		var action = digitalActions.get(actionName);
		if (action != null) action.add(input);
	}

	public function setHitBox(Hitbox:Hitbox, HitboxOld:HitboxOld, state:FlxInputState):Void
	{
		if (ClientPrefs.data.hitboxmode == 'Classic') {
			addHitboxNOTES('note_up', HitboxOld.buttonUp, state);
			addHitboxNOTES('note_down', HitboxOld.buttonDown, state);
			addHitboxNOTES('note_left', HitboxOld.buttonLeft, state);
			addHitboxNOTES('note_right', HitboxOld.buttonRight, state);
		}
		else {
			addHitboxNOTES('note_up', Hitbox.buttonUp, state);
			addHitboxNOTES('note_down', Hitbox.buttonDown, state);
			addHitboxNOTES('note_left', Hitbox.buttonLeft, state);
			addHitboxNOTES('note_right', Hitbox.buttonRight, state);
		}
	}

	public function setMobilePadUI(MobilePad:MobilePad, DPad:String, Action:String, state:FlxInputState):Void
	{
		if (MobilePad == null)
			return;

		switch (DPad)
		{
			case "UP_DOWN" | "OptionsC":
				addButtonUI('ui_up', MobilePad.buttonUp, state);
				addButtonUI('ui_down', MobilePad.buttonDown, state);
			case "LEFT_RIGHT":
				addButtonUI('ui_left', MobilePad.buttonLeft, state);
				addButtonUI('ui_right', MobilePad.buttonRight, state);
			case "UP_LEFT_RIGHT":
				addButtonUI('ui_up', MobilePad.buttonUp, state);
				addButtonUI('ui_left', MobilePad.buttonLeft, state);
				addButtonUI('ui_right', MobilePad.buttonRight, state);
			case "DUO":
				addButtonUI('ui_up', MobilePad.buttonUp, state);
				addButtonUI('ui_down', MobilePad.buttonDown, state);
				addButtonUI('ui_left', MobilePad.buttonLeft, state);
				addButtonUI('ui_right', MobilePad.buttonRight, state);
				addButtonUI('ui_up', MobilePad.buttonUp2, state);
				addButtonUI('ui_down', MobilePad.buttonDown2, state);
				addButtonUI('ui_left', MobilePad.buttonLeft2, state);
				addButtonUI('ui_right', MobilePad.buttonRight2, state);
			case "NONE": // do nothing
			default:
				addButtonUI('ui_up', MobilePad.buttonUp, state);
				addButtonUI('ui_down', MobilePad.buttonDown, state);
				addButtonUI('ui_left', MobilePad.buttonLeft, state);
				addButtonUI('ui_right', MobilePad.buttonRight, state);
		}

		switch (Action)
		{
			case "A" | "ChartingStateC":
				addButtonUI('accept', MobilePad.buttonA, state);
			case "B" | "B_X_Y" | "B_E":
				addButtonUI('back', MobilePad.buttonB, state);
			case "P":
				addButtonUI('pause', MobilePad.buttonP, state);
			case "OptionsC":
				addButtonUI('ui_left', MobilePad.buttonLeft, state);
				addButtonUI('ui_right', MobilePad.buttonRight, state);
				addButtonUI('accept', MobilePad.buttonA, state);
				addButtonUI('back', MobilePad.buttonB, state);
			case "NONE" | "E" | "controlExtend": // do nothing
			default:
				addButtonUI('accept', MobilePad.buttonA, state);
				addButtonUI('back', MobilePad.buttonB, state);
		}
	}

	public function setMobilePadNOTES(MobilePad:MobilePad, DPad:String, Action:String, state:FlxInputState):Void
	{
		if (MobilePad == null)
			return;

		switch (DPad)
		{
			case "UP_DOWN" | "OptionsC":
				 addButtonNOTES('note_up', MobilePad.buttonUp, state);
				 addButtonNOTES('note_down', MobilePad.buttonDown, state);
			case "LEFT_RIGHT":
				 addButtonNOTES('note_left', MobilePad.buttonLeft, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight, state);
			case "UP_LEFT_RIGHT":
				 addButtonNOTES('note_up', MobilePad.buttonUp, state);
				 addButtonNOTES('note_left', MobilePad.buttonLeft, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight, state);
			case "DUO":
				 addButtonNOTES('note_up', MobilePad.buttonUp, state);
				 addButtonNOTES('note_down', MobilePad.buttonDown, state);
				 addButtonNOTES('note_left', MobilePad.buttonLeft, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight, state);
				 addButtonNOTES('note_up', MobilePad.buttonUp2, state);
				 addButtonNOTES('note_down', MobilePad.buttonDown2, state);
				 addButtonNOTES('note_left', MobilePad.buttonLeft2, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight2, state);
			case "NONE": // do nothing
			default:
				 addButtonNOTES('note_up', MobilePad.buttonUp, state);
				 addButtonNOTES('note_down', MobilePad.buttonDown, state);
				 addButtonNOTES('note_left', MobilePad.buttonLeft, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight, state);
		}

		switch (Action)
		{
			case "A" | "ChartingStateC":
				 addButtonNOTES('accept', MobilePad.buttonA, state);
			case "B" | "B_X_Y" | "B_E":
				 addButtonNOTES('back', MobilePad.buttonB, state);
			case "P":
				 addButtonNOTES('pause', MobilePad.buttonP, state);
			case "OptionsC":
				 addButtonNOTES('accept', MobilePad.buttonA, state);
				 addButtonNOTES('back', MobilePad.buttonB, state);
				 addButtonNOTES('note_left', MobilePad.buttonLeft, state);
				 addButtonNOTES('note_right', MobilePad.buttonRight, state);
			case "NONE" | "E" | "controlExtend": // do nothing
			default:
				 addButtonNOTES('accept', MobilePad.buttonA, state);
				 addButtonNOTES('back', MobilePad.buttonB, state);
		}
	}

	public function removeVirtualControlsInput(Tinputs:Array<FlxActionInput>):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var x = Tinputs.length;
				while (x-- > 0)
				{
					if (Tinputs[x] == action.inputs[i])
						action.remove(action.inputs[i]);
				}
			}
		}
	}
	#end
	
	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	// IGNORE THESE
	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
	}
}
