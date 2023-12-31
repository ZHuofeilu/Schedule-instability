
//Yucheng He 2023-12-23T22:40:14Z
pwd
// cd ./YOUR TARGET WORKING DIRECTORY


use uk_6_wave_caddi,replace
drop if survey == 1
save uk_5_wave_caddi, replace

use uk_5_wave_caddi
keep if emplnow < 5
keep if emplnow > 0
g work_from_home = emplnow
recode work_from_home 1/2 = 1 3/4 = 2
g class=dclasuk
drop if class>3
drop if econstat==9
g child = nkids
recode child 0 = 0 1/5 = 1
gen weekend = 1
replace weekend = 2 if dday > 5 
replace marstat = . if marstat <0 

keep if typical==1
egen pidp = group( mainid diaryord)
order pidp
sort pidp
save 5_wave_cleaned, replace


use 5_wave_cleaned


//g Work
foreach var of varlist pri1-pri144 {
egen w_`var' = anymatch(`var'),v(117)
}

//Housework
foreach var of varlist pri1-pri144 {
egen h_`var' = anymatch(`var'),v(105,106,107,108,121,122,123,124,126)
}

//Free time-leisure actrivities
foreach var of varlist pri1-pri144 {
egen f_`var' = anymatch(`var'),v(102,111,112,113,114,115,116,125,127,128,129,130,131,132,133,135,136)
}

//Personal care
foreach var of varlist pri1-pri144 {
egen p_`var' = anymatch(`var'),v(101,103,104,109,110)
}

//Sleep
foreach var of varlist pri1-pri144 {
egen s_`var' = anymatch(`var'),v(101)
}

save 3days_cleaned, replace

//Frag 
use 3days_cleaned
keep pidp w_pri1-w_pri144
reshape long  w_pri,i(pidp) j(time)
g b=w_pri
xtset pidp time
gen lag=l.b
g c=b-lag
g f=c
keep pidp time f
reshape wide f,i(pidp)j(time)
egen frag_start=rcount( f1-f144 ), c(@==1)
egen frag_end=rcount( f1-f144 ), c(@==-1)

save frag_covid, replace

clear
use 3days_cleaned
merge 1:m pidp using "frag_covid"
keep if _merge == 3
drop _merge

//drop if frag_start==0


egen unpaid_1 = rowtotal(h_pri*)
egen paid_1 = rowtotal(w_pri*)
egen personal_1 = rowtotal(p_pri*)
egen sleep = rowtotal(s_pri*)
foreach var of varlist pidp-sleep {
replace `var' = . if `var' <0 
}

save 3days_cleaned, replace


//Workplace
use 3days_cleaned
foreach var of varlist loc1-loc144 {
egen h_`var' = anymatch(`var'),v(201)
}

foreach var of varlist loc1-loc144 {
egen w_`var' = anymatch(`var'),v(202)
}

foreach var of varlist loc1-loc144 {
egen o_`var' = anymatch(`var'),v(203)
}
keep pidp w_pri1-w_pri144 h_loc1-h_loc144 w_loc1-w_loc144 o_loc1-o_loc144 diaryord
reshape long w_pri h_loc w_loc o_loc,i(pidp)j(time)
g homework=w_pri*h_loc
g work_work=w_pri*w_loc
g other_work=w_pri*o_loc
keep pidp time homework work_work other_work
reshape wide homework work_work other_work,i(pidp) j(time)
egen homework_time=rowtotal(homework*)
egen workplace_time=rowtotal(work_work*)
egen other_time=rowtotal(other_work*)
keep pidp homework_time workplace_time other_time

save work_place, replace


use 3days_cleaned
merge 1:m pidp using "work_place"
keep if _merge==3
drop _merge

g homework_i=homework_time
g workplace_i=workplace_time
g other_i=other_time
g nonworkplace_time=homework_time+other_time

recode homework_i 0=0 1/102=1
recode workplace_i 0=0 1/max=1
recode other_i 0=0 1/max=1

g workplace=.
replace workplace=1 if workplace_i==0 //Non Workplace
replace workplace=2 if nonworkplace_time==0 //On Site
replace workplace=3 if workplace==. //Mix



sort mainid
by mainid: egen min_workplace = min(workplace)
by mainid: egen max_workplace = max(workplace)
gen change_workplace = min_workplace != max_workplace

gen location = .
replace location = 1 if change_workplace == 0 & min_workplace == 1
replace location = 2 if change_workplace == 0 & min_workplace == 2
replace location = 3 if change_workplace == 1
//new_var 为 1（non workplace）
//new_var 为 2（workplace）
//new_var 为 3（mix）

save 3days_cleaned, replace


//
drop if dday >5
save "3days_cleaned(weekday)", replace
