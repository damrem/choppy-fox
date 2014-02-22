package ;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.group.FlxTypedGroup.FlxTypedGroup;

/**
 * ...
 * @author damrem
 */
class LandscapeFactory
{	
	public static function createStalagmite(x:Float, height:Float=64):FlxSprite
	{
		var sprite = new FlxSprite();
		sprite.loadGraphic("assets/images/column.png", true, false, 64, 400, false, 'spikes');
		sprite.animation.add('spin', [0, 1, 2], 10);
		sprite.animation.play('spin');
		sprite.scrollFactor.y = 0;
		sprite.immovable = true;
		
		sprite.x = x;
		sprite.y = FlxG.height - height;
		
		return sprite;
	}
	
	public static function createStalactite(x:Float, height:Float=64):FlxSprite
	{
		var sprite = createStalagmite(x);
		sprite.angle = 180;
		sprite.y = height - sprite.height;
		return sprite;
	}
	
	public static function createJaw()
	{
		
	}
	
	public static function createSlide()
	{
		
	}
	
	public static function createDouble()
	{
		
	}
	
	
	
	
	
}