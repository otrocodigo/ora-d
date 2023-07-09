module ora.layer;
import ora;

import imagefmt;
import std.conv;

/**
    Open Raster blending modes
*/
enum BlendingMode : string
{
	Normal = "svg:src-over",
	Darken = "svg:darken",
	Multiply = "svg:multiply",
	ColorBurn = "svg:color-burn",
	Lighten = "svg:lighten",
	Screen = "svg:screen",
	ColorDodge = "svg:color-dodge",
	Overlay = "svg:overlay",
	SoftLight = "svg:soft-light",
	HardLight = "svg:hard-light",
	Difference = "svg:difference",
	Hue = "svg:hue",
	Saturation = "svg:saturation",
	Color = "svg:color",
	Luminosity = "svg:luminosity"
}

/**
    The different types of layer
*/
enum LayerType
{
	/**
        Any other type of layer
	*/
	Any = 0,

	/**
        An open folder
	*/
	OpenFolder = 1,

	/**
        A closed folder
	*/
	ClosedFolder = 2,

	/**
        A bounding section divider
    
        Hidden in the UI
	*/
	SectionDivider = 3
}

final class Layer
{
package(ora):
private:
	ORA _parent;
	string _src;
	IFImage _image;
	ubyte[] _data;

public:
	this(ubyte[] expandedData = [])
	{
		if (expandedData == [])
			return;

		this._image = read_image(expandedData);
		this.width = this._image.w;
		this.height = this._image.h;
	}

	/**
	 * The type of layer
	 */
	LayerType type;

	/**
	 * Blending mode
	 */
	BlendingMode blendModeKey;

	/**
          * Name of layer
         */
	string name;

	/**
	 * The data of the layer
	 */
	@property ref ubyte[] data()
	{
		return this._data;
	}

	/**
	 * Gets the size of this layer
          */
	uint[2] size()
	{
		return [
			width,
			height
		];
	}

	/**
	 * Top X coordinate of layer
	 */
	@property int top() const
	{
		return y;
	}

	/**
	 * Left X coordinate of layer
	 */
	@property int left() const
	{
		return x;
	}

	/**
	 * Bottom Y coordinate of layer
	 */
	@property int bottom() const
	{
		return y + height;
	}

	/**
	 * Right X coordinate of layer
	 */
	@property int right() const
	{
		return x + width;
	}

	/**
	 * Gets the center coordinates of the layer
	 */
	uint[2] center()
	{
		return [
			left + (width / 2),
			top + (height / 2),
		];
	}

	/**
	 * Opacity of the layer
	*/
	int opacity;

	/**
	 * Location for layer
	 */
	union
	{
		struct
		{
			/**
			 * X coordinate of layer
			 */
			int x;

			/**
			 * Y coordinate of layer
			 */
			int y;
		}

		/**
		 * Location as array
		 */
		int[2] location;
	}

	/**
	 * Width of layer
	 */
	int width;

	/**
	 * Height of layer
	 */
	int height;

	/**
	 * Visibility of layer
	 */
	string visibility;

	/**
	 * Check if the layer is a group
	 * Returns: if the layer is a group
	 */
	bool isLayerGroup()
	{
		return type == LayerType.OpenFolder || type == LayerType.ClosedFolder;
	}

	/**
	 * Is layer visible?
	 * Returns: if the layer is visible
	 */
	@property bool isVisible() const
	{
		return visibility == "visible";
	}

	/**
	 * Is the layer useful?
	 */
	bool isLayerUseful()
	{
		return !isLayerGroup() && (width != 0 && height != 0);
	}

	/**
	 * Extract the layer image
	 */
	void extractLayerImage()
	{
		this._data = this._image.buf8;
	}
}
