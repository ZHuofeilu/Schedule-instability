Now we have two cleaned datasets: 
(1) 3days_cleaned [the one with weekend diaries] (2) 3days_cleaned(weekday) [the one with only weekday diaries]
Note: The code is written by using stata (file name "data cleaning")

By using these two datasets, in R, we generated other two datasets with Manhattan distance:
(1) schedule_analysis(weekday) and (2) schedule_analysis(weekend)
Note: The code is written by using quarto (file name "code_quarto")

To start analysis, please use stata dofile "data analysis" and use (1) schedule_analysis(weekday) or (2) schedule_analysis(weekend) as the data.

