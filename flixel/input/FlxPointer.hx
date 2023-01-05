package flixel.input;

import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxCoordUtil;
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
	 * NOTE: `x` and `y` also store the world position of the pointer on `FlxG.camera`.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   result  Optional point used for the returned result. If null, one is created.
	 * @return  The pointer's location in world space.
	 */
	public function getWorldPosition(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		return FlxCoordUtil.windowToWorldXY(windowX, windowY, camera, result);
	}

	/**
	 * Fetch the screen position of the pointer on any given camera.
	 * NOTE: `screenX` and `screenY` also store the screen position of the pointer on `FlxG.camera`.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   result  Optional point used for the returned result. If null, one is created.
	 * @return  The pointer's location in screen space.
	 */
	public inline function getScreenPosition(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		return FlxCoordUtil.windowToCameraXY(windowX, windowY, camera, result);
	}

	/**
	 * Fetch the screen position of the pointer relative to given camera's viewport.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   result  Optional point used for the returned result. If null, one is created.
	 * @return  The pointer's location relative to camera's viewport.
	 */
	public inline function getPositionInCameraView(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		return getScreenPosition(camera, result);
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
	 * @param   objectOrGroup  The object or group being tested.
	 * @param   camera         Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function overlaps(objectOrGroup:FlxBasic, ?camera:FlxCamera):Bool
	{
		var result:Bool = false;

		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null)
		{
			group.forEachExists(function(basic:FlxBasic)
			{
				if (overlaps(basic, camera))
				{
					result = true;
					return;
				}
			});
		}
		else
		{
			getPosition(_cachedPoint);
			var object:FlxObject = cast objectOrGroup;
			result = object.overlapsPoint(_cachedPoint, true, camera);
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
		final camera = FlxG.camera;
		
		screenY = Std.int(FlxCoordUtil.windowToCameraY(windowY, camera));
		screenX = Std.int(FlxCoordUtil.windowToCameraX(windowX, camera));
		
		x = Std.int(FlxCoordUtil.cameraToWorldX(screenX, camera));
		y = Std.int(FlxCoordUtil.cameraToWorldY(screenY, camera));
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
