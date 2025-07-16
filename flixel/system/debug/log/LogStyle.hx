package flixel.system.debug.log;

import flixel.util.FlxSignal;
import haxe.PosInfos;

using flixel.util.FlxStringUtil;

/**
 * A class that allows you to create a custom style for `FlxG.log.advanced()`.
 * Also used internally for the pre-defined styles.
 */
class LogStyle
{
	// @formatter:off
	@:deprecated('LogStyle.NORMAL is deprecated, use FlxG.log.styles.NORMAL, instead')
	@:noCompletion
	public static var NORMAL(get, set):LogStyle;
	@:deprecated('LogStyle.WARNING is deprecated, use FlxG.log.styles.WARNING, instead')
	@:noCompletion
	public static var WARNING(get, set):LogStyle;
	@:deprecated('LogStyle.ERROR is deprecated, use FlxG.log.styles.ERROR, instead')
	@:noCompletion
	public static var ERROR(get, set):LogStyle;
	@:deprecated('LogStyle.NOTICE is deprecated, use FlxG.log.styles.NOTICE, instead')
	@:noCompletion
	public static var NOTICE(get, set):LogStyle;
	@:deprecated('LogStyle.CONSOLE is deprecated, use FlxG.log.styles.CONSOLE, instead')
	@:noCompletion
	public static var CONSOLE(get, set):LogStyle;
	
	@:noCompletion static inline function get_NORMAL() return FlxG.log.styles.NORMAL;
	@:noCompletion static inline function set_NORMAL(value:LogStyle) return FlxG.log.styles.NORMAL = value;
	
	@:noCompletion static inline function get_WARNING() return FlxG.log.styles.WARNING;
	@:noCompletion static inline function set_WARNING(value:LogStyle) return FlxG.log.styles.WARNING = value;
	
	@:noCompletion static inline function get_ERROR() return FlxG.log.styles.ERROR;
	@:noCompletion static inline function set_ERROR(value:LogStyle) return FlxG.log.styles.ERROR = value;
	
	@:noCompletion static inline function get_NOTICE() return FlxG.log.styles.NOTICE;
	@:noCompletion static inline function set_NOTICE(value:LogStyle) return FlxG.log.styles.NOTICE = value;
	
	@:noCompletion static inline function get_CONSOLE()return FlxG.log.styles.CONSOLE;
	@:noCompletion static inline function set_CONSOLE(value:LogStyle) return FlxG.log.styles.CONSOLE = value;
	// @formatter:on

	/**
	 * A prefix which is always attached to the start of the logged data
	 */
	public var prefix:String;

	public var color:String;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var underlined:Bool;

	/**
	 * A sound to be played when this LogStyle is used
	 */
	public var errorSound:String;

	/**
	 * Whether the console should be forced to open when this LogStyle is used
	 */
	public var openConsole:Bool;

	/**
	 * A callback function that is called when this LogStyle is used
	 */
	@:deprecated("callbackFunction is deprecated, use callback, instead")
	public var callbackFunction:()->Void;
	
	/**
	 * A callback function that is called when this LogStyle is used
	 * **Note:** Unlike the deprecated `callbackFunction`, this is called every time,
	 * even when logged with `once = true` and even in release mode.
	 */
	public final onLog = new FlxTypedSignal<(data:Any, ?pos:PosInfos) -> Void>();
	
	/**
	 * Whether an exception is thrown when this LogStyle is used.
	 * **Note**: Unlike other log style properties, this happens even in release mode.
	 * @since 5.4.0
	 */
	public var throwException:Bool = false;
	
	/**
	 * Create a new LogStyle to be used in conjunction with `FlxG.log.advanced()`
	 *
	 * @param   prefix            A prefix which is always attached to the start of the logged data
	 * @param   color             The text color
	 * @param   size              The text size
	 * @param   bold              Whether the text is bold or not
	 * @param   italic            Whether the text is italic or not
	 * @param   underlined        Whether the text is underlined or not
	 * @param   errorSound        A sound to be played when this LogStyle is used
	 * @param   openConsole       Whether the console should be forced to open when this LogStyle is used
	 * @param   callbackFunction  A callback function that is called when this LogStyle is used
	 * @param   callback          A callback function that is called when this LogStyle is used
	 * @param   throwError        Whether an error is thrown when this LogStyle is used
	 */
	 @:haxe.warning("-WDeprecated")
	public function new(prefix = "", color = "FFFFFF", size = 12, bold = false, italic = false, underlined = false,
			?errorSound:String, openConsole = false, ?callbackFunction:()->Void, ?callback:(Any, ?PosInfos)->Void, throwException = false)
	{
		this.prefix = prefix;
		this.color = color;
		this.size = size;
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
		this.errorSound = errorSound;
		this.openConsole = openConsole;
		this.callbackFunction = callbackFunction;
		if (callback != null)
			onLog.add(callback);
		this.throwException = throwException;
	}
	
	/**
	 * Converts the data into a log message according to this style.
	 * 
	 * @param   data  The data being logged
	 */
	public function toLogString(data:Array<Any>)
	{
		// Format FlxPoints, Arrays, Maps or turn the data entry into a String
		final texts = new Array<String>();
		for (i in 0...data.length)
		{
			final text = Std.string(data[i]);
			
			// Make sure you can't insert html tags
			texts.push(StringTools.htmlEscape(text));
		}
		
		return prefix + texts.join(" ");
	}
	
	/**
	 * Converts the data into an html log message according to this style.
	 * 
	 * @param   data  The data being logged
	 */
	public inline function toHtmlString(data:Array<Any>)
	{
		return toLogString(data).htmlFormat(size, color, bold, italic, underlined);
	}
}
