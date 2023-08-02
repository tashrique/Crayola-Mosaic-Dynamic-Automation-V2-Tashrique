var doc = app.activeDocument;
activeDocument.activeLayer.isBackgroundLayer = false;


// Calculate white percentage
function getWhitePercentage(doc) {
    var totalPixels = doc.width.value * doc.height.value;

    var h = doc.histogram
    var selectedPixels = 1;
    for (var i = 200; i < 256; i++) { selectedPixels += h[i] }
    whitePercentage = (selectedPixels / totalPixels) * 100
    return whitePercentage;
}


whiteness = getWhitePercentage(doc);
whiteness;