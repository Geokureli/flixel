package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for OUYA controllers
 */
enum abstract OUYAID(Int) to Int
{
	var O = 6;
	var U = 8;
	var Y = 9;
	var A = 7;
	var LB = 15;
	var RB = 16;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	var HOME = 0x01000012;	// Not sure if press HOME is taken in account on OUYA
	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;

	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;
	var DPAD_DOWN = 18;
	var DPAD_UP = 17;
	
	var LEFT_STICK_UP = 23;
	var LEFT_STICK_DOWN = 24;
	var LEFT_STICK_LEFT = 25;
	var LEFT_STICK_RIGHT = 26;
	
	var RIGHT_STICK_UP = 27;
	var RIGHT_STICK_DOWN = 28;
	var RIGHT_STICK_LEFT = 29;
	var RIGHT_STICK_RIGHT = 30;
	
	// If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<OUYAID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<OUYAID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
	
	
	public function toGeneric():FlxGamepadInputID
	{
		return switch (cast this:OUYAID)
		{
			case OUYAID.A                : FlxGamepadInputID.A;
			case OUYAID.O                : FlxGamepadInputID.B;
			case OUYAID.U                : FlxGamepadInputID.X;
			case OUYAID.Y                : FlxGamepadInputID.Y;
			case OUYAID.DPAD_UP          : FlxGamepadInputID.DPAD_UP;
			case OUYAID.DPAD_DOWN        : FlxGamepadInputID.DPAD_DOWN;
			case OUYAID.DPAD_LEFT        : FlxGamepadInputID.DPAD_LEFT;
			case OUYAID.DPAD_RIGHT       : FlxGamepadInputID.DPAD_RIGHT;
			case OUYAID.LB               : FlxGamepadInputID.LEFT_SHOULDER;
			case OUYAID.RB               : FlxGamepadInputID.RIGHT_SHOULDER;
			case OUYAID.LEFT_TRIGGER     : FlxGamepadInputID.LEFT_TRIGGER;
			case OUYAID.RIGHT_TRIGGER    : FlxGamepadInputID.RIGHT_TRIGGER;
			case OUYAID.HOME             : FlxGamepadInputID.START;
			case OUYAID.LEFT_STICK_CLICK : FlxGamepadInputID.LEFT_STICK_CLICK;
			case OUYAID.LEFT_STICK_UP    : FlxGamepadInputID.LEFT_STICK_DIGITAL_UP;
			case OUYAID.LEFT_STICK_DOWN  : FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN;
			case OUYAID.LEFT_STICK_RIGHT : FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT;
			case OUYAID.LEFT_STICK_LEFT  : FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT;
			case OUYAID.RIGHT_STICK_CLICK: FlxGamepadInputID.RIGHT_STICK_CLICK;
			case OUYAID.RIGHT_STICK_UP   : FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP;
			case OUYAID.RIGHT_STICK_DOWN : FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN;
			case OUYAID.RIGHT_STICK_RIGHT: FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT;
			case OUYAID.RIGHT_STICK_LEFT : FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT;
		}
	}
}
