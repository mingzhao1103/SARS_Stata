*Poverty
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Poverty"

use "Poverty_Child_to_Public.dta",clear

codebook sampleid vhhid

gen wave=6

rename resbyid childc

rename cyear cyear6

ta childage
rename childage childage6
 
ta birthyr 
rename birthyr childby6

ta birthm
ta birthm,nol
recode birthm 98=. 
rename birthm childbm6

ta childsex
ta childsex,nol
recode childsex 5=0
rename childsex childmale6

ta bthkg 
rename bthkg bwkg6
replace bwkg6=. if bwkg6>10

ta nowkg
rename nowkg nowkg6
replace nowkg6=. if nowkg6>100
 
ta nowcm 
rename nowcm nowcm6
replace nowcm6=. if nowcm6>100

ta xbplace
ta xbplace,nol
recode xbplace 2=0
rename xbplace childhkb6

rename edulevnow childedu6
rename chi chi6
rename maths math6
rename eng eng6
rename illness illfreq6

ta childhealth
ta childhealth,nol
lab def childhealth 1 "1: very good" 2 "2: good" 3 "3: fair" 4 "4: not good",replace
lab val childhealth childhealth
rename childhealth childhealth6

ta optimistic 
ta sociable 
ta childdisorder4 
ta childdisorder6

rename optimistic optimistic6
rename sociable sociable6
rename childdisorder4 disorder64
rename childdisorder6 disorder66

keep sampleid vhhid wave childc cyear6 ///
illfreq6 childhealth6 chi6 math6 eng6 childedu6 childhkb6 bwkg6 childmale6 childbm6 childby6 childage6 ///
nowkg6 nowcm6 disorder* optimistic6 sociable6

save "W6_child.dta",replace

tab childby6

drop if childby6>2005

save "W6_child.dta",replace

**********************************************************************************************
*family relations setup
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Poverty"	

use "W6_child.dta",clear

merge m:1 vhhid using "Poverty_Family_to_Public.dta"

keep if _merge==3 

save "W6_family_relations.dta",replace


**********************************************************************************************
*family relations W6
**********************************************************************************************

*Rename T1

use "W6_family_relations.dta",clear

rename hhsize fcount
rename childc childcode

forval i=1/9 {
	rename t1p`i'hedu t1p`i'edu
}

//keep related variables
keep sampleid vhhid childcode fcount  ///
t1p*code t1p*birthyr t1p*age t1p*sex t1p*marstat t1p*edu t1p*empsts

save "W6_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W6_family_relations.dta",clear

rename hhsize fcount
rename childc childcode

//keep related variables
keep sampleid vhhid childcode fcount  ///
t2p*code t2p*marstat t2p*spocode t2p*childcode* t2p*dadcode t2p*momcode t2p*dadalive t2p*momalive

save "W6_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W6_family_relations_T1.dta", clear
	 
//reshape requires rename
forval i=1/9{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyr byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'
	 rename t1p`i'marstat marstat`i'
	 rename t1p`i'edu edu`i'
	 rename t1p`i'empsts empsts`i'	 
}

reshape long code byear age sex marstat edu empsts, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code
	 
save "W6_fam_T1_long.dta",replace
	 
**********************************************************************************************
*Reshape T2

use "W6_family_relations_T2.dta", clear	 

forval i=1/9{
	 rename t2p`i'code code`i'
	 rename t2p`i'marstat t2marstat`i'
	 rename t2p`i'dadalive dadalive`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momalive momalive`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/10{
	 rename t2p`i'childcode`j' childcode`j'p`i'
	 }
}
		 
reshape long code t2marstat  ///
		dadalive dadcode momalive momcode spocode  ///
		childcode1p childcode2p childcode3p childcode4p childcode5p childcode6p  ///
		childcode7p childcode8p childcode9p childcode10p childcode11p,  ///
		i(sampleid) j(numb)
		
drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code

save "W6_fam_T2_long.dta",replace

**********************************************************************************************
*Merge T1 & T2

merge 1:1 sampleid code using "W6_fam_T1_long.dta"

drop _merge
	  
**comparing Table 1 and Table 2 information
count if marstat!=t2marstat

duplicates report sampleid
tab fcount

drop momalive dadalive
	  
save "W6_fam_T12_long.dta", replace  

keep if code==childcode

keep sampleid sex
rename sex childmale6
merge 1:1 sampleid using "W6_child.dta"
drop _merge

save "SARS_child6.dta",replace

**********************************************************************************************
*fatherid & motherid

use "SARS_child6.dta",clear

gen famid=vhhid

replace famid= subinstr(famid, "D", "", .)
replace famid= substr(famid, 1, 6)

egen faid = concat(famid dadcode) if code==childcode & dadcode!=.
egen moid = concat(famid momcode) if code==childcode & momcode!=.
egen chid = concat(famid childcode) if code==childcode & childcode!=.

gen dad= substr(faid, -3, .)
gen mom= substr(moid, -3, .)

gen dad1= substr(dad, 1, 1)
gen mom1= substr(mom, 1, 1)

gen dad2= substr(dad, -2, .)
gen mom2= substr(mom, -2, .)

replace dad1="0" if dad1=="1"
replace mom1="0" if mom1=="1"

egen fatherid = concat(famid dad1 dad2) if dad1!="" & dad2!=""
egen motherid = concat(famid mom1 mom2) if mom1!="" & mom2!=""

order sampleid vhhid cyear code childc childid fatherid motherid

save "SARS_child6.dta",replace

**********************************************************************************************
*W6 adult

/*
use "Poverty_Adult_to_Public.dta",clear
save "W6_adult.dta",replace
*/

//per capita family income monthly
use "Poverty_Family_to_Public.dta",clear

keep vhhid hhsize fammoninc_all fammonincg

des fammoninc_all fammonincg
gen famincg=fammonincg if fammonincg!=.k & fammonincg!=.r

replace fammoninc_all=famincg if famincg>fammoninc_all & famincg!=.
replace fammoninc_all=famincg if fammoninc_all==. & famincg!=. & famincg!=0

drop fammonincg famincg

save "W6_Family Variables.dta",replace

use "W6_adult.dta",clear

merge m:1 vhhid using "W6_Family Variables.dta"

tab fammoninc_all,m

gen phinc6=fammoninc_all 
replace phinc6=phinc6/hhsize

sum phinc6,d   //median 6250
replace phinc6=6250 if phinc6==.

keep sampleid age6 birthyr6 male6 edu6 single6 hsh6 bplace6 health6 phinc6 

duplicates r sampleid
duplicates drop sampleid,force

drop if sampleid==""

save "W6_adult.dta",replace

**********************************************************************************************
*Parent Id

use "W6_adult.dta",clear

keep if male6==1

gen fatherid=sampleid if male6==1

foreach var of varlist _all{     
	rename `var' f_`var'   
}

rename f_fatherid fatherid

save "W6_father.dta",replace


use "W6_adult.dta",clear

keep if male6==0

gen motherid=sampleid if male6==0

foreach var of varlist _all{     
	rename `var' m_`var'   
}

rename m_motherid motherid

save "W6_mother.dta",replace


use "SARS_child6.dta",clear

merge m:1 fatherid using "W6_father.dta"

drop if _merge==2
drop _merge

merge m:1 motherid using "W6_mother.dta"

drop if _merge==2
drop _merge

save "SARS_child6_setup.dta",replace
















































