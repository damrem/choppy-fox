package ;
import flixel.FlxSprite;

/**
 * ...
 * @author damrem
 */
class Ring extends FlxSprite
{
	var targetTrap:Trap;
	public function new(TargetTrap:Trap) 
	{
		super();
		
		targetTrap = TargetTrap;
		
		scrollFactor.y = 0;
		loadGraphic("assets/images/ring.png", true, false, 16, 16);
		animation.add('spin', [0, 1, 2, 3], 10);
		animation.play('spin');
	}
	
	override public function update()
	{
		super.update();
		x = targetTrap.x + (targetTrap.width - width) / 2;
		y = targetTrap.y - height - 4;
	}
	
}