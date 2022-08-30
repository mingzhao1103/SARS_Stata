*R2
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/R2"

use "PSSDR2Individual_CASER (11 Mar).dta",clear

rename SampleID sampleid
rename p_VhhID vhhid

codebook sampleid vhhid

gen wave=7

rename CYear cyear7

ta age
rename age childage7
 
ta birthyr 
rename birthyr childby7

ta birthm
ta birthm,nol
recode birthm 98=. 
rename birthm childbm7

ta sex
ta sex,nol
recode sex 5=0
rename sex childmale7

ta childbthkg 

ta weightkg
rename weightkg nowkg7
replace nowkg7=. if nowkg7>200
 
ta heightcmT 
rename heightcmT nowcm7
replace nowcm7=. if nowcm7>200

ta bplace
ta bplace,nol
recode bplace 2=0 3 997=.
rename bplace childhkb7

rename edu childedu7

ta health
ta health,nol
recode health 5=4
lab def health 1 "1: very good" 2 "2: good" 3 "3: fair" 4 "4: not good",replace
lab val health health
rename health childhealth7
 
rename blue blue7
rename worthless worthless7
rename hopeless hopeless7

keep sampleid vhhid wave childc cyear7 ///
childhealth7 childedu7 childhkb7  childmale7 childbm7 childby7 childage7 ///
nowkg7 nowcm7 blue7 worthless7 hopeless7

save "W7_child.dta",replace

tab childby7

drop if childby7<1999

save "W7_child.dta",replace

**********************************************************************************************
*family relations setup
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/R2"	

use "W7_child.dta",clear

merge m:1 vhhid using "PSSDR2Family_CASER (11 Mar 2020).dta"

keep if _merge==3 

save "W7_family_relations.dta",replace

**********************************************************************************************
*family relations W7
**********************************************************************************************

*Rename T1

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/R2"

use "W7_family_relations.dta",clear

rename hhsize fcount

foreach var of varlist pCODE*{      
	rename `var' `=lower("`var'")'   
}

rename pcode pcode1
rename t1birthyr t1birthyr1
rename t1age t1age1
rename t1sex t1sex1
rename t1marstat t1marstat1
rename t1hedu t1hedu1
rename t1empsts t1empsts1

forval i=1/6 {
	rename pcode`i' t1p`i'code
	rename t1birthyr`i' t1p`i'birthyr
	rename t1age`i' t1p`i'age
	rename t1sex`i' t1p`i'sex
	rename t1marstat`i' t1p`i'marstat
	rename t1hedu`i' t1p`i'edu
	rename t1empsts`i' t1p`i'empsts
	
}

//keep related variables
keep sampleid vhhid fcount  ///
t1p*code t1p*birthyr t1p*age t1p*sex t1p*marstat t1p*edu t1p*empsts

save "W7_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W7_family_relations.dta",clear

rename hhsize fcount

rename t2code t2code1
rename t2spocode t2spocode1
rename t2child1code t2child1code1
rename t2child2code t2child2code1 
rename t2child3code t2child3code1
rename t2child4code t2child4code1
rename t2child5code t2child5code1
rename t2child6code t2child6code1
rename t2dadcode t2dadcode1
rename t2momcode t2momcode1

forval i=1/6 {
	rename t2code`i' t2p`i'code
	rename t2spocode`i' t2p`i'spocode
	rename t2dadcode`i' t2p`i'dadcode
	rename t2momcode`i' t2p`i'momcode

	forval j=1/6{
	rename t2child`j'code`i' t2p`i'childcode`j' 
	 }
}	

//keep related variables
keep sampleid vhhid fcount  ///
t2p*code t2p*spocode t2p*childcode* t2p*dadcode t2p*momcode

save "W7_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W7_family_relations_T1.dta", clear
	 
//reshape requires rename
forval i=1/6{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyr byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'
	 rename t1p`i'marstat marstat`i'
	 rename t1p`i'edu edu`i'
	 rename t1p`i'empsts empsts`i'	 
}

reshape long code byear age sex marstat edu empsts, i(sampleid) j(numb)

order sampleid vhhid code numb
sort sampleid vhhid code

drop code
	 
save "W7_fam_T1_long.dta",replace
	 
**********************************************************************************************
*Reshape T2

use "W7_family_relations_T2.dta", clear	 

forval i=1/6{
	 rename t2p`i'code code`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/6{
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

save "W7_fam_T2_long.dta",replace

**********************************************************************************************
*Merge T1 & T2

merge 1:1 sampleid numb using "W7_fam_T1_long.dta"

keep if _merge==3
drop _merge

duplicates report sampleid
tab fcount
	  
save "W7_fam_T12_long.dta", replace  

use "W7_fam_T12_long.dta",clear

//没有childcode
gen child3= substr(sampleid, -3, .)

gen child1= substr(child3, 1, 1)

gen child2= substr(child3, -2, .)

replace child1="1" if child1=="0"

egen childcode = concat(child1 child2) if child1!="" & child2!=""

destring childcode,replace

keep if code==childcode

rename sex childmale7

merge 1:1 sampleid using "W7_child.dta"
drop _merge

save "SARS_child7.dta",replace

**********************************************************************************************
*fatherid & motherid

use "SARS_child7.dta",clear

gen famid=vhhid

replace famid= subinstr(famid, "D", "", .)
replace famid= substr(famid, 1, 6)

egen faid = concat(famid dadcode) 
egen moid = concat(famid momcode) 
egen chid = concat(famid childcode) 

gen dad= substr(faid, -3, .)
gen mom= substr(moid, -3, .)

gen dad1= substr(dad, 1, 1)
gen mom1= substr(mom, 1, 1)

gen dad2= substr(dad, -2, .)
gen mom2= substr(mom, -2, .)

replace dad1="0" if dad1=="1"
replace mom1="0" if mom1=="1"

egen fatherid = concat(famid dad1 dad2)
egen motherid = concat(famid mom1 mom2)

order sampleid vhhid cyear code childc chid fatherid motherid

save "SARS_child7.dta",replace

**********************************************************************************************
*W7 adult

use "PSSDR2Individual_CASER (11 Mar).dta",clear

//age
tab age,m
gen age7=age
tab age7

rename birthyr birthyr7

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male7)
label variable male7 "Gender"
lab def male7 0 "0: female" 1 "1: male"
lab val male7 male7
tab male7,m

//education
tab edu,m
tab edu, nolab
recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=.,gen(edu7)
label variable edu7 "Educational degree"
lab def edu7 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu7 edu7
tab edu7,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single7)
label variable single7 "Single"
lab def single7 1 "1: single" 0 "0: no" 
lab val single7 single7
tab single7,m

//Hongkong passport
tab hkpmnt,m
tab hkpmnt,nol
recode hkpmnt 1=1 5=0 *=., gen(hsh7)
label variable hsh7 "Hongkong passport"
lab def hsh7 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh7 hsh7
tab hsh7,m

//mainland immigrant
ta bplace
gen bplace7=bplace
recode bplace7 1=1 2=2 *=3
label variable bplace7 "Birth place"
lab def bplace7 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace7 bplace7
tab bplace7,m

//self-report health
gen health7=health
replace health7=. if health7<0 
tab health7,m

save "W7_adult.dta",replace

//per capita family income monthly
use "PSSDR2Family_CASER (11 Mar 2020).dta",clear

keep vhhid hhsize fammoninc fammonincr fammonincg fammonincgr

tab fammoninc,nol
replace fammoninc=. if fammoninc>500000

ta fammonincr
replace fammoninc=500 if fammonincr==1 & fammoninc==.      //median 0-1000
replace fammoninc=1500 if fammonincr==2 & fammoninc==.     //median 1000-2000
replace fammoninc=3000 if fammonincr==3 & fammoninc==.     //median 2000-4000
replace fammoninc=5000 if fammonincr==4 & fammoninc==.     //median 4000-6000
replace fammoninc=7000 if fammonincr==5 & fammoninc==.     //median 6000-8000
replace fammoninc=9000 if fammonincr==6 & fammoninc==.     //median 8000-10000
replace fammoninc=11250 if fammonincr==7 & fammoninc==.    //median 10000-12500
replace fammoninc=13750 if fammonincr==8 & fammoninc==.    //median 12500-15000
replace fammoninc=16250 if fammonincr==9 & fammoninc==.    //median 15000-17500
replace fammoninc=18750 if fammonincr==10 & fammoninc==.   //median 17500-20000
replace fammoninc=22500 if fammonincr==11 & fammoninc==.   //median 20000-25000
replace fammoninc=27500 if fammonincr==12 & fammoninc==.   //median 25000-30000
replace fammoninc=35000 if fammonincr==13 & fammoninc==.   //median 30000-40000
replace fammoninc=45000 if fammonincr==14 & fammoninc==.   //median 40000-50000
replace fammoninc=55000 if fammonincr==15 & fammoninc==.   //median 50000-60000
replace fammoninc=60000 if fammonincr==16 & fammoninc==.   //median >=60000

tab fammonincg,nol
replace fammonincg=. if fammonincg>20000

tab fammonincgr
tab fammonincgr,nol
replace fammonincg=500 if fammonincgr==1 & fammonincg==.      //median 0-1000
replace fammonincg=1500 if fammonincgr==2 & fammonincg==.     //median 1000-2000

replace fammoninc=fammoninc+fammonincg if fammonincg!=.

gen phinc7=fammoninc if fammoninc!=.

drop fammoninc fammonincr fammonincg fammonincgr

save "W7_Family Variables.dta",replace


use "W7_adult.dta",clear

rename p_VhhID vhhid
rename SampleID sampleid

merge m:1 vhhid using "W7_Family Variables.dta"

replace phinc7=phinc7/hhsize

sum phinc7,d   //median 7500
replace phinc7=7500 if phinc7==.

keep sampleid age7 birthyr7 male7 edu7 single7 hsh7 bplace7 health7 phinc7 

duplicates r sampleid
duplicates drop sampleid,force

drop if sampleid==""

save "W7_adult.dta",replace

**********************************************************************************************
*Parent Id

use "W7_adult.dta",clear

keep if male7==1

gen fatherid=sampleid if male7==1

foreach var of varlist _all{     
	rename `var' f_`var'   
}

rename f_fatherid fatherid

save "W7_father.dta",replace


use "W7_adult.dta",clear

keep if male7==0

gen motherid=sampleid if male7==0

foreach var of varlist _all{     
	rename `var' m_`var'   
}

rename m_motherid motherid

save "W7_mother.dta",replace


use "SARS_child7.dta",clear

merge m:1 fatherid using "W7_father.dta"

drop if _merge==2
drop _merge

merge m:1 motherid using "W7_mother.dta"

drop if _merge==2
drop _merge

save "SARS_child7_setup.dta",replace

**********************************************************************************************
*rematch father & mother again

use "SARS_child7_setup.dta",clear

keep sampleid fatherid motherid

save "parentid.dta",replace


use "W7_fam_T12_long.dta",clear

merge m:1 sampleid using "parentid.dta"

gen dad= substr(fatherid, -3, .)
gen mom= substr(motherid, -3, .)

gen dad1= substr(dad, 1, 1)
gen mom1= substr(mom, 1, 1)

gen dad2= substr(dad, -2, .)
gen mom2= substr(mom, -2, .)

replace dad1="1" if dad1=="0"
replace mom1="1" if mom1=="0"

egen fcode = concat(dad1 dad2)
egen mcode = concat(mom1 mom2)

destring fcode mcode,replace

tab marstat
tab marstat,nol

recode marstat 1 4 5 6=1 2 3=0 *=., gen (single7)
label variable single7 "Single"
lab def single7 1 "1: single" 0 "0: no" 
lab val single7 single7
tab single7,m

tab edu
tab edu,nol

recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=.,gen(edu7)
label variable edu7 "Educational degree"
lab def edu7 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu7 edu7
tab edu7,m

gen child3= substr(sampleid, -3, .)

gen child1= substr(child3, 1, 1)

gen child2= substr(child3, -2, .)

replace child1="1" if child1=="0"

egen childcode = concat(child1 child2) if child1!="" & child2!=""

destring childcode,replace

drop if code==childcode

save "parentid.dta",replace


use "parentid.dta",clear

keep if code==fcode

keep sampleid fatherid single7 edu7 byear sex

rename byear f_birthyr7
rename sex f_male7
rename edu7 f_edu7
rename single7 f_single7

save "fid.dta",replace


use "parentid.dta",clear

keep if code==mcode

keep sampleid motherid single7 edu7 byear sex

rename byear m_birthyr7
rename sex m_male7
rename edu7 m_edu7
rename single7 m_single7

save "mid.dta",replace


use "SARS_child7.dta",clear

merge m:1 sampleid fatherid using "fid.dta"

drop if _merge==2
drop _merge

merge m:1 sampleid motherid using "mid.dta"

drop if _merge==2
drop _merge

save "SARS_child7_setup2.dta",replace


use "SARS_child7_setup2.dta",clear

merge 1:1 sampleid using "SARS_child7_setup.dta"

drop _merge

save "SARS_child7_setup.dta",replace






























