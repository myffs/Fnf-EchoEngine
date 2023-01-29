package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.FlxObject;

class AmongCreditsState extends MusicBeatState
{
    private static var amongCreditsStuff:Array<Dynamic> = [ //Sticky Note Name - Portrait Name - Description - Link
        //PORTRAITS ARE STORED IN SHARED/CREDITS/PORTRAITS. MAKE SURE TO ADD ONE TO ADVOID CRASHES. COPY GEM AND EDIT YOUR COPY TO MAKE YOUR OWN PORTRAIT. THANK YOU! -Jellyburn
        ['Jellyburn',		'gem',	    'we arent in kansas anymore.',	'https://www.youtube.com/watch?v=Fx2PXKDFIWM'],
	['Memehoovy',		'thales',	    'hoi im a meme and uh im a memer and a sloth',	'https://www.youtube.com/watch?v=xe005d1kAMc']
        ['MyFNF',		'pagt',	    'no this is MYFNF',	'https://www.youtube.com/watch?v=dvNvmTGv40k']
    ];

    var nameText:FlxText;
    var descText:FlxText;
    var curDesc:Int = 0;

    var wallback:FlxSprite;
    var frame:FlxSprite;
    var dumnote:FlxSprite;
    var lamp:FlxSprite;
    var lamplight:FlxSprite;
    var tree1:FlxSprite;
    var tree2:FlxSprite;

    var portrait:FlxSprite;

    var mole:FlxSprite; //hey mol :]

    private var camFollowPos:FlxObject;

    override public function create()
    {
        super.create();

        camFollowPos = new FlxObject(0, 0, 1, 1);

        FlxG.camera.zoom = 0.8;
        FlxG.camera.follow(camFollowPos, LOCKON);

        camFollowPos.setPosition(660, 370);

        wallback = new FlxSprite().loadGraphic(Paths.image('credits/wallback', 'shared'));
		wallback.antialiasing = true;
        wallback.scale.set(1.3, 1.3);
		add(wallback);

        portrait = new FlxSprite(0, 100).loadGraphic(Paths.image('credits/portraits/gem', 'shared'));
		portrait.antialiasing = true;
		add(portrait);

        frame = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/frame', 'shared'));
		frame.antialiasing = true;
		add(frame);

        dumnote = new FlxSprite(0, 30).loadGraphic(Paths.image('credits/stickynote', 'shared'));
		dumnote.antialiasing = true;
		dumnote.scale.set(1.25, 1.25);
		add(dumnote);

        lamp = new FlxSprite(0, -50).loadGraphic(Paths.image('credits/lamp', 'shared'));
		lamp.antialiasing = true;
        lamp.x = (FlxG.width / 2)  - (lamp.width / 2);
	        lamp.visible = true;
		add(lamp);

        lamplight = new FlxSprite(0, 50).loadGraphic(Paths.image('credits/lamplight', 'shared'));
		lamplight.antialiasing = true;
        lamplight.x = (FlxG.width / 2)  - (lamplight.width / 2);
        lamplight.blend = ADD;
        lamplight.alpha = 0.2;
	     lamplight.visible = true;
		add(lamplight);

        tree1 = new FlxSprite(-400, 0).loadGraphic(Paths.image('credits/tree', 'shared'));
		tree1.antialiasing = true;
		add(tree1);

        tree2 = new FlxSprite(1050, 0).loadGraphic(Paths.image('credits/tree2', 'shared'));
		tree2.antialiasing = true;
		add(tree2);

        mole = new FlxSprite(601, 620).loadGraphic(Paths.image('credits/mole', 'shared'));
		mole.antialiasing = false;
        add(mole);

        descText = new FlxText(0, 600, 1200, "", 0);
		descText.setFormat(Paths.font("AmaticSC-Bold.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 1.3;
        add(descText);

        nameText = new FlxText(565, 120, 800, "", 0);
		nameText.setFormat(Paths.font("Dum-Regular.ttf"), 45, FlxColor.BLACK, CENTER);
		nameText.angle = -12;
        nameText.updateHitbox();
        add(nameText);

        updateDescription();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (amongCreditsStuff[curDesc][1] == 'mol') { mole.visible = true; tree2.visible = false; tree1.visible = true; }
        else{ mole.visible = false; tree2.visible = true; tree1.visible = false; }
     
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;

		if (leftP)
		{
			updateDescription(-1);
		}
		if (rightP)
		{
			updateDescription(1);
		}

    	if (controls.BACK)			
        {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
        if(controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			CoolUtil.browserLoad(amongCreditsStuff[curDesc][3]);
		}
    }

    function updateDescription(?change:Int)
    {
        curDesc += change;
        
        if(curDesc >= amongCreditsStuff.length - 1)
        {
            curDesc = amongCreditsStuff.length - 1;
            tree2.visible = true;
        }
        else
            tree2.visible = false;
        if(curDesc <= 0)
        {
            curDesc = 0;
            tree1.visible = false;
        }
        else
            tree1.visible = true;

        nameText.text = amongCreditsStuff[curDesc][0];

        descText.text = amongCreditsStuff[curDesc][2];
        descText.x = ((FlxG.width / 2) - (descText.width / 2));

        switch(amongCreditsStuff[curDesc][0]){
            default:
                nameText.y = 120;
        }

        portrait.loadGraphic(Paths.image('credits/portraits/' + amongCreditsStuff[curDesc][1], 'shared'));
        portrait.x = ((FlxG.width / 2) - (portrait.width / 2));
        frame.x = portrait.x - 55;
        dumnote.x = frame.x + 560;
    }
}
