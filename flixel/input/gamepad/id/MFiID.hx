package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for MFi controllers
 */
enum abstract MFiID(Int) to Int
{
	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;
	
	var A = 6;
	var B = 7;
	var X = 8;
	var Y = 9;
	var LB = 15;
	var RB = 16;
	var BACK = 10;
	var GUIDE = 11;
	var START = 12;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	
	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;

	var LEFT_STICK_UP = 21;
	var LEFT_STICK_DOWN = 22;
	var LEFT_STICK_LEFT = 23;
	var LEFT_STICK_RIGHT = 24;
		
	var RIGHT_STICK_UP = 25;
	var RIGHT_STICK_DOWN = 26;
	var RIGHT_STICK_LEFT = 27;
	var RIGHT_STICK_RIGHT = 28;
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<MFiID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<MFiID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
	
	public function toGeneric():FlxGamepadInputID
	{
		return switch (cast this:MFiID)
		{
			case MFiID.A                : FlxGamepadInputID.A;
			case MFiID.B                : FlxGamepadInputID.B;
			case MFiID.X                : FlxGamepadInputID.X;
			case MFiID.Y                : FlxGamepadInputID.Y;
			case MFiID.DPAD_UP          : FlxGamepadInputID.DPAD_UP;
			case MFiID.DPAD_DOWN        : FlxGamepadInputID.DPAD_DOWN;
			case MFiID.DPAD_LEFT        : FlxGamepadInputID.DPAD_LEFT;
			case MFiID.DPAD_RIGHT       : FlxGamepadInputID.DPAD_RIGHT;
			case MFiID.LB               : FlxGamepadInputID.LEFT_SHOULDER;
			case MFiID.RB               : FlxGamepadInputID.RIGHT_SHOULDER;
			case MFiID.LEFT_TRIGGER     : FlxGamepadInputID.LEFT_TRIGGER;
			case MFiID.RIGHT_TRIGGER    : FlxGamepadInputID.RIGHT_TRIGGER;
			case MFiID.START            : FlxGamepadInputID.START;
			case MFiID.BACK             : FlxGamepadInputID.BACK;
			case MFiID.LEFT_STICK_CLICK : FlxGamepadInputID.LEFT_STICK_CLICK;
			case MFiID.RIGHT_STICK_CLICK: FlxGamepadInputID.RIGHT_STICK_CLICK;
			case MFiID.LEFT_STICK_UP    : FlxGamepadInputID.LEFT_STICK_DIGITAL_UP;
			case MFiID.LEFT_STICK_DOWN  : FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN;
			case MFiID.LEFT_STICK_RIGHT : FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT;
			case MFiID.LEFT_STICK_LEFT  : FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT;
			case MFiID.RIGHT_STICK_UP   : FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP;
			case MFiID.RIGHT_STICK_DOWN : FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN;
			case MFiID.RIGHT_STICK_RIGHT: FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT;
			case MFiID.RIGHT_STICK_LEFT : FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT;
			case MFiID.GUIDE            : FlxGamepadInputID.GUIDE;
		}
	}
}
