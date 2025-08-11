package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.debug.log.LogStyle;
import haxe.PosInfos;

/**
 * Accessed via `FlxG.log`.
 */
class LogFrontEnd
{
	/**
	 * Whether everything you trace() is being redirected into the log window.
	 */
	public var redirectTraces(default, set):Bool = false;

	public final styles = new LogFrontEndStyles();
	
	var _standardTraceFunction:(Dynamic, ?PosInfos)->Void;
	
	public inline function add(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.NORMAL, false, pos);
	}
	
	public inline function warn(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.WARNING, true, pos);
	}
	
	public inline function error(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.ERROR, true, pos);
	}
	
	public inline function notice(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.NOTICE, false, pos);
	}
	
	/**
	 * Add an advanced log message to the debugger by also specifying a LogStyle. Backend to FlxG.log.add(), FlxG.log.warn(), FlxG.log.error() and FlxG.log.notice().
	 *
	 * @param   data      Any Data to log.
	 * @param   style     The LogStyle to use, for example LogStyle.WARNING. You can also create your own by importing the LogStyle class.
	 * @param   fireOnce  Whether you only want to log the Data in case it hasn't been added already
	 */
	@:haxe.warning("-WDeprecated")
	public function advanced(data:Any, ?style:LogStyle, fireOnce = false, ?pos:PosInfos):Void
	{
		if (style == null)
			style = styles.NORMAL;
		
		final arrayData = (!(data is Array) ? [data] : cast data);
		
		#if FLX_DEBUG
		// Check null game since `FlxG.save.bind` may be called before `new FlxGame`
		if (FlxG.game == null || FlxG.game.debugger == null)
		{
			_standardTraceFunction(arrayData);
		}
		else if (FlxG.game.debugger.log.add(arrayData, style, fireOnce))
		{
			#if (FLX_SOUND_SYSTEM && !FLX_UNIT_TEST)
			if (style.errorSound != null)
			{
				final sound = FlxAssets.getSoundAddExtension(style.errorSound);
				if (sound != null)
					FlxG.sound.load(sound).play();
			}
			#end
			
			if (style.openConsole)
				FlxG.debugger.visible = true;
			
			if (style.callbackFunction != null)
				style.callbackFunction();
		}
		#end
		
		style.onLog.dispatch(data, pos);
		
		if (style.throwException)
			throw style.toLogString(arrayData);
	}

	/**
	 * Clears the log output.
	 */
	public inline function clear():Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.log.clear();
		#end
	}

	@:allow(flixel.FlxG)
	function new()
	{
		_standardTraceFunction = haxe.Log.trace;
	}

	inline function set_redirectTraces(redirect:Bool):Bool
	{
		haxe.Log.trace = (redirect) ? processTraceData : _standardTraceFunction;
		return redirectTraces = redirect;
	}

	/**
	 * Internal function used as a interface between trace() and add().
	 *
	 * @param   data  The data that has been traced
	 * @param   info  Information about the position at which trace() was called
	 */
	function processTraceData(data:Any, ?info:PosInfos):Void
	{
		var paramArray:Array<Any> = [data];

		if (info.customParams != null)
		{
			for (i in info.customParams)
			{
				paramArray.push(i);
			}
		}

		advanced(paramArray, FlxG.log.styles.NORMAL);
	}
}

/**
 * Allows global access to the various log styles. Styles are `NORMAL`, `NOTICE`, `WARNING`,
 * `ERROR` and `CONSOLE`. Each style's behavior can be changed at runtime. There are also
 * compiler flags: `FLX_LOG_LEVEL_THROW`, `FLX_LOG_LEVEL_OPEN` and `FLX_LOG_LEVEL_BEEP` to
 * determine which levels will throw errors, open the console and beep, set these flags to:
 * `error`, `warning`, `notice`, `normal` or `none` so that the given level **and all higher
 * priorities** will be set.
 */
class LogFrontEndStyles
{
	static inline var DEFAULT_BEEP_SOUND = "flixel/sounds/beep";
	
	/** The lowest severity message style. By default, doesn't open the console or beep */
	public var NORMAL:LogStyle = new LogStyle();
	
	/** A low severity message style. By default, doesn't open the console or beep */
	public var NOTICE:LogStyle = new LogStyle("[NOTICE] ", "5CF878");
	
	/** Logged when something unexpected but safe happens. By default, opens the console and beeps */
	public var WARNING:LogStyle = new LogStyle("[WARNING] ", "D9F85C");
	
	/** Logged when something unsafe happens. By default, opens the console and beeps */
	public var ERROR:LogStyle = new LogStyle("[ERROR] ", "FF8888");
	
	/** Used internally by Flixel's console debugging tool */
	public var CONSOLE:LogStyle = new LogStyle("> ", "5A96FA");
	
	public function new()
	{
		final styles = [this.ERROR, this.WARNING, this.NOTICE, this.NORMAL];
		final levels = [Level.ERROR, Level.WARNING, Level.NOTICE, Level.NORMAL, Level.NONE];
		
		inline function getIndex(level:String)
		{
			return levels.indexOf(level.toLowerCase());
		}
		
		inline function assertIndex(level:String)
		{
			final levelValid = level.toLowerCase();
			if (!levels.contains(levelValid))
				throw 'Invalid level: $level';
			
			return levels.indexOf(levelValid.toLowerCase());
		}
		
		inline function forEachLevel(level:Int, func:(LogStyle)->Void)
		{
			for (i in level...styles.length)
				func(styles[i]);
		}
		
		inline function forEachStyleBackup(flag:String, backup:Level, func:(LogStyle)->Void)
		{
			final index = getIndex(flag);
			forEachLevel(index < 0 ? assertIndex(backup) : index, func);
		}
		
		final levelThrow = '${haxe.macro.Compiler.getDefine("FLX_LOG_LEVEL_THROW")}';
		final levelOpen = '${haxe.macro.Compiler.getDefine("FLX_LOG_LEVEL_OPEN")}';
		final levelBeep = '${haxe.macro.Compiler.getDefine("FLX_LOG_LEVEL_BEEP")}';
		
		forEachStyleBackup(levelThrow, Level.ERROR, (style)->style.throwException = true);
		forEachStyleBackup(levelOpen, Level.WARNING, (style)->style.openConsole = true);
		forEachStyleBackup(levelBeep, Level.WARNING, (style)->style.errorSound = DEFAULT_BEEP_SOUND);
	}
}

private enum abstract Level(String) to String from String
{
	var ERROR = "error";
	var WARNING = "warning";
	var NORMAL = "normal";
	var NOTICE = "info";
	var NONE = "none";
}