package flixel.util;

import flixel.tweens.FlxEase;

/**
 * A color space designed to that relative changes in hue will not change the overall
 * perceived lightness on modern displays
 * @see https://bottosson.github.io/posts/oklab/
 */
@:forward(alpha, alphaFloat)
abstract FlxOKLabColor(FlxColor) from FlxColor to FlxColor from Int from UInt to Int to UInt
{
	/** A number between 0 and 1, indicating the lightness of the color */
	public var lightness(get, set):Float;
	
	/** The opposing red/green channel, usually between -0.4 and 0.4 */
	public var redGreen(get, set):Float;
	
	/** The opposing blue/yellow channel, usually between -0.4 and 0.4 */
	public var blueYellow(get, set):Float;
	
	/** Casts to the RGBA colorspace */
	public var rgba(get, never):FlxColor;
	inline function get_rgba() return this;
	
	/**
	 * A color space designed to that relative changes in hue will not change the overall
	 * perceived lightness on modern displays
	 * 
	 * @param   lightness   A number between 0 and 1, indicating the lightness of the color
	 * @param   redGreen    The opposing red/green channel, usually between -0.4 and 0.4
	 * @param   blueYellow  The opposing blue/yellow channel, usually between -0.4 and 0.4
	 * @param   alpha       How opaque the color should be, either between 0 and 1 or 0 and 255
	 * @return  This color
	 */
	public inline function new (lightness:Float, redGreen:Float, blueYellow:Float, alpha = 1.0)
	{
		this = new FlxColor();
		set(lightness, redGreen, blueYellow, alpha);
	}
	
	public inline function set(lightness:Float, redGreen:Float, blueYellow:Float, alpha = 1.0):FlxOKLabColor
	{
		final _l = cubed((lightness + 0.3963377774 * redGreen + 0.2158037573 * blueYellow));
		final _m = cubed((lightness - 0.1055613458 * redGreen - 0.0638541728 * blueYellow));
		final _s = cubed((lightness - 0.0894841775 * redGreen - 1.2914855480 * blueYellow));

		this.redFloat = gamma( 4.0767416621 * _l - 3.3077115913 * _m + 0.2309699292 * _s);
		this.greenFloat = gamma(-1.2684380046 * _l + 2.6097574011 * _m - 0.3413193965 * _s);
		this.blueFloat = gamma(-0.0041960863 * _l - 0.7034186147 * _m + 1.7076147010 * _s);
		this.alphaFloat = alpha;
		
		return this;
	}
	
	/**
	 * Get an interpolated color based on two different colors.
	 *
	 * @param   color1  The first color
	 * @param   color2  The second color
	 * @param   t       A value from 0 to 1 representing how much to shift between the colors
	 * @return  The interpolated color
	 */
	public static inline function interpolate(color1:FlxOKLabColor, color2:FlxOKLabColor, t = 0.5):FlxColor
	{
		var lg = (color2.lightness - color1.lightness) * t + color1.lightness;
		var rg = (color2.redGreen - color1.redGreen) * t + color1.redGreen;
		var by = (color2.blueYellow - color1.blueYellow) * t + color1.blueYellow;
		var a = Std.int((color2.alphaFloat - color1.alphaFloat) * t + color1.alphaFloat);
		
		return new FlxOKLabColor(lg, rg, by, a);
	}
	
	public function toString()
	{
		inline function rndf(n:Float) return '${Math.round(n * 1000) / 1000}';
		return 'oklab(${Math.round(lightness * 1000) / 10}%, ${rndf(redGreen)}, ${rndf(blueYellow)})';
	}
	
	static inline var L_R = 0.4122214708;
	static inline var L_G = 0.5363325363;
	static inline var L_B = 0.0514459929;
	
	static inline var M_R = 0.2119034982;
	static inline var M_G = 0.6806995451;
	static inline var M_B = 0.1073969566;
	
	static inline var S_R = 0.0883024619;
	static inline var S_G = 0.2817188376;
	static inline var S_B = 0.6299787005;
	
	static inline var LG_L = 0.2104542553;
	static inline var LG_M = 0.7936177850;
	static inline var LG_S =-0.0040720468;
	
	static inline var RG_L = 1.9779984951;
	static inline var RG_M =-2.4285922050;
	static inline var RG_S = 0.4505937099;
	
	static inline var BY_L = 0.0259040371;
	static inline var BY_M = 0.7827717662;
	static inline var BY_S =-0.8086757660;
	
	function get_lightness()
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);
		
		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);

		return _l * LG_L + _m * LG_M + _s * LG_S;
	}
	
	function set_lightness(value:Float)
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);
		
		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);

		final rg = _l * RG_L + _m * RG_M + _s * RG_S;
		final by = _l * BY_L + _m * BY_M + _s * BY_S;
		set(value, rg, by, this.alphaFloat);
		return value;
	}
	
	function get_redGreen()
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);

		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);

		return _l * RG_L + _m * RG_M + _s * RG_S;
	}
	
	function set_redGreen(value:Float)
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);
		
		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);
		
		final lg = _l * LG_L + _m * LG_M + _s * LG_S;
		final by = _l * BY_L + _m * BY_M + _s * BY_S;
		set(lg, value, by, this.alphaFloat);
		return value;
	}
	
	function get_blueYellow()
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);
		
		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);

		return _l * BY_L + _m * BY_M + _s * BY_S;
	}
	
	function set_blueYellow(value:Float)
	{
		final _r = inverseGamma(this.redFloat);
		final _g = inverseGamma(this.greenFloat);
		final _b = inverseGamma(this.blueFloat);
		
		final _l = cubeRoot(L_R * _r + L_G * _g + L_B * _b);
		final _m = cubeRoot(M_R * _r + M_G * _g + M_B * _b);
		final _s = cubeRoot(S_R * _r + S_G * _g + S_B * _b);

		final lg = _l * LG_L + _m * LG_M + _s * LG_S;
		final rg = _l * RG_L + _m * RG_M + _s * RG_S;
		set(lg, rg, value, this.alphaFloat);
		return value;
	}
	
	static function gamma(n:Float)
		return n >= 0.0031308 ? 1.055 * Math.pow(n, 1 / 2.4) - 0.055 : 12.92 * n;
	
	static function inverseGamma(n:Float)
		return n >= 0.04045 ? Math.pow((n + 0.055) / (1 + 0.055), 2.4) : n / 12.92;
	
	static inline function cubed(n:Float)
		return Math.pow(n, 3);
		
	static inline function cubeRoot(n:Float)
		return Math.pow(n, 1/3);
	
	/**
	 * Create a color from the least significant four bytes of an Int
	 *
	 * @param   value  An Int with bytes in the format 0xAARRGGBB
	 * @return  This color
	 */
	public static inline function fromInt(value:Int):FlxOKLabColor
	{
		return new FlxColor(value);
	}
	
	/**
	 * Generate a color from integer RGB values (0 to 255)
	 *
	 * @param   red    The red value of the color from 0 to 255
	 * @param   green  The green value of the color from 0 to 255
	 * @param   blue   The green value of the color from 0 to 255
	 * @param   alpha  How opaque the color should be, from 0 to 255
	 * @return  This color
	 */
	public static inline function fromRGB(red:Int, green:Int, blue:Int, alpha = 0xFF):FlxOKLabColor
	{
		return FlxColor.fromRGB(red, green, blue, alpha);
	}
	
	/**
	 * Generate a color from float RGB values (0 to 1)
	 *
	 * @param   red    The red value of the color from 0 to 1
	 * @param   green  The green value of the color from 0 to 1
	 * @param   blue   The green value of the color from 0 to 1
	 * @param   alpha  How opaque the color should be, from 0 to 1
	 * @return  This color
	 */
	public static inline function fromRGBFloat(red:Float, green:Float, blue:Float, alpha = 1.0):FlxOKLabColor
	{
		return FlxColor.fromRGBFloat(red, green, blue, alpha);
	}
	
	/**
	 * Generate a color from CMYK values (0 to 1)
	 *
	 * @param   cyan     The cyan value of the color from 0 to 1
	 * @param   magenta  The magenta value of the color from 0 to 1
	 * @param   yellow   The yellow value of the color from 0 to 1
	 * @param   black    The black value of the color from 0 to 1
	 * @param   alpha    How opaque the color should be, from 0 to 1
	 * @return  This color
	 */
	public static inline function fromCMYK(cyan:Float, magenta:Float, yellow:Float, black:Float, alpha = 1.0):FlxOKLabColor
	{
		return FlxColor.fromCMYK(cyan, magenta, yellow, black, alpha);
	}
	
	/**
	 * Generate a color from HSB (aka HSV) components.
	 *
	 * @param   hue         A number from 0 to 360, indicating a position on a color strip or wheel.
	 * @param   saturation  A number from 0 to 1, indicating the vibrancy.  0 is gray, 1 is vibrant.
	 * @param   brightness  A number from 0 to 1.  0 is black, 1 is full bright.
	 * @param   alpha       How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return  This color
	 */
	public static function fromHSB(hue:Float, saturation:Float, brightness:Float, alpha = 1.0):FlxOKLabColor
	{
		return FlxColor.fromHSB(hue, saturation, brightness, alpha);
	}
	
	/**
	 * Generate a color from HSL components.
	 *
	 * @param   hue         A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param   saturation  A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param   lightness   A number between 0 and 1, indicating the lightness of the color
	 * @param   alpha       How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return  This color
	 */
	public static inline function fromHSL(hue:Float, saturation:Float, lightness:Float, alpha = 1.0):FlxOKLabColor
	{
		return FlxColor.fromHSL(hue, saturation, lightness, alpha);
	}
	
	/**
	 * Parses a `String` and returns a `FlxOKLabColor` or `null` if the `String` couldn't be parsed.
	 *
	 * Examples (input -> output in hex):
	 *
	 * - `0x00FF00`    -> `0xFF00FF00`
	 * - `0xAA4578C2`  -> `0xAA4578C2`
	 * - `#0000FF`     -> `0xFF0000FF`
	 * - `#3F000011`   -> `0x3F000011`
	 * - `GRAY`        -> `0xFF808080`
	 * - `blue`        -> `0xFF0000FF`
	 *
	 * @param	str 	The string to be parsed
	 * @return	A `FlxOKLabColor` or `null` if the `String` couldn't be parsed
	 */
	public static inline function fromString(str:String):Null<FlxOKLabColor>
	{
		return FlxColor.fromString(str);
	}
}