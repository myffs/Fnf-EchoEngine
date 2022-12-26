package;

import Flx.Sprite.Group;
import Flx.Sprite;
import Flx.Typed.Group;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;



new(X:Float = 0, Y:Float = 0, MaxSize:Int = 255)
  directAlpha:Bool = false
    group:FlxTypedGroup<T>
      length:Int
        maxSize:Int
          members:Array<T>
            add(Sprite:T):T
              clear():Void
                clone():FlxTypedSpriteGroup<T>
                               countDead():Int
              countLiving():Int
          destroy():Void
                 findMaxX():Float
                   findMaxY():Float
                     findMinX():Float
                       findMinY():Float
                         forEach(Function:T ‑> Void, Recurse:Bool = false):Void
                           forEachAlive(Function:T ‑> Void, Recurse:Bool = false):Void
                             forEachDead(Function:T ‑> Void, Recurse:Bool = false):Void
                          forEachExists(Function:T ‑> Void, Recurse:Bool = false):Void
                            forEachOfType<K>(ObjectClass:Class<K>, Function:K ‑> Void, Recurse:Bool = false):Void
                                                      getFirstAlive():T
                                                        getFirstAvailable(?ObjectClass:Class<T>, Force:Bool = false):T
                                                           getFirstDead():T
                                                             getFirstExisting():T
                                                               getFirstNull():Int
                                                                 getRandom(StartIndex:Int = 0, Length:Int = 0):T
                                                                   insert(Position:Int, Sprite:T):T
                                                                     isOnScreen(?Camera:FlxCamera):Bool
                                                                       iterator(?filter:T ‑> Bool):FlxTypedGroupIterator<T>
                                                                         kill():Void
                                                                           loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite
                                                                             loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite
                                                                               loadRotatedGraphic(Graphic:FlxGraphicAsset, Rotations:Int = 16, Frame:Int = -1, AntiAliasing:Bool = false, AutoBuffer:Bool = false, ?Key:String):FlxSprite
                                                                                 makeGraphic(Width:Int, Height:Int, Color:Int = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSprite
                                                                                   multiTransformChildren<V>(FunctionArray:Array<(T, V) ‑> Void>, ValueArray:Array<V>):Void
                                                                                     overlapsPoint(point:FlxPoint, InScreenSpace:Bool = false, ?Camera:FlxCamera):Bool
                                                                                       pixelsOverlapPoint(point:FlxPoint, Mask:Int = 0xFF, ?Camera:FlxCamera):Bool
                                                                                         recycle(?ObjectClass:Class<T>, ?ObjectFactory:() ‑> T, Force:Bool = false, Revive:Bool = true):T
                                                                                          remove(Sprite:T, Splice:Bool = false):T
                                                                                            replace(OldObject:T, NewObject:T):T
                                                                                              replaceColor(Color:Int, NewColor:Int, FetchPositions:Bool = false):Array<FlxPoint>
                                                                                                revive():Void
                                                                                                  setPosition(X:Float = 0, Y:Float = 0):Void
                                                                                                    sort(Function:(Int, T, T) ‑> Int, Order:Int = FlxSort.ASCENDING):Void
                                                                                                      stamp(Brush:FlxSprite, X:Int = 0, Y:Int = 0):Void
                                                                                                        transformChildren<V>(Function:(T, V) ‑> Void, Value:V):Void
                                                                                                          function(sprite, v:Dynamic) { s.acceleration.x = v; s.makeGraphic(10,10,0xFF000000); }


class PlayState extends FlxState
{
	override public function create()
	{
		bgColor = 0;

super.create();
    
		var button = new FlxButton(0, 0, "Create block", onButtonClicked;
		button.screenCenter();
		add(button);
	}

	function onButtonClicked()
	{
		FlxG.camera.flash(128, 64, FlxColor.RED);
	}
}

class PlayState extends FlxState
{
	override public function create()
	{
		var text = new FlxText();
		text.text = "";
		text.color = FlxColor.BLACK;
		text.size = 16;
		text.screenCenter();
		add(text);

		var button = new FlxButton(0, 0, "Animation", switchState);
		button.screenCenter();
		button.y = text.y + text.height + 16;
		add(button);

		bgColor = 0;

super.create();
	}

	private function switchState():Void
	{
		FlxG.switchState(new OtherState());
	}
}

class OtherState extends FlxState
{
	override public function create()
	{
		var text = new FlxText();
		text.text = "Not done yet!!! Come back soon!!!";
		text.color = FlxColor.BLACK;
		text.size = 16;
		text.screenCenter();
		add(text);

		var button = new FlxButton(0, 0, "Switch States", switchState);
		button.screenCenter();
		button.y = text.y + text.height + 16;
		add(button);

		bgColor = 0;

super.create();
	}

	private function switchState():Void
	{
		FlxG.switchState(new PlayState());
	}
}
