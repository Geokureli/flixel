package flixel.input;

import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;

class FlxPointer
{
	/** The position in world-space when converted via FlxG.camera */
	public var x(default, null):Int = 0;
	/** The position in world-space when converted via FlxG.camera */
	public var y(default, null):Int = 0;

	/** The position in FlxG.camera's screen-space */
	public var screenX(default, null):Int = 0;
	/** The position in FlxG.camera's screen-space */
	public var screenY(default, null):Int = 0;

	/** The raw position in the application's window */
	public var windowX(default, null):Int = 0;
	/** The raw position in the application's window */
	public var windowY(default, null):Int = 0;

	@:deprecated("_globalScreenX is deprecated, use windowX")
	var _globalScreenX(get, set):Int;
	@:deprecated("_globalScreenY is deprecated, use windowY")
	var _globalScreenY(get, set):Int;

	static var _cachedPoint:FlxPoint = new FlxPoint();

	public function new() {}

	/**
	 * Fetch the world position of the pointer on any given camera.
	 * NOTE: x and y also store the world position of the pointer on the main camera.
	 *
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point	An existing point object to store the results (if you don't want a new one created).
	 * @return 	The touch point's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}
		getScreenPosition(Camera, _cachedPoint);
		point.x = _cachedPoint.x + Camera.scroll.x;
		point.y = _cachedPoint.y + Camera.scroll.y;
		return point;
	}

	/**
	 * Fetch the screen position of the pointer on any given camera.
	 * NOTE: screenX and screenY also store the screen position of the pointer on the main camera.
	 *
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point		An existing point object to store the results (if you don't want a new one created).
	 * @return 	The touch point's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}

		point.x = (windowX - Camera.x + 0.5 * Camera.width * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;
		point.y = (windowY - Camera.y + 0.5 * Camera.height * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;

		return point;
	}

	/**
	 * Fetch the screen position of the pointer relative to given camera's viewport.
	 *
	 * @param 	Camera		If unspecified, first/main global camera is used instead.
	 * @param 	point		An existing point object to store the results (if you don't want a new one created).
	 * @return 	The touch point's location relative to camera's viewport.
	 */
	@:access(flixel.FlxCamera)
	public function getPositionInCameraView(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
			Camera = FlxG.camera;

		if (point == null)
			point = FlxPoint.get();

		point.x = (windowX - Camera.x) / Camera.zoom + Camera.viewMarginX;
		point.y = (windowY - Camera.y) / Camera.zoom + Camera.viewMarginY;

		return point;
	}

	/**
	 * Returns a FlxPoint with this input's x and y.
	 */
	public function getPosition(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(x, y);
	}

	/**
	 * Checks to see if some FlxObject overlaps this FlxObject or FlxGroup.
	 * If the group has a LOT of things in it, it might be faster to use FlxG.overlaps().
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param 	ObjectOrGroup The object or group being tested.
	 * @param 	Camera Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return 	Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function overlaps(ObjectOrGroup:FlxBasic, ?Camera:FlxCamera):Bool
	{
		var result:Bool = false;

		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null)
		{
			group.forEachExists(function(basic:FlxBasic)
			{
				if (overlaps(basic, Camera))
				{
					result = true;
					return;
				}
			});
		}
		else
		{
			getPosition(_cachedPoint);
			var object:FlxObject = cast ObjectOrGroup;
			result = object.overlapsPoint(_cachedPoint, true, Camera);
		}

		return result;
	}

	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	@:deprecated("setGlobalScreenPositionUnsafe is deprecated, use setWindowPositionUnsafe")
	public inline function setGlobalScreenPositionUnsafe(newX:Float, newY:Float):Void
	{
		setWindowPositionUnsafe(newX, newY);
	}

	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	public inline function setWindowPositionUnsafe(newX:Float, newY:Float):Void
	{
		windowX = Std.int(newX / FlxG.scaleMode.scale.x);
		windowY = Std.int(newY / FlxG.scaleMode.scale.y);

		updatePositions();
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("x", x), LabelValuePair.weak("y", y)]);
	}

	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, screenX, and screenY variables based on the default camera.
	 */
	function updatePositions():Void
	{
		getScreenPosition(FlxG.camera, _cachedPoint);
		screenX = Std.int(_cachedPoint.x);
		screenY = Std.int(_cachedPoint.y);

		getWorldPosition(FlxG.camera, _cachedPoint);
		x = Std.int(_cachedPoint.x);
		y = Std.int(_cachedPoint.y);
	}
	
	function get__globalScreenX()
	{
		return windowX;
	}
	
	function get__globalScreenY()
	{
		return windowY;
	}
	
	function set__globalScreenX(value:Int)
	{
		return windowX = value;
	}
	
	function set__globalScreenY(value:Int)
	{
		return windowY = value;
	}
}
