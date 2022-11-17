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

		// create new fields based on file references!
		for (fileRef in fileReferences)
			fields.push(fileRef.createField());
		
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

		// create new fields based on file references!
		for (fileRef in fileReferences)
			fields.push(fileRef.createField());
		
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
		
		// create new fields based on file references!
		for (fileRef in fileReferences)
			fields.push(fileRef.createField());
		
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
					Context.warning('Duplicate files named "${file.name}" ignoring $oldValue', Context.currentPos());
				}
				else
				{
					Context.warning('Duplicate files named "${file.name}" ignoring ${file.value}', Context.currentPos());
				}
				return;
			}
		}
		
		fileReferences.push(file);
	}
	
	static function checkForManifestsFolder()
	{
		var folder = getManifestFolder();
		Context.registerModuleDependency(Context.getLocalModule(), folder);
		if (!FileSystem.exists(folder))
		{
			Context.error(
				'Manifest missing, try building to see manifest assets.\nManifest path:"$folder"',
				Context.currentPos()
			);
		}
	}
	
	/**
	 * Runs lime update, with the same compiler flags passed into the lime display, to rebuild the
	 * manifest. Currently never used.
	 */
	static function updateManifest()
	{
		final target = FlxLimeMacroUtil.getTargetName();
		final defines = Context.getDefines();
		var args = ["run", "lime", "update", target];
		for (flag in defines.keys())
		{
			final value = defines[flag];
			args.push('-D$flag=$value');
		}
		Context.info('Manifest missing, building assets', Context.currentPos());
		Sys.command("haxelib", args);
	}
	
	public static function getManifestFolder()
	{
		var exportPath = Path.directory(Compiler.getOutput());
		#if windows
		exportPath = Path.normalize('$exportPath/../bin');
		#elseif mac
		final target = Context.definedValue("target.name");
		if (target == "cpp" || target == "neko" || target == "hl")
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
			Context.warning('Invalid name: $name for file: $value', Context.currentPos());
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
	
	public function createField():Field
	{
		return {
			name: name,
			doc: documentation,
			access: [Access.APublic, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro:String, macro $v{value}),
			pos: Context.currentPos()
		};
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