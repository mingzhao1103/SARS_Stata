
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "PSSD_child.dta",clear

tab childby,m

keep if childby==1999 | childby==2000| childby==2001 | childby==2002 | childby==2003 | childby==2004 | childby==2005 | childby==2006 | childby==2007

save "SARS_child.dta",replace

********************************************************************************

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/PSSDW4Individual_CASER (5 Sept).dta",clear

tab birthyr

keep if birthyr==1999 | birthyr==2000 | birthyr==2001 | birthyr==2002 | birthyr==2003

//age
tab age,m
gen childage=age
tab childage

rename birthyr childby
rename birthm childbm

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(childmale)

tab childmale,m

//education

//birth weight

//now weight & height
rename weightkg nowkg6
rename weightpd nowpd6
rename heightcm nowcm6
rename heightft nowft6
rename heightih nowih6

//birth place
gen childhkb=bplacew4n
recode childhkb 1=1 2=0
tab childhkb,m

//self-report health
tab health,m
tab health,nol
drop childhealth
gen childhealth=health
recode childhealth 1 2=1 3=2 4=3 5=4
lab def childhealth 1 "1: very good" 2 "2: good" 3 "3: fair" 4 "4: not good",replace
lab val childhealth childhealth
tab childhealth,m

rename SampleID sampleid
rename p_VhhID vhhid

keep sampleid vhhid childage childby childbm childmale childhkb childhealth ///
nowpd6 nowkg6 nowft6 nowih6 nowcm6

rename childage childage6
rename childby childby6
rename childbm childbm6
rename childmale childmale6
rename childhkb childhkb6
rename childhealth childhealth6

save "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_child_exra.dta",replace

********************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child.dta",clear

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_child_exra.dta"


des childage6 childby6 childbm6 childmale6 childhkb6 childhealth6

tab childage if childage6!=.

tab childby if childby6!=.

tab childbm if childbm6!=.

replace childbm=childbm6 if childbm6!=.

tab childmale if childmale!=childmale6 & childmale6!=.

tab childhkb if childhkb6!=.

replace childhkb=childhkb6 if childhkb6!=.

tab childhealth childhealth6 if childhealth!=childhealth6 & childhealth6!=.

replace childhealth=childhealth6 if childhealth6!=.

save "SARS_child.dta",replace

********************************************************************************

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta",clear

keep if code==childcode

keep sampleid childid fatherid motherid

rename fatherid fatherid1
rename motherid motherid1

save "/Users/mingzhao/Desktop/SARS_HKPSSD/W1_parentid.dta"


use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta",clear

keep if code==childcode

keep sampleid childid fatherid motherid

rename fatherid fatherid2
rename motherid motherid2

save "/Users/mingzhao/Desktop/SARS_HKPSSD/W2_parentid.dta"


use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta",clear

keep if code==childcode

keep sampleid childid fatherid motherid

rename fatherid fatherid3
rename motherid motherid3

save "/Users/mingzhao/Desktop/SARS_HKPSSD/W3_parentid.dta"


use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long_clean.dta",clear

keep if code==childcode

keep sampleid childid fatherid motherid

rename fatherid fatherid4
rename motherid motherid4

save "/Users/mingzhao/Desktop/SARS_HKPSSD/W4_parentid.dta"

********************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child.dta",clear

drop _merge

merge 1:1 sampleid using "W1_parentid.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           534
        from master                       171  (_merge==1)
        from using                        363  (_merge==2)

    matched                               595  (_merge==3)
    -----------------------------------------

*/

drop if _merge==2

drop _merge

merge 1:1 sampleid using "W2_parentid.dta"

/*
 Result                           # of obs.
    -----------------------------------------
    not matched                           570
        from master                       284  (_merge==1)
        from using                        286  (_merge==2)

    matched                               482  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2

drop _merge

merge 1:1 sampleid using "W3_parentid.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           738
        from master                       500  (_merge==1)
        from using                        238  (_merge==2)

    matched                               266  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2

drop _merge

merge 1:1 sampleid using "W4_parentid.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           878
        from master                       620  (_merge==1)
        from using                        258  (_merge==2)

    matched                               146  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2

drop _merge

order sampleid vhhid fatherid1 motherid1 fatherid2 motherid2 fatherid3 motherid3 fatherid4 motherid4


list sampleid if fatherid1!=fatherid2 & fatherid1!=. & fatherid2!=.  
/*
     +-----------+
     |  sampleid |
     |-----------|
 11. | 202110002 |
 44. | 209130005 |
 84. | 218040006 |
     +-----------+
	  19. | 202110003
	  430. | 250730005
*/

list sampleid if motherid1!=motherid2 & motherid1!=. & motherid2!=.
/*
     +-----------+
     |  sampleid |
     |-----------|
 44. | 209130005 |
 84. | 218040006 |
168. | 232350003 |
320. | 272540004 |
     +-----------+
	 311. | 232350002
*/

list sampleid if fatherid1!=fatherid3 & fatherid1!=. & fatherid3!=.  

list sampleid if motherid1!=motherid3 & motherid1!=. & motherid3!=.


list sampleid if fatherid1!=fatherid4 & fatherid1!=. & fatherid4!=.  

list sampleid if motherid1!=motherid4 & motherid1!=. & motherid4!=.


list sampleid if fatherid2!=fatherid3 & fatherid2!=. & fatherid3!=.  
/*
     +-----------+
     |  sampleid |
     |-----------|
 84. | 218040006 |
401. | 317370007 |
     +-----------+
*/

list sampleid if motherid2!=motherid3 & motherid2!=. & motherid3!=.
/*
     +-----------+
     |  sampleid |
     |-----------|
 84. | 218040006 |
168. | 232350003 |
320. | 272540004 |
401. | 317370007 |
     +-----------+
311. | 232350002
*/

list sampleid if fatherid2!=fatherid4 & fatherid2!=. & fatherid4!=.  
/*
     +-----------+
     |  sampleid |
     |-----------|
401. | 317370007 |
     +-----------+
*/

list sampleid if motherid2!=motherid4 & motherid2!=. & motherid4!=.
/*
     +-----------+
     |  sampleid |
     |-----------|
320. | 272540004 |
401. | 317370007 |
     +-----------+
311. | 232350002
*/

list sampleid if fatherid3!=fatherid4 & fatherid3!=. & fatherid4!=.  

list sampleid if motherid3!=motherid4 & motherid3!=. & motherid4!=.

save "SARS_child.dta",replace

********************************************************************************

use "SARS_child.dta",clear

drop if sampleid=="202110002" |  ///
		sampleid=="209130005" |  ///
		sampleid=="218040006" |  ///
		sampleid=="209130005" |  ///
		sampleid=="218040006" |  ///
		sampleid=="232350003" |  ///
		sampleid=="272540004" |  ///
		sampleid=="218040006" |  ///
		sampleid=="317370007" |  ///
		sampleid=="218040006" |  ///
		sampleid=="232350003" |  ///
		sampleid=="272540004" |  ///
		sampleid=="317370007" |  ///
		sampleid=="317370007" |  ///
		sampleid=="272540004" |  ///
		sampleid=="317370007" |  ///
		sampleid=="232350002" |  ///
		sampleid=="202110003" |  ///
		sampleid=="250730005"

gen fatherid=strofreal(fatherid1, "%12.0f")
replace fatherid=strofreal(fatherid2, "%12.0f") if fatherid2!=.
replace fatherid=strofreal(fatherid3, "%12.0f") if fatherid3!=.
replace fatherid=strofreal(fatherid4, "%12.0f") if fatherid4!=.

gen motherid=strofreal(motherid1, "%12.0f")
replace motherid=strofreal(motherid2, "%12.0f") if motherid2!=.
replace motherid=strofreal(motherid3, "%12.0f") if motherid3!=.
replace motherid=strofreal(motherid4, "%12.0f") if motherid4!=.

save "SARS_child_correctcases.dta",replace

********************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child.dta",clear

keep if sampleid=="202110002" |  ///
		sampleid=="209130005" |  ///
		sampleid=="218040006" |  ///
		sampleid=="209130005" |  ///
		sampleid=="218040006" |  ///
		sampleid=="232350003" |  ///
		sampleid=="272540004" |  ///
		sampleid=="218040006" |  ///
		sampleid=="317370007" |  ///
		sampleid=="218040006" |  ///
		sampleid=="232350003" |  ///
		sampleid=="272540004" |  ///
		sampleid=="317370007" |  ///
		sampleid=="317370007" |  ///
		sampleid=="272540004" |  ///
		sampleid=="317370007" |  ///
		sampleid=="232350002" |  ///
		sampleid=="202110003" |  ///
		sampleid=="250730005"
		
save "SARS_child_wrongcases.dta",replace	
		
//save "SARS_child_wrongcases_corrected.dta",replace	
		
use "SARS_child_correctcases.dta",clear

append using "SARS_child_wrongcases_corrected.dta"

drop dadcode momcode spocode childcode*p ///
fatherid1 fatherid2 fatherid3 fatherid4 fatherid_o father ///
motherid1 motherid2 motherid3 motherid4 motherid_o mother
		
drop childby6 childbm6 childmale6 childhkb6 childhealth6 ///
fcount4 famid fam cid fid mid marstat mar2stat ///
fcount3 cid2 fid2 mid2 childid_o t2marstat edu ///
empsts fcount famsizeall famsizeco famsizenonco did norder ///	
sex byear age childcode		
		
order sampleid vhhid cyear code childc childid fatherid motherid wave childage childby childbm childmale childedu bwpd bwkg childhkb illfreq childhealth	///
childby* childbm* childedu* chi1 chi2 chi3 chi4 chi5 math* eng* childhealth* childage*  ////
illfreq* childfrnd* hardw* caref* selfc* focus* obeyl* insist* neat* envirsup* homewk* dischild* disteacher*  ///
disorder* diff* optimistic* sociable* popular* independent*
		
save "SARS_child.dta",replace		

********************************************************************************

use "SARS_child.dta",clear

gen fam= substr(sampleid, 1, 6)

gen dad= substr(fatherid, -3, .)
gen mom= substr(motherid, -3, .)

gen dad1= substr(dad, 1, 1)
gen mom1= substr(mom, 1, 1)

gen dad2= substr(dad, -2, .)
gen mom2= substr(mom, -2, .)

replace dad1="0" if dad1=="1"
replace mom1="0" if mom1=="1"

egen fatherid1 = concat(fam dad1 dad2) if dad1!="" & dad2!=""
egen motherid1 = concat(fam mom1 mom2) if mom1!="" & mom2!=""

order sampleid vhhid cyear code childc childid fatherid fatherid1 motherid motherid1

drop fatherid motherid
rename fatherid1 fatherid
rename motherid1 motherid

save "SARS_child.dta",replace

********************************************************************************

use "PSSD_adult.dta",clear

tab male

keep if male==1

foreach var of varlist _all{     
	rename `var' f_`var'   
}

gen fatherid=sampleid

order sampleid fatherid

save "PSSD_father.dta",replace


use "PSSD_adult.dta",clear

tab male

keep if male==0

foreach var of varlist _all{     
	rename `var' m_`var'   
}

gen motherid=sampleid

order sampleid motherid

save "PSSD_mother.dta",replace


use "SARS_child.dta",clear

drop if fatherid=="" & motherid==""

tab childby,m
/*
    childby |      Freq.     Percent        Cum.
------------+-----------------------------------
       2001 |         99       23.57       23.57
       2002 |         81       19.29       42.86
       2003 |         75       17.86       60.71
       2004 |         69       16.43       77.14
       2005 |         96       22.86      100.00
------------+-----------------------------------
      Total |        420      100.00
*/

save "SARS_child.dta",replace

********************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child.dta",clear

count if fatherid!=""  //415
count if motherid!=""  //420

merge m:1 fatherid using "PSSD_father.dta"
drop if _merge==2
drop _merge
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         4,843
        from master                        82  (_merge==1)
        from using                      4,761  (_merge==2)

    matched                               338  (_merge==3)
    -----------------------------------------
*/

merge m:1 motherid using "PSSD_mother.dta"
drop if _merge==2
drop _merge
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         5,226
        from master                        51  (_merge==1)
        from using                      5,175  (_merge==2)

    matched                               369  (_merge==3)
    -----------------------------------------
*/

order sampleid vhhid cyear code childc childid fatherid motherid childage childby childbm childmale childedu bwpd bwkg childhkb illfreq childhealth ///
f_birthyr f_edu f_phinc m_birthyr m_edu m_phinc

save "SARS_child_setup.dta",replace




















































