package flixel.system.macros;

import haxe.PosInfos;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import lime.utils.AssetType;

using StringTools;
using flixel.util.FlxArrayUtil;

class FlxAssetPaths
{
	public static function buildFileReferences(directory = "assets/", subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";

		Context.registerModuleDependency(Context.getLocalModule(), directory);

		var fileReferences = getFileReferences(directory, subDirectories, include, exclude, rename);
		var fields = Context.getBuildFields();

		for (fileRef in fileReferences)
		{
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
				pos: Context.currentPos()
			});
		}
		return fields;
	}

	static function getFileReferences(directory:String, subDirectories = false, ?include:EReg, ?exclude:EReg,
			?rename:String->Null<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if (ios || tvos) "../assets/" + directory #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo)
		{
			var path = resolvedPath + name;

			if (include != null && !include.match(path))
				continue;

			if (exclude != null && exclude.match(path))
				continue;

			if (!FileSystem.isDirectory(path))
			{
				// ignore invisible files
				if (name.startsWith("."))
					continue;

				var reference = FileReference.fromPath(path, rename);
				if (reference != null)
					addIfUnique(fileReferences, reference);
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, include, exclude, rename));
			}
		}

		return fileReferences;
	}
	

	public static function buildAllManifestReferences(?include:EReg, ?exclude:EReg, ?rename:String->Null<String>):Array<Field>
	{
		var fileReferences = getAllManifestReferences(include, exclude, rename);
		var fields = Context.getBuildFields();

		for (fileRef in fileReferences)
		{
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	static function getAllManifestReferences(?include:EReg, ?exclude:EReg, ?rename:String->Null<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var manifestFolder = getManifestFolder();
		
		checkForManifestsFolder();
		
		var directoryInfo = FileSystem.readDirectory(manifestFolder);
		var libraries:Array<String> = [];
		for (file in FileSystem.readDirectory(manifestFolder))
			getManifestReferences(Path.withoutExtension(file), include, exclude, rename, fileReferences);
		
		return fileReferences;
	}

	public static function buildManifestReferences(manifest:String, ?include:EReg, ?exclude:EReg, ?rename:String->Null<String>):Array<Field>
	{
		checkForManifestsFolder();
		var fileReferences = getManifestReferences(manifest, include, exclude, rename);
		var fields = Context.getBuildFields();
		
		for (fileRef in fileReferences)
		{
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	static function getManifestReferences(manifestId:String, ?include:EReg, ?exclude:EReg, ?rename:String->Null<String>, ?fileReferences:Array<FileReference>):Array<FileReference>
	{
		if (fileReferences == null)
			fileReferences = [];
		
		var path = getManifestFolder() + '$manifestId.json';
		var assets:Array<ManifestAsset> = haxe.Unserializer.run(haxe.Json.parse(File.getContent(path)).assets);
		for (asset in assets)
		{
			var id = asset.id;
			
			// hide flixel files
			if (id.startsWith("flixel/"))
				continue;
			
			if (include != null && !include.match(id))
				continue;
			
			if (exclude != null && exclude.match(id))
				continue;
			
			var reference = FileReference.fromPath(id, manifestId, rename);
			if (reference != null)
				addIfUnique(fileReferences, reference);
		}
		
		return fileReferences;
	}
	
	static function addIfUnique(fileReferences:Array<FileReference>, file:FileReference)
	{
		for (i in 0...fileReferences.length)
		{
			if (fileReferences[i].name == file.name)
			{
				var oldValue = fileReferences[i].value;
				// if the old file is nested deeper in the folder structure
				if (oldValue.split("/").length > file.value.split("/").length)
				{
					// replace it with the new one
					fileReferences[i] = file;
					warn('Duplicate files named "${file.name}" ignoring $oldValue');
				}
				else
				{
					warn('Duplicate files named "${file.name}" ignoring ${file.value}');
				}
				return;
			}
		}
		
		fileReferences.push(file);
	}
	
	static function checkForManifestsFolder()
	{
		var defines = "\n";
		for (name=>value in Context.getDefines())
			defines += '$name=>$value\n';
		
		// trace(defines);
		
		var folder = getManifestFolder();
		if (!FileSystem.exists(folder))
		{
			final target = FlxLimeMacroUtil.getTargetName();
			
			trace('Manifest missing, building assets target=$target folder=$folder');
			// Sys.command("haxelib",  ["run", "lime", "update", target]);
		}
		else
		{
			trace('Manifest found: $folder');
		}
	}
	
	public static function getManifestFolder()
	{
		var exportPath = Path.directory(Compiler.getOutput());
		#if windows
		exportPath = Path.normalize('$exportPath/../bin');
		#elseif mac
		final target = Context.definedValue("target.name");
		if (target == "cpp" || target == "neko")
		{
			final project = FlxLimeMacroUtil.getProjectXml();
			if (project == null)
				Context.error("Could not find Project.xml in project root", Context.currentPos());
			
			var fileName:String = null;
			for (app in project.elementsNamed("app"))
			{
				if (app.get("file") != null)
					fileName = app.get("file");
			}
			
			if (fileName != null)
				exportPath = Path.normalize('$exportPath/../bin/$fileName.app/Contents/Resources');
		}
		#end
		return exportPath + "/manifest/";
	}

	static inline function warn(msg:String, ?info:PosInfos)
	{
		haxe.Log.trace("[Warning] " + msg, info);
	}
}

private class FileReference
{
	static var valid = ~/^[_A-Za-z]\w*$/;

	public static function fromPath(value:String, ?library:String, ?rename:String->Null<String>):Null<FileReference>
	{
		var name = value;

		if (rename != null)
		{
			name = rename(name);
			// exclude null
			if (name == null)
				return null;
		}
		else
			name = value.split("/").pop();

		// replace some forbidden names to underscores, since variables cannot have these symbols.
		name = name.split("-").join("_").split(".").join("__");
		if (!valid.match(name)) // #1796
		{
			trace('[Warning] Invalid name: $name for file: $value');
			return null;
		}
		
		if (library != "default" && library != "" && library != null)
			value = '$library:$value';
		
		return new FileReference(name, value);
	}

	public var name(default, null):String;
	public var value(default, null):String;
	public var documentation(default, null):String;

	function new(name:String, value:String)
	{
		this.name = name;
		this.value = value;
		this.documentation = "`\"" + value + "\"` (auto generated).";
	}
}

typedef ManifestAsset = 
{
	var preload:Bool;
	var size:Int;
	var path:String;
	var id:String;
	var type:AssetType;
}