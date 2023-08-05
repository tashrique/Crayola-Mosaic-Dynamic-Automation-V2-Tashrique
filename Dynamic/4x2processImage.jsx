{
    // Initialization
    {
        app.preferences.rulerUnits = Units.PIXELS;
        var TOLERANCE = 6;
        var doc = app.activeDocument;
        activeDocument.activeLayer.isBackgroundLayer = false;
    }
    //Magic Wand Tool to select all white border
    function MagicWand(tolerance) {
        var idslct = charIDToTypeID("slct");
        var desc248 = new ActionDescriptor();
        var idnull = charIDToTypeID("null");
        var ref5 = new ActionReference();
        var idmagicWandTool = stringIDToTypeID("magicWandTool");
        ref5.putClass(idmagicWandTool);
        desc248.putReference(idnull, ref5);
        var iddontRecord = stringIDToTypeID("dontRecord");
        desc248.putBoolean(iddontRecord, true);
        var idforceNotify = stringIDToTypeID("forceNotify");
        desc248.putBoolean(idforceNotify, true);
        executeAction(idslct, desc248, DialogModes.NO);

        var idsetd = charIDToTypeID("setd");
        var desc250 = new ActionDescriptor();
        var idnull = charIDToTypeID("null");
        var ref6 = new ActionReference();
        var idChnl = charIDToTypeID("Chnl");
        var idfsel = charIDToTypeID("fsel");
        ref6.putProperty(idChnl, idfsel);
        desc250.putReference(idnull, ref6);
        var idT = charIDToTypeID("T   ");
        var desc251 = new ActionDescriptor();
        var idHrzn = charIDToTypeID("Hrzn");
        var idPxl = charIDToTypeID("#Pxl");
        desc251.putUnitDouble(idHrzn, idPxl, 40.000000);
        var idVrtc = charIDToTypeID("Vrtc");
        var idPxl = charIDToTypeID("#Pxl");
        desc251.putUnitDouble(idVrtc, idPxl, 40.000000);
        var idPnt = charIDToTypeID("Pnt ");
        desc250.putObject(idT, idPnt, desc251);
        var idTlrn = charIDToTypeID("Tlrn");
        desc250.putInteger(idTlrn, tolerance);
        var idAntA = charIDToTypeID("AntA");
        desc250.putBoolean(idAntA, true);
        executeAction(idsetd, desc250, DialogModes.NO);
    }
    //Delete selection
    function dltBG() {

        var idDlt = charIDToTypeID("Dlt ");
        executeAction(idDlt, undefined, DialogModes.NO);
    }
    //Delete Background and Crop
    function dltBGandCrop() {

        var idDlt = charIDToTypeID("Dlt ");
        executeAction(idDlt, undefined, DialogModes.NO);

        var idInvs = charIDToTypeID("Invs");
        executeAction(idInvs, undefined, DialogModes.NO);

        var idCrop = charIDToTypeID("Crop");
        var desc1030 = new ActionDescriptor();
        var idDlt = charIDToTypeID("Dlt ");
        desc1030.putBoolean(idDlt, true);
        executeAction(idCrop, desc1030, DialogModes.NO);

        var idsetd = charIDToTypeID("setd");
        var desc1033 = new ActionDescriptor();
        var idnull = charIDToTypeID("null");
        var ref36 = new ActionReference();
        var idChnl = charIDToTypeID("Chnl");
        var idfsel = charIDToTypeID("fsel");
        ref36.putProperty(idChnl, idfsel);
        desc1033.putReference(idnull, ref36);
        var idT = charIDToTypeID("T   ");
        var idOrdn = charIDToTypeID("Ordn");
        var idNone = charIDToTypeID("None");
        desc1033.putEnumerated(idT, idOrdn, idNone);
        executeAction(idsetd, desc1033, DialogModes.NO);


    }
    //Decide whether framed pic or 3D/Other shape
    function runWhitePercentage() {
        // Run getWhitePercentage for each image

        var processScript = File(scriptFolder + "/4x1getWhitePercentage.jsx");
        if (processScript.exists) {
            // Setting argument
            var whiteness = $.evalFile(processScript);
        } else {
            alert("4x1getWhitePercentage.jsx script file does not exist.");
        }

        return whiteness;
    }
    //Fetch colors from CSV
    function getColorsFromCSV() {

        // Open csv file
        {
            var scriptFolder = new File($.fileName).parent;
            var txtFile = new File(scriptFolder + "/workingFolderPath.txt");
            txtFile.open('r');
            var folderPath = txtFile.read();
            txtFile.close();

            var folderPath = folderPath.replace(/\\/g, "/");
            folderPath = folderPath.replace(/(\r\n|\n|\r)/gm, "");
            var folderPath = folderPath + "/Output";
            csvFilePath = folderPath + "/MosaicColorData.csv";
            var file = new File(csvFilePath);

            filename = folderPath + "/" + app.activeDocument.name;

        }

        var colors = {};

        if (file.open('r')) {
            var line;
            file.readln(); // Skip the header line
            while (!file.eof) { // while not the end of the file
                line = file.readln(); // read the next line
                var fields = line.split(','); // split the line into fields

                // Assume the CSV structure is: 
                // "Colorfulness, Contrast, White, File path, R, G, B, cR, cG, cB"
                // Extract just the filename from the full path in the CSV file
                var csvFilename = fields[3].replace(/\\/g, "/").replace(/"/g, '');

                if (csvFilename == filename) {
                    // alert("MATCHED!")
                    colors = {
                        R: fields[4] ? parseInt(fields[4].replace(/"/g, ''), 10) : 0,
                        G: fields[5] ? parseInt(fields[5].replace(/"/g, ''), 10) : 0,
                        B: fields[6] ? parseInt(fields[6].replace(/"/g, ''), 10) : 0,
                        cR: fields[7] ? parseInt(fields[7].replace(/"/g, ''), 10) : 0,
                        cG: fields[8] ? parseInt(fields[8].replace(/"/g, ''), 10) : 0,
                        cB: fields[9] ? parseInt(fields[9].replace(/"/g, ''), 10) : 0
                    };
                    break;
                }
            }
            file.close();
        } else {
            alert("Failed to open file: " + csvFilepath);
        }



        return colors;
    }
    //get colors direcctly from image analysis on the go
    function getColorsOnTheRun() {

        // Open csv file
        {
            var scriptFolder = new File($.fileName).parent;
            var txtFile = new File(scriptFolder + "/workingFolderPath.txt");
            txtFile.open('r');
            var folderPath = txtFile.read();
            txtFile.close();

            var folderPath = folderPath.replace(/\\/g, "/");
            folderPath = folderPath.replace(/(\r\n|\n|\r)/gm, "");
            var folderPath = folderPath + "/Output";
            csvFilePath = folderPath + "/MosaicColorData.csv";
            var file = new File(csvFilePath);

            filename = folderPath + "/" + app.activeDocument.name;

        }

        var colors = {};

        if (file.open('r')) {
            var line;
            file.readln(); // Skip the header line
            while (!file.eof) { // while not the end of the file
                line = file.readln(); // read the next line
                var fields = line.split(','); // split the line into fields

                // Assume the CSV structure is: 
                // "Colorfulness, Contrast, White, File path, R, G, B, cR, cG, cB"
                // Extract just the filename from the full path in the CSV file
                var csvFilename = fields[3].replace(/\\/g, "/").replace(/"/g, '');

                if (csvFilename == filename) {
                    // alert("MATCHED!")
                    colors = {
                        R: fields[4] ? parseInt(fields[4].replace(/"/g, ''), 10) : 0,
                        G: fields[5] ? parseInt(fields[5].replace(/"/g, ''), 10) : 0,
                        B: fields[6] ? parseInt(fields[6].replace(/"/g, ''), 10) : 0,
                        cR: fields[7] ? parseInt(fields[7].replace(/"/g, ''), 10) : 0,
                        cG: fields[8] ? parseInt(fields[8].replace(/"/g, ''), 10) : 0,
                        cB: fields[9] ? parseInt(fields[9].replace(/"/g, ''), 10) : 0
                    };
                    break;
                }
            }
            file.close();
        } else {
            alert("Failed to open file: " + csvFilepath);
        }

        // alert('Dominant color: ' + colors.R + ', ' + colors.G + ', ' + colors.B);
        // alert('Complementary color: ' + colors.cR + ', ' + colors.cG + ', ' + colors.cB);

        return colors;
    }
    // Set background color from presets to non rectangle images
    function zoomOutandSetBG(complementaryColor) {

        var docRef = app.activeDocument;
        var layerRef = docRef.activeLayer;

        layerRef.resize(92, 92, AnchorPosition.MIDDLECENTER);

        // convert color values to a SolidColor object
        var colorToSet = new SolidColor();
        colorToSet.rgb.red = complementaryColor.R;
        colorToSet.rgb.green = complementaryColor.G;
        colorToSet.rgb.blue = complementaryColor.B;

        // get document width and height
        var docWidth = app.activeDocument.width.value;
        var docHeight = app.activeDocument.height.value;

        // calculate new size (it's the bigger dimension of the current document size)
        var newSize = Math.max(docWidth, docHeight);

        // expand canvas to a square
        app.activeDocument.resizeCanvas(newSize, newSize, AnchorPosition.MIDDLECENTER);

        // add a new layer for the background
        var backgroundLayer = app.activeDocument.artLayers.add();
        backgroundLayer.name = "Background color";

        // move the new layer to the bottom
        backgroundLayer.move(app.activeDocument.layers[app.activeDocument.layers.length - 1], ElementPlacement.PLACEAFTER);

        // select the new layer and fill it with the complementary color
        app.activeDocument.activeLayer = backgroundLayer;
        app.activeDocument.selection.selectAll();
        app.activeDocument.selection.fill(colorToSet);
        app.activeDocument.selection.deselect();

        // groupLayers();
        // var layerSetRef = docRef.layerSets.add();
        // backgroundLayer.move(layerSetRef, ElementPlacement.INSIDE);
        // layerRef.move(layerSetRef, ElementPlacement.INSIDE);
    }
    // Resize smallest side to 960px and 300 resolution
    function resize() {
        var doc = app.activeDocument;
        var docWidth = doc.width.value;
        var docHeight = doc.height.value;

        if (docWidth <= docHeight) {
            doc.resizeImage(UnitValue(960, "px"), null, 300, ResampleMethod.BICUBIC);
        } else {
            doc.resizeImage(null, UnitValue(960, "px"), 300, ResampleMethod.BICUBIC);
        }
    }
    //Rescale the image
    function rescale() {
        var docRef = app.activeDocument;
        var layerRef = docRef.activeLayer;
        docRef.selection.deselect();
        docRef.activeLayer = layerRef;
        var startRulerUnits = app.preferences.rulerUnits;
        app.preferences.rulerUnits = Units.PERCENT;

        // Scale the layer by 115%
        layerRef.resize(107, 107, AnchorPosition.MIDDLECENTER);

        app.preferences.rulerUnits = startRulerUnits;

        // Crop to the canvas size
        var bounds = [0, 0, docRef.width, docRef.height]; // this is the top, left, bottom and right points
        docRef.crop(bounds);
    }
    // Mask selected subject 
    function maskSelectedSubject() {
        // Mask selected subject 
        function maskSelectedSubject() {
            try {
                var docRef = app.activeDocument;
                var layerRef = docRef.activeLayer;

                // Save current selection
                var savedSelection = docRef.selection;

                // Get the bounds of the current selection
                var selectionBounds = docRef.selection.bounds;

                // Calculate the center of the selection
                var centerX = Math.max(Math.min((selectionBounds[2] + selectionBounds[0]) / 2, docRef.width.as('px') - 480), 480);
                var centerY = Math.max(Math.min((selectionBounds[3] + selectionBounds[1]) / 2, docRef.height.as('px') - 480), 480);

                // Define half of the square size
                var halfSquare = 480; // half of 960

                // Create a new square selection within the document bounds
                docRef.selection.select([
                    [centerX - halfSquare, centerY - halfSquare],
                    [centerX + halfSquare, centerY - halfSquare],
                    [centerX + halfSquare, centerY + halfSquare],
                    [centerX - halfSquare, centerY + halfSquare]
                ]);

                // Create a new layer for the mask
                var newLayer = docRef.artLayers.add();
                {
                    var idMk = charIDToTypeID("Mk  ");
                    var desc1965 = new ActionDescriptor();
                    var idNw = charIDToTypeID("Nw  ");
                    var idChnl = charIDToTypeID("Chnl");
                    desc1965.putClass(idNw, idChnl);
                    var idAt = charIDToTypeID("At  ");
                    var ref44 = new ActionReference();
                    var idChnl = charIDToTypeID("Chnl");
                    var idChnl = charIDToTypeID("Chnl");
                    var idMsk = charIDToTypeID("Msk ");
                    ref44.putEnumerated(idChnl, idChnl, idMsk);
                    desc1965.putReference(idAt, ref44);
                    var idUsng = charIDToTypeID("Usng");
                    var idUsrM = charIDToTypeID("UsrM");
                    var idRvlS = charIDToTypeID("RvlS");
                    desc1965.putEnumerated(idUsng, idUsrM, idRvlS);
                    executeAction(idMk, desc1965, DialogModes.NO);

                    var idMk = charIDToTypeID("Mk  ");
                    var desc2004 = new ActionDescriptor();
                    var idNw = charIDToTypeID("Nw  ");
                    var idChnl = charIDToTypeID("Chnl");
                    desc2004.putClass(idNw, idChnl);
                    var idAt = charIDToTypeID("At  ");
                    var ref51 = new ActionReference();
                    var idChnl = charIDToTypeID("Chnl");
                    var idChnl = charIDToTypeID("Chnl");
                    var idMsk = charIDToTypeID("Msk ");
                    ref51.putEnumerated(idChnl, idChnl, idMsk);
                    var idLyr = charIDToTypeID("Lyr ");
                    ref51.putName(idLyr, "Layer 0");
                    desc2004.putReference(idAt, ref51);
                    var idUsng = charIDToTypeID("Usng");
                    var ref52 = new ActionReference();
                    var idChnl = charIDToTypeID("Chnl");
                    var idChnl = charIDToTypeID("Chnl");
                    var idMsk = charIDToTypeID("Msk ");
                    ref52.putEnumerated(idChnl, idChnl, idMsk);
                    var idLyr = charIDToTypeID("Lyr ");
                    var idOrdn = charIDToTypeID("Ordn");
                    var idTrgt = charIDToTypeID("Trgt");
                    ref52.putEnumerated(idLyr, idOrdn, idTrgt);
                    desc2004.putReference(idUsng, ref52);
                    executeAction(idMk, desc2004, DialogModes.NO);
                }

                newLayer.remove();
            } catch (e) {
                alert("Could not mask the selection: " + e.message);
            }
        }

        maskSelectedSubject();

    }
    //Group layers according to doc name - Need Edit
    function nameGroups() {
        var docRef = app.activeDocument;

        // Create a new group
        var layerSetRef = docRef.layerSets.add();

        // Move all layers into the new group
        for (var i = docRef.artLayers.length - 1; i >= 0; i--) {
            docRef.artLayers[i].move(layerSetRef, ElementPlacement.INSIDE);
        }

        // Set the group's name to the document's name without its extension
        var docNameWithoutExtension = docRef.name.replace(/\.[^\.]+$/, '');
        layerSetRef.name = docNameWithoutExtension;
    }
    //Name layers accoridng to the doc name
    function nameLayers() {
        var docRef = app.activeDocument;

        // Get the document's name without its extension
        var docNameWithoutExtension = docRef.name.replace(/\.[^\.]+$/, '');

        // Rename all layers
        for (var i = docRef.artLayers.length - 1; i >= 0; i--) {

            // Use this layerNumber in the name
            docRef.artLayers[i].name = docNameWithoutExtension;
        }
    }
    //Crop 
    function Crop2Size() {
        var status = 0;
        status = selectSubject();

        // Select subject possilble
        if (status == 1) {

            // Initialization
            {
                if (app.documents.length == 0) {
                    alert('No documents are open');
                    return;
                }

                app.preferences.rulerUnits = Units.PIXELS;
                var doc = app.activeDocument;
                if (doc.selection.bounds.length == 0) {
                    alert('No selection in the active document');
                    return;
                }
            }

            maskSelectedSubject();
        }

        // Select subject not possible
        else {
            try {
                var docRef = app.activeDocument;
                var layerRef = docRef.activeLayer;

                docRef.selection.selectAll();
                var savedSelection = docRef.selection;

                var maskLayer = docRef.artLayers.add();
                maskLayer.move(layerRef, ElementPlacement.PLACEAFTER);

                docRef.selection = savedSelection;

                layerRef.grouped = true;
                maskSelectedSubject();


                for (var i = 0; i < docRef.layers.length; i++) {
                    var layer = docRef.layers[i];
                    if (layer.name == "Layer 1") {
                        layer.remove();
                        break; // Exit the loop after the layer is found and removed
                    }
                }


                app.activeDocument.selection.deselect();

            }
            catch (e) {
                alert("Could not mask, scale, and group the layers: " + e.message);
            }
        }
    }
    //Save and close
    function savePhoto() {

        //---------------------------------------------------------------------
        var path = new File($.fileName).parent;
        var doc = app.activeDocument;

        // Create a new folder path
        var newFolderPath = new Folder(path + "/Working Folder");
        // Check if the folder exists, if not create it
        if (!newFolderPath.exists) {
            newFolderPath.create();
        }

        // Define the new file path
        var newFilePath = new File(newFolderPath + "/" + doc.name);
        var file = new File(newFilePath);

        //Settings for JPG
        var jpgSaveOptions = new JPEGSaveOptions();
        jpgSaveOptions.embedColorProfile = true;
        jpgSaveOptions.formatOptions = FormatOptions.STANDARDBASELINE;
        jpgSaveOptions.matte = MatteType.NONE;
        jpgSaveOptions.quality = 12; // Maximum quality

        doc.saveAs(file, jpgSaveOptions, true, Extension.LOWERCASE);

//---------------------------------------------------------------------
        // Create a new folder path
        var newFolderPath1 = new Folder(path + "/Crayola Folder");
        // Check if the folder exists, if not create it
        if (!newFolderPath1.exists) {
            newFolderPath1.create();
        }

        // Define the new file path
        var newFilePath1 = new File(newFolderPath1 + "/temp" + doc.name);
        var file1 = new File(newFilePath1);
        doc.saveAs(file1, jpgSaveOptions, true, Extension.LOWERCASE);

        // Close 
        doc.close(SaveOptions.DONOTSAVECHANGES);

    }
    //Open file and get Filepath
    function openFile() {
        var scriptFolder = new File($.fileName).parent;
        var txtFile = new File(scriptFolder + "/workingFolderPath.txt");
        txtFile.open('r');
        var folderPath = txtFile.read();
        txtFile.close();
        var folderPath = folderPath.replace(/\\/g, "/");
        folderPath = folderPath.replace(/(\r\n|\n|\r)/gm, "");
        folderPath = folderPath + "/Output";
        folderPath = String(folderPath);
        return folderPath;
    }
    //Unlink Mask and Image
    function unlink() {
        var idsetd = charIDToTypeID("setd");
        var desc2006 = new ActionDescriptor();
        var idnull = charIDToTypeID("null");
        var ref129 = new ActionReference();
        var idLyr = charIDToTypeID("Lyr ");
        ref129.putName(idLyr, "Layer 0");
        desc2006.putReference(idnull, ref129);
        var idT = charIDToTypeID("T   ");
        var desc2007 = new ActionDescriptor();
        var idUsrs = charIDToTypeID("Usrs");
        desc2007.putBoolean(idUsrs, false);
        var idLyr = charIDToTypeID("Lyr ");
        desc2006.putObject(idT, idLyr, desc2007);
        executeAction(idsetd, desc2006, DialogModes.NO);
    }
    //Convert RGB to HSV and vice versa
    function RGBtoHSV(r, g, b) {
        r /= 255, g /= 255, b /= 255;

        var max = Math.max(r, g, b);
        var min = Math.min(r, g, b);
        var h, s, v = max;

        var d = max - min;
        s = max === 0 ? 0 : d / max;

        if (max === min) {
            h = 0; // achromatic
        } else {
            switch (max) {
                case r: h = (g - b) / d + (g < b ? 6 : 0); break;
                case g: h = (b - r) / d + 2; break;
                case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }

        return [h, s, v];
    }
    function HSVtoRGB(h, s, v) {
        var r;
        var g;
        var b;

        var i = Math.floor(h * 6);
        var f = h * 6 - i;
        var p = v * (1 - s);
        var q = v * (1 - f * s);
        var t = v * (1 - (1 - f) * s);

        switch (i % 6) {
            case 0: r = v, g = t, b = p; break;
            case 1: r = q, g = v, b = p; break;
            case 2: r = p, g = v, b = t; break;
            case 3: r = p, g = q, b = v; break;
            case 4: r = t, g = p, b = v; break;
            case 5: r = v, g = p, b = q; break;
        }

        return [r * 255, g * 255, b * 255];
    }
    //Get complementary color
    function getPastelComplement(colors) {
        var rComp = 255 - colors.R;
        var gComp = 255 - colors.G;
        var bComp = 255 - colors.B;

        // Convert to HSV
        var hsv = RGBtoHSV(rComp, gComp, bComp);

        // If the hue is in the cyan range, shift it by a certain amount
        if (hsv[0] > 5 / 12 && hsv[0] < 7 / 12) {
            // Shift the hue value by 1/12 (30 degrees) to skip the cyan area
            // You can modify this shift amount to get the desired effect
            hsv[0] += 1 / 12;

            // Make sure the hue stays within the 0-1 range
            if (hsv[0] > 1) {
                hsv[0] -= 1;
            }
        }

        // Make more PASTELLLLLLLLLLLLLLL!
        hsv[2] = Math.min(1, hsv[2] + 0.6);
        hsv[1] = Math.max(0, hsv[1]);

        var rgb = HSVtoRGB(hsv[0], hsv[1], hsv[2]);
        return { R: Math.round(rgb[0]), G: Math.round(rgb[1]), B: Math.round(rgb[2]) };
    }
}



/* MAIN STRING ARGS :)

Intentionally Calling Back My CS136 Trauma

Ughh not the camel case rn

*/
function main() {

    // Work on individual images
    {
        // Initialize variables
        var whiteness = 0;
        MagicWand(TOLERANCE); // Tolerance = 15
        var whiteness = runWhitePercentage();

        if (whiteness > 25) {
            dltBG();
            var colors = getColorsFromCSV();
            var complementaryColor = getPastelComplement(colors);
            zoomOutandSetBG(complementaryColor);
        } else { dltBGandCrop(); }


        if (whiteness <= 25) { rescale(); }
        nameLayers();
        resize();
        activeDocument.flatten();
        savePhoto();
    }
}
main();

















