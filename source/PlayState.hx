package ;
import flash.display.Stage;
import flash.Lib;
import flixel.addons.display.FlxBackdrop;
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
	var plane:FlxSprite;
	var clickToStartMessage:FlxText;
	var isPlaying:Bool;
	var controlIsUp:Int;
	inline static var LOOPING_SPEED_DEG:Float = 2.5;
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
		
		gameOverLabel = createMessage("GAME OVER!");
		
	}
	
	private function createPlane():FlxSprite
	{
		var plane = new FlxSprite();
		plane.loadGraphic("assets/images/plane.png", true, false, 48, 33, true, 'plane');
		plane.animation.add('rotate', [0, 1], 10);
		plane.setOriginToCenter();
		plane.scrollFactor.y = 0.0;
		return plane;
	}
	
	function createMessage(msg:String):FlxText
	{
		var stg:Stage = FlxG.stage;
		var w:Int = 200;
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
		plane.velocity.x = 100.0;
		plane.velocity.y = 0.0;
		plane.angle = 0.0;
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
		
		plane.animation.play('rotate');
		
		
		isPlaying = true;
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
		super.update();
	}
	
	function updateWorldBounds()
	{
		//FIXME le x du worldbounds augmente un peu trop et l'avion se retrouve hors-world
		FlxG.worldBounds.x = plane.x - 100;
		FlxG.worldBounds.y = plane.y - 100;
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
				setScore(score+1);
			}
		}
		//trace(pipes);
	}
	
	function collide(planeObj:FlxObject, pipesObj:FlxObject)
	{
		gameOver();
	}
	
	function updatePipes(t:Float)
	{
		
		var creatingOccurence = Math.random();
		//Lib.trace(creatingOccurence);
		var isCreating = creatingOccurence < 0.01;
		
		if (isCreating)
		{
			var yShift = FlxRandom.intRanged( -25, 25);
			var space = FlxRandom.intRanged(75, 100);
			
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
		pipes.add(pipe);
		return pipe;
	}
	
	function updatePlane()
	{
		//	si le bouton est enfoncé ou qu'on est en auto-looping,
		//	on rotationne progressivement la vélocité de l'avion
		if (FlxG.mouse.pressed || autoLooping)
		{
			Lib.trace("mouse pressed=" + FlxG.mouse.pressed);
			Lib.trace("autolooping=" + autoLooping);
			var rotatedVelocity:FlxVector = new FlxVector(plane.velocity.x, plane.velocity.y);
			rotatedVelocity.rotateByDegrees(LOOPING_SPEED_DEG * controlIsUp);
			plane.velocity.x = rotatedVelocity.x;
			plane.velocity.y = rotatedVelocity.y;
			
			this.plane.angle = rotatedVelocity.degrees;
		}
		
		//	à la fin du clic, on inverse le contrôle ou on passe en auto-looping si le looping n'est pas terminé
		if (FlxG.mouse.justReleased && !autoLooping)
		{
			Lib.trace("justReleased");
			Lib.trace("plane.velocity.x=" + plane.velocity.x);
			//	si à la fin du looping, l'avion avance, c'est cool
			if (plane.velocity.x > 0)
			{
				//Lib.trace("plane.velocity.x > 0 -> inversion");
				controlIsUp *= -1;
			}
			//	s'il recule, on passe en auto-looping
			else
			{
				//Lib.trace("plane.velocity.x < 0 -> passage en autolooping");
				autoLooping = true;
			}
		}
		
		//	fin de l'auto-looping
		if (autoLooping && plane.velocity.x > 0 && Math.abs(plane.velocity.y) < 0.25)
		{
			Lib.trace(autoLooping + "&&" + plane.velocity.x + ">0&&abs(" + plane.velocity.y + ")<50");
			Lib.trace("fin d'autolooping");
			autoLooping = false;
			controlIsUp *= -1;
		}
		
		var object:FlxObject = cast(plane, FlxObject);
		if (!object.isOnScreen())
		{
			gameOver();
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
		
		plane.velocity.x = plane.velocity.y = 0.0;
		
		add(gameOverLabel);
		
		FlxG.camera.shake(0.01, 0.5);
		
		//if(score 
	}
}