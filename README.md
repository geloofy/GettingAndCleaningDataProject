GettingAndCleaningDataProject
=============================

Course Project for Coursera Getting and Cleaning Data course

To run, first ensure source files are available in working directory.
Run source("run_analysis.R") from R console.

run_analysis.R
-------------------------------

Main analysis script
* Loads the required packages: "data.table", "reshape2", "knitr"
* Initializes variables
* Imports data
* Merges data sets
* Extracts mean and standard deviation
* Applies descriptive activity names
* Applies descriptive variable names - separates features from featureName
* Writes output Tidy.txt
* Generates CodeBook.md

codebook.Rmd
-------------------------------

Codebook markup used for generating codebook

