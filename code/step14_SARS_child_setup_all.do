clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

/*
use "SARS_child6_setup.dta",clear
merge 1:1 sampleid using "height.dta"

drop nowcm6
rename nowft6 nowcm6

keep if _merge==3

save "SARS_child6_setup.dta",replace
*/

use "SARS_child_setup.dta",clear

append using "SARS_child6_setup.dta"
append using "SARS_child7_setup.dta"

replace childby=childby6 if childby==.
replace childbm=childbm6 if childbm==.

replace childby=childby7 if childby==.
replace childbm=childbm7 if childbm==.

tab childby,m
tab childbm,m

/*
gen bm = floor((12)*runiform() + 1) if childbm==.
tab bm
replace childbm=bm if childbm==.
drop bm
*/

*sample restriction
replace childhkb=childhkb6 if childhkb==.
replace childhkb=childhkb7 if childhkb==.
tab childhkb,m

keep if childhkb==1

save "SARS_child_setup.dta",replace
