package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class MouseRecord
{
	public var x(default, null):Null<Int>;
	public var y(default, null):Null<Int>;
	/**
	 * The state of the left mouse button.
	 */
	public var leftButton(default, null):Null<FlxInputState>;
	/**
	 * The state of the middle mouse button.
	 */
	public var middleButton(default, null):Null<FlxInputState>;
	/**
	 * The state of the right mouse button.
	 */
	public var rightButton(default, null):Null<FlxInputState>;
	/**
	 * The state of the mouse wheel.
	 */
	public var wheel(default, null):Null<Int>;
	
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   x            The main X value of the mouse in screen space.
	 * @param   y            The main Y value of the mouse in screen space.
	 * @param   leftButton   The state of the left mouse button.
	 * @param   middleButton The state of the middle mouse button.
	 * @param   rightButton  The state of the right mouse button.
	 * @param   Wheel        The state of the mouse wheel.
	 */
	public function new(?x:Int, ?y:Int, ?leftButton:FlxInputState, ?middleButton:FlxInputState, ?rightButton:FlxInputState, ?wheel:Int)
	{
		this.x = x;
		this.y = y;
		this.leftButton = leftButton;
		this.middleButton = middleButton;
		this.rightButton = rightButton;
		this.wheel = wheel;
	}
	
	public function toString():String
	{
		inline function intToString(value:Null<Int>):String
		{
			return value == null ? "" : Std.string(value);
		}
		return intToString(x)
			+ "," + intToString(y)
			+ "," + intToString(cast leftButton)
			+ "," + intToString(cast middleButton)
			+ "," + intToString(cast rightButton)
			+ "," + intToString(wheel);
	}
	
	public static function fromString(data:String):Null<MouseRecord>
	{
		var mouse = data.split(",");
		if (mouse.length == 6)
		{
			inline function parseInt(data:String):Null<Int> 
			{
				return data == "" ? null : Std.parseInt(data);
			}
			return new MouseRecord
			(
				parseInt(mouse[0]),// x
				parseInt(mouse[1]),// y
				parseInt(mouse[2]),// left
				parseInt(mouse[3]),// middle
				parseInt(mouse[4]),// right
				parseInt(mouse[5]) // wheel
			);
		}
		return null;
	}
	
}