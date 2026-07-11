# About

Creates PNG plots for joint confidence regions from five different approaches using the csv file in the `data` folder and outputs them in `plot_outputs` folder.

# Usage

1. Download the folder (Click the green button `Code` on the upper part of this page and select `Download ZIP`) then unzip/extract.
   <img width="891" height="445" alt="image" src="https://github.com/user-attachments/assets/fd062d00-cc5c-4ff2-99e1-d2c165ba532b" />

2. Double click the `.Rproj` file (highlighted in the below image) to open it in RStudio.  
   <img width="332" height="232" alt="image" src="https://github.com/user-attachments/assets/ccad58ad-ddb8-4c8e-a198-581ad7822cfd" />

3. In the R Console, run `renv::restore()`. Type Y then press Enter to agree when asked. Wait for updates and installs to get done.
   <img width="991" height="692" alt="image" src="https://github.com/user-attachments/assets/61762b01-7b22-42d5-92e5-1cbffdfd6906" />
 
4. Store your updated csv file to plot in the `data` folder. The code expects only the format and filename of the sample csv file found in the `data` folder. Note that I changed the filename's version number to use three digits (`v005` instead of `v5`); please adjust accordingly. In case of curiosity, I used `mean_travel_time_ranking_2011.rds` in `data` folder mainly for the `ISO`.
   
5. Open `main.R` and change the value of `your_csv` (line 1 of the file) to the filename of the data you want to use for plotting. Please mind the version number (refer to previous step). 
6. In the R Console, run `source("main.R")`. This will produce the needed plots (PNG format) and store them in `plot_outputs` folder. The filenames of the generated plots follow the version number of your csv file. You may ignore the warning messages if there are no issues, else please let me know.
   <img width="1470" height="343" alt="image" src="https://github.com/user-attachments/assets/dabe26d5-9659-4f30-beb3-e13c84dba734" />


# Notes

- If values are not yet ready for some of the approaches, please leave them blank but keep the labels, similar to what's shown in the sample csv file. This is because the row numbers are hard-coded.
- The `main.R` may be tweaked in a way that you prefer.
