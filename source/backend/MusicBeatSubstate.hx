package backend;

import flixel.FlxSubState;
import flixel.input.actions.FlxActionInput;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	#if TOUCH_CONTROLS
	public var mobilePad:MobilePad;
	public static var mobilec:MobileControls;
	var trackedinputsUI:Array<Dynamic> = [];
	var trackedinputsNOTES:Array<Dynamic> = [];

	public function addMobilePad(?DPad:String, ?Action:String) {
		if (mobilePad != null)
			removeMobilePad();

		mobilePad = new MobilePad(DPad, Action);
		add(mobilePad);

		controls.trackedInputsUI = [];
		controls.setMobilePadUI(mobilePad, DPad, Action, PRESSED);
		trackedinputsUI = controls.trackedInputsUI;
		
		mobilePad.alpha = ClientPrefs.data.mobilePadAlpha;
	}

	public function addMobileControls() {
		controls.trackedInputsNOTES = [];
		
		mobilec = new MobileControls();

		switch (MobileControls.mode)
		{
			case MOBILEPAD_RIGHT | MOBILEPAD_LEFT | MOBILEPAD_CUSTOM:
				controls.setMobilePadNOTES(mobilec.vpad, "FULL", "NONE", PRESSED);
				MusicBeatState.checkHitbox = false;
			case DUO:
				controls.setMobilePadNOTES(mobilec.vpad, "DUO", "NONE", PRESSED);
				MusicBeatState.checkHitbox = false;
			case HITBOX:
				controls.setHitBox(mobilec.newhbox, mobilec.hbox, PRESSED);
				MusicBeatState.checkHitbox = true;
			default:
		}

		trackedinputsNOTES = controls.trackedInputsNOTES;

		var camcontrol = new flixel.FlxCamera();
		FlxG.cameras.add(camcontrol, false);
		camcontrol.bgColor.alpha = 0;
		mobilec.cameras = [camcontrol];

		add(mobilec);
	}

	public function removeMobilePad() {
		if (trackedinputsUI.length > 0)
			controls.removeVirtualControlsInput(trackedinputsUI);

		if (mobilePad != null)
			remove(mobilePad);
	}

	public function addMobilePadCamera() {
		var camcontrol = new flixel.FlxCamera();
		camcontrol.bgColor.alpha = 0;
		FlxG.cameras.add(camcontrol, false);
		mobilePad.cameras = [camcontrol];
	}

	override function destroy() {
		if (trackedinputsNOTES.length > 0)
			controls.removeVirtualControlsInput(trackedinputsNOTES);

		if (trackedinputsUI.length > 0)
			controls.removeVirtualControlsInput(trackedinputsUI);

		super.destroy();

		if (mobilePad != null)
			mobilePad = FlxDestroyUtil.destroy(mobilePad);
			
		if (mobilec != null)
			mobilec = FlxDestroyUtil.destroy(mobilec);

		controls.trackedInputsUI = [];
		controls.trackedInputsNOTES = [];
	}
	#end

	override function update(elapsed:Float)
	{
		//everyStep();
		if(!persistentUpdate) MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing
	}
	
	public function sectionHit():Void
	{
		//yep, you guessed it, nothing again
	}
	
	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
