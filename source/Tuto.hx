package ;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxSave;

/**
 * ...
 * @author damrem
 */
class Tuto extends FlxSpriteGroup
{

	public function new() 
	{
		super();
		
		var bg:FlxSprite = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
		bg.alpha = 0.75;
		add(bg);
		
		var x1:Float = FlxG.width / 4;
		var x2:Float = FlxG.width * 3 / 4;
		var w:Int = 200;
		var Y:Float = FlxG.height / 3;
		
		var up:Hero = new Hero();
		up.animation.play('up');
		up.x = x1;
		up.y = Y - up.height;
		add(up);
		
		var upLabel:FlxText = new FlxText(x1 - w / 2, Y, w, "Press to fly up.", 16);
		upLabel.alignment = 'center';
		upLabel.scrollFactor.x = upLabel.scrollFactor.y = 0.0;
		add(upLabel);
		
		var forw:Hero = new Hero();
		forw.animation.play('forward');
		forw.x = x2;
		forw.y = Y - forw.height;
		add(forw);
		
		var forwLabel:FlxText = new FlxText(x2 -w / 2, Y, w, "Release to move forward.", 16);
		forwLabel.alignment = 'center';
		forwLabel.scrollFactor.x = forwLabel.scrollFactor.y = 0.0;
		add(forwLabel);
	}
	
}