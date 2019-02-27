package flixel.input.touch;

#if FLX_TOUCH
import flash.events.TouchEvent;
import flash.geom.Point;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.FlxSwipe;
import flixel.input.IFlxInput;
import flixel.math.FlxPoint;
import flixel.system.replay.TouchRecord;
import flixel.util.FlxDestroyUtil;

/**
 * Helper class, contains and tracks touch points in your game.
 * Automatically accounts for parallax scrolling, etc.
 */
@:allow(flixel.input.touch.FlxTouchManager)
class FlxTouch extends FlxPointer implements IFlxDestroyable implements IFlxInput
{	
	/**
	 * The _unique_ ID of this touch. You should not make not any further assumptions
	 * about this value - IDs are not guaranteed to start from 0 or ascend in order.
	 * The behavior may vary from device to device.
	 */
	public var touchPointID(get, never):Int;
	
	public var justReleased(get, never):Bool;
	public var released(get, never):Bool;
	public var pressed(get, never):Bool;
	public var justPressed(get, never):Bool;
	
	var input:FlxInput<Int>;
	var flashPoint = new Point();
	
	public var justPressedPosition(default, null) = FlxPoint.get();
	public var justPressedTimeInTicks(default, null):Int = -1;

	/**
	 * Helper variables for recording purposes.
	 */
	var _lastX:Int = 0;
	var _lastY:Int = 0;
	
	public function destroy():Void
	{
		input = null;
		justPressedPosition = FlxDestroyUtil.put(justPressedPosition);
		flashPoint = null;
	}

	/**
	 * Resets the justPressed/justReleased flags and sets touch to not pressed.
	 */
	public function recycle(x:Int, y:Int, pointID:Int):Void
	{
		setXY(x, y);
		input.ID = pointID;
		input.reset();
	}
	
	/**
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageX touch coordinate
	 * @param	PointID		touchPointID of the touch
	 */
	function new(x:Int = 0, y:Int = 0, pointID:Int = 0)
	{
		super();
		
		input = new FlxInput(pointID);
		setXY(x, y);
	}
	
	/**
	 * Called by the internal game loop to update the just pressed/just released flags.
	 */
	function update():Void
	{
		input.update();
		
		if (justPressed)
		{
			justPressedPosition.set(screenX, screenY);
			justPressedTimeInTicks = FlxG.game.ticks;
		}
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, justPressedPosition, getScreenPosition(), justPressedTimeInTicks));
		}
		#end
	}
	
	/**
	 * Function for updating touch coordinates. Called by the TouchManager.
	 * 
	 * @param	X	stageX touch coordinate
	 * @param	Y	stageY touch coordinate
	 */
	function setXY(X:Int, Y:Int):Void
	{
		flashPoint.setTo(X, Y);
		flashPoint = FlxG.game.globalToLocal(flashPoint);
		
		setGlobalScreenPositionUnsafe(flashPoint.x, flashPoint.y);
	}
	
	inline function get_touchPointID():Int
	{
		return input.ID;
	}
	
	inline function get_justReleased():Bool
	{
		return input.justReleased;
	}
	
	inline function get_released():Bool
	{
		return input.released;
	}
	
	inline function get_pressed():Bool
	{
		return input.pressed;
	}
	
	inline function get_justPressed():Bool
	{
		return input.justPressed;
	}
	
	@:access(flixel.input.FlxInput.last)
	function record():Null<TouchRecord>
	{
		if (_lastX == _globalScreenX && _lastY == _globalScreenY && input.last == input.current)
		{
			return null;
		}
		
		inline function getChange<T>(value:T, lastValue:T):Null<T>
		{
			return value == lastValue ? null : value;
		}
		var record:TouchRecord = new TouchRecord
		(
			touchPointID,
			getChange(_globalScreenX, _lastX),
			getChange(_globalScreenY, _lastY),
			getChange(input.current, input.last)
		);
		
		_lastX = _globalScreenX;
		_lastY = _globalScreenY;
		input.last = input.current;
		return record;
	}
	
	@:access(flixel.input.FlxInput.last)
	function playback(record:TouchRecord):Void
	{
		if (record.x != null || record.y != null)
		{
			if (record.x != null) _globalScreenX = record.x;
			if (record.y != null) _globalScreenY = record.y;
			updatePositions();
		}
		
		if (record.state != null)
		{
			// Manually dispatch a touch event so that, e.g., FlxButtons click correctly on playback.
			// Note: some clicks are fast enough to not pass through a frame where they are PRESSED
			// and JUST_RELEASED is swallowed by FlxButton and others, but not third-party code
			if ((input.last == PRESSED || input.last == JUST_PRESSED)
				&& (record.state == RELEASED || record.state == JUST_RELEASED))
			{
				FlxG.stage.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_END, true, false, record.id, false, _globalScreenX, _globalScreenY));
			}
			
			input.last = input.current = record.state;
		}
		
		// Copied from update()
		if (justPressed)
		{
			justPressedPosition.set(screenX, screenY);
			justPressedTimeInTicks = FlxG.game.ticks;
		}
		#if FLX_POINTER_INPUT
		else if (justReleased)
		{
			FlxG.swipes.push(new FlxSwipe(touchPointID, justPressedPosition, getScreenPosition(), justPressedTimeInTicks));
		}
		#end
	}
}
#else
class FlxTouch {}
#end
