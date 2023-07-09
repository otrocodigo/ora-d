/**
 * This ORA (Open Raster) file parser
 *
 * Authors: otrocodigo
 */

module ora.parser;
import ora;
import ora.layer;

import std.file;
import std.zip;
import std.exception;
import std.conv;
import dxml.dom;
import std.algorithm : filter;
import std.algorithm.searching : canFind;

/**
 * Parser a 'Open Raster' document
 */
ORA parseDocument(string fileName)
{
	ZipArchive file = new ZipArchive(read(fileName));
	return parseORAFile(file);
}

package(ora):
private:
T getAttrValue(T, A...)(in A attributes, string name, T defaultValue)
{
	auto value = attributes.filter!(x => x[0] == name).front;
	return value.length > 1 ? to!T(value[1]) : defaultValue;
}

ORA parseORAFile(ZipArchive oraZipFile)
{
	ORA ora;
	ora.fileRef = oraZipFile;

	// Check mimetype
	enforce("mimetype" in oraZipFile.directory, "Invalid document: no file 'mimetype'");

	auto mimetypeMember = oraZipFile.directory["mimetype"];
	oraZipFile.expand(mimetypeMember);

	enforce(cast(string) mimetypeMember.expandedData == "image/openraster", "Invalid document: invalid mimetype");

	// Check stack.xml
	enforce("stack.xml" in oraZipFile.directory, "Invalid document: no file 'stack.xml'");

	auto stackMember = oraZipFile.directory["stack.xml"];
	oraZipFile.expand(stackMember);

	auto stackData = stackMember.expandedData;

	auto rootDOM = parseDOM!simpleXML(cast(string) stackData);

	// BEGIN: extract image properties
	auto imageDOM = rootDOM.children[0];
	auto imageAttrs = imageDOM.attributes;

	// width of image
	ora.width = getAttrValue!int(imageAttrs, "w", 0);

	// height of image
	ora.height = getAttrValue!int(imageAttrs, "h", 0);

	// X coordinate of image
	ora.x = getAttrValue!int(imageAttrs, "xres", 0);

	// Y coordinate of image
	ora.y = getAttrValue!int(imageAttrs, "yres", 0);

	// version of image
	auto ver = getAttrValue!string(imageAttrs, "version", "");

	enforce(ver != "", "Invalid document: undefined image version");
	ora.ver = ver;
	// END: extract image properties

	// BEGIN: extract layers
	auto stackDOM = imageDOM.children[0];
	auto childDOMs = stackDOM.children;

	void importAttributes(DOMEntity!string[] childrens)
	{
		foreach (childDOM; childrens)
		{
			auto layerAttrs = childDOM.attributes;

			// visibility of layer
			auto visibility = getAttrValue!string(layerAttrs, "visibility", "visible");

			// name (location) of layer
			auto name = getAttrValue!string(layerAttrs, "name", "");

			switch (childDOM.name)
			{
			case "layer":
				// src (location) of layer
				auto src = getAttrValue!string(layerAttrs, "src", "");

				// Invalid layer: undefined image source
				if (src == "")
					break;

				auto layerImgMember = ora.fileRef.directory[src];
				ora.fileRef.expand(layerImgMember);

				Layer layer = new Layer(layerImgMember.expandedData);

				// X coordinate of layer
				layer.x = getAttrValue!int(layerAttrs, "x", 0);

				// Y coordinate of layer
				layer.y = getAttrValue!int(layerAttrs, "y", 0);

				layer.visibility = visibility;

				layer.name = name;

				// composite operation of layer
				auto compositeOp = getAttrValue!string(layerAttrs, "composite-op", "svg:src-over");

				// default composite operation as 'Normal'
				if (canFind(["svg:plus", "svg:dst-in", "svg:dst-out", "svg:src-atop","svg:dst-atop"], compositeOp))
				  compositeOp = "svg:src-over";

				// blending mode of layer
				layer.blendModeKey = cast(BlendingMode) compositeOp;

				// opacity of layer
				layer.opacity = cast(int)(getAttrValue!double(layerAttrs, "opacity", 1.0) * 255.0);

				// type of layer
				layer.type = LayerType.Any;

				ora.layers ~= layer;
				break;
			case "stack":
				Layer group = new Layer();
				group.name = name;
				group.visibility = visibility;
				group.type = LayerType.OpenFolder;

				importAttributes(childDOM.children);

				ora.layers ~= group;

				Layer groupEnd = new Layer();
				groupEnd.type = LayerType.SectionDivider;
				ora.layers ~= groupEnd;

				break;
			default:
				assert(0, "unsupported dom");
			}
		}
	}

	importAttributes(childDOMs);

	// END: extract layers

	return ora;
}
