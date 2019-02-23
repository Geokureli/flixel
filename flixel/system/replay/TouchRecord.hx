package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class TouchRecord
{
	public var id(default, null):Int;
	
	public var x(default, null):Int;
	public var y(default, null):Int;
	/**
	 * The state of the touch.
	 */
	public var state(default, null):FlxInputState;
	
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   X        The main X value of the mouse in screen space.
	 * @param   Y        The main Y value of the mouse in screen space.
	 * @param   Button   The state of the left mouse button.
	 * @param   Wheel    The state of the mouse wheel.
	 */
	public function new(id:Int, x:Int, y:Int, state:FlxInputState)
	{
		this.id = id;
		this.x = x;
		this.y = y;
		this.state = state;
	}
}