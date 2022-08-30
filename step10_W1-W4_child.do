*W1
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1"

use "HKPSSD1stWave_Corrected_Child_CASER_20140528.dta",clear

//respgender childage bthpd bthkg xbplace edulevnow chi maths eng childhealth drfreq

gen wave=1

//age
tab childage,m
gen childage1=childage
tab childage1

gen childby1=.
gen childbm1=.

//gender
tab respgender
tab respgender,nol
recode respgender 5=0, gen(childmale1)
tab childmale1,m

//birth weight
rename bthpd bwpd1
rename bthkg bwkg1

//now weight & height
rename nowpd nowpd1
rename nowkg nowkg1
rename nowft nowft1
rename nowih nowih1
rename nowcm nowcm1

//birth place
tab xbplace,m
tab xbplace,nol
recode xbplace 1=1 *=0,gen(childhkb1)

//education
tab edulevnow,m
tab edulevnow, nolab
rename edulevnow childedu1

//grade ranking
tab chi,nol 
tab maths,nol 
tab eng,nol

rename chi chi1
rename maths math1
rename eng eng1

recode chi1 -8=.
recode math1 -8=.
recode eng1 -8=. 

//health
tab childhealth
rename childhealth childhealth1

//illness
tab drfreq,nol
replace drfreq=. if drfreq<0
rename drfreq drfreq1

//others
rename cyear cyear1

keep sampleid vhhid wave childc cyear1 ///
drfreq1 childhealth1 chi1 math1 eng1 childedu1 childhkb1 bwkg1 bwpd1 childmale1 childage1 ///
nowpd1 nowkg1 nowft1 nowih1 nowcm1

save "W1_child.dta",replace

*W2M
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "HKPSSD2ndWave_M_Child_CASER_11.5.2015.dta",clear

//childage childsex birthyr_ch birthm_ch bthpd bthkg bplace_ch edulevnow chi maths eng childhealth illfreq
//careful optimistic sociable popular independent envirsup homewk dischild disteacher childfrnd 

gen wave=2

//age
tab childage,m
gen childage2=childage
tab childage2

rename birthyr_ch childby2
rename birthm_ch childbm2

//gender
tab childsex
tab childsex,nol
recode childsex 5=0, gen(childmale2)
tab childmale2,m

//birth weight
rename bthpd bwpd2
rename bthkg bwkg2

//now weight & height
rename nowpd nowpd2
rename nowkg nowkg2
rename nowft nowft2
rename nowih nowih2
rename nowcm nowcm2

//birth place
tab bplace_ch,m
tab bplace_ch,nol
recode bplace_ch 1=1 *=0,gen(childhkb2)

//education
tab edulevnow,m
tab edulevnow, nolab
rename edulevnow childedu2
recode childedu2 997=.

//grade ranking
tab chi,nol 
tab maths,nol 
tab eng,nol

rename chi chi2
rename maths math2
rename eng eng2

//health
tab childhealth
rename childhealth childhealth2

//illness
rename illfreq illfreq2

//others
rename cyear cyear2
rename careful careful2
rename optimistic optimistic2
rename sociable sociable2
rename popular popular2 
rename independent independent2
rename envirsup envirsup2
rename homewk homewk2
rename dischild dischild2
rename disteacher disteacher2
rename childfrnd childfrnd2

keep sampleid vhhid wave childc cyear2 ///
illfreq2 childhealth2 chi2 math2 eng2 childedu2 childhkb2 bwkg2 bwpd2 childmale2 childbm2 childby2 childage2 ///
careful2 optimistic2 sociable2 popular2 independent2 envirsup2 homewk2 dischild2 disteacher2 childfrnd2  ///
nowpd2 nowkg2 nowft2 nowih2 nowcm2

save "W2M_child.dta",replace

*W2B
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "HKPSSD2ndWave_B_Child_CASER_1.27.2015.dta",clear

//childage childsex childbirthyr childbirthm childbthpd childbthkg childbplace childedulevnow childchi childmaths childeng childhealth childillfreq
//childcareful childoptimistic childsociable childpopular childindependent childenvirsup childhomewk childdischild childdisteacher childfrnd 
//childdisorder1 childdisorder2 childdisorder3 childdisorder4 childdisorder5 childdisorder6 childdisorder7 childdisorder8 childdisorder9 childdisorder10 childdiff1 childdiff2 childdiff3 

gen wave=3

//age
tab childage,m
gen childage3=childage
tab childage3

rename childbirthyr childby3
rename childbirthm childbm3

//gender
tab childsex
tab childsex,nol
recode childsex 5=0, gen(childmale3)
tab childmale3,m

//birth weight
rename childbthpd bwpd3
rename childbthkg bwkg3

//now weight & height
rename childnowpd nowpd3
rename childnowkg nowkg3
rename childnowft nowft3
rename childnowih nowih3
rename childnowcm nowcm3

//birth place
tab childbplace,m
tab childbplace,nol
recode childbplace 1=1 *=0,gen(childhkb3)

//education
tab childedulevnow,m
tab childedulevnow, nolab
rename childedulevnow childedu3

//grade ranking
tab childchi,nol 
tab childmaths,nol 
tab childeng,nol

rename childchi chi3
rename childmaths math3
rename childeng eng3

//health
tab childhealth
rename childhealth childhealth3

//illness
rename childillfreq illfreq3

//others
rename cyear cyear3
rename childcareful careful3
rename childoptimistic optimistic3
rename childsociable sociable3
rename childpopular popular3 
rename childindependent independent3
rename childenvirsup envirsup3
rename childhomewk homewk3
rename childdischild dischild3
rename childdisteacher disteacher3
rename childfrnd childfrnd3

rename childdisorder1 disorder31
rename childdisorder2 disorder32
rename childdisorder3 disorder33
rename childdisorder4 disorder34
rename childdisorder5 disorder35
rename childdisorder6 disorder36
rename childdisorder7 disorder37
rename childdisorder8 disorder38
rename childdisorder9 disorder39
rename childdisorder10  disorder310
rename childdiff1 diff31
rename childdiff2 diff32
rename childdiff3 diff33

keep sampleid vhhid wave childc cyear3 ///
illfreq3 childhealth3 chi3 math3 eng3 childedu3 childhkb3 bwkg3 bwpd3 childmale3 childbm3 childby3 childage3 ///
careful3 optimistic3 sociable3 popular3 independent3 envirsup3 homewk3 dischild3 disteacher3 childfrnd3 ///
disorder* diff* ///
nowpd3 nowkg3 nowft3 nowih3 nowcm3

save "W2B_child.dta",replace

*W3
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"	

use "HKPSSD3rdWave_Child_CASER_7.25.2016.dta",clear

//age birthyr birthm bthpd bthkg bplace_ch edulevnow chi maths eng childhealth illfreq
//hardw caref selfc focus obeyl insist neat envirsup homewk dischild disteacher childfrnd 
//excuse templ obedi worry upset bully dep lie thief scare 

gen wave=4

//age
tab age,m
gen childage4=age
tab childage4

rename birthyr childby4
rename birthm childbm4

//gender
gen childmale4=.

//birth weight
rename bthpd bwpd4
rename bthkg bwkg4

//now weight & height
rename nowpd nowpd4
rename nowkg nowkg4
rename nowft nowft4
rename nowih nowih4
rename nowcm nowcm4

//birth place
tab bplace_ch,m
tab bplace_ch,nol
recode bplace_ch 1=1 2=0,gen(childhkb4)

//education
tab edulevnow,m
tab edulevnow, nolab
rename edulevnow childedu4

//grade ranking
tab chi,nol 
tab maths,nol 
tab eng,nol

rename chi chi4
rename maths math4
rename eng eng4

//health
tab childhealth
rename childhealth childhealth4

//illness
rename illfreq illfreq4

//others
gen cyear4=2015
rename cid childc

rename hardw hardw4
rename caref caref4
rename selfc selfc4
rename focus focus4 
rename obeyl obeyl4
rename insist insist4
rename neat neat4
rename envirsup envirsup4
rename homewk homewk4
rename dischild dischild4
rename disteacher disteacher4
rename childfrnd childfrnd4

rename excuse excuse4
rename templ templ4
rename obedi obedi4
rename worry worry4
rename upset upset4
rename bully bully4
rename dep dep4
rename lie lie4
rename thief thief4
rename scare scare4

keep sampleid vhhid wave childc cyear4 ///
illfreq4 childhealth4 chi4 math4 eng4 childedu4 childhkb4 bwkg4 bwpd4 childmale4 childbm4 childby4 childage4 ///
hardw4 caref4 selfc4 focus4 obeyl4 insist4 neat4 envirsup4 homewk4 dischild4 disteacher4 childfrnd4 ///
excuse4 templ4 obedi4 worry4 upset4 bully4 dep4 lie4 thief4 scare4 ///
nowpd4 nowkg4 nowft4 nowih4 nowcm4

save "W3_child.dta",replace

*W4
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

use "PSSDW4Child_CASER (5 Sept).dta",clear

foreach var of varlist _all{   
	rename `var' `=lower("`var'")'  
}
//co3_1 co3 co3_2 childbthpdw4n childbthkgw4n childbplacew4n edulevnow chi maths eng childhealth illfreq
//hard caref selfc focus obeyl insist neat envirsup homewk dischild disteacher childfrnd 
//childdisorder1 childdisorder2 childdisorder3 childdisorder4 childdisorder5 childdisorder6 childdisorder7 childdisorder8 childdisorder9 childdisorder10

gen wave=5

//age
tab co3_1,m
gen childage5=co3_1
tab childage5

rename co3 childby5
rename co3_2 childbm5
replace childbm5=. if childbm5>12

//gender
gen childmale5=.

//birth weight
rename childbthpdw4n bwpd5
rename childbthkgw4n bwkg5
replace bwpd5=. if bwpd5>100
replace bwkg5=. if bwkg5>100

//now weight & height
replace nowcmw4n=nowcmw4nt if nowcmw4n>200 & nowcmw4nt<200
replace nowftw4n=nowftw4nt if nowftw4n>200 & nowftw4nt<200
replace nowihw4n=nowihw4nt if nowihw4n>200 & nowihw4nt<200

rename nowpdw4n nowpd5
rename nowkgw4n nowkg5
rename nowftw4n nowft5
rename nowihw4n nowih5
rename nowcmw4n nowcm5

//birth place
tab childbplacew4n,m
tab childbplacew4n,nol
recode childbplacew4n 1=1 .=. *=0,gen(childhkb5)

//education
tab edulevnow,m
tab edulevnow,nolab
rename edulevnow childedu5

//grade ranking
tab chi,nol 
tab maths,nol 
tab eng,nol

rename chi chi5
rename maths math5
rename eng eng5

//health
tab childhealth
rename childhealth childhealth5

//illness
rename illfreq illfreq5

//others
rename co1 childc
rename cyear cyear5

rename hard hardw5
rename caref caref5
rename selfc selfc5
rename focus focus5 
rename obeyl obeyl5
rename insist insist5
rename neat neat5
rename envirsup envirsup5
rename homewk homewk5
rename dischild dischild5
rename disteacher disteacher5
rename childfrnd childfrnd5

rename childdisorder1 disorder51
rename childdisorder2 disorder52
rename childdisorder3 disorder53
rename childdisorder4 disorder54
rename childdisorder5 disorder55
rename childdisorder6 disorder56
rename childdisorder7 disorder57
rename childdisorder8 disorder58
rename childdisorder9 disorder59
rename childdisorder10  disorder510

keep sampleid vhhid wave childc cyear5 ///
illfreq5 childhealth5 chi5 math5 eng5 childedu5 childhkb5 bwkg5 bwpd5 childmale5 childbm5 childby5 childage5 ///
hardw5 caref5 selfc5 focus5 obeyl5 insist5 neat5 envirsup5 homewk5 dischild5 disteacher5 childfrnd5 ///
disorder* ///
nowpd5 nowkg5 nowft5 nowih5 nowcm5

save "W4_child.dta",replace

*W1*W2M*W2B*W3*W4*
********************************************************************************
********************************************************************************
********************************************************************************

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_child.dta",clear

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_child.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           481
        from master                       189  (_merge==1)
        from using                        292  (_merge==2)

    matched                               215  (_merge==3)
    -----------------------------------------
*/
drop _merge

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2M_child.dta"

/*    
    Result                           # of obs.
    -----------------------------------------
    not matched                           611
        from master                       342  (_merge==1)
        from using                        269  (_merge==2)

    matched                               354  (_merge==3)
    -----------------------------------------
*/
drop _merge

destring sampleid,replace

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_child.dta"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           857
        from master                       432  (_merge==1)
        from using                        425  (_merge==2)

    matched                               533  (_merge==3)
    -----------------------------------------
*/

drop _merge

tostring sampleid,replace

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2B_child.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,333
        from master                     1,289  (_merge==1)
        from using                         44  (_merge==2)

    matched                               101  (_merge==3)
    -----------------------------------------
*/

drop _merge

save "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta",replace


use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta",clear
keep if code==childcode
keep sampleid byear
rename byear childby1
merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta"
drop _merge
save "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta",clear
keep if code==childcode
keep sampleid sex
rename sex childmale4
merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta"
drop _merge
save "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long_clean.dta",clear
keep if code==childcode
keep sampleid sex
rename sex childmale5
merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta"
drop _merge
save "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_child.dta",clear

//missings:childbm1
gen childbm1=.

*W1: 987
*W2M:623
*W2B:145
*W3: 507
*W4: 404

//age
gen childage=childage1
replace childage=childage2 if childage2!=.
replace childage=childage3 if childage3!=.
replace childage=childage4 if childage4!=.
replace childage=childage5 if childage5!=.

tab childage,m

gen childby=childby1
replace childby=childby2 if childby2!=.
replace childby=childby3 if childby3!=.
replace childby=childby4 if childby4!=.
replace childby=childby5 if childby5!=.

tab childby,m

gen childbm=childbm1
replace childbm=childbm2 if childbm2!=.
replace childbm=childbm3 if childbm3!=.
replace childbm=childbm4 if childbm4!=.
replace childbm=childbm5 if childbm5!=.

recode childbm -7=.

tab childbm,m

//gender
gen childmale=childmale1
replace childmale=childmale2 if childmale2!=.
replace childmale=childmale3 if childmale3!=.
replace childmale=childmale4 if childmale4!=.
replace childmale=childmale5 if childmale5!=. 
label variable childmale "Gender"
lab def childmale 0 "0: female" 1 "1: male"
lab val childmale childmale

tab childmale,m
recode childmale 5=0
drop childmale1 childmale2 childmale3 childmale4 childmale5

//education
gen childedu=childedu1
replace childedu=childedu2 if childedu2!=.
replace childedu=childedu3 if childedu3!=.
replace childedu=childedu4 if childedu4!=.
replace childedu=childedu5 if childedu5!=.

tab childedu,m

//birth weight
gen bwpd=bwpd1
replace bwpd=bwpd2 if bwpd2!=.
replace bwpd=bwpd3 if bwpd3!=.
replace bwpd=bwpd4 if bwpd4!=.
replace bwpd=bwpd5 if bwpd5!=.

tab bwpd,m
replace bwpd=. if bwpd<0

drop bwpd1 bwpd2 bwpd3 bwpd4 bwpd5

gen bwkg=bwkg1
replace bwkg=bwkg2 if bwkg2!=.
replace bwkg=bwkg3 if bwkg3!=.
replace bwkg=bwkg4 if bwkg4!=.
replace bwkg=bwkg5 if bwkg5!=.

tab bwkg,m
replace bwkg=. if bwkg<0

drop bwkg1 bwkg2 bwkg3 bwkg4 bwkg5

//Cyear
gen cyear=cyear1
replace cyear=cyear2 if cyear2!=.
replace cyear=cyear3 if cyear3!=.
replace cyear=cyear4 if cyear4!=.
replace cyear=cyear5 if cyear5!=.

tab cyear,m

drop cyear1 cyear2 cyear3 cyear4 cyear5

//illness
gen illfreq1=.
replace illfreq1=5 if drfreq1==1
replace illfreq1=4 if drfreq1==2 | drfreq1==3
replace illfreq1=3 if drfreq1==4 | drfreq1==5 
replace illfreq1=2 if drfreq1==6 
replace illfreq1=1 if drfreq1==7 

gen illfreq=illfreq1
replace illfreq=illfreq2 if illfreq2!=.
replace illfreq=illfreq3 if illfreq3!=.
replace illfreq=illfreq4 if illfreq4!=.
replace illfreq=illfreq5 if illfreq5!=.

tab illfreq,m

//birth place
gen childhkb=childhkb1
replace childhkb=childhkb2 if childhkb2!=.
replace childhkb=childhkb3 if childhkb3!=.
replace childhkb=childhkb4 if childhkb4!=.
replace childhkb=childhkb5 if childhkb5!=.

tab childhkb,m
drop childhkb1 childhkb2 childhkb3 childhkb4 childhkb5

//self-report health
gen childhealth=childhealth1
replace childhealth=childhealth2 if childhealth2!=.
replace childhealth=childhealth3 if childhealth3!=.
replace childhealth=childhealth4 if childhealth4!=.
replace childhealth=childhealth5 if childhealth5!=.
label variable childhealth "Self-rated health"
lab def childhealth 1 "1: very good" 2 "2: good" 3 "3: fair" 4 "4: not good",replace
lab val childhealth childhealth

tab childhealth,m
recode childhealth 5=4

order sampleid vhhid cyear childc childage childby childbm childmale childedu bwpd bwkg childhkb illfreq childhealth

save "/Users/mingzhao/Desktop/SARS_HKPSSD/PSSD_child.dta",replace
