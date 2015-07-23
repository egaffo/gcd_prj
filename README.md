This repo implements the course project of the Coursera "Getting and Cleaning Data" course 2015.
- README.md is this file
- run_analysis.R script performs all the processings of the data
- CodeBook.md describes the variables, the data, and any transformations or work that are performed to clean up the data

To run the analysis from the command line:
  R --no-save < run_analysis.R
The script will download the data and save it in the current directory as data.zip. The script automatically uncompress the package and run the analysis. 
When finished you will have the result in the tidyDS.txt file.

Package requirements:
- plyr
- dplyr

sessionInfo():
R version 3.2.1 (2015-06-18)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 14.04.2 LTS

locale:
 [1] LC_CTYPE=it_IT.UTF-8       LC_NUMERIC=C               LC_TIME=it_IT.UTF-8        LC_COLLATE=it_IT.UTF-8    
 [5] LC_MONETARY=it_IT.UTF-8    LC_MESSAGES=it_IT.UTF-8    LC_PAPER=it_IT.UTF-8       LC_NAME=C                 
 [9] LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=it_IT.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] dplyr_0.4.2 plyr_1.8.3 

loaded via a namespace (and not attached):
[1] lazyeval_0.1.10 magrittr_1.5    R6_2.0.1        assertthat_0.1  parallel_3.2.1  DBI_0.3.1       tools_3.2.1     Rcpp_0.11.6    

RStudio Version 0.99.465