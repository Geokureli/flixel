package flixel.system.replay;

/**
 * Helper class for the new replay system.  Represents all the game inputs for one "frame" or "step" of the game loop.
 */
class FrameRecord
{
	/**
	 * Which frame of the game loop this record is from or for.
	 */
	public var frame:Int;
	/**
	 * An array of simple integer pairs referring to what key is pressed, and what state its in.
	 */
	public var keys:Array<CodeValuePair>;
	/**
	 * A container for the mouse state values.
	 */
	public var mouse:MouseRecord;
	/**
	 * An array of touch states.
	 */
	public var touches:Array<TouchRecord>;
	
	/**
	 * Instantiate array new frame record.
	 */
	public function new()
	{
		frame = 0;
		keys = null;
		mouse = null;
	}
	
	/**
	 * Load this frame record with input data from the input managers.
	 * @param Frame		What frame it is.
	 * @param Keys		Keyboard data from the keyboard manager.
	 * @param Mouse		Mouse data from the mouse manager.
	 * @return A reference to this FrameRecord object.
	 */
	public function create(Frame:Float, ?Keys:Array<CodeValuePair>, ?Mouse:MouseRecord, ?Touches:Array<TouchRecord>):FrameRecord
	{
		frame = Math.floor(Frame);
		keys = Keys;
		mouse = Mouse;
		touches = Touches;
		
		return this;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		keys = null;
		mouse = null;
	}
	
	/**
	 * Save the frame record data to array simple ASCII string.
	 * @return	A String object containing the relevant frame record data.
	 */
	public function save():String
	{
		var output:String = frame + "k";
		
		if (keys != null)
		{
			var object:CodeValuePair;
			var i:Int = 0;
			var l:Int = keys.length;
			while (i < l)
			{
				if (i > 0)
				{
					output += ",";
				}
				object = keys[i++];
				output += object.code + ":" + object.value;
			}
		}
		
		output += "m";
		if (mouse != null)
		{
			output += mouse.x + "," + mouse.y + "," + mouse.button + "," + mouse.wheel;
		}
		
		
		output += "t";
		if (touches != null)
		{
			var touch:TouchRecord;
			var i:Int = 0;
			var l:Int = touches.length;
			while (i < l)
			{
				if (i > 0)
				{
					output += ",";
				}
				touch = touches[i++];
				output += touch.id + ";" + touch.x + ";" + touch.y + ";" + touch.state;
			}
		}
		
		return output;
	}
	
	/**
	 * Load the frame record data from array simple ASCII string.
	 * @param	Data	A String object containing the relevant frame record data.
	 */
	public function load(Data:String):FrameRecord
	{
		var i:Int;
		var l:Int;
		
		//get frame number
		var array:Array<String> = Data.split("k");
		frame = Std.parseInt(array[0]);
		
		//split up keyboard and mouse data
		array = array[1].split("m");
		var keyData:String = array[0];
		array = array[1].split("t");
		var mouseData:String = array[0];
		var touchData:String = array[1];
		
		//parse keyboard data
		if (keyData.length > 0)
		{
			//get keystroke data pairs
			array = keyData.split(",");
			
			//go through each data pair and enter it into this frame's key state
			var keyPair:Array<String>;
			i = 0;
			l = array.length;
			while (i < l)
			{
				keyPair = array[i++].split(":");
				if (keyPair.length == 2)
				{
					if (keys == null)
					{
						keys = new Array<CodeValuePair>();
					}
					keys.push(new CodeValuePair(Std.parseInt(keyPair[0]), Std.parseInt(keyPair[1])));
				}
			}
		}
		
		//mouse data is just 4 integers, easy peezy
		if (mouseData.length > 0)
		{
			array = mouseData.split(",");
			if (array.length >= 4)
			{
				mouse = new MouseRecord(Std.parseInt(array[0]), Std.parseInt(array[1]), Std.parseInt(array[2]), Std.parseInt(array[3]));
			}
		}
		
		//mouse data is just 4 integers, easy peezy
		if (touchData.length > 0)
		{
			array = touchData.split(",");
			i = 0;
			l = array.length;
			while (i < l)
			{
				var touch = array[i++].split(";");
				if (touch.length >= 4)
				{
					if (touches == null)
					{
						touches = new Array<TouchRecord>();
					}
					touches.push(new TouchRecord(Std.parseInt(touch[0]), Std.parseInt(touch[1]), Std.parseInt(touch[2]), Std.parseInt(touch[3])));
				}
			}
		}
		return this;
	}
}