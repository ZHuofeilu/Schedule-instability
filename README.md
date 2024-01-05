Introduction

	Data cleaning (recovered): the do file for data cleaning
	Data analysis: the dofile for data analysis

	Schedule_quarto: the quarto file for paper writing
	Code_quarto: the quarto file for generating variables

	3days_cleaned.dta: is the cleaned data with both weekday and weekend diaries
	3days_cleaned(weekday).dta: is the cleaned data with only weekday diaries

	Schedule_analysis(weekend): is the sliced sample with Manhattan distance (generated from 3days_cleaned)
	Schedule_analysis(weekay): is the sliced sample with Manhattan distance generated from 3days_cleaned(weekday)

The cleaning process is: 

1.	Data cleaning (stata do file) [get 3days_cleaned]
2.	Code_quarto [get Schedule_analysis(weekend)/(weekday)]
3.	Data analysis (stata do file)
