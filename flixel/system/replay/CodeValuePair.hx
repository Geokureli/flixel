package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

class CodeValuePair
{
	public var code:Int;
	public var value:FlxInputState;
	
	public function new(code:Int, value:FlxInputState)
	{
		this.code = code;
		this.value = value;
	}
	
	public function toString():String
	{
		return code + ":" + value;
	}
	
	public static function fromString(data:String):Null<CodeValuePair>
	{
		var keyPair = data.split(":");
		if (keyPair.length == 2)
		{
			return new CodeValuePair(Std.parseInt(keyPair[0]), Std.parseInt(keyPair[1]));
		}
		return null;
	}
	
	public static inline function arrayFromString(data:String):Null<Array<CodeValuePair>>
	{
		var keys:Null<Array<CodeValuePair>> = null;
		var list = data.split(",");
		
		var i = 0;
		var l = list.length;
		while (i < l)
		{
			var key = CodeValuePair.fromString(list[i++]);
			if (key != null)
			{
				if (keys == null)
				{
					keys = [];
				}
				keys.push(key);
			}
		}
		return keys;
	}
	
	public static function arrayToString(keys:Array<CodeValuePair>):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = keys.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += ",";
			}
			output += keys[i++].toString();
		}
		
		return output;
	}
	
	/**
	 * Copies all active key data from the previous frame unless the current key data overrides it
	 * @param newKeys List of all unique key changes from the current frame
	 * @param oldKeys List of all unique key changes from the previous frame
	 */
	public static function mergePreviousArray(newKeys:Array<CodeValuePair>, oldKeys:Array<CodeValuePair>):Void
	{
		// Create lookup
		var usedKeys:Array<Int> = [];
		
		var i = 0;
		var l = newKeys.length;
		while (i < l)
		{
			usedKeys.push(newKeys[i++].code);
		}
		
		i = 0;
		l = oldKeys.length;
		//use the previous frame's key state if there is no change
		while (i < l)
		{
			var key = oldKeys[i++];
			if (key.value != RELEASED && usedKeys.indexOf(key.code) == -1)
			{
				newKeys.push(key);
			}
		}
	}
}