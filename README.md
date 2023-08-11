### Dynamic Mosaic Automation Tool v2 Artkive 👨🏻‍💻


## Description

This tool automates the creation of 5x5 mosaic and 3x3 Crayola products. It takes in a directory of order folders, then generates a mosaic by selecting, editing, and arranging the images to construct the desired mosaic. It also has a review step in order for the user to verify the results generated by the tool.

## What it does
- Finds Your Images: The tool looks inside a folder called 'Orders in Progress' on your computer.
- Selects the Best Pictures: It picks colorful, vivid pictures and trims any white borders around them.
- Arranges the Images: For a 5x5 mosaic, it takes the five most colorful images and puts them in special places, then shuffles the rest. For a 3x3 Crayola, it uses the top 9 images and arranges them randomly.
- Adjusts Non-Rectangular Images: If an image isn't a regular shape, the tool gives it a gentle-colored background to keep the grid look.
- Lets You Edit: You can open the created files in Photoshop and change things like position and size.
- Prepares for Printing: Use the 'Finalize' script to create files ready for high-quality printing and to show your customer a preview.


## Assumptions
Make sure your order folders have:
- The order number as their name.
- No white borders around the images.
- No subfolders within them.
- The PSD files are opened in Photoshop before running `Finalize` script



## How to Use

![image](https://github.com/tashrique/dynamic-automation-v2-artkive/assets/105752119/430af5ae-7096-4f48-9b4d-e7e3aa4a556d)

These are the files and folders that will be visible to the user. In order to start the automation, copy all the order folders inside the `Orders in Progress` and double click the `Start Crayola-Mosaic Automation`
shortcut. You will be prompted with the following dialog box: 

![image](https://github.com/tashrique/dynamic-automation-v2-artkive/assets/105752119/df0ae862-f380-491b-b023-d55cf962c265)

Select the automation you want to run. After you click run, it will start generating the PSDs. The PSDs will be saved in a folder named `000 Output Month-Day` format like the following: 

![image](https://github.com/tashrique/dynamic-automation-v2-artkive/assets/105752119/fff373ad-2cbe-4c7f-8c19-7ed97255328e)


When the PSDs are done generating, you can go inside the output folder and open all the PSDs in Photoshop and edit as you need. You will also have a file called `Shuffle.atn` inside the `Source Code` folder that you can import into Photoshop as an action folder. This action can be used to rearrange the images in the mosaic. It has two actions separated for Mosaic and Crayola.

![image](https://github.com/tashrique/dynamic-automation-v2-artkive/assets/105752119/a9830491-3de8-4a17-b876-8a8e4fcca001)

After you are done reviewing the PSDs, don't close them. Keep them open and run the `Finalize` script. This will generate a High-Res JPG for print and a Customer Proof Frame for each of the files that are open in Photoshop currently. It will close every doc afterward.

Watch the following video for a more in-depth explanation - 
- [Part 1](https://www.loom.com/share/13d3a432eadd47dfaccbd3964909f239?sid=49d83cc0-7226-458a-9cb4-607009ccee70)
- [Part 2](https://www.loom.com/share/b209735de59d43b388ea0f1483c3319f?sid=fbacfabc-a26c-4579-a3fd-68f7f77950a4)
- [Part 3](https://www.loom.com/share/cbfd7aa858d1479bb43dd927779a42a0?sid=14eac5a8-0c55-4eb3-a770-92723fd846d9)


## Credits

Created by `Tashrique Ahmed`.

with `Cipriano Taylor`.

[The Kive Company](https://www.artkiveapp.com)
