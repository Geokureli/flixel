package flixel.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

class FlxLimeMacroUtil
{
	public static function getTargetName()
	{
		return 
			#if macos "macos"
			#elseif html5 "html5"
			#else Context.definedValue("target.name")
			#end;
	}
}
#end