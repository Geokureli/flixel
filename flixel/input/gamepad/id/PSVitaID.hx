package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * Native PSVita input values.
 * (The only way to use these is to actually be using a PSVita with the upcoming openfl vita target!)
 *
 * This will ONLY work with the gamepad API (available only in OpenFL "next", not "legacy") and will NOT work with the joystick API
 */
enum abstract PSVitaID(Int) to Int
{
	var X = 6;
	var CIRCLE = 7;
	var SQUARE = 8;
	var TRIANGLE = 9;
	var SELECT = 10;
	var START = 12;
	var L = 15;
	var R = 16;

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
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<PSVitaID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<PSVitaID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
	
	public function toGeneric():FlxGamepadInputID
	{
		return switch (cast this:PSVitaID)
		{
			case PSVitaID.X                : FlxGamepadInputID.A;
			case PSVitaID.CIRCLE           : FlxGamepadInputID.B;
			case PSVitaID.SQUARE           : FlxGamepadInputID.X;
			case PSVitaID.TRIANGLE         : FlxGamepadInputID.Y;
			case PSVitaID.DPAD_UP          : FlxGamepadInputID.DPAD_UP;
			case PSVitaID.DPAD_DOWN        : FlxGamepadInputID.DPAD_DOWN;
			case PSVitaID.DPAD_LEFT        : FlxGamepadInputID.DPAD_LEFT;
			case PSVitaID.DPAD_RIGHT       : FlxGamepadInputID.DPAD_RIGHT;
			case PSVitaID.L                : FlxGamepadInputID.LEFT_SHOULDER;
			case PSVitaID.R                : FlxGamepadInputID.RIGHT_SHOULDER;
			case PSVitaID.SELECT           : FlxGamepadInputID.BACK;
			case PSVitaID.LEFT_STICK_UP    : FlxGamepadInputID.LEFT_STICK_DIGITAL_UP;
			case PSVitaID.LEFT_STICK_DOWN  : FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN;
			case PSVitaID.LEFT_STICK_RIGHT : FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT;
			case PSVitaID.LEFT_STICK_LEFT  : FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT;
			case PSVitaID.RIGHT_STICK_UP   : FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP;
			case PSVitaID.RIGHT_STICK_DOWN : FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN;
			case PSVitaID.RIGHT_STICK_RIGHT: FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT;
			case PSVitaID.RIGHT_STICK_LEFT : FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT;
			case PSVitaID.PS               : FlxGamepadInputID.GUIDE;
		}
	}
}
