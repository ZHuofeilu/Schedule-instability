
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

//keep if typical==1
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
replace workplace=1 if homework_i>0 &  workplace_i==0 & other_i==0 //home
replace workplace=10 if workplace_i==1 & nonworkplace_time==0 //Office
replace workplace=100 if workplace_i==0 & nonworkplace_time==0 //no work
replace workplace=1000 if workplace==. //mix

sort mainid
by mainid: egen mean_workplace = mean(workplace)
by mainid: egen min_workplace = min(workplace)
by mainid: egen mmax_workplace = max(workplace)
gen location = .
replace location = 1 if mean_workplace == 1 & min_workplace==1 & mmax_workplace==1
replace location = 2 if mean_workplace == 10 & min_workplace==10 & mmax_workplace==10
replace location = 3 if mean_workplace == 100 & min_workplace==100 & mmax_workplace==100
replace location = 4 if mean_workplace == 1000 & min_workplace==1000 & mmax_workplace==1000
replace location = 5 if location==. & mean_workplace < 300 
replace location = 6 if location==. 

//new_var  1（home）
//new_var  2（office）
//new_var  3（no work）
//new_var  4（always mix）
//new_var  5（home+work）
//new_var  6（mix）
sort mainid
by mainid: egen mean_hour = mean(paid_1)

drop if location==3
recode location 1=1 2=2 4=3 5=4 6=5

//new_var  1（home）
//new_var  2（office）
//new_var  3（always mix）
//new_var  4（home+work）
//new_var  5（mix）



gen location2 = .
replace location2 = 1 if mean_workplace == 1 & min_workplace==1 & mmax_workplace==1
replace location2 = 2 if mean_workplace == 10 & min_workplace==10 & mmax_workplace==10
replace location2 = 3 if mean_workplace == 100 & min_workplace==100 & mmax_workplace==100
replace location2 = 4 if location2==. 

save 3days_cleaned, replace




//enjoyment.dta
keep pidp w_pri1-w_pri144 enj1-enj144

reshape long w_pri enj, i(pidp) j(diaryord)

g w_enj=w_pri*enj

keep pidp w_enj diaryord
reshape wide w_enj,i(pidp) j(diaryord)

egen work_enj=rowtotal(w_enj*)

keep pidp work_enj

save "enj.dta",replace

use "3days_cleaned.dta", replace
merge 1:m pidp using "enj"
drop _merge

save "3days_cleaned.dta",replace

//nonwork
keep pidp w_pri1-w_pri144 enj1-enj144

reshape long w_pri enj, i(pidp) j(diaryord)
recode w_pri 0=1 1=0
g w_enj=w_pri*enj

keep pidp w_enj diaryord
reshape wide w_enj,i(pidp) j(diaryord)

egen nonwork_enj=rowtotal(w_enj*)

keep pidp nonwork_enj

save "nonwork_enj.dta",replace

use "3days_cleaned.dta", replace
merge 1:m pidp using "nonwork_enj"
drop _merge



replace work_enj=work_enj/paid_1
replace nonwork_enj=nonwork_enj/(144-paid_1)


save "3days_cleaned.dta",replace




//
drop if dday >5
save "3days_cleaned(weekday)", replace


