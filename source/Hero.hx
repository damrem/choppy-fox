package ;
import flixel.FlxSprite;

/**
 * ...
 * @author damrem
 */
class Hero extends FlxSprite
{
	inline static var MAX_SPEED:Float = 125.0;
	inline static var FRICTION:Float = 50.0;
	
	public function new() 
	{
		super();
		
		loadGraphic("assets/images/tails.png", true, false, 36, 36, true, 'hero');
		animation.add('up', [0, 1, 2], 10);
		animation.add('forward', [3, 4, 5], 10);
		animation.add('lose', [6, 7], 10);
		
		setOriginToCenter();
		
		width = height = 20;
		maxVelocity.x = MAX_SPEED;
		drag.x = FRICTION;
		centerOffsets();
		
		scrollFactor.y = 0;
	}
	
}