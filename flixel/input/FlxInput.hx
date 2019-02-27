package flixel.input;

class FlxInput<T> implements IFlxInput
{
	public var ID:T;
	
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	
	public var current:FlxInputState = RELEASED;
	/**
	 * Whether the `JUST_PRESSED` or `JUST_RELEASED` was processed
	 */
	var waitedFrame:Bool = false;
	/**
	 * Helper variable for recording purposes.
	 */
	var last:FlxInputState = RELEASED;
	
	public function new(ID:T) 
	{
		this.ID = ID;
	}
	
	public function press():Void
	{
		waitedFrame = false;
		current = pressed ? PRESSED : JUST_PRESSED;
	}
	
	public function release():Void
	{
		waitedFrame = false;
		current = pressed ? JUST_RELEASED: RELEASED;
	}
	
	public function update():Void
	{
		if (current == JUST_RELEASED && waitedFrame) 
		{
			current = RELEASED;
		}
		else if (current == JUST_PRESSED && waitedFrame)
		{
			current = PRESSED;
		}
		
		waitedFrame = true;
	}
	
	public function reset():Void
	{
		current = RELEASED;
		last = RELEASED;
		waitedFrame = false;
	}
	
	public function hasState(state:FlxInputState):Bool
	{
		return switch (state)
		{
			case JUST_RELEASED: justReleased;
			case RELEASED:      released;
			case PRESSED:       pressed;
			case JUST_PRESSED:  justPressed;
		}
	}
	
	inline function get_justReleased():Bool
	{
		return current == JUST_RELEASED;
	}
	
	inline function get_released():Bool
	{
		return current == RELEASED || justReleased;
	}
	
	inline function get_pressed():Bool
	{
		return current == PRESSED || justPressed;
	}
	
	inline function get_justPressed():Bool
	{
		return current == JUST_PRESSED;
	}
}

@:enum
abstract FlxInputState(Int) from Int
{
	var JUST_RELEASED = -1;
	var RELEASED      =  0;
	var PRESSED       =  1;
	var JUST_PRESSED  =  2;
}