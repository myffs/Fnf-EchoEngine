package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class SpecialThanksState extends MusicBeatState 
{

    public static var thanks:Array<Dynamic> = [ //Name,icon,discription,BG color
    ['Special Thanks'],
    ['Shadow Mario',  'shadowmario', 'Creator of Psych Engine', '000000'],
    ['River', 'river', 'Artist of Psych Engine', 'FFC0CB'],
    ['Yoshubs', 'shubs', 'Assistant Programmer of Psych Engine', '89CFF0'],
    ['bbPanzu', 'bb',  'EX-Programmer of Psych Engine', '00FF00'],
    
    ] 
}


for(i in pisspoop){
    creditsStuff.push(i);
}

for (i in 0...creditsStuff.length)
{
    var isSelectable:Bool = !unselectableCheck(i);
    var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
    optionText.isMenuItem = true;
    optionText.targetY = i;
    optionText.changeX = false;
    optionText.snapToPosition();
    grpOptions.add(optionText);

    if(isSelectable) {
        if(creditsStuff[i][5] != null)
        {
            Paths.currentModDirectory = creditsStuff[i][5];
        }

        var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
        icon.xAdd = optionText.width + 10;
        icon.sprTracker = optionText;

        // using a FlxGroup is too much fuss!
        iconArray.push(icon);
        add(icon);
        Paths.currentModDirectory = '';

        if(curSelected == -1) curSelected = i;
    }
    else optionText.alignment = CENTERED;
}

descBox = new AttachedSprite();
descBox.makeGraphic(1, 1, FlxColor.BLACK);
descBox.xAdd = -10;
descBox.yAdd = -10;
descBox.alphaMult = 0.6;
descBox.alpha = 0.6;
add(descBox);

descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
descText.scrollFactor.set();
//descText.borderSize = 2.4;
descBox.sprTracker = descText;
add(descText);

bg.color = getCurrentBGColor();
intendedColor = bg.color;
changeSelection();
super.create();
}

var quitting:Bool = false;
var holdTime:Float = 0;
override function update(elapsed:Float)
{
if (FlxG.sound.music.volume < 0.7)
{
    FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
}

if(!quitting)
{
    if(creditsStuff.length > 1)
    {
        var shiftMult:Int = 1;
        if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

        var upP = controls.UI_UP_P;
        var downP = controls.UI_DOWN_P;

        if (upP)
        {
            changeSelection(-shiftMult);
            holdTime = 0;
        }
        if (downP)
        {
            changeSelection(shiftMult);
            holdTime = 0;
        }

        if(controls.UI_DOWN || controls.UI_UP)
        {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
            {
                changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
            }
        }
    }

    if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
        CoolUtil.browserLoad(creditsStuff[curSelected][3]);
    }
    if (controls.BACK)
    {
        if(colorTween != null) {
            colorTween.cancel();
        }
        FlxG.sound.play(Paths.sound('cancelMenu'));
        MusicBeatState.switchState(new MainMenuState());
        quitting = true;
    }
}

for (item in grpOptions.members)
{
    if(!item.bold)
    {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
        if(item.targetY == 0)
        {
            var lastX:Float = item.x;
            item.screenCenter(X);
            item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
        }
        else
        {
            item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
        }
    }
}
super.update(elapsed);
}

var moveTween:FlxTween = null;
function changeSelection(change:Int = 0)
{
FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
do {
    curSelected += change;
    if (curSelected < 0)
        curSelected = creditsStuff.length - 1;
    if (curSelected >= creditsStuff.length)
        curSelected = 0;
} while(unselectableCheck(curSelected));

var newColor:Int =  getCurrentBGColor();
if(newColor != intendedColor) {
    if(colorTween != null) {
        colorTween.cancel();
    }
    intendedColor = newColor;
    colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
        onComplete: function(twn:FlxTween) {
            colorTween = null;
        }
    });
}

var bullShit:Int = 0;

for (item in grpOptions.members)
{
    item.targetY = bullShit - curSelected;
    bullShit++;

    if(!unselectableCheck(bullShit-1)) {
        item.alpha = 0.6;
        if (item.targetY == 0) {
            item.alpha = 1;
        }
    }
}

descText.text = creditsStuff[curSelected][2];
descText.y = FlxG.height - descText.height + offsetThing - 60;

if(moveTween != null) moveTween.cancel();
moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
descBox.updateHitbox();
}

#if MODS_ALLOWED
private var modsAdded:Array<String> = [];
function pushModCreditsToList(folder:String)
{
if(modsAdded.contains(folder)) return;

var creditsFile:String = null;
if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
else creditsFile = Paths.mods('data/credits.txt');

if (FileSystem.exists(creditsFile))
{
    var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
    for(i in firstarray)
    {
        var arr:Array<String> = i.replace('\\n', '\n').split("::");
        if(arr.length >= 5) arr.push(folder);
        creditsStuff.push(arr);
    }
    creditsStuff.push(['']);
}
modsAdded.push(folder);
}
#end

function getCurrentBGColor() {
var bgColor:String = creditsStuff[curSelected][4];
if(!bgColor.startsWith('0x')) {
    bgColor = '0xFF' + bgColor;
}
return Std.parseInt(bgColor);
}

private function unselectableCheck(num:Int):Bool {
return creditsStuff[num].length <= 1;
}
}
