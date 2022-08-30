*W1
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1"

use "HKPSSD1stWave_Corrected_Adult_CASER_20140528.dta",clear

//age
tab nage,m
gen age1=nage
tab age1

rename birthyr birthyr1

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male1)
label variable male1 "Gender"
lab def male1 0 "0: female" 1 "1: male"
lab val male1 male1
tab male1,m

//education
tab nedu,m
tab nedu, nolab
recode nedu 0=1 1=2 2=3 3/4=4 *=.,gen(edu1)
label variable edu1 "Educational degree"
lab def edu1 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu1 edu1
tab edu1,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single1)
label variable single1 "Single"
lab def single1 1 "1: single" 0 "0: no" 
lab val single1 single1
tab single1,m

//Hongkong passport
tab hkpermant,m
tab hkpermant,nol
recode hkpermant 1=1 5=0 *=., gen(hsh1)
label variable hsh1 "Hongkong passport"
lab def hsh1 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh1 hsh1
tab hsh1,m

//mainland immigrant
tab xbplace,m
tab xbplace,nol
recode xbplace 2=1 -7 -8=. *=0, gen(imm1)
label variable imm1 "Immigrant"
lab def imm1 1 "1: immigrant" 0 "0: no" 
lab val imm1 imm1
tab imm1,m

gen bplace1=xbplace
recode bplace1 1=1 2=2 -7 -8=. *=3
label variable bplace1 "Birth place"
lab def bplace1 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace1 bplace1
tab bplace1,m

//self-report health
gen health1=health
replace health1=. if health1<0 
tab health1,m

//working status
tab wklt7d
tab joblt7d
tab fhelplt7d
gen work1=0
replace work1=1 if wklt7d==1|joblt7d==1|fhelplt7d==1
label variable work1 "Working Status"
lab def work1 1 "1: working" 0 "0: no" 
lab val work1 work1
tab work1,m

//occupation
tab jbtype,m
tab jbtype,nol
recode jbtype 1=1 2/3=2 4=3 5=4 6=5 7/9=6 10=7 11=8 *=., gen(occup1)
label variable occup1 "Occupation"
lab def occup1 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation" 7 "7: military" 8 "8: others"
lab val occup1 occup1
tab occup1

//occupation revision
tab occup1
recode occup1 7/8=.
lab def occup1 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation",replace
tab occup1

save "W1_adult.dta",replace

//per capita family income monthly
use "HKPSSD1stWave_Corrected_Family_CASER_20140528.dta",clear

keep vhhid hhsize fammoninc fammonincr

save "W1_Family Variables.dta",replace

use "W1_adult.dta",clear

merge m:1 vhhid using "W1_Family Variables.dta"

tab fammoninc,nol 
tab fammonincr 
tab fammonincr,nol 
gen phinc1=fammoninc
replace phinc1=500 if fammonincr==1 & fammoninc<0      //median 0-1000
replace phinc1=1500 if fammonincr==2 & fammoninc<0     //median 1000-2000
replace phinc1=3000 if fammonincr==3 & fammoninc<0     //median 2000-4000
replace phinc1=5000 if fammonincr==4 & fammoninc<0     //median 4000-6000
replace phinc1=7000 if fammonincr==5 & fammoninc<0     //median 6000-8000
replace phinc1=9000 if fammonincr==6 & fammoninc<0     //median 8000-10000
replace phinc1=11250 if fammonincr==7 & fammoninc<0    //median 10000-12500
replace phinc1=13750 if fammonincr==8 & fammoninc<0    //median 12500-15000
replace phinc1=16250 if fammonincr==9 & fammoninc<0    //median 15000-17500
replace phinc1=18750 if fammonincr==10 & fammoninc<0   //median 17500-20000
replace phinc1=22500 if fammonincr==11 & fammoninc<0   //median 20000-25000
replace phinc1=27500 if fammonincr==12 & fammoninc<0   //median 25000-30000
replace phinc1=35000 if fammonincr==13 & fammoninc<0   //median 30000-40000
replace phinc1=45000 if fammonincr==14 & fammoninc<0   //median 40000-50000
replace phinc1=55000 if fammonincr==15 & fammoninc<0   //median 50000-60000
replace phinc1=60000 if fammonincr==16 & fammoninc<0   //median >=60000

tab phinc1,m
replace phinc1=. if phinc1<0

replace phinc1=phinc1/hhsize

replace phinc1=ninc if phinc1==.

sum phinc1,d  //median=4500

replace phinc1=4500 if phinc1==.

keep sampleid age1 birthyr1 male1 edu1 single1 hsh1 imm1 health1 work1 occup1 phinc1 bplace1

duplicates drop sampleid,force

drop if sampleid==.

save "W1_adult.dta",replace

*W2M
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "HKPSSD2ndWave_M_Adult_CASER_11.5.2015.dta",clear

//age
tab age,m
gen age2=age
tab age2

rename birthyr birthyr2

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male2)
label variable male2 "Gender"
lab def male2 0 "0: female" 1 "1: male"
lab val male2 male2
tab male2,m

//education
tab edu,m
tab edu, nolab
recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=.,gen(edu2)
label variable edu2 "Educational degree"
lab def edu2 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu2 edu2
tab edu2,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single2)
label variable single2 "Single"
lab def single2 1 "1: single" 0 "0: no" 
lab val single2 single2
tab single2,m

//Hongkong passport
tab hkpmnt,m
tab hkpmnt,nol
recode hkpmnt 1=1 5=0 *=., gen(hsh2)
label variable hsh2 "Hongkong passport"
lab def hsh2 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh2 hsh2
tab hsh2,m

//mainland immigrant
tab bplace,m
tab bplace,nol
recode bplace 2=1 *=0, gen(imm2)
label variable imm2 "Immigrant"
lab def imm2 1 "1: immigrant" 0 "0: no" 
lab val imm2 imm2
tab imm2,m

gen bplace2=bplace
recode bplace2 1=1 2=2 .=. *=3
label variable bplace2 "Birth place"
lab def bplace2 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace2 bplace2
tab bplace2,m

//self-report health
gen health2=health
tab health2,m

//working status
tab wklt7d
tab joblt7d
tab fhelplt7d
gen work2=0
replace work2=1 if wklt7d==1|joblt7d==1|fhelplt7d==1
label variable work2 "Working Status"
lab def work2 1 "1: working" 0 "0: no" 
lab val work2 work2
tab work2,m

//occupation
tab jbtype,m
tab jblasttype,m
tab jbtype,nol
tab jblasttype,nol
gen occup2=jbtype
replace occup2=jblasttype if occup2==.
recode occup2 1=1 2/3=2 4=3 5=4 6=5 7/9=6 10=7 11=8 *=.
label variable occup2 "Occupation"
lab def occup2 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation" 7 "7: military" 8 "8: others"
lab val occup2 occup2
tab occup2

//occupation revision
tab occup2
recode occup2 7/8=.
lab def occup2 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation",replace
tab occup2

rename p_vhhid vhhid

save "W2M_adult.dta",replace

//per capita family income monthly
use "HKPSSD2ndWave_M_Family_CASER_11.5.2015.dta",clear

keep vhhid hhsizex2 HE18 fammonincr2

rename hhsizex2 hhsize
rename HE18 fammoninc
rename fammonincr2 fammonincr

save "W2M_Family Variables.dta",replace

use "W2M_adult.dta",clear

merge m:1 vhhid using "W2M_Family Variables.dta"

tab fammoninc,nol 
tab fammonincr 
tab fammonincr,nol 
gen phinc2=fammoninc
replace phinc2=500 if fammonincr==1 & fammoninc<0      //median 0-1000
replace phinc2=1500 if fammonincr==2 & fammoninc<0     //median 1000-2000
replace phinc2=3000 if fammonincr==3 & fammoninc<0     //median 2000-4000
replace phinc2=5000 if fammonincr==4 & fammoninc<0     //median 4000-6000
replace phinc2=7000 if fammonincr==5 & fammoninc<0     //median 6000-8000
replace phinc2=9000 if fammonincr==6 & fammoninc<0     //median 8000-10000
replace phinc2=11250 if fammonincr==7 & fammoninc<0    //median 10000-12500
replace phinc2=13750 if fammonincr==8 & fammoninc<0    //median 12500-15000
replace phinc2=16250 if fammonincr==9 & fammoninc<0    //median 15000-17500
replace phinc2=18750 if fammonincr==10 & fammoninc<0   //median 17500-20000
replace phinc2=22500 if fammonincr==11 & fammoninc<0   //median 20000-25000
replace phinc2=27500 if fammonincr==12 & fammoninc<0   //median 25000-30000
replace phinc2=35000 if fammonincr==13 & fammoninc<0   //median 30000-40000
replace phinc2=45000 if fammonincr==14 & fammoninc<0   //median 40000-50000
replace phinc2=55000 if fammonincr==15 & fammoninc<0   //median 50000-60000
replace phinc2=60000 if fammonincr==16 & fammoninc<0   //median >=60000

tab phinc2,m
replace phinc2=. if phinc2<0

replace phinc2=phinc2/hhsize

tab incmonth,m
replace incmonth=. if incmonth<0
replace incmonth=500 if incmonthr==1 & incmonth==.      //median 0-1000
replace incmonth=1500 if incmonthr==2 & incmonth==.     //median 1000-2000
replace incmonth=3000 if incmonthr==3 & incmonth==.     //median 2000-4000
replace incmonth=5000 if incmonthr==4 & incmonth==.     //median 4000-6000
replace incmonth=7000 if incmonthr==5 & incmonth==.     //median 6000-8000
replace incmonth=9000 if incmonthr==6 & incmonth==.     //median 8000-10000
replace incmonth=11250 if incmonthr==7 & incmonth==.    //median 10000-12500
replace incmonth=13750 if incmonthr==8 & incmonth==.    //median 12500-15000
replace incmonth=16250 if incmonthr==9 & incmonth==.    //median 15000-17500
replace incmonth=18750 if incmonthr==10 & incmonth==.   //median 17500-20000
replace incmonth=22500 if incmonthr==11 & incmonth==.   //median 20000-25000
replace incmonth=27500 if incmonthr==12 & incmonth==.   //median 25000-30000
replace incmonth=35000 if incmonthr==13 & incmonth==.   //median 30000-40000
replace incmonth=45000 if incmonthr==14 & incmonth==.   //median 40000-50000
replace incmonth=55000 if incmonthr==15 & incmonth==.   //median 50000-60000
replace incmonth=60000 if incmonthr==16 & incmonth==.   //median >=60000
 
tab nowkincm,m
replace nowkincm=. if nowkincm<0
replace nowkincm=500 if nowkincmr==1 & nowkincm==.      //median 0-1000
replace nowkincm=1500 if nowkincmr==2 & nowkincm==.     //median 1000-2000
replace nowkincm=3000 if nowkincmr==3 & nowkincm==.     //median 2000-4000
replace nowkincm=5000 if nowkincmr==4 & nowkincm==.     //median 4000-6000
replace nowkincm=7000 if nowkincmr==5 & nowkincm==.     //median 6000-8000
replace nowkincm=9000 if nowkincmr==6 & nowkincm==.     //median 8000-10000
replace nowkincm=11250 if nowkincmr==7 & nowkincm==.    //median 10000-12500
replace nowkincm=13750 if nowkincmr==8 & nowkincm==.    //median 12500-15000
replace nowkincm=16250 if nowkincmr==9 & nowkincm==.    //median 15000-17500
replace nowkincm=18750 if nowkincmr==10 & nowkincm==.   //median 17500-20000
replace nowkincm=22500 if nowkincmr==11 & nowkincm==.   //median 20000-25000
replace nowkincm=27500 if nowkincmr==12 & nowkincm==.   //median 25000-30000
replace nowkincm=35000 if nowkincmr==13 & nowkincm==.   //median 30000-40000
replace nowkincm=45000 if nowkincmr==14 & nowkincm==.   //median 40000-50000
replace nowkincm=55000 if nowkincmr==15 & nowkincm==.   //median 50000-60000
replace nowkincm=60000 if nowkincmr==16 & nowkincm==.   //median >=60000

tab otherincm,m
replace otherincm=. if otherincm<0

gen ninc=incmonth
replace ninc=nowkincm if incmonth==. & nowkincm!=.
replace ninc=incmonth+nowkincm if incmonth!=. & nowkincm!=.

tab otherincm
tab ninc if otherincm!=.,m

replace ninc=ninc+otherincm if otherincm!=.

replace phinc2=ninc if phinc2==.

sum phinc2,d  //median=5625

replace phinc2=5625 if phinc2==.

keep sampleid age2 birthyr2 male2 edu2 single2 hsh2 imm2 health2 work2 occup2 phinc2 bplace2

duplicates drop sampleid,force

drop if sampleid==""

save "W2M_adult.dta",replace

*W2B
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "HKPSSD2ndWave_B_Adult_CASER_1.27.2015.dta",clear

//age
tab age,m
gen age2=age
tab age2

rename birthyr birthyr2

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male2)
label variable male2 "Gender"
lab def male2 0 "0: female" 1 "1: male"
lab val male2 male2
tab male2,m

//education
tab edu,m
tab edu, nolab
recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=.,gen(edu2)
label variable edu2 "Educational degree"
lab def edu2 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu2 edu2
tab edu2,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single2)
label variable single2 "Single"
lab def single2 1 "1: single" 0 "0: no" 
lab val single2 single2
tab single2,m

//Hongkong passport
tab hkpmnt,m
tab hkpmnt,nol
recode hkpmnt 1=1 5=0 *=., gen(hsh2)
label variable hsh2 "Hongkong passport"
lab def hsh2 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh2 hsh2
tab hsh2,m

//mainland immigrant
tab bplace,m
tab bplace,nol
recode bplace 2=1 *=0, gen(imm2)
label variable imm2 "Immigrant"
lab def imm2 1 "1: immigrant" 0 "0: no" 
lab val imm2 imm2
tab imm2,m

gen bplace2=bplace
recode bplace2 1=1 2=2 .=. *=3
label variable bplace2 "Birth place"
lab def bplace2 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace2 bplace2
tab bplace2,m

//self-report health
gen health2=health

//working status
tab wklt7d
tab joblt7d
tab fhelplt7d
gen work2=0
replace work2=1 if wklt7d==1|joblt7d==1|fhelplt7d==1
label variable work2 "Working Status"
lab def work2 1 "1: working" 0 "0: no" 
lab val work2 work2
tab work2,m

//occupation
tab jbtype,m
tab jblasttype,m
tab jbtype,nol
tab jblasttype,nol
gen occup2=jbtype
replace occup2=jblasttype if occup2==.
recode occup2 1=1 2/3=2 4=3 5=4 6=5 7/9=6 10=7 11=8 *=.
label variable occup2 "Occupation"
lab def occup2 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation" 7 "7: military" 8 "8: others"
lab val occup2 occup2
tab occup2

//occupation revision
tab occup2
recode occup2 7/8=.
lab def occup2 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation",replace
tab occup2

rename p_vhhid vhhid

save "W2B_adult.dta",replace

//per capita family income monthly
use "HKPSSD2ndWave_B_Family_CASER_1.27.2015.dta",clear

keep vhhid hhsize h22_income

rename h22_income fammoninc

save "W2B_Family Variables.dta",replace

use "W2B_adult.dta",clear

merge m:1 vhhid using "W2B_Family Variables.dta"

gen phinc2=fammoninc

tab phinc2,m

replace phinc2=phinc2/hhsize

sum phinc2,d  //median=7000

replace phinc2=7000 if phinc2==.

keep sampleid age2 birthyr2 male2 edu2 single2 hsh2 imm2 health2 work2 occup2 phinc2 bplace2

rename birthyr2 birthyr3
rename age2 age3
rename male2 male3
rename edu2 edu3
rename single2 single3
rename hsh2 hsh3
rename imm2 imm3
rename bplace2 bplace3
rename health2 health3
rename work2 work3
rename occup2 occup3
rename phinc2 phinc3

save "W2B_adult.dta",replace

*W3
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"	

use "HKPSSD3rdWave_Adult_CASER_7.25.2016.dta",clear

//age
tab age,m
gen age3=age
tab age3

rename birthyr birthyr3

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male3)
label variable male3 "Gender"
lab def male3 0 "0: female" 1 "1: male"
lab val male3 male3
tab male3,m

//education
tab edu,m
tab edu, nolab
recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=.,gen(edu3)
label variable edu3 "Educational degree"
lab def edu3 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu3 edu3
tab edu3,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single3)
label variable single3 "Single"
lab def single3 1 "1: single" 0 "0: no" 
lab val single3 single3
tab single3,m

//Hongkong passport
tab hkpmnt,m
tab hkpmnt,nol
recode hkpmnt 1=1 5=0 *=., gen(hsh3)
label variable hsh3 "Hongkong passport"
lab def hsh3 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh3 hsh3
tab hsh3,m

//mainland immigrant
tab bplace,m
tab bplace,nol
recode bplace 2=1 -7=. *=0, gen(imm3)
label variable imm3 "Immigrant"
lab def imm3 1 "1: immigrant" 0 "0: no" 
lab val imm3 imm3
tab imm3,m

gen bplace3=bplace
recode bplace3 1=1 2=2 -7 .=. *=3
label variable bplace3 "Birth place"
lab def bplace3 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace3 bplace3
tab bplace3,m

//self-report health
gen health3=health

//working status
tab wklt7d
tab joblt7d
tab fhelplt7d
gen work3=0
replace work3=1 if wklt7d==1|joblt7d==1|fhelplt7d==1
label variable work3 "Working Status"
lab def work3 1 "1: working" 0 "0: no" 
lab val work3 work3
tab work3,m

//occupation
tab jbtype,m
tab jblasttype,m
tab jbtype,nol
tab jblasttype,nol
gen occup3=jbtype
replace occup3=jblasttype if occup3==.
recode occup3 1=1 2/3=2 4=3 5=4 6=5 7/9=6 10=7 11=8 *=.
label variable occup3 "Occupation"
lab def occup3 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation" 7 "7: military" 8 "8: others"
lab val occup3 occup3
tab occup3

//occupation revision
tab occup3
recode occup3 7/8=.
lab def occup3 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation",replace
tab occup3

rename p_VhhID vhhid
rename SampleID sampleid

save "W3_adult.dta",replace

//per capita family income monthly
use "HKPSSD3rdWave_Family_CASER_7.25.2016.dta",clear

keep vhhid hhsizex3 fammoninc_all

rename hhsizex3 hhsize
rename fammoninc_all fammoninc

save "W3_Family Variables.dta",replace

use "W3_adult.dta",clear

merge m:1 vhhid using "W3_Family Variables.dta"

gen phinc3=fammoninc

tab phinc3,m

replace phinc3=phinc3/hhsize

sum phinc3,d  //median=7000

replace phinc3=7000 if phinc3==.

keep sampleid age3 birthyr3 male3 edu3 single3 hsh3 imm3 health3 work3 occup3 phinc3 bplace3

rename birthyr3 birthyr4
rename age3 age4
rename male3 male4
rename edu3 edu4
rename single3 single4
rename hsh3 hsh4
rename imm3 imm4
rename bplace3 bplace4
rename health3 health4
rename work3 work4
rename occup3 occup4
rename phinc3 phinc4

duplicates drop sampleid,force

drop if sampleid==""

save "W3_adult.dta",replace

*W4
********************************************************************************
********************************************************************************
********************************************************************************
clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

use "PSSDW4Individual_CASER (5 Sept).dta",clear

foreach var of varlist _all{      //all variables
	rename `var' `=lower("`var'")'    //variable names in lower case
}

rename p_vhhid vhhid

//age
tab age,m
gen age4=age
tab age4

rename birthyr birthyr4

//gender
tab sex
tab sex,nol
recode sex 5=0, gen(male4)
label variable male4 "Gender"
lab def male4 0 "0: female" 1 "1: male"
lab val male4 male4
tab male4,m

//education
tab edu,m
tab edu, nolab
recode edu 0/2=1 3=2 4/5 10 11=3 6/9 12=4 *=., gen(edu4)
label variable edu4 "Educational degree"
lab def edu4 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu4 edu4
tab edu4,m

//marital status
tab marital,m
tab marital,nolab
recode marital 1 4 5 6=1 2 3=0 *=., gen (single4)
label variable single4 "Single"
lab def single4 1 "1: single" 0 "0: no" 
lab val single4 single4
tab single4,m

//Hongkong passport
tab hkpmnt,m
tab hkpmnt,nol
recode hkpmnt 1=1 5=0 *=., gen(hsh4)
label variable hsh4 "Hongkong passport"
lab def hsh4 1 "1: Hongkong passport" 0 "0: no" 
lab val hsh4 hsh4
tab hsh4,m

//mainland immigrant
tab bplacew4n,m
tab bplacew4n,nol
recode bplacew4n 2=1 *=0, gen(imm4)
label variable imm4 "Immigrant"
lab def imm4 1 "1: immigrant" 0 "0: no" 
lab val imm4 imm4
tab imm4,m

gen bplace4=bplacew4n
recode bplace4 1=1 2=2 .=. *=3
label variable bplace4 "Birth place"
lab def bplace4 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace4 bplace4
tab bplace4,m

//self-report health
tab health,m
tab health,nol
gen health4=health
tab health4

//working status
tab whwk4,m
tab whwk4,nol
gen work4=whwk4
label variable work4 "Working Status"
lab def work4 1 "1: working" 0 "0: no" 
lab val work4 work4
tab work4,m

//occupation
tab jbtypew4n
tab jblasttypew4n
tab jbtypew4n,nol
tab jblasttypew4n,nol
gen occup4=jbtypew4n
replace occup4=jblasttypew4n if occup4==.
recode occup4 1=1 2/3=2 4=3 5=4 6=5 7/9=6 10=7 11=8 *=.
label variable occup4 "Occupation"
lab def occup4 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation" 7 "7: military" 8 "8: others"
lab val occup4 occup4
tab occup4

//occupation revision
tab occup4
recode occup4 7/8=.
lab def occup4 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation",replace
tab occup4

save "W4_adult.dta",replace

//per capita family income monthly
use "PSSDW4Family_CASER (5 Sept).dta",clear

foreach var of varlist _all{      //all variables
	rename `var' `=lower("`var'")'    //variable names in lower case
}

keep vhhid ha1 fammoninc fammonincr 

save "W4_Family Variables.dta",replace

use "W4_adult.dta",clear

merge m:1 vhhid using "W4_Family Variables.dta"

tab fammoninc
tab fammoninc,nol 
tab fammonincr 
tab fammonincr,nol 
gen phinc4=fammoninc if fammoninc <999998
replace phinc4=500 if fammonincr==1 & fammoninc>999997     //median 0-1000
replace phinc4=1500 if fammonincr==6 & fammoninc>999997     //median 1000-2000
replace phinc4=3000 if fammonincr==7 & fammoninc>999997    //median 2000-4000
replace phinc4=5000 if fammonincr==8 & fammoninc>999997    //median 4000-6000
replace phinc4=7000 if fammonincr==9 & fammoninc>999997    //median 6000-8000
replace phinc4=9000 if fammonincr==10 & fammoninc>999997    //median 8000-10000
replace phinc4=11250 if fammonincr==11 & fammoninc>999997   //median 10000-12500
replace phinc4=13750 if fammonincr==12 & fammoninc>999997   //median 12500-15000
replace phinc4=16250 if fammonincr==13 & fammoninc>999997   //median 15000-17500
replace phinc4=18750 if fammonincr==14 & fammoninc>999997  //median 17500-20000
replace phinc4=22500 if fammonincr==15 & fammoninc>999997   //median 20000-25000
replace phinc4=27500 if fammonincr==16 & fammoninc>999997   //median 25000-30000
replace phinc4=35000 if fammonincr==31 & fammoninc>999997   //median 30000-40000
replace phinc4=45000 if fammonincr==62 & fammoninc>999997   //median 40000-50000
replace phinc4=55000 if fammonincr==82 & fammoninc>999997   //median 50000-60000

replace phinc4=phinc4/ha1

sum phinc4,d   //median 7250
replace phinc4=7250 if phinc4==.

keep sampleid age4 birthyr4 male4 edu4 single4 hsh4 imm4 health4 work4 occup4 phinc4 bplace4

rename birthyr4 birthyr5
rename age4 age5
rename male4 male5
rename edu4 edu5
rename single4 single5
rename hsh4 hsh5
rename imm4 imm5
rename bplace4 bplace5
rename health4 health5
rename work4 work5
rename occup4 occup5
rename phinc4 phinc5

duplicates drop sampleid,force

drop if sampleid==""

save "W4_adult.dta",replace

*W1*W2M*W2B*W3*W4*
********************************************************************************
********************************************************************************
********************************************************************************

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_adult.dta",clear

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_adult.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         4,129
        from master                     1,188  (_merge==1)
        from using                      2,941  (_merge==2)

    matched                             2,219  (_merge==3)
    -----------------------------------------
*/
drop _merge

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2M_adult.dta"

/*    
	Result                           # of obs.
    -----------------------------------------
    not matched                         4,327
        from master                     3,202  (_merge==1)
        from using                      1,125  (_merge==2)

    matched                             3,146  (_merge==3)
    -----------------------------------------
*/
drop _merge

destring sampleid,replace

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_adult.dta"
/*
	Result                           # of obs.
    -----------------------------------------
    not matched                         5,635
        from master                     2,945  (_merge==1)
        from using                      2,690  (_merge==2)

    matched                             4,528  (_merge==3)
    -----------------------------------------
*/

drop _merge

tostring sampleid,replace

merge 1:1 sampleid using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2B_adult.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         9,022
        from master                     8,612  (_merge==1)
        from using                        410  (_merge==2)

    matched                             1,551  (_merge==3)
    -----------------------------------------
*/
drop _merge

save "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_adult.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/SARS_adult.dta",clear

//age
gen age=age1
replace age=age2 if age2!=.
replace age=age3 if age3!=.
replace age=age4 if age4!=.
replace age=age5 if age5!=.

tab age,m
drop age1 age2 age3 age4 age5

gen birthyr=birthyr1
replace birthyr=birthyr2 if birthyr2!=.
replace birthyr=birthyr3 if birthyr3!=.
replace birthyr=birthyr4 if birthyr4!=.
replace birthyr=birthyr5 if birthyr5!=.

tab birthyr,m
drop birthyr1 birthyr2 birthyr3 birthyr4 birthyr5

//gender
gen male=male1
replace male=male2 if male2!=.
replace male=male3 if male3!=.
replace male=male4 if male4!=.
replace male=male5 if male5!=. 
label variable male "Gender"
lab def male 0 "0: female" 1 "1: male"
lab val male male

tab male,m
drop male1 male2 male3 male4 male5

//education
gen edu=edu1
replace edu=edu2 if edu2!=.
replace edu=edu3 if edu3!=.
replace edu=edu4 if edu4!=.
replace edu=edu5 if edu5!=.
label variable edu "Educational degree"
lab def edu 1 "1: primary or below" 2 "2: junior high" 3 "3: senior high" 4 "4: college or above",replace
lab val edu edu

tab edu,m

//marital status
gen single=single1
replace single=single2 if single2!=.
replace single=single3 if single3!=.
replace single=single4 if single4!=.
replace single=single5 if single5!=.
label variable single "Single"
lab def single 1 "1: single" 0 "0: no" 
lab val single single

tab single,m

//Hongkong passport
gen hkp=hsh1
replace hkp=hsh2 if hsh2!=.
replace hkp=hsh3 if hsh3!=.
replace hkp=hsh4 if hsh4!=.
replace hkp=hsh5 if hsh5!=.
label variable hkp "Hongkong passport"
lab def hkp 1 "1: Hongkong passport" 0 "0: no" 
lab val hkp hkp

tab hkp,m

//mainland immigrant
gen imm=imm1
replace imm=imm2 if imm2!=.
replace imm=imm3 if imm3!=.
replace imm=imm4 if imm4!=.
replace imm=imm5 if imm5!=.
label variable imm "Immigrant"
lab def imm 1 "1: immigrant" 0 "0: no" 
lab val imm imm

tab imm,m
drop imm1 imm2 imm3 imm4 imm5

gen bplace=bplace1
replace bplace=bplace2 if bplace2!=.
replace bplace=bplace3 if bplace3!=.
replace bplace=bplace4 if bplace4!=.
replace bplace=bplace5 if bplace5!=.
label variable bplace "Birth place"
lab def bplace 1 "1: Hong Kong" 2 "2: Mainland" 3 "3: others"
lab val bplace bplace

tab bplace,m
drop bplace1 bplace2 bplace3 bplace4 bplace5

//self-report health
gen health=health1
replace health=health2 if health2!=.
replace health=health3 if health3!=.
replace health=health4 if health4!=.
replace health=health5 if health5!=.
label variable health "Self-rated health"
lab def health 1 "1: excellent" 2 "2: very good" 3 "3: good" 4 "4: fair" 5 "5: not good",replace
lab val health health
tab health

tab health,m

//working status
gen work=work1
replace work=work2 if work2!=.
replace work=work3 if work3!=.
replace work=work4 if work4!=.
replace work=work5 if work5!=.
label variable work "Working Status"
lab def work 1 "1: working" 0 "0: no" 
lab val work work

tab work,m

//occupation
gen occup=occup1
replace occup=occup2 if occup2!=.
replace occup=occup3 if occup3!=.
replace occup=occup4 if occup4!=.
replace occup=occup5 if occup5!=.
label variable occup "Occupation"
lab def occup 1 "1: cadre" 2 "2: professional–technical" 3 "3: office worker" ///
4 "4: commercial and service worker" 5 "5: agriculture–fishing" ///
6 "6: production–transportation"
lab val occup occup

tab occup,m

//per capita family income monthly
gen phinc=phinc1
replace phinc=phinc2 if phinc2!=.
replace phinc=phinc3 if phinc3!=.
replace phinc=phinc4 if phinc4!=.
replace phinc=phinc5 if phinc5!=.

tab phinc,m

order sampleid age birthyr male edu single hkp imm bplace health work occup phinc  ///
edu* single* hsh* health* work* occup* phinc*

save "/Users/mingzhao/Desktop/SARS_HKPSSD/PSSD_adult.dta",replace
