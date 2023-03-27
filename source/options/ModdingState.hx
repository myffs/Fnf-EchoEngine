package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class ModdingState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Developers';
		rpcTitle = 'Developer + Modding Menu'; //for Discord Rich Presence

		var option:Option = new Option('Run Mod Plugins',
			'If checked, This will run the plugins \n( if you make a plugins folder in mods )',
			'plugins',
			'bool',
			false);
		addOption(option);
    
    	var option:Option = new Option('Debug Mode',
			'If checked, You can just debug stuff',
			'debugStuff',
			'bool',
			false);
		addOption(option);

		super();
	}
}
