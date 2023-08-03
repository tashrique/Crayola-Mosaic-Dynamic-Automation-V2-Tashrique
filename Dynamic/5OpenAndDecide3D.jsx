// Open folder
{
	var scriptFolder = new File($.fileName).parent;
	var txtFile = new File(scriptFolder + "/workingFolderPath.txt");
	txtFile.open('r');
	var folderPath = txtFile.read();
	txtFile.close();
	var folderPath = folderPath.replace(/\\/g, "/");
	folderPathRaw = folderPath.replace(/(\r\n|\n|\r)/gm, "");
	folderPathOk = folderPathRaw + "/Output";
	var folder = new Folder(folderPathOk);
}
// Recursive function to update linked smart objects
function refreshLinkedSmartObjects(layerSet) {
	for (var i = 0; i < layerSet.layers.length; i++) {
		var layer = layerSet.layers[i];

		// If the layer is a smart object and is linked, update it
		if (layer.kind === LayerKind.SMARTOBJECT && layer.linked) {
			try {
				layer.updateSmartObject();  // This updates the smart object

			} catch (e) {
				alert("An error occurred while updating a smart object: " + e);
			}
		}

		// If the layer is a LayerSet (group), recursively update its layers
		if (layer.typename === 'LayerSet') {
			refreshLinkedSmartObjects(layer);
		}
	}
}
//Save as PSD
function saveAsPSD(saveFile) {
	var psdSaveOptions = new PhotoshopSaveOptions();
	psdSaveOptions.embedColorProfile = true;
	psdSaveOptions.layers = true;  // Preserve layers
	app.activeDocument.saveAs(saveFile, psdSaveOptions, true);
	app.activeDocument.close(SaveOptions.DONOTSAVECHANGES);

}
// Rasterize linked layers
function processLayers(layers) {
	for (var i = 0; i < layers.length; i++) {
		var layer = layers[i];

		if (layer.typename === 'ArtLayer') {
			try {
				if (layer.kind === LayerKind.SMARTOBJECT) {
					layer.rasterize(RasterizeType.ENTIRELAYER)
				}
			} catch (e) {
				alert("An error occurred while trying to embed a smart object: " + e);
			}
		} else if (layer.typename === 'LayerSet') {
			// Use layer.layers if it's available
			var subLayers = layer.layers || layer.layerSets;

			if (subLayers) {
				// If the layer is a group (LayerSet), recursively process its layers
				processLayers(subLayers);
			}
		}
	}
}

function main(folder) {


	// Initiliaze
	{

		while (app.documents.length > 0) {
			activeDocument.close(SaveOptions.DONOTSAVECHANGES);
		}

		var scriptFolder = new File($.fileName).parent;
		var templateFile = new File(scriptFolder + "/template.psd");
		var newDoc = app.open(templateFile);
		app.activeDocument = newDoc;
	}

	if (folder.exists) {
		var files = folder.getFiles();


		// Process each photo and save in Working Folder
		{
			for (var i = 0; i < files.length; i++) {
				var file = files[i];

				if (file instanceof File && file.name.match(/\.(jpg|jpeg|png|gif)$/i)) {
					app.open(file);
					// Run processImages for each image
					{
						var processScript = File(scriptFolder + "/5-2processImage.jsx");
						if (processScript.exists) {
							// Setting argument
							$.evalFile(processScript);
						} else {
							alert("Script file does not exist.");
						}
					}
				}
			}
		}

		//Refresh images
		{
			app.activeDocument = newDoc;
			refreshLinkedSmartObjects(newDoc);
		}

		// Save the document
		{
			var folder = new Folder(folderPathRaw);
			var lastPart = folder.name;

			var date = new Date();
			var formattedDate = (date.getMonth() + 1) + "-" + date.getDate(); // Months are 0-based in JavaScript
			var outputFolder = new File($.fileName).parent.parent;

			var saveFolder = new Folder(outputFolder + "/000 Output " + formattedDate); // Specify the folder path
			if (!saveFolder.exists) {
				saveFolder.create(); // If the folder doesn't exist, create it
			}

			var fileLocation = saveFolder + "/" + lastPart;
			var saveFile = new File(fileLocation); // Specify the file name
			saveAsPSD(saveFile);
		}

		//Open generated PSD
		{
			var reOpen = new File(fileLocation + ".psd");
			var newDoc = app.open(reOpen);
		}

		// Rasterize linked layers
		{
			processLayers(app.activeDocument.layers);
		}


		// Save and close the document
		{
			app.activeDocument.save();
			app.activeDocument.close(SaveOptions.DONOTSAVECHANGES);
		}



	} else {
		alert("Output folder does not exist");
	}
}


main(folder);