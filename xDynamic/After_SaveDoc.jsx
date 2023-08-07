function saveInNewFormat(doc) {
    // Get the current file path
    var filePath = doc.path;
    var tname = doc.name;
    app.activeDocument = doc;
    
    // Extract the original file name without the extension
    var originalFileName = doc.name.replace(/\..+$/, '');

    // New names for PSD and JPG files
    var newPsdName = originalFileName + '-DF.psd';
    var newJpgName = originalFileName + '-CP.jpg';

    // Create new file objects with the new names
    var newPsdFile = new File(filePath + '/' + newPsdName);
    var newJpgFile = new File(filePath + '/' + newJpgName);

    // Save the PSD with the new name
    doc.saveAs(newPsdFile, new PhotoshopSaveOptions(), true, Extension.LOWERCASE);

    // Save a JPG copy with the new name
    var jpgSaveOptions = new JPEGSaveOptions();
    jpgSaveOptions.embedColorProfile = true;
    jpgSaveOptions.formatOptions = FormatOptions.STANDARDBASELINE;
    jpgSaveOptions.matte = MatteType.NONE;
    jpgSaveOptions.quality = 12; // Maximum quality
    doc.saveAs(newJpgFile, jpgSaveOptions, true, Extension.LOWERCASE);
    
    // Delete the original file
    doc.close(SaveOptions.DONOTSAVECHANGES);
    var originalFile = new File(filePath + '/' + tname);
    originalFile.remove();
}

// Loop over all open documents
for (var i = app.documents.length - 1; i >= 0; i--) {
    saveInNewFormat(app.documents[i]);
}
