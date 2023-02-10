package;

import flixel.util.FlxTimer;
import lime.net.URIParser;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static final psychEngineVersion:String = '0.6.3'; // This is also used for Discord RPC
	public static final echoEngineVersion:String = '0.4.2'; // yeah baby
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	var storyMode:FlxSprite;
	var freeplay:FlxSprite;
	var mods:FlxSprite;
	var awards:FlxSprite;
	var credits:FlxSprite;
	var options:FlxSprite;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var introTimer:FlxTimer;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.keyBinds.get('debug_1');

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		var scale:Float = 1;

		storyMode = new FlxSprite(10, -280);
		storyMode.frames = Paths.getSparrowAtlas("mainmenu/menu_story_mode");
		storyMode.animation.addByPrefix("idle", "story_mode basic", 24, true);
		storyMode.animation.addByPrefix("selected", "story_mode white", 24, true);
		storyMode.animation.play("idle");
		storyMode.scrollFactor.set(0, 1);
		storyMode.antialiasing = ClientPrefs.globalAntialiasing;
		add(storyMode);

		freeplay = new FlxSprite(10, -140);
		freeplay.frames = Paths.getSparrowAtlas("mainmenu/menu_freeplay");
		freeplay.animation.addByPrefix("idle", "freeplay basic", 24, true);
		freeplay.animation.addByPrefix("selected", "freeplay white", 24, true);
		freeplay.animation.play("idle");
		freeplay.scrollFactor.set(0, 1);
		freeplay.antialiasing = ClientPrefs.globalAntialiasing;
		add(freeplay);

		mods = new FlxSprite(10, 0);
		mods.frames = Paths.getSparrowAtlas("mainmenu/menu_mods");
		mods.animation.addByPrefix("idle", "mods basic", 24, true);
		mods.animation.addByPrefix("selected", "mods white", 24, true);
		mods.animation.play("idle");
		mods.scrollFactor.set(0, 1);
		mods.antialiasing = ClientPrefs.globalAntialiasing;
		add(mods);

		awards = new FlxSprite(10, 140);
		awards.frames = Paths.getSparrowAtlas("mainmenu/menu_awards");
		awards.animation.addByPrefix("idle", "awards basic", 24, true);
		awards.animation.addByPrefix("selected", "awards white", 24, true);
		awards.animation.play("idle");
		awards.scrollFactor.set(0, 1);
		awards.antialiasing = ClientPrefs.globalAntialiasing;
		add(awards);

		credits = new FlxSprite(10, 280);
		credits.frames = Paths.getSparrowAtlas("mainmenu/menu_credits");
		credits.animation.addByPrefix("idle", "credits basic", 24, true);
		credits.animation.addByPrefix("selected", "credits white", 24, true);
		credits.animation.play("idle");
		credits.scrollFactor.set(0, 1);
		credits.antialiasing = ClientPrefs.globalAntialiasing;
		add(credits);

		options = new FlxSprite(10, 560);
		options.frames = Paths.getSparrowAtlas("mainmenu/menu_options");
		options.animation.addByPrefix("idle", "options basic", 24, true);
		options.animation.addByPrefix("selected", "options white", 24, true);
		options.animation.play("idle");
		options.scrollFactor.set(0, 1);
		options.antialiasing = ClientPrefs.globalAntialiasing;
		add(options);

		introTimer = new FlxTimer();
		introTimer.start(0.5);

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Echo Engine v" + echoEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	function switchState(_)
	{
		switch (curSelected)
		{
			case 1:
				MusicBeatState.switchState(new StoryMenuState());
			case 2:
				MusicBeatState.switchState(new FreeplayState());
			case 3:
				MusicBeatState.switchState(new ModsMenuState());
			case 4:
				MusicBeatState.switchState(new AchievementsMenuState());
			case 5:
				MusicBeatState.switchState(new CreditsState());
			case 7:
				LoadingState.loadAndSwitchState(new options.OptionsState());
		}
	}

	function secondTween(_)
	{
		switch (curSelected)
		{
			case 1:
				FlxTween.tween(storyMode.scale, {x: storyMode.scale.x + 2, y: storyMode.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});

			case 2:
				FlxTween.tween(freeplay.scale, {x: freeplay.scale.x + 2, y: freeplay.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});

			case 3:
				FlxTween.tween(mods.scale, {x: mods.scale.x + 2, y: mods.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});

			case 4:
				FlxTween.tween(awards.scale, {x: awards.scale.x + 2, y: awards.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});

			case 5:
				FlxTween.tween(credits.scale, {x: credits.scale.x + 2, y: credits.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});

			case 7:
				FlxTween.tween(options.scale, {x: options.scale.x + 2, y: options.scale.y + 2}, 0.33, {ease: FlxEase.circIn, onComplete: switchState});
				FlxTween.tween(FlxG.camera, {zoom: 2}, 0.33, {ease: FlxEase.circIn});
		}
	}

	function introTween()
	{
		FlxTween.tween(storyMode, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(freeplay, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(mods, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(awards, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(credits, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
		FlxTween.tween(options, {alpha: 1, x: 10}, 0.8, {ease: FlxEase.circOut});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (curSelected == 6)
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					switch (curSelected)
					{
						case 1:
							FlxTween.tween(storyMode, {x: storyMode.x + 220}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(freeplay, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(mods, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(awards, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(credits, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(options, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 1);

						case 2:
							FlxTween.tween(storyMode, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(freeplay, {x: freeplay.x + 300}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(mods, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(awards, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(credits, {alpha: 0, y: options.y + 100}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(options, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 65);

						case 3:
							FlxTween.tween(storyMode, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(freeplay, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(mods, {x: mods.x + 440}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(awards, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(credits, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(options, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 130);

						case 4:
							FlxTween.tween(storyMode, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(freeplay, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(mods, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(awards, {x: awards.x + 350}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(credits, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(options, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 195);

						case 5:
							FlxTween.tween(storyMode, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(freeplay, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(mods, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(awards, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(credits, {x: credits.x + 285}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							FlxTween.tween(options, {alpha: 0, y: options.y + 10}, 0.33, {ease: FlxEase.circOut});
							camFollow.setPosition(400, 240);

						case 7:
							FlxTween.tween(storyMode, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(freeplay, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(mods, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(awards, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(credits, {alpha: 0, y: storyMode.y - 10}, 0.33, {ease: FlxEase.circOut});
							FlxTween.tween(options, {x: options.x + 340}, 0.5, {ease: FlxEase.circOut, onComplete: secondTween});
							camFollow.setPosition(400, 390);
					}
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

			if (curSelected == 8)
			{
				curSelected = 1;
				storyMode.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x - 90, 1); // don't ask me why this specific one has to be the x - 90. i don't know.
			}
			else if (curSelected == 0)
			{
				curSelected = 7;
				options.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 390);
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		storyMode.animation.play('idle');
		freeplay.animation.play('idle');
		mods.animation.play('idle');
		awards.animation.play('idle');
		credits.animation.play('idle');
		options.animation.play('idle');

		switch (curSelected)
		{
			case 1:
				storyMode.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x - 90, 1); // don't ask me why this specific one has to be the x - 90. i don't know.

			case 2:
				freeplay.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 65);

			case 3:
				mods.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 130);

			case 4:
				awards.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 195);

			case 5:
				credits.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 240);

			case 6:
				credits.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 325);

			case 7:
				options.animation.play('selected');
				camFollow.setPosition(storyMode.getGraphicMidpoint().x, 390);
		}
	}
}
