
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child_setup.dta",clear

***
***SARS: March 2003 - July 2003
***

//treatment#1
*1: Born and pregnant during SARS

gen treat1=.
replace treat1=1 if childby==2003 & childbm>2 & childbm <13
replace treat1=1 if childby==2004 & childbm>0 & childbm <4
replace treat1=0 if childby==2002 & childbm>1 & childbm <13
replace treat1=0 if childby==2003 & childbm>0 & childbm <3

tab treat1

tab treat1, gen(treat1)

rename treat11 control

//treatment#2
*1: Born during SARS
*2: Pregnant during SARS

gen treat2=.
replace treat2=1 if childby==2003 & childbm>2 & childbm <8
replace treat2=2 if childby==2003 & childbm>7 & childbm <13
replace treat2=2 if childby==2004 & childbm>0 & childbm <4
replace treat2=0 if childby==2002 & childbm>1 & childbm <13
replace treat2=0 if childby==2003 & childbm>0 & childbm <3

tab treat2

tab treat2, gen(treat2)

drop treat21

//treatment#3
*1: First trimester during SARS
*2: Second trimester during SARS
*3: Third trimester during SARS

gen treat32=.
replace treat32=1 if childby==2003 & childbm>8 & childbm <13
replace treat32=1 if childby==2004 & childbm>0 & childbm <4
replace treat32=0 if treat32!=1 & treat1!=.

gen treat33=.
replace treat33=1 if childby==2003 & childbm>5 & childbm <13
replace treat33=0 if treat33!=1 & treat1!=.


gen treat34=.
replace treat34=1 if childby==2003 & childbm>2 & childbm <10
replace treat34=0 if treat34!=1 & treat1!=.

*********************************************************************************

//birth weight
**1kg = 2.2046226pd
**1pd = 0.4535924kg
tab bwpd if bwkg==.,m
tab bwkg if bwpd==.,m

dis 6.8*0.4535924

replace bwkg=3.1 if bwkg==. & bwpd!=.

tab bwkg,m

replace bwkg=bwkg6 if bwkg==.

//gender
tab childmale,m
recode childmale6 5=0
replace childmale=childmale6 if childmale==.
replace childmale=childmale7 if childmale==.
gen m = floor((2)*runiform() + 0) if childmale==.
tab m
replace childmale=m if childmale==.
drop m
tab childmale,m

//health
replace childhealth=childhealth5
replace childhealth=childhealth4 if childhealth4!=.
replace childhealth=childhealth3 if childhealth3!=.
replace childhealth=childhealth2 if childhealth2!=.
replace childhealth=childhealth1 if childhealth1!=.

replace childhealth=childhealth6 if childhealth6!=.
replace childhealth=childhealth7 if childhealth7!=.

tab childhealth,m
recode childhealth 3/5=3

//BMI = kg/m2
tab nowcm1
replace nowcm1=nowcm1*100 if nowcm1<10 & nowcm1>0
tab nowcm2
tab nowcm3
replace nowcm3 = 100 in 598
tab nowcm4
tab nowcm5
tab nowcm6
replace nowcm6=. if nowcm6>200
tab nowcm7

gen childcm=.

replace childcm=nowcm1 if nowcm1>0 & nowcm1!=.
replace childcm=nowcm2 if nowcm2>0 & nowcm2!=.
replace childcm=nowcm3 if nowcm3>0 & nowcm3!=.
replace childcm=nowcm4 if nowcm4>0 & nowcm4!=. 
replace childcm=nowcm5 if nowcm5>0 & nowcm5!=.
replace childcm=nowcm6 if nowcm6>0 & nowcm6!=.
replace childcm=nowcm7 if nowcm7>0 & nowcm7!=.

replace childcm=. if childcm>200

gen childkg=.
replace childkg=nowkg1 if nowkg1>0 & nowkg1!=.
replace childkg=nowkg2 if nowkg2>0 & nowkg2!=.
replace childkg=nowkg3 if nowkg3>0 & nowkg3!=.
replace childkg=nowkg4 if nowkg4>0 & nowkg4!=.
replace childkg=nowkg5 if nowkg5>0 & nowkg5!=.
replace childkg=nowkg6 if nowkg6>0 & nowkg6!=.
replace childkg=nowkg7 if nowkg7>0 & nowkg7!=.

replace childkg=. if childkg>200

gen childpd=.
replace childpd=nowpd1 if nowpd1>0 & nowpd1!=.
replace childpd=nowpd2 if nowpd2>0 & nowpd2!=.
replace childpd=nowpd3 if nowpd3>0 & nowpd3!=.
replace childpd=nowpd4 if nowpd4>0 & nowpd4!=.
replace childpd=nowpd5 if nowpd5>0 & nowpd5!=.

replace childpd=. if childpd>200

gen childm=childcm/100

replace childkg=childpd*0.4535924 if childkg==.

gen bmi= childkg/(childm*childm)
 
//age at delivery
tab m_birthyr,m
gen momby = m_birthyr
replace momby = m_birthyr6 if m_birthyr6!=.
replace momby = m_birthyr7 if m_birthyr7!=.

replace momby = f_birthyr if m_birthyr==. & f_birthyr!=.

replace momby = f_birthyr6 if m_birthyr6==. & f_birthyr6!=.
replace momby = f_birthyr7 if m_birthyr7==. & f_birthyr7!=.

tab momby,m

gen momage = childby - momby
tab momage,m
replace momage=45 if momage>45 & momage!=.
sum momage

gen momage2=momage*momage

//education
tab m_edu,m
gen momedu = m_edu
replace momedu = f_edu if m_edu==. & f_edu!=.
tab momedu,m

replace momedu=m_edu6 if momedu==.
replace momedu=m_edu7 if momedu==.

replace momedu=f_edu6 if momedu==. & f_edu6!=. 
replace momedu=f_edu7 if momedu==. & f_edu7!=.

gen momeduy=.
replace momeduy=6 if momedu==1
replace momeduy=9 if momedu==2
replace momeduy=12 if momedu==3
replace momeduy=16 if momedu==4

gen momeduy2=momeduy*momeduy

//household income
tab m_phinc,m
gen phinc = m_phinc
replace phinc = f_phinc if m_phinc==. & f_phinc!=.
replace phinc = f_phinc if f_phinc > m_phinc & f_phinc!=.
tab phinc,m

replace phinc = m_phinc6 if phinc==. & m_phinc6!=.
replace phinc = m_phinc7 if phinc==. & m_phinc7!=.
replace phinc = f_phinc6 if f_phinc6 > m_phinc6 & f_phinc6!=.
replace phinc = f_phinc7 if f_phinc7 > m_phinc7 & f_phinc7!=.

sum phinc if wave==6,d //median=6250
sum phinc if wave==7,d //median=7500
replace phinc=6250 if wave==6 & phinc==.
replace phinc=7500 if wave==7 & phinc==.

tab wave if phinc==.

sum phinc if wave==1,d //median=5000
sum phinc if wave==2,d //median=6667
sum phinc if wave==3,d //median=8000
sum phinc if wave==4,d //median=6000
sum phinc if wave==5,d //median=6333

replace phinc=5000 if wave==1 & phinc==.
replace phinc=6667 if wave==2 & phinc==.
replace phinc=8000 if wave==3 & phinc==.
replace phinc=6000 if wave==4 & phinc==.
replace phinc=6333 if wave==5 & phinc==.

gen lninc=ln(phinc)
tab lninc,m

//single
gen single=.
replace single=m_single1
replace single=m_single2 if m_single2!=.
replace single=m_single3 if m_single3!=.
replace single=m_single4 if m_single4!=.
replace single=m_single5 if m_single5!=.
replace single=m_single6 if m_single6!=.
replace single=m_single7 if m_single7!=.

tab single,m

replace single=f_single1 if single==.
replace single=f_single2 if f_single2!=. & single==.
replace single=f_single3 if f_single3!=. & single==.
replace single=f_single4 if f_single4!=. & single==.
replace single=f_single5 if f_single5!=. & single==.
replace single=f_single6 if f_single6!=. & single==.
replace single=f_single7 if f_single7!=. & single==.

//distress
ta childhealth1
gen upset1=childhealth1
recode upset1 3 4 5=1 1 2=0
ta upset1

ta optimistic2 
ta sociable2
gen upset2=optimistic2
recode upset2 1 2 3=0 4 5=1
replace upset2=1 if sociable2==4 | sociable2==5
ta upset2

ta disorder34 
ta disorder36 
gen upset3=disorder34
recode upset3 1=0 3=1
replace upset3=1 if disorder36==3
ta upset3

gen disorder44=worry4
gen disorder46=upset4
ta worry4
ta upset4
recode upset4 1=0 3 5=1
replace upset4=1 if disorder44==3|disorder44==5
ta upset4

ta disorder54   
ta disorder56 
gen upset5=disorder56
recode upset5 1=0 3 5=1
replace upset5=1 if disorder54==3|disorder54==5
ta upset5

ta disorder64 
ta disorder66 
ta optimistic6 
ta sociable6
gen upset6=disorder66
recode upset6 1=0 3 5=1
replace upset6=1 if disorder64==3|disorder64==5
ta upset6

ta blue7 
ta worthless7 
ta hopeless7
ta childhealth7
gen upset7=childhealth7
recode upset7 1 2 3=0 4=1 
ta upset7

gen anx=.
replace anx=0 if upset1==0
replace anx=0 if upset2==0
replace anx=0 if upset3==0
replace anx=0 if upset4==0
replace anx=0 if upset5==0
replace anx=0 if upset6==0
replace anx=0 if upset7==0

replace anx=1 if upset1==1
replace anx=1 if upset2==1
replace anx=1 if upset3==1
replace anx=1 if upset4==1
replace anx=1 if upset5==1
replace anx=1 if upset6==1
replace anx=1 if upset7==1

ta anx,m

save "SARS_child_analysis.dta",replace


