package ;
import flixel.util.FlxPoint;
import flixel.util.FlxAngle;
/**
 * ...
 * @author damrem
 */
class FlxVector
{
	
	
	public static function rotateVector(vector:FlxPoint, angle_deg:Float):FlxPoint
	{
		var angle_rad:Float = FlxAngle.asRadians(angle_deg);
		
		var s:Float = Math.sin(angle_rad);
        var c:Float = Math.cos(angle_rad);
        return new FlxPoint(vector.x * c - vector.y * s, vector.x * s + vector.y * c);
	}
	
	public static function getAngleDeg(vector:FlxPoint):Float
	{
		
	}
}