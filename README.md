# What this does

Creates plots for joint confidence regions from five different approaches using the csv file in the `data` folder.

# How to use

1. Download the folder (Click the green button `Code` and select `Download ZIP`) then unzip.
   <img width="878" height="407" alt="image" src="https://github.com/user-attachments/assets/ca76b77f-043f-43fe-a46f-c69cbcfe2105" />

3. Open the `.Rproj` file in RStudio.
4. On R Console, run `renv::restore()`
5. Store your new file to plot in the `data` folder. Make sure it follows the format of the file (both the filename and content). Please see sample in the `data` folder.
6. Open `main.R` and change the value of `your_csv` (line 1 of the file) to the filename of the data you want to use for plotting.
5. On R Console, run `source("main.R")`
6. Find the outputs in `plot_outputs` folder

# Notes

If values are not yet ready for some of the approaches, please leave them blank but keep the labels, similar to what's shown in the sample file. This is because the row numbers are hard-coded. 
