package flixel.system.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using haxe.macro.Tools;

class FlxLimeMacroUtil
{
	public static function getTargetName()
	{
		// Todo: check all targets
		return 
			#if macos "macos"
			#elseif html5 "html5"
			#else Context.definedValue("target.name")
			#end;
	}
	
	public static function getProjectXml()
	{
		final projectPath = "Project.xml";
		if (FileSystem.exists(projectPath))
			return Xml.parse(File.getContent(projectPath)).firstElement();
		// Todo: check other locations
		return null;
	}
}
#end