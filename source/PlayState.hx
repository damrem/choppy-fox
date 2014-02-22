package ;

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

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	inline static var MAX_SPEED:Float = 125.0;
	inline static var FORWARD:Float = 150.0;
	inline static var GRAVITY:Float = 100.0;
	inline static var UP:Float = -100.0;
	inline static var FRICTION:Float = 50.0;
	
	var musicCredit:FlxText;
	var plane:FlxSprite;
	var clickToStartMessage:FlxText;
	var isPlaying:Bool;
	var controlIsUp:Int;
	var bg:FlxBackdrop;
	var pipes:FlxTypedGroup<FlxSprite>;
	var gameOverLabel:FlxText;
	var scoreLabel:FlxText;
	var score:UInt;
	var bestScore:UInt;
	var save:FlxSave;
	var t:Float;
	var autoLooping:Bool;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		FlxG.sound.playMusic("assets/music/POL-rocket-station-short.wav", 0.1);
		
		Lib.trace("create");
		super.create();
		
		//save = new FlxSave();
		
		bg = new FlxBackdrop("assets/images/sprite background mugen 0017.png", 0.8, 0.0, true, false);
		add(bg);
		
		plane = createPlane();
		add(plane);
		
		FlxG.camera.follow(this.plane, FlxCamera.STYLE_PLATFORMER);
		
		
		pipes = new FlxTypedGroup<FlxSprite>();
		
		clickToStartMessage = this.createMessage('CLICK TO START');
		add(this.clickToStartMessage);
		
		scoreLabel = createScore();
		
		reset();
		
		musicCredit = new FlxText(FlxG.width - 210, FlxG.height - 20, 200, "Music by PlayOnLoop");
		musicCredit.scrollFactor.x = musicCredit.scrollFactor.y = 0;
		musicCredit.alignment = 'right';
		musicCredit.alpha = 0.1;
		add(musicCredit);
		
		MouseEventManager.addSprite(musicCredit, null, navigateToPlayOnLoop);
		
		gameOverLabel = createMessage("GAME OVER!\nCLICK TO RESTART...");
		
		//explode();
		
		
		
		
	}
	
	function navigateToPlayOnLoop(sprite:FlxSprite)
	{
		FlxG.openURL("http://www.playonloop.com/2013-music-loops/rocket-station/", '_blank');
	}
	
	private function createPlane():FlxSprite
	{
		
		var plane = new FlxSprite();
		plane.loadGraphic("assets/images/tails.png", true, false, 36, 36, true, 'plane');
		plane.animation.add('up', [0, 1, 2], 10);
		plane.animation.add('forward', [3, 4, 5], 10);
		plane.setOriginToCenter();
		
		plane.width = plane.height = 25;
		plane.maxVelocity.x = MAX_SPEED;
		plane.drag.x = FRICTION;
		plane.centerOffsets();
		
		plane.scrollFactor.y = 0.0;
		
		return plane;
	}
	
	function createMessage(msg:String):FlxText
	{
		var stg:Stage = FlxG.stage;
		var w:Int = 400;
		var label:FlxText = new FlxText((stg.stageWidth - w) / 2, stg.stageHeight / 2, w, msg, 16);
		label.alignment = 'center';
		label.scrollFactor.x = label.scrollFactor.y = 0.0;
		return label;
	}
	
	function createScore():FlxText
	{
		var w:Int = 200;
		var label:FlxText = new FlxText(FlxG.stage.stageWidth - w - 10, 10, w, "0", 16);
		label.alignment = 'right';
		label.scrollFactor.x = label.scrollFactor.y = 0.0;
		return label;
	}
	
	function reset()
	{
		Lib.trace("reset");
		isPlaying = false;
		
		setScore(0);
		
		controlIsUp = -1;
		
		pipes.forEach(recyclePipe);
		
		var stg:Stage = FlxG.stage;
		plane.setPosition(stg.stageWidth / 4, stg.stageHeight / 2);
		plane.velocity.x = plane.velocity.y = 0.0;
		plane.angle = 0.0;
		
		maxPlaneX = plane.x;
	}
	
	function recyclePipe(pipe:FlxSprite) 
	{
		pipe.kill();
	}
	
	function setScore(_score:UInt)
	{
		score = _score;
		scoreLabel.text = "" + score;
	}
	
	private function start()
	{
		Lib.trace("start");
		remove(clickToStartMessage);
		remove(gameOverLabel);
		
		add(scoreLabel);
		
		plane.visible = true;
		plane.animation.play('forward');
		//plane.velocity.x = 100.0;
		//plane.acceleration.y = JETPACK_INTENSITY;
		
		isPlaying = true;
	}
	
	function moveForward(startAnim:Bool)
	{
		plane.acceleration.x = FORWARD;
		plane.acceleration.y = GRAVITY;
		if (startAnim)
		{
			plane.animation.play('forward');
		}
		
	}
	
	function moveUp(startAnim:Bool)
	{
		plane.acceleration.x = 0.0;
		plane.acceleration.y = UP;
		if (startAnim)
		{
			plane.animation.play('up');
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

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{	
		t = Lib.getTimer() / 1000;
		if (this.isPlaying)
		{
			this.updatePlaying(t);
		}
		else
		{
			this.updateWaiting();
		}
		if(FlxG.keys.justReleased.D)
		{
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		}
		/*
		if (FlxG.mouse.justReleased)
		{
			explode(FlxG.mouse.x, FlxG.mouse.y);
		}
		*/
		
		super.update();
	}
	
	function updateWorldBounds()
	{
		//FIXME le x du worldbounds augmente un peu trop et l'avion se retrouve hors-world
		FlxG.worldBounds.x = plane.x - 100;
		//FlxG.worldBounds.y = plane.y - 100;
		//Lib.trace(bg.getScreenXY());
		//Lib.trace("world: " + FlxG.worldBounds);
		//Lib.trace("plane:" + plane);
		//Lib.trace(FlxG.worldBounds.containsFlxPoint(new FlxPoint(plane.x, plane.y)));
		
	}
	
	function updatePlaying(t:Float) 
	{
		//Lib.trace("updatePlaying");
		updateWorldBounds();
		updatePipes(t);
		updatePlane();
		updateScore();
		FlxG.collide(plane, pipes, collide);
		//pipes.forEach(checkPlaneCollision);
		
	}
	
	function checkPlaneCollision(pipe:FlxSprite) 
	{
		if (FlxG.pixelPerfectOverlap(plane, pipe))
		{
			collide(plane, pipe);
		}
	}
	
	function updateScore()
	{
		//Lib.trace("updateScore");
		var nextPipe:FlxSprite = pipes.getFirstAlive();
		if (nextPipe != null)
		{
			if(plane.x > nextPipe.x)
			{
				pipes.getFirstAlive().alpha = 0.5;
				pipes.getFirstAlive().set_alive(false);
				pipes.getFirstAlive().alpha = 0.5;
				pipes.getFirstAlive().set_alive(false);
				setScore(score + 1);
				
				FlxG.sound.play("assets/sounds/score.mp3");
			}
		}
		//trace(pipes);
	}
	
	var explosion:FlxEmitterExt;
	
	static inline var EXPLOSION_LIFESPAN:Float = 0.25;
	static inline var EXPLOSION_DISTANCE:Float = 0.0;
	static inline var EXPLOSION_LIFESPAN_RANGE:Float = 0.25;
	static inline var EXPLOSION_DISTANCE_RANGE:Float = 75.0;
	static inline var EXPLOSION_QUANTITY:Int = 100;
	
	function explode()
	{
		//Lib.trace("explode(" + X + ", " + Y);
		//Lib.trace(plane.y);
		plane.visible = false;
		
		explosion = new FlxEmitterExt();
		
		explosion.setMotion(0, EXPLOSION_DISTANCE, EXPLOSION_LIFESPAN, 360, EXPLOSION_DISTANCE_RANGE, EXPLOSION_LIFESPAN_RANGE);// (0, 0.5, 0.05, 360, 200, 1.8);
		
		explosion.makeParticles("assets/images/explosion-particle.png", EXPLOSION_QUANTITY, 0, true, 0);
		explosion.setAlpha(1, 1, 0, 0);
		
		explosion.at(plane);
		add(explosion);
		
		explosion.setAll('scrollFactor', new FlxPoint(1.0, 0.0));
		
		explosion.start(true, EXPLOSION_LIFESPAN, 0.1, EXPLOSION_QUANTITY, EXPLOSION_LIFESPAN);
		explosion.update();
		
		FlxG.sound.play("assets/sounds/explosion.mp3");
	}
	
	function collide(planeObj:FlxObject, pipesObj:FlxObject)
	{
		explode();
		
		gameOver();
	}
	
	/**
	 * Modulo du plus loin que l'avion soit allé pour génération de tuyaux.
	 */
	var prevModulo:Float;
	/**
	 * Le plus loin que l'avion soit allé pour génération de tuyaux.
	 */
	var maxPlaneX:Float;
	
	inline static var PIPE_SPACE:Float = 200.0;
	
	inline static var HOLE_HEIGHT_MIN:Float = 50.0;
	inline static var HOLE_HEIGHT_MAX:Float = 75.0;
	
	inline static var PIPE_Y_SHIFT_MAX:Float = 50.0;
	
	function updatePipes(t:Float)
	{
		if (plane.x > maxPlaneX)	maxPlaneX = plane.x;
		//Lib.trace(maxPlaneX);
		
		var currModulo:Float = maxPlaneX % PIPE_SPACE;
		var isCreating = (currModulo < prevModulo);
		prevModulo = currModulo;
		
		//var creatingOccurence = Math.random();
		//Lib.trace(creatingOccurence);
		//var isCreating = creatingOccurence < 0.01;
		
		if (isCreating)
		{
			var yShift = FlxRandom.intRanged( cast(-PIPE_Y_SHIFT_MAX/2, Int), cast(PIPE_Y_SHIFT_MAX/2, Int));
			var space = FlxRandom.intRanged(cast(HOLE_HEIGHT_MIN, Int), cast(HOLE_HEIGHT_MAX, Int));
			
			var pipeTop:FlxSprite = createPipe();
			pipeTop.scale.x = -1;
			pipeTop.y = -32 + yShift - space / 2;
			pipeTop.angle = 180;
			
			var pipeBottom:FlxSprite = createPipe();
			pipeBottom.y = FlxG.stage.stageHeight + 32 - pipeBottom.height + yShift + space / 2;
			
			pipeTop.x = pipeBottom.x = plane.x + FlxG.stage.stageWidth;
			
			add(pipeTop);
			add(pipeBottom);
		}
	
	}
	function createPipe():FlxSprite
	{
		var pipe = new FlxSprite( 0, 0, "assets/images/pipe.png");
		pipe.scrollFactor.y = 0;
		pipe.immovable = true;
		//pipe.velocity.y = FlxRandom.floatRanged( -10, 10);
		pipes.add(pipe);
		return pipe;
	}
	
	function updatePlane()
	{
		//	si le bouton est enfoncé ou qu'on est en auto-looping,
		//	on rotationne progressivement la vélocité de l'avion
		if (FlxG.mouse.pressed)
		{
			moveUp(FlxG.mouse.justPressed);
		}
		else
		{
			moveForward(FlxG.mouse.justReleased);
		}
		
		
		
		
		
		
		var object:FlxObject = cast(plane, FlxObject);
		if (!object.isOnScreen())
		{
			gameOver();
			
			explode();
		}
	}
	
	
	
	
	
	function updateWaiting()
	{
		if (FlxG.mouse.justReleased)
		{
			Lib.trace("released");
			this.reset();
			this.start();
		}
	}
	
	function gameOver()
	{
		Lib.trace("gameOver");
		this.isPlaying = false;
		
		plane.velocity.x = plane.velocity.y = plane.acceleration.x = plane.acceleration.y = 0.0;
		
		add(gameOverLabel);
		
		FlxG.camera.shake(0.01, 0.5);
		
		//if(score 
	}
}