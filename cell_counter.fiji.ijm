macro "-" {} //menu divider

macro "Counter" {

	// This macro can count cells or nodules. Parameters that can be changed are:
	// output directory, size and circularity of particles / as well as outliers, color channel
	// Change outputdir to the output directory, ensuring there is a slash / at the end

	//outputDir = getDirectory("Choose input directory");

	List.clear()
	run("Clear Results");
	selectImage(getImageID());
	originalName = getTitle();
	
	newTitle = originalName + "_duplicated";
	// Duplicate the image and split color channels
	run("Duplicate...", "title=[" + newTitle + "]");
	selectWindow(originalName)
	run("Split Channels");
	selectWindow(originalName + " (green)");
	close();
	selectWindow(originalName + " (blue)");
	close();

	// Apply pseudo flat field correction and contrast enhancement (contrast not necessary)
	selectWindow(originalName + " (red)");
	run("Enhance Contrast...", "saturated=0.3");
	selectWindow(originalName + " (red)");
	run("Pseudo flat field correction", "blurring=100");


	// Despeckle and remove outliers - can change radius and threshold here
	selectWindow(originalName + " (red)");
	run("Despeckle");
	selectWindow(originalName + " (red)");
	run("Remove Outliers...", "radius=10 threshold=1 which=Dark");
	selectWindow(originalName + " (red)");
	run("Remove Outliers...", "radius=3 threshold=1 which=Bright");

	// Adjust threshold - Don't mess with this
	selectWindow(originalName + " (red)");
	run("Threshold...");
	setAutoThreshold("Default");
	run("Convert to Mask");
	// Fill holes if necessary 
	//selectWindow(originalName + " (red)");
	//run("Fill Holes");
	// Apply watershed
	selectWindow(originalName + " (red)");
	run("Watershed");


	// Analyze particles - change size and circularity here!
	selectWindow(originalName + " (red)");
	run("Analyze Particles...", "size=500-Infinity pixel circularity=0.3-1.00 show=[Bare Outlines] add summarize display");

	selectWindow(originalName + " (red)_background");
	selectWindow(newTitle);
	roiManager("Show All");

}

macro "Batch Counter" {

	// This macro can count cells or nodules. Parameters that can be changed are:
	// output directory, size and circularity of particles / as well as outliers, color channel

	// You are FIRST prompted for the INPUT directory (where your pictures are)
	// You are SECONDLY prompted for the OUTPUT directory (where you want to store your results)

	inputDir = getDirectory("Choose input directory");
	outputDir = getDirectory("Choose output directory");

	list = getFileList(inputDir);
	for (i = 0; i < list.length; i++) {
		if (endsWith(list[i], ".tif") || endsWith(list[i], ".jpg") || endsWith(list[i], ".png")) {
			List.clear()
			run("Clear Results");
			roiManager("reset");
			open (inputDir + list[i]);
			selectImage(getImageID());
			originalName = getTitle();

			// Duplicate the image and split color channels
			run("Duplicate...", "title=[" + originalName + "]_duplicated");
			selectWindow(originalName);
			run("Split Channels");
			selectWindow(originalName + " (green)");
			close();
			selectWindow(originalName + " (blue)");
			close();

			// Apply pseudo flat field correction and contrast enhancement (contrast not necessary)
			selectWindow(originalName + " (red)");
			run("Enhance Contrast...", "saturated=0.3");
			selectWindow(originalName + " (red)");
			run("Pseudo flat field correction", "blurring=100");

			// Despeckle and remove outliers - can change radius and threshold here
			selectWindow(originalName + " (red)");
			run("Despeckle");
			selectWindow(originalName + " (red)");
			run("Remove Outliers...", "radius=10 threshold=1 which=Dark");
			selectWindow(originalName + " (red)");
			run("Remove Outliers...", "radius=3 threshold=1 which=Bright");

			// Adjust threshold - Don't mess with this
			selectWindow(originalName + " (red)");
			run("Threshold...");
			setAutoThreshold("Default");
			run("Convert to Mask");

			// Apply watershed
			selectWindow(originalName + " (red)");
			run("Watershed");


			// Analyze particles - change size and circularity here!
			selectWindow(originalName + " (red)");
			run("Analyze Particles...", "size=700-Infinity circularity=0.4-1.00 show=[Bare Outlines] add summarize display");


			selectWindow(originalName + " (red)_background");
	
			selectWindow(originalName + "_duplicated");
			roiManager("Show All");
			run("Flatten");
			saveAs("Tiff", outputDir+originalName+"_duplicated.tif");

			// Saving Results

			selectWindow(originalName + " (red)");
			run("Flatten");
			saveAs("Tiff", outputDir+originalName+"_outline.tif");

			selectWindow("Summary");
			saveAs("Results", outputDir+originalName+"_summary.csv");

			selectWindow("Results");
			saveAs("Results", outputDir+originalName+"_results.csv");

			// Close all windows
			List.clear()
			roiManager("reset");
			selectWindow("ROI Manager");
			close();
			selectWindow("Results");
			close();
			selectWindow(originalName+"_summary.csv");
			close();
			close("*");
		}
	}
	showMessage("Macro complete");
}