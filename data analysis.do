label define location_label 1 "Always Home" 2 "Always Office" 3 "Always Mix" 4 "Home+Office" 5 "Mix" 

label values location location_label



g work_from_home2=empbfore
recode work_from_home2 1/2=1 3/4=2 5/max=.


g place =.
replace place =1 if location2==1 & work_from_home==1
replace place =2 if location2==1 & work_from_home==2
replace place =3 if location2==2 & work_from_home==1
replace place =4 if location2==2 & work_from_home==2
replace place =5 if location2==4 & work_from_home==1
replace place =6 if location2==4 & work_from_home==2

label define place_label1 1 "Home(Office)" 2 "Home(home)" 3 "Office(Office)" 4 "Office(home)" 5 "Mix(Office)" 6 "Mix(home)"

label values place place_label1



g place2=place
recode place2 1=1 2=2 3=3 4=3 5=4 6=5



g part_time=emplnow

recode part_time 1=1 2=2 3=1 4=2

g part =.
replace part =1 if location2==1 & part_time==1
replace part =2 if location2==1 & part_time==2
replace part =3 if location2==2 & part_time==1
replace part =4 if location2==2 & part_time==2
replace part =5 if location2==4 & part_time==1
replace part =6 if location2==4 & part_time==2

label define part_label 1 "Home(FT)" 2 "Home(PT)" 3 "Office(FT)" 4 "Office(PT)" 5 "Mix(FT)" 6 "Mix(PT)"

label values part part_label



g part2=part
recode part2 1=1 2=2 3=3 4=3 5=4 6=5

// location

reg mean_distance ib4.location ib2.emplnow i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg mean_work_hours_diff ib4.location ib2.emplnow i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg av_pressure ib4.location ib2.emplnow i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg mean_hour ib4.location ib2.emplnow i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat


margins,at(location=(1 2 3 4 5))
marginsplot

//part2
reg mean_distance ib6.part  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg mean_work_hours_diff ib6.part  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg av_pressure ib6.part  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg mean_hour ib6.part  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat



margins,at(part=(1 2 3 4 5 6))
marginsplot


//place
reg mean_distance ib6.place  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg mean_work_hours_diff ib6.place  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg av_pressure ib6.place  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat

reg  mean_hour ib6.place  i.work_from_home2  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat


margins,at(place=(1 2 3 4 5 6))
marginsplot



//
reg av_pressure mean_work_hours_diff mean_distance mean_hour  i.child i.sex      i.class   i.marstat i.dagegrp i.econstat



g diff=mean_work_hours_diff 

khb regress av_pressure ib4.location || diff mean_hour, concomitant( i.child i.sex      i.class   i.marstat i.dagegrp i.econstat) summary disentangle
