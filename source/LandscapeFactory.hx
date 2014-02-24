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
	public static function createStalagmite(x:Float, height:Float=64, xRange:Float=0, yRange:Float=0, speed:Float=0):Trap
	{
		var trap = new Trap(x, FlxG.height - height, xRange, yRange, speed);
		return trap;
	}
	/*
	public static function createStalactite(x:Float, height:Float=64, xRange:Float=0, yRange:Float=0, speed:Float=0):FlxSprite
	{
		var trap = createStalagmite(x, height - 400, xRange, yRange, speed);
		trap.angle = 180;
		return trap;
	}
	*/
}