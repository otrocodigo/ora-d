# ORA-D
`ora-d` is an implementation of the [Open Raster Specification](https://www.openraster.org/) to D to support basic extraction of layer info and layer data from ORA files

### Dependencies

`dxml` by jmdavis is required

- [https://github.com/jmdavis/dxml](https://github.com/jmdavis/dxml)
- [https://code.dlang.org/packages/dxml](https://github.com/jmdavis/dxml)

`imagefmt` by tjhann is required

- [https://github.com/tjhann/imagefmt](https://github.com/tjhann/imagefmt)
- [https://code.dlang.org/packages/imagefmt](https://code.dlang.org/packages/imagefmt)

## Parsing a document
To parse a ORA document, use `parseDocument` in `ora`.
```d
ORA document = parseDocument("myFile.ora");
```

## Extracting layer data from layer
To extract layer data (textures) from a layer use `Layer.extractLayerImage()`
```d
ORA doc = parseDocument("myfile.ora");
foreach(layer; doc.layers) {
    
    // Skip non-image layers
    if (layer.type != LayerType.Any) continue;

    // Extract the layer image data.
    // The output RGBA output is stored in Layer.data
    layer.extractLayerImage();

    // write_image from imagefmt is used here to export the layer as a PNG
    write_image(buildPath(outputFolder, layer.name~".png"), layer.width, layer.height, layer.data, 4);
}
```
