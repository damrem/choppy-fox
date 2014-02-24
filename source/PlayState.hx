package ;

import flixel.group.FlxSpriteGroup;
import flixel.plugin.MouseEventManager;
import flash.display.Stage;
import flash.Lib;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.particles.FlxEmitterExt;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxTypedEmitter.Bounds;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxSave;
import flixel.util.FlxVector;
import flixel.group.FlxGroup;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	inline static var WAITING:String = 'waiting';
	inline static var ARRIVING:String = 'arriving';
	inline static var PLAYING:String = 'playing';
	inline static var GAME_OVER:String = 'gameOver';
	var state:String;
	
	inline static var FORWARD:Float = 150.0;
	inline static var GRAVITY:Float = 100.0;
	inline static var UP:Float = -100.0;
	
	var logo:FlxText;
	var rings:FlxSpriteGroup;
	var bestScoreLabel:FlxText;
	var save:FlxSave;
	var tuto:Tuto;
	var hud:FlxSpriteGroup;
	var musicCredit:FlxText;
	var hero:FlxSprite;
	var clickToStartLabel:FlxText;
	var bg:FlxBackdrop;
	var traps:FlxSpriteGroup;
	var gameOverLabel:FlxText;
	var scoreLabel:FlxText;
	var score:UInt;
	var t:Float;
	var autoLooping:Bool;
	var credits:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		
		super.create();
		Lib.trace("create");		
		
		FlxG.sound.playMusic("assets/music/11-angel-island-zone-act-2.mp3", 0.1);
		
		hud = new FlxSpriteGroup();
		hud.scrollFactor.x = hud.scrollFactor.y = 0;
		
		tuto = new Tuto();
		
		addBG();
		
		traps = new FlxSpriteGroup();
		traps.scrollFactor.y = 0;
		add(traps);
		
		rings = new FlxSpriteGroup(3);
		rings.scrollFactor.y = 0;
		add(rings);
		
		logo = new FlxText(0, FlxG.height / 8, FlxG.width, "CHOPPY FOX", 48);
		logo.alignment = 'center';
		
		clickToStartLabel = createMessage('CLICK TO START');
		gameOverLabel = createMessage("GAME OVER!\nCLICK TO RESTART...");
		
		scoreLabel = createScore(8, 24);
		bestScoreLabel = createScore(36, 16);
		
		credits = new FlxText(8, 0, 200, "damrem");
		credits.y = FlxG.height - credits.height - 8;
		
		MouseEventManager.addSprite(credits, null, onClickCredits);
		
		save = new FlxSave();
		save.bind('tails');
		Lib.trace(save.data.bestScore);
		if (save.data.bestScore == null)
		{
			setBestScore(0);
		}
		else
		{
			setBestScore(save.data.bestScore);
		}
		hud.add(scoreLabel);
		//hud.add(scoreSeparator);
		hud.add(bestScoreLabel);
		
		hero = new Hero();
		add(hero);

		add(hud);
		
		wait();
	}
	
	function onClickCredits(Credits:FlxSprite) 
	{
		FlxG.openURL("http://www.damienremars.com", "_blank");
	}
	
	function setBestScore(bestScore:UInt) 
	{
		Lib.trace("setBestScore(" + bestScore);
		save.data.bestScore = bestScore;
		bestScoreLabel.text = bestScore + "";
	}
	
	function addBG()
	{
		add(new FlxBackdrop("assets/images/bg5.png", 0.0, 0.0, false, false));
		add(new FlxBackdrop("assets/images/bg4.png", 0.1, 0.0, true, false));
		add(new FlxBackdrop("assets/images/bg3.png", 0.2, 0.0, true, false));
		add(new FlxBackdrop("assets/images/bg2.png", 0.4, 0.0, true, false));
		add(new FlxBackdrop("assets/images/bg1.png", 0.8, 0.0, true, false));
	}
	
	function navigateToPlayOnLoop(sprite:FlxSprite)
	{
		FlxG.openURL("http://www.playonloop.com/2013-music-loops/rocket-station/", '_blank');
	}
	
	function createMessage(msg:String):FlxText
	{
		var w:Int = 400;
		var label:FlxText = new FlxText((FlxG.width - w) / 2, FlxG.height / 2, w, msg, 16);
		label.alignment = 'center';
		label.scrollFactor.x = label.scrollFactor.y = 0.0;
		return label;
	}
	
	function createScore(Y:Float, Size:UInt):FlxText
	{
		var w:Int = 200;
		var label:FlxText = new FlxText(FlxG.stage.stageWidth - w - 8, Y, w, "0", Size);
		label.alignment = 'right';
		label.scrollFactor.x = label.scrollFactor.y = 0;
		return label;
	}
	
	function wait()
	{
		
		Lib.trace("wait");
		state = WAITING;
		
		setScore(0);
		
		rings.forEach(killSprite);
		traps.forEach(killSprite);
		
		//FlxG.camera = new FlxCamera();
		FlxG.camera.follow(null);
		
		hero.animation.play('forward');
		hero.setPosition(-36, FlxG.height/ 3);
		hero.velocity.x = hero.velocity.y = 0.0;
		hero.acceleration.y = 0;
		
		maxHeroX = hero.x;
		hud.remove(gameOverLabel);
		hud.add(tuto);
		hud.add(logo);
		hud.add(clickToStartLabel);
		hud.add(credits);
		
	}
	
	function killSprite(sprite:FlxSprite) 
	{
		sprite.kill();
	}
	
	function setScore(_score:UInt)
	{
		score = _score;
		scoreLabel.text = "" + score;
	}
	
	private function start()
	{
		Lib.trace("start");
		
		state = PLAYING;
		
		FlxG.camera.follow(this.hero, FlxCamera.STYLE_PLATFORMER, new FlxPoint(-FlxG.width/3, 0));
		
		hero.animation.play('forward');
	}
	
	

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{	
		//Lib.trace(state);
		t = Lib.getTimer() / 1000;
		if (state == PLAYING)
		{
			this.updatePlaying(t);
		}
		else if(state == ARRIVING)
		{
			this.updateArriving();
		}
		else if(state == WAITING)
		{
			this.updateWaiting();
		}
		else if (state == GAME_OVER)
		{
			this.updateGameOver();
		}
		if(FlxG.keys.justReleased.D)
		{
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		}
		
		super.update();
	}
	
	function updateArriving() 
	{
		if (hero.x >= FlxG.width / 3)
		{
			start();
		}
	}
	
	function updateGameOver() 
	{
		if (FlxG.mouse.justReleased)
		{
			Lib.trace("justReleased");
			
			FlxG.resetState();
		}
	}
	
	function updateWaiting()
	{
		if (FlxG.mouse.justReleased 
		&& 
		!(FlxG.mouse.x >= credits.x 
		&& FlxG.mouse.x <= credits.x + credits.width
		&& FlxG.mouse.y >= credits.y
		&& FlxG.mouse.y <= credits.y + credits.height)
		)
		{
			Lib.trace("released");
			arrive();
			
		}
	}
	
	function arrive() 
	{
		Lib.trace("arrive");
		state = ARRIVING;
		
		hud.remove(logo);
		hud.remove(credits);
		hud.remove(clickToStartLabel);
		hud.remove(gameOverLabel);
		hud.remove(tuto);		
		
		moveForward(true);
		hero.acceleration.y = 0;
	}
	
	function updatePlaying(t:Float) 
	{
		updateWorldBounds();
		generateLandscape(t);
		updateHero();
		FlxG.overlap(hero, rings, pickUpRing);
		FlxG.collide(hero, traps, loseLife);
	}
	
	function updateWorldBounds()
	{
		FlxG.worldBounds.x = hero.x - 100;		
	}
	
	function pickUpRing(hero:FlxObject, ring:FlxObject) 
	{
		ring.kill();
		setScore(score + 1);
		FlxG.sound.play("assets/sounds/ring.mp3");
	}
	
	var explosion:FlxEmitterExt;
	
	static inline var EXPLOSION_LIFESPAN:Float = 0.25;
	static inline var EXPLOSION_DISTANCE:Float = 0.0;
	static inline var EXPLOSION_LIFESPAN_RANGE:Float = 0.25;
	static inline var EXPLOSION_DISTANCE_RANGE:Float = 75.0;
	static inline var EXPLOSION_QUANTITY:Int = 100;
	
	
	
	function loseLife(hero:FlxObject, trap:FlxObject)
	{
		Lib.trace("collide");
		//explode();
		
		gameOver();
		
		
	}
	
	/**
	 * Modulo du plus loin que l'avion soit allé pour génération de tuyaux.
	 */
	var prevModulo:Float;
	/**
	 * Le plus loin que l'avion soit allé pour génération de tuyaux.
	 */
	var maxHeroX:Float;
	
	inline static var SPACE_BETWEEN_TRAPS:Float = 200.0;
	function generateLandscape(t:Float)
	{
		if (hero.x > maxHeroX)	maxHeroX = hero.x;
		
		var currModulo:Float = maxHeroX % SPACE_BETWEEN_TRAPS;
		var isCreating = (currModulo < prevModulo);
		prevModulo = currModulo;
		
		if (isCreating)
		{
			var miteX:Float = hero.x + FlxG.width + FlxRandom.floatRanged( -48, 48);
			var miteHeight:Float = FlxRandom.floatRanged(64, FlxG.height - 96);
			
			var movementType = FlxRandom.intRanged(0, 3);
			
			var miteXRange:Float = 0;
			var miteYRange:Float = 0;
			var miteSpeed:Float = 0;
			
			if (movementType == 2)
			{
				miteXRange = FlxRandom.floatRanged(2, 4) * 16;
				miteYRange = 0;
				miteSpeed = FlxRandom.floatRanged(2, 4) * 8;
			}
			else if (movementType == 3)
			{
				miteXRange = 0;
				miteYRange = FlxRandom.intRanged(2, 4) * 16;
				miteSpeed = FlxRandom.intRanged(2, 4) * 8;
			}
			
			var mite:Trap = LandscapeFactory.createStalagmite(miteX, miteHeight, miteXRange, miteYRange, miteSpeed);
			traps.add(mite);
			
			var ring = new Ring(mite);
			rings.add(ring);
		}
	}
	
	function createRing():FlxSprite
	{
		var ring = new FlxSprite();
		ring.scrollFactor.y = 0;
		ring.loadGraphic("assets/images/ring.png", true, false, 16, 16);
		ring.animation.add('spin', [0, 1, 2, 3], 10);
		ring.animation.play('spin');
		//rings.add(ring);
		return ring;
	}
	
	function updateHero()
	{
		//	si le bouton est enfoncé ou qu'on est en auto-looping,
		//	on rotationne progressivement la vélocité de l'avion
		if (FlxG.mouse.pressed)
		{
			moveUp(FlxG.mouse.justPressed);
			//waitToRestart = true;
		}
		else
		{
			moveForward(FlxG.mouse.justReleased);
			//waitToRestart = false;
		}
		
		var object:FlxObject = cast(hero, FlxObject);
		if (!object.isOnScreen())
		{
			gameOver();
		}
	}
	
	function gameOver()
	{
		Lib.trace("gameOver");
		state = GAME_OVER;
		
		if (score > save.data.bestScore)
		{
			setBestScore(score);
		}
		
		hero.acceleration.x = 0.0;
		hero.acceleration.y = GRAVITY;
		hero.animation.play('lose');
		
		hud.add(gameOverLabel);
		
		FlxG.camera.shake(0.01, 0.5);
		FlxG.sound.playMusic("assets/music/18-game-over.mp3", 0.1);
	}
	
	function moveForward(startAnim:Bool)
	{
		hero.acceleration.x = FORWARD;
		hero.acceleration.y = GRAVITY;
		if (startAnim)
		{
			hero.animation.play('forward');
		}
		
	}
	
	function moveUp(startAnim:Bool)
	{
		hero.acceleration.x = 0.0;
		hero.acceleration.y = UP;
		if (startAnim)
		{
			hero.animation.play('up');
		}
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
}