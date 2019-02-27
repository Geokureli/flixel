package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class TouchRecord
{
	public var id(default, null):Int;
	public var x(default, null):Null<Int>;
	public var y(default, null):Null<Int>;
	/**
	 * The state of the touch.
	 */
	public var state(default, null):Null<FlxInputState>;
	/**
	 * Whether this record has unresolved changes that persist to the next frame
	 */
	public var hasPersistantChanges(get, never):Bool;
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   id    The id of touch.
	 * @param   x     The main X value of the touch in screen space.
	 * @param   y     The main Y value of the touch in screen space.
	 * @param   state The state of the touch.
	 */
	public function new(id:Int, ?x:Int, ?y:Int, ?state:FlxInputState)
	{
		this.id = id;
		this.x = x;
		this.y = y;
		this.state = state;
	}
	
	inline function get_hasPersistantChanges():Bool
	{
		return state != null && state != RELEASED;
	}
	
	public function mergePreviousFrame(record:TouchRecord):Void
	{
		if (x == null) x = record.x;
		if (y == null) y = record.y;
		if (state == null) state = record.state;
	}
	
	public function toString():String
	{
		inline function toNullableString(value:Null<Int>):String
		{
			return value == null ? "" : Std.string(value);
		}
		return id + ";" + toNullableString(x) + ";" + toNullableString(y) + ";" + toNullableString(cast state);
	}
	
	static function fromString(data:String):Null<TouchRecord>
	{
		var touch = data.split(";");
		if (touch.length == 4)
		{
			inline function parseInt(data:String):Null<Int> 
			{
				return data == "" ? null : Std.parseInt(data);
			}
			
			return new TouchRecord
			(
				parseInt(touch[0]),
				parseInt(touch[1]),
				parseInt(touch[2]),
				parseInt(touch[3])
			);
		}
		return null;
	}
	
	public static function arrayFromString(data:String):Null<Array<TouchRecord>>
	{
		var array = data.split(",");
		var list:Null<Array<TouchRecord>> = null;
		var i = 0;
		var l = array.length;
		while (i < l)
		{
			var touch = fromString(array[i++]);
			if (touch != null)
			{
				if (list == null)
				{
					list = [];
				}
				list.push(touch);
			}
		}
		return list;
	}
	
	public static function arrayToString(touches:Array<TouchRecord>):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = touches.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += ",";
			}
			output += touches[i++].toString();
		}
		return output;
	}
	
	/**
	 * Copies all active touch data from the previous frame unless the current touch data overrides it
	 * @param newTouches List of all unique touch changes from the current frame
	 * @param oldTouches List of all unique touch changes from the previous frame
	 */
	public static function mergePreviousArray(newTouches:Null<Array<TouchRecord>>, oldTouches:Array<TouchRecord>):Null<Array<TouchRecord>>
	{
		// Create lookup
		var map:Map<Int, TouchRecord>  = new Map();
		
		for(touch in newTouches)
		{
			map[touch.id] = touch;
		}
		
		for(touch in oldTouches)
		{
			// merge previous state's touch data 
			if(touch.hasPersistantChanges)
			{
				if (newTouches == null)
				{
					newTouches = [];
				}
				
				if (map.exists(touch.id))
					map[touch.id].mergePreviousFrame(touch);
				else
					newTouches.push(touch);
			}
		}
		
		return newTouches;
	}
}