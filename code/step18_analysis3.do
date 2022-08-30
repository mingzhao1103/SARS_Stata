clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child_analysis.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

tab bwkg
replace bwkg=3.8 if bwkg==7.5

gen t1st3rd=0
replace t1st3rd=1 if treat32==1 & treat34==1

gen t1st2nd=0
replace t1st2nd=1 if treat32==1 & treat33==1

gen t2nd3rd=0
replace t2nd3rd=1 if treat33==1 & treat34==1

reg bwkg treat32 treat33 treat34 if nomi
outreg2 using "table5.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table5.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 t1st2nd t2nd3rd if nomi
outreg2 using "table5.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 t1st2nd t2nd3rd childmale momeduy lninc momage momage2 if nomi
outreg2 using "table5.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 t1st3rd if nomi
outreg2 using "table5.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

reg bwkg treat32 treat33 treat34 t1st3rd childmale momeduy lninc momage momage2 if nomi
outreg2 using "table5.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label





set seed 19911102
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2 if nomi
outreg2 using "table8.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

set seed 19911102
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 t1st2nd t2nd3rd childmale momeduy lninc momage momage2 if nomi
outreg2 using "table8.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label

set seed 19911102
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 t1st3rd childmale momeduy lninc momage momage2 if nomi
outreg2 using "table8.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 4) label



********************************************************************

use "match_1st.dta",clear

reg bwkg treat32
outreg2 using "table4.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

set seed 19911103
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table9.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label


use "match_2nd.dta",clear

reg bwkg treat33
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

set seed 19911103
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table9.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label



use "match_3rd.dta",clear

reg bwkg treat34
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

set seed 19911103
bootstrap, reps(100): reg bwkg treat32 treat33 treat34 childmale momeduy lninc momage momage2
outreg2 using "table9.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label


********************************************************************

use "match_1st.dta",clear

tab control
tab treat33
tab treat34

tab childmale if control==0
tab childmale if control==1

tab control, sum(bwkg)
tab control, sum(momeduy)
tab control, sum(phinc)
tab control, sum(momage)


use "match_2nd.dta",clear

tab control
tab treat32
tab treat34

tab childmale if control==0
tab childmale if control==1

tab control, sum(bwkg)
tab control, sum(momeduy)
tab control, sum(phinc)
tab control, sum(momage)


use "match_3rd.dta",clear

tab control
tab treat32
tab treat33

tab childmale if control==0
tab childmale if control==1

tab control, sum(bwkg)
tab control, sum(momeduy)
tab control, sum(phinc)
tab control, sum(momage)


clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child_analysis.dta",clear

mark nomi if !mi(bwkg, control, childmale, momeduy, lninc, momage) 
tab nomi

drop if nomi==0
keep if control==0
//keep if control==1

tab control

tab childmale

tab control, sum(bwkg)
tab control, sum(momeduy)
tab control, sum(phinc)
tab control, sum(momage)


tab treat32
tab treat33
tab treat34






















