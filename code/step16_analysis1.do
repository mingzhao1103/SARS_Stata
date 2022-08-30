
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
*random experiment I
**1-year exposure pre 

//treatment#1
*1: Born and pregnant during SARS

*control vs treat12

//treatment#2
*1: Born during SARS
*2: Pregnant during SARS

*control vs treat22 vs treat23

//treatment#3
*1: First trimester during SARS
*2: Second trimester during SARS
*3: Third trimester during SARS

*control vs treat32 vs treat33 vs treat34

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child_analysis_1.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

replace bwkg=3.8 if bwkg==7.5

gen treat42=0 if control==1
replace treat42=1 if treat32==1

gen treat43=0 if control==1
replace treat43=1 if treat33==1

gen treat44=0 if control==1
replace treat44=1 if treat34==1

reg bwkg treat42 if nomi
outreg2 using "table2.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
reg bwkg treat42 treat33 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat43 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 2) label
reg bwkg treat43 treat32 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 2) label

reg bwkg treat44 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 3) label
reg bwkg treat44 treat32 treat33 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 3) label


reg bwkg treat32 treat33 treat34 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

/*
set seed 20200523
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table4.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
*/



use "SARS_child_analysis_1.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

replace bwkg=3.8 if bwkg==7.5

gen treat42=0 if control==1
replace treat42=1 if treat32==1

gen treat43=0 if control==1
replace treat43=1 if treat33==1

gen treat44=0 if control==1
replace treat44=1 if treat34==1


psmatch2 treat42 childmale momeduy lninc momage momage2 if nomi, out(bwkg) neighbor(1) noreplace ate logit 


gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2

reg bwkg treat32
outreg2 using "table3.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

//save "match_1st.dta",replace



use "SARS_child_analysis_1.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

replace bwkg=3.8 if bwkg==7.5

gen treat42=0 if control==1
replace treat42=1 if treat32==1

gen treat43=0 if control==1
replace treat43=1 if treat33==1

gen treat44=0 if control==1
replace treat44=1 if treat34==1


psmatch2 treat43 childmale momeduy lninc momage momage2 if nomi, out(bwkg) neighbor(1) noreplace ate logit 


gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2

reg bwkg treat33
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 2) label

reg bwkg treat32 treat33 treat34
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 2) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 2) label

//save "match_2nd.dta",replace



use "SARS_child_analysis.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

replace bwkg=3.8 if bwkg==7.5

gen treat42=0 if control==1
replace treat42=1 if treat32==1

gen treat43=0 if control==1
replace treat43=1 if treat33==1

gen treat44=0 if control==1
replace treat44=1 if treat34==1


psmatch2 treat44 childmale momeduy lninc momage momage2 if nomi, out(bwkg) neighbor(1) noreplace ate logit 


gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2

reg bwkg treat34
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 3) label

reg bwkg treat32 treat33 treat34
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 3) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 3) label

//save "match_3rd.dta",replace

 
/*
use "match_1st.dta",clear
gen match=1
save "match_1st.dta",replace

use "match_2nd.dta",clear
gen match=2
save "match_2nd.dta",replace

use "match_3rd.dta",clear
gen match=3
save "match_3rd.dta",replace


use "match_1st.dta",clear 
append using "match_2nd.dta"
append using "match_3rd.dta"

order sampleid control bwkg childmale momeduy lninc momage momage2 match treat42 treat43 treat44






















