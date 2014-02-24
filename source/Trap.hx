package ;
import flixel.FlxSprite;

/**
 * ...
 * @author damrem
 */
class Trap extends FlxSprite
{
	public static inline var STATIC:String = 'static';
	public static inline var HORIZONTAL:String = 'horizontal';
	public static inline var VERTICAL:String = 'vertical';
	
	public var type:String;
	
	public var originalX:Float;
	public var xRange:Float;
	
	public var originalY:Float;
	public var yRange:Float;
	
	public var speed:Float;
	
	public function new(X:Float, Y:Float, XRange:Float=0, YRange:Float=0, Speed:Float=0) 
	{
		super();
		
		x = originalX = X;
		y = originalY = Y;
		xRange = XRange;
		yRange = YRange;
		speed = Speed;
		velocity.x = velocity.y = speed;
		
		loadGraphic("assets/images/column.png", true, false, 64, 400, false, 'spikes');
		animation.add('spin', [0, 1, 2], 10);
		animation.play('spin');
		width = 48;
		centerOffsets();
		scrollFactor.y = 0;
		immovable = true;
	}
	
	override public function update()
	{
		super.update();
		if ((x < originalX - xRange / 2) || (x > originalX + xRange / 2))
		{
			velocity.x *= -1;
		}
		if ((y < originalY - yRange / 2) || (y > originalY + yRange / 2))
		{
			velocity.y *= -1;
		}
	}
	
}