/**
 * Distributed under the 2-Clause BSD License, see LICENSE file.
 *
 * Authors: otrocodigo
 */

module ora;
import std.zip;

public import ora.parser : parseDocument;
public import ora.layer;

struct ORA
{
package(ora):
public:
	/**
	 * Document source
	 */
	ZipArchive fileRef;

	/**
	 * Width of document
	*/
	int width;

	/**
	 * Height of document
	*/
	int height;

	/**
	 * X coordinate of document
	 */
	int x;

	/**
	 * Y coordinate of document
	 */
	int y;

	/**
	 * Version of document
	 */
	string ver;

	/**
	 * Layers of document
	 */
	Layer[] layers;

	/**
          * Gets the size of document
          */
	uint[2] size()
	{
		return [
			width,
			height
		];
	}

}
