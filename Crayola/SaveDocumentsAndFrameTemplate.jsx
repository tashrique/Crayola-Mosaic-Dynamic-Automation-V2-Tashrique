//Initialize
var scriptFolder = new File($.fileName).parent;
var templatePath = scriptFolder + "/Frame.jpg";
var templateFile = new File(templatePath);
var template = app.open(templateFile);




//Go through loop and perform copy and save
for (var i = app.documents.length - 1; i >= 0; i--) {
    var currentDocument = app.documents[i];
    app.activeDocument = currentDocument;
    // Resize
    currentDocument.resizeImage(template.width * 0.63, template.height * 0.63, currentDocument.resolution, ResampleMethod.BICUBIC);
    // Unlock layer
    if (currentDocument.activeLayer.isBackgroundLayer) {
        currentDocument.activeLayer.isBackgroundLayer = false;
    }

    // Duplicate current document's layer to the template
    currentDocument.activeLayer.duplicate(template, ElementPlacement.PLACEATBEGINNING);
    // Activate the template
    app.activeDocument = template;
    // Center the duplicated layer on the template
    var duplicatedLayer = template.layers[0]; // Assuming the duplicated layer is at the beginning
    var xOffset = (template.width - duplicatedLayer.bounds[2]) / 2;
    var yOffset = (template.height - duplicatedLayer.bounds[3]) / 2;
    duplicatedLayer.translate(xOffset, yOffset);


    // Export the resultant image
    var jpgSaveOptions = new JPEGSaveOptions();
    jpgSaveOptions.embedColorProfile = true;
    jpgSaveOptions.formatOptions = FormatOptions.STANDARDBASELINE;
    jpgSaveOptions.matte = MatteType.NONE;
    jpgSaveOptions.quality = 12; // Maximum quality

    var originalFileName = currentDocument.name.replace(/\..+$/, '');
    var newJpgName = originalFileName + '-CPF.jpg';
    var newJpgFile = new File(currentDocument.path + '/' + newJpgName);
    template.saveAs(newJpgFile, jpgSaveOptions, true, Extension.LOWERCASE);

    // Delete the duplicated layer from the template to prepare for the next iteration
    duplicatedLayer.remove();

}





// Close all open documents without saving
while (app.documents.length > 0) {
    app.documents[0].close(SaveOptions.DONOTSAVECHANGES);
}




