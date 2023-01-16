package;

import flixel.FlxSubState;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import WeekData;
import openfl.utils.Assets as OpenFlAssets;
import AttachedSprite.AttachedDropDownMenu;
import AttachedSprite.AttachedInputText;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var selector:FlxText;
	var songs:Array<SongMetadata> = [];
	var songsOG:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var showSearch:Bool = false;
	var searchY:Float = 0;
	var searchBG:FlxSprite;
	var searchText:AttachedInputText;
	var searchSort:AttachedDropDownMenu;
	static var lastSearch:String = '';
	static var lastSort:String = 'Week (Default)';

	public static var lastPlayed:Array<SongMetadata> = [];

	public static var fromPlayState:Bool = false;


	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup();
		add(grpSongs);
		grpIcons = new FlxTypedGroup();
		add(grpIcons);

		songs = songsOG.copy();
		if ((curSelected >= songs.length) || (fromPlayState && lastSort == 'Last Played')) curSelected = 0;
		setListFromSearch(lastSearch, lastSort, false);
		regenMenu(false);
		fromPlayState = false;

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));
			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;
			FlxG.stage.addChild(texFel);
			// scoreText.textField.htmlText = md;
			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy";
		var size:Int = 16;
		if (songsOG.length < 1) {
			leText = "Press CTRL to open the Gameplay Changers Menu";
		}
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		searchBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 75, FlxColor.BLACK);
		searchBG.alpha = 0.6;
		searchY = -searchBG.height;
		add(searchBG);

		searchText = new AttachedInputText(0, 0, 140);
		searchText.text = lastSearch;
		searchText.sprTracker = searchBG;
		searchText.xAdd = 150;
		searchText.yAdd = (searchBG.height / 2) - (searchText.height / 2);
		add(searchText);
		var text = new AttachedFlxText(0, 0, 0, 'Search:');
		text.sprTracker = searchText;
		text.yAdd = -15;
		add(text);

		var sortTypes = [
			'Week (Default)',
			'Name',
			'Last Played'
		];
		searchSort = new AttachedDropDownMenu(0, 0, FlxUIDropDownMenu.makeStrIdLabelArray(sortTypes, true), function(pressed:String) {
			var selectedType:Int = Std.parseInt(pressed);
			setListFromSearch(lastSearch, sortTypes[selectedType]);
		});
		searchSort.sprTracker = searchBG;
		searchSort.xAdd = 350;
		searchSort.yAdd = (searchBG.height / 2) - (searchSort.header.height / 2);
		add(searchSort);
		var text = new AttachedFlxText(0, 0, 0, 'Sort by:');
		text.sprTracker = searchSort;
		text.yAdd = -15;
		add(text);

		super.create();
	}

	override function openSubState(subState:FlxSubState) {
		super.openSubState(subState);
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songsOG.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;
			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{

		FlxG.mouse.visible = true;

		if (FlxG.sound.music != null) {
			if (FlxG.sound.music.volume < 0.7)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}

			if (instPlaying > -1) {
				Conductor.songPosition = FlxG.sound.music.time;
			}
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		var blockInput:Bool = false;
		var blockPressWhileTypingOn = [searchText];
		for (inputText in blockPressWhileTypingOn) {
			if (inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if (!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			var blockPressWhileScrolling = [searchSort];
			for (dropDownMenu in blockPressWhileScrolling) {
				if (dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput) {
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			var accepted = controls.ACCEPT;
			var space = FlxG.keys.justPressed.SPACE;
			var ctrl = FlxG.keys.justPressed.CONTROL;

			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT) shiftMult = 3;

			if (songs.length > 1)
			{
				if (upP || (!FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel > 0))
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP || (!FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel < 0))
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * ((controls.UI_UP) ? -shiftMult : shiftMult));
						changeDiff();
					}
				}
			}

			if (songs.length > 0 && CoolUtil.difficulties.length > 1) {
				if ((controls.UI_LEFT_P ) || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel < 0))
					changeDiff(-1);
				else if ((controls.UI_RIGHT_P ) || (FlxG.keys.pressed.SHIFT && FlxG.mouse.wheel > 0))
					changeDiff(1);
			}

			if (controls.BACK )
			{
				persistentUpdate = false;
				if (colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.7);
				MusicBeatState.switchState(new MainMenuState());
				FlxG.mouse.visible = true;
			}

			if (ctrl)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if (songs.length > 0)
			{
				if (space)
				{
					if (instPlaying != curSelected)
					{
						#if PRELOAD_ALL
						destroyFreeplayVocals();
						FlxG.sound.music.volume = 0;
						Paths.currentModDirectory = songs[curSelected].folder;
						var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
						PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
						if (PlayState.SONG.needsVoices)
							vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
						else
							vocals = new FlxSound();
		
						FlxG.sound.list.add(vocals);
						FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
						vocals.play();
						vocals.persist = true;
						vocals.looped = true;
						vocals.volume = 0.7;
						instPlaying = curSelected;
						#end
					}
				}
				else if (accepted && !showSearch)
				{
					fromPlayState = true;
					persistentUpdate = false;
					var song:String = songs[curSelected].songName;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					trace(poop);

					PlayState.SONG = Song.loadFromJson(poop, song);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;

					trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
					if (colorTween != null) {
						colorTween.cancel();
					}
					
					if (FlxG.keys.pressed.SHIFT) {
						PlayState.chartingMode = true;
						LoadingState.loadAndSwitchState(new ChartingState());
					} else {
						LoadingState.loadAndSwitchState(new PlayState());
					}

					FlxG.sound.music.volume = 0;
					
					destroyFreeplayVocals();
					FlxG.save.data.lastPlayed = lastPlayed;
					FlxG.save.flush();
				}
				else if (controls.RESET )
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				}

				if (showSearch && FlxG.mouse.screenY > searchBG.height) {
					showSearch = false;
					searchY = -searchBG.height;
				}
			}
		}

		if (!showSearch && FlxG.mouse.screenY <= 50) {
			showSearch = true;
			searchY = 0;
		}

		searchBG.y = FlxMath.lerp(searchBG.y, searchY, CoolUtil.boundTo(elapsed * 9.6, 0, 1));

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if HIGHSCORE_ALLOWED
		if (songs.length > 0) {
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		}
		#end

		PlayState.storyDifficulty = curDifficulty;
		if (CoolUtil.difficulties.length > 1) {
			diffText.text = '< ${CoolUtil.difficultyString()} >';
		} else {
			diffText.text = CoolUtil.difficultyString();
		}
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		
		if (songs.length > 0) {
			var newColor:Int = songs[curSelected].color;
			if (newColor != intendedColor) {
				if (colorTween != null) {
					colorTween.cancel();
				}
				intendedColor = newColor;
				colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
					onComplete: function(twn:FlxTween) {
						colorTween = null;
					}
				});
			}

			#if HIGHSCORE_ALLOWED
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
			#end

			var bullShit:Int = 0;

			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}

			if (iconArray[curSelected] != null)
				iconArray[curSelected].alpha = 1;

			for (item in grpSongs.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;

				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
			
			Paths.currentModDirectory = songs[curSelected].folder;
			PlayState.storyWeek = songs[curSelected].week;

			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		}

		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = FlxMath.maxInt(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		changeDiff();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	function sortAlphabetically(a:SongMetadata, b:SongMetadata):Int {
		var val1 = a.displayName.toUpperCase();
		var val2 = b.displayName.toUpperCase();
		if (val1 < val2) {
		  return -1;
		} else if (val1 > val2) {
		  return 1;
		} else {
		  return 0;
		}
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUIInputText.CHANGE_EVENT && (sender is AttachedInputText)) {
			if (sender == searchText) {
				setListFromSearch(searchText.text, lastSort);
			}
		}
	}

	function sortArray(arrayInput:Array<SongMetadata>, sort:String = ''):Array<SongMetadata> {
		var arr = arrayInput.copy();
		switch (sort) {
			case 'Name':
				arr.sort(sortAlphabetically);
			case 'Last Played':
				var sortedArray:Array<SongMetadata> = [];
				for (song in lastPlayed) {
					for (j in arr) {
						if (j.songName == song.songName && j.folder == song.folder) {
							sortedArray.push(j);
							break;
						}
					}
				}
				arr = sortedArray.copy();
		}
		return arr;
	}

	function setListFromSearch(text:String = '', sort:String = '', change:Bool = true) {
		var lastSongs:Array<String> = [];
		for (i in songs) {
			lastSongs.push(WeekData.formatWeek(i.songName, i.folder));
		}

		if (text == '') {
			songs = sortArray(songsOG, sort);
		} else {
			var daText = text.toLowerCase();
			var filteredSongs = songsOG.filter(song -> song.displayName.toLowerCase().startsWith(daText));
			if (sort == 'Name')
				filteredSongs = sortArray(filteredSongs, sort);
			var daOtherSongs = songsOG.filter(song -> (!song.displayName.toLowerCase().startsWith(daText) && song.displayName.toLowerCase().contains(daText)));
			if (sort == 'Name')
				daOtherSongs = sortArray(daOtherSongs, sort);
			for (i in daOtherSongs) {
				if (!filteredSongs.contains(i)) {
					filteredSongs.push(i);
				}
			}
			if (sort != 'Name') {
				filteredSongs = sortArray(filteredSongs, sort);
			}
			if (songs != filteredSongs) {
				songs = filteredSongs;
			}
		}
		lastSearch = text;
		lastSort = sort;

		var equal = true;
		if (songs.length == lastSongs.length) {
			for (i in 0...songs.length) {
				if (WeekData.formatWeek(songs[i].songName, songs[i].folder) != lastSongs[i]) {
					equal = false;
					break;
				}
			}
		} else {
			equal = false;
		}
		if (!equal) {
			regenMenu(change);
		}
	}

	function regenMenu(change:Bool = true) {
		for (i in 0...grpSongs.members.length) {
			var obj = grpSongs.members[0];
			obj.kill();
			grpSongs.remove(obj, true);
			obj.destroy();
		}
		for (i in 0...grpIcons.members.length) {
			var obj = grpIcons.members[0];
			obj.kill();
			grpIcons.remove(obj, true);
			obj.destroy();
		}
		iconArray = [];
		for (i in 0...songs.length)
			{
				var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
				songText.isMenuItem = true;
				songText.targetY = i - curSelected;
				grpSongs.add(songText);
	
				var maxWidth = 980;
				if (songText.width > maxWidth)
				{
					songText.scaleX = maxWidth / songText.width;
				}
				songText.snapToPosition();
	
				Paths.currentModDirectory = songs[i].folder;
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				songText.screenCenter(X);
			}
			WeekData.setDirectoryFromWeek();
		if (change) {
			changeSelection(0, false);
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var displayName:String = "";
	public var difficulties:Array<String> = null;
	public var iconHiddenUntilPlayed:Bool = false;

	public function new(song:String, week:Int, songCharacter:String, color:Int, ?displayName:String, iconHiddenUntilPlayed:Bool = false)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null) this.folder = '';
		this.displayName = displayName;
		if (this.displayName == null) this.displayName = this.songName;
		this.iconHiddenUntilPlayed = iconHiddenUntilPlayed;
	}
}
