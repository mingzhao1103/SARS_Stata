clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD"

use "SARS_child_setup.dta",clear


*sample restriction
**SARS: 11 March to 11 July

tab childby,m
tab childbm,m

gen bm = floor((12)*runiform() + 1) if childbm==.
tab bm
replace childbm=bm if childbm==.

drop if childby==2001
drop if childby==2005 & childbm>6 & childbm<13

tab childhkb,m
keep if childhkb==1

*variable coding

//treatment 
gen treat=.
replace treat=1 if childby==2003 & childbm>2 & childbm <13
replace treat=1 if childby==2004 & childbm>0 & childbm <5

replace treat=0 if childby==2002
replace treat=0 if childby==2003 & childbm>0 & childbm <3
replace treat=0 if childby==2004 & childbm>4 & childbm <13
replace treat=0 if childby==2005 & childbm>0 & childbm <7 

tab treat,m

gen pretreat=0
replace pretreat=1 if treat==1
replace pretreat=1 if childby==2002
replace pretreat=1 if childby==2003 & childbm>0 & childbm <3

gen postreat=0
replace postreat=1 if treat==1
replace postreat=1 if childby==2004 & childbm>4 & childbm <13
replace postreat=1 if childby==2005 & childbm>0 & childbm <7

gen control1=0
replace control1=1 if childby==2002
replace control1=1 if childby==2003 & childbm>0 & childbm <3

gen control2=0
replace control2=1 if childby==2004 & childbm>4 & childbm <13
replace control2=1 if childby==2005 & childbm>0 & childbm <7


//birth weight
**1kg = 2.2046226pd
**1pd = 0.4535924kg
tab bwpd if bwkg==.,m
tab bwkg if bwpd==.,m

dis 6.8*0.4535924

replace bwkg=3.1 if bwkg==. & bwpd!=.

tab bwpd,m
tab bwkg,m

//grades
gen math=math5
replace math=math4 if math4!=. 
replace math=math3 if math3!=. 
replace math=math2 if math2!=. 
replace math=math1 if math1!=. 

tab math,m

gen chi=chi5
replace chi=chi4 if chi4!=. 
replace chi=chi3 if chi3!=. 
replace chi=chi2 if chi2!=. 
replace chi=chi1 if chi1!=. 

tab chi,m

gen eng=eng5
replace eng=eng4 if eng4!=. 
replace eng=eng3 if eng3!=. 
replace eng=eng2 if eng2!=. 
replace eng=eng1 if eng1!=. 

tab eng,m

//gender
tab childmale

//health
replace childhealth=childhealth5
replace childhealth=childhealth4 if childhealth4!=.
replace childhealth=childhealth3 if childhealth3!=.
replace childhealth=childhealth2 if childhealth2!=.
replace childhealth=childhealth1 if childhealth1!=.

tab childhealth,m
recode childhealth 3/5=3

//illness
replace illfreq=illfreq5
replace illfreq=illfreq4 if illfreq4!=.
replace illfreq=illfreq3 if illfreq3!=.
replace illfreq=illfreq2 if illfreq2!=.
replace illfreq=illfreq1 if illfreq1!=.

tab illfreq,m

//age at delivery
tab m_birthyr,m
gen momby = m_birthyr
replace momby = f_birthyr if m_birthyr==. & f_birthyr!=.

gen momage = childby - momby
tab momage,m

gen momage2=momage*momage

//education
tab m_edu,m
gen momedu = m_edu
replace momedu = f_edu if m_edu==. & f_edu!=.
tab momedu,m

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

gen lninc=ln(phinc)
tab lninc,m

//parent health 
replace m_health=.
replace f_health=.

replace m_health=m_health5 if m_health5!=.
replace m_health=m_health4 if m_health4!=.
replace m_health=m_health3 if m_health3!=.
replace m_health=m_health2 if m_health2!=.
replace m_health=m_health1 if m_health1!=.

replace f_health=f_health5 if f_health5!=.
replace f_health=f_health4 if f_health4!=.
replace f_health=f_health3 if f_health3!=.
replace f_health=f_health2 if f_health2!=.
replace f_health=f_health1 if f_health1!=.

gen phealth = m_health
replace phealth = f_health if m_health==. &  f_health!=.

tab phealth,m

//district
tab kld

//出生后第几个月开始经历经济下滑
gen ecbm=.
replace ecbm=1 if control2==1
replace ecbm=1 if childby==2003 & childbm>6 & childbm <13
replace ecbm=1 if childby==2004 & childbm>0 & childbm <5
replace ecbm=2 if childby==2003 & childbm==6
replace ecbm=3 if childby==2003 & childbm==5
replace ecbm=4 if childby==2003 & childbm==4 
replace ecbm=5 if childby==2003 & childbm==3 
replace ecbm=6 if childby==2003 & childbm==2 
replace ecbm=7 if childby==2003 & childbm==1 
replace ecbm=8 if childby==2002 & childbm==12
replace ecbm=9 if childby==2002 & childbm==11 
replace ecbm=10 if childby==2002 & childbm==10 
replace ecbm=11 if childby==2002 & childbm==9 
replace ecbm=12 if childby==2002 & childbm==8 
replace ecbm=13 if childby==2002 & childbm==7 
replace ecbm=14 if childby==2002 & childbm==6 
replace ecbm=15 if childby==2002 & childbm==5 
replace ecbm=16 if childby==2002 & childbm==4 
replace ecbm=17 if childby==2002 & childbm==3 
replace ecbm=18 if childby==2002 & childbm==2 
replace ecbm=19 if childby==2002 & childbm==1 

tab ecbm if pretreat==1
tab ecbm if postreat==1


//经历了几个月经济下滑
gen exbm1=.
replace exbm1=12 if control1==1
replace exbm1=12 if childby==2003 & childbm<8 
replace exbm1=11 if childby==2003 & childbm==8
replace exbm1=10 if childby==2003 & childbm==9
replace exbm1=9 if childby==2003 & childbm==10
replace exbm1=8 if childby==2003 & childbm==11
replace exbm1=7 if childby==2003 & childbm==12
replace exbm1=6 if childby==2004 & childbm==1
replace exbm1=5 if childby==2004 & childbm==2
replace exbm1=4 if childby==2004 & childbm==3
replace exbm1=3 if childby==2004 & childbm==4

replace exbm1=2 if childby==2004 & childbm==5 
replace exbm1=1 if childby==2004 & childbm==6
replace exbm1=0 if childby==2004 & childbm==7
replace exbm1=0 if childby==2004 & childbm==8
replace exbm1=0 if childby==2004 & childbm==9
replace exbm1=0 if childby==2004 & childbm==10
replace exbm1=0 if childby==2004 & childbm==11
replace exbm1=0 if childby==2004 & childbm==12
replace exbm1=0 if childby==2005 & childbm==1
replace exbm1=0 if childby==2005 & childbm==2
replace exbm1=0 if childby==2005 & childbm==3 
replace exbm1=0 if childby==2005 & childbm==4
replace exbm1=0 if childby==2005 & childbm==5
replace exbm1=0 if childby==2005 & childbm==6

tab exbm1 if pretreat==1
tab exbm1 if postreat==1

gen exbm2=.
replace exbm2=24 if control1==1
replace exbm2=24 if childby==2003 & childbm<8 
replace exbm2=23 if childby==2003 & childbm==8
replace exbm2=22 if childby==2003 & childbm==9
replace exbm2=21 if childby==2003 & childbm==10
replace exbm2=20 if childby==2003 & childbm==11
replace exbm2=19 if childby==2003 & childbm==12
replace exbm2=18 if childby==2004 & childbm==1
replace exbm2=17 if childby==2004 & childbm==2
replace exbm2=16 if childby==2004 & childbm==3
replace exbm2=15 if childby==2004 & childbm==4

replace exbm2=14 if childby==2004 & childbm==5 
replace exbm2=13 if childby==2004 & childbm==6
replace exbm2=12 if childby==2004 & childbm==7
replace exbm2=11 if childby==2004 & childbm==8
replace exbm2=10 if childby==2004 & childbm==9
replace exbm2=9 if childby==2004 & childbm==10
replace exbm2=8 if childby==2004 & childbm==11
replace exbm2=7 if childby==2004 & childbm==12
replace exbm2=6 if childby==2005 & childbm==1
replace exbm2=5 if childby==2005 & childbm==2
replace exbm2=4 if childby==2005 & childbm==3 
replace exbm2=3 if childby==2005 & childbm==4
replace exbm2=2 if childby==2005 & childbm==5
replace exbm2=1 if childby==2005 & childbm==6

tab exbm2 if pretreat==1
tab exbm2 if postreat==1

gen exbm3=.
replace exbm3=36 if control1==1
replace exbm3=36 if childby==2003 & childbm<8 
replace exbm3=35 if childby==2003 & childbm==8
replace exbm3=34 if childby==2003 & childbm==9
replace exbm3=33 if childby==2003 & childbm==10
replace exbm3=32 if childby==2003 & childbm==11
replace exbm3=31 if childby==2003 & childbm==12
replace exbm3=30 if childby==2004 & childbm==1
replace exbm3=29 if childby==2004 & childbm==2
replace exbm3=28 if childby==2004 & childbm==3
replace exbm3=27 if childby==2004 & childbm==4

replace exbm3=26 if childby==2004 & childbm==5 
replace exbm3=25 if childby==2004 & childbm==6
replace exbm3=24 if childby==2004 & childbm==7
replace exbm3=23 if childby==2004 & childbm==8
replace exbm3=22 if childby==2004 & childbm==9
replace exbm3=21 if childby==2004 & childbm==10
replace exbm3=20 if childby==2004 & childbm==11
replace exbm3=19 if childby==2004 & childbm==12
replace exbm3=18 if childby==2005 & childbm==1
replace exbm3=17 if childby==2005 & childbm==2
replace exbm3=16 if childby==2005 & childbm==3 
replace exbm3=15 if childby==2005 & childbm==4
replace exbm3=14 if childby==2005 & childbm==5
replace exbm3=13 if childby==2005 & childbm==6

tab exbm3 if pretreat==1
tab exbm3 if postreat==1

sum treat childmale momeduy lninc kld ecbm exbm1 exbm2 exbm3

save "SARS_child_random.dta",replace

********************************************************************************

//random experiment

use "SARS_child_random.dta",clear

mark nomi if !mi(treat,bwkg,childmale,momeduy,lninc,kld) 

tab childhealth if nomi==1 & treat==1
tab childhealth if nomi==1 & treat==0

tab childhealth if nomi==1 & control1==1
tab childhealth if nomi==1 & control2==1

sum bwkg childmale momeduy phinc lninc kld if nomi==1 & treat==1
sum bwkg childmale momeduy phinc lninc kld if nomi==1 & treat==0
sum bwkg childmale momeduy phinc lninc kld if nomi==1 & control1==1
sum bwkg childmale momeduy phinc lninc kld if nomi==1 & control2==1

ttest childhealth if nomi, by(treat)
ttest childhealth if nomi & pretreat, by(treat)
ttest childhealth if nomi & postreat, by(treat)

//Birth weight

reg bwkg treat                             if nomi
outreg2 using "treat0.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
reg bwkg treat childmale momeduy lninc kld if nomi
outreg2 using "treat0.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat                            if pretreat & nomi
outreg2 using "treat0.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
reg bwkg treat childmale momeduy lninc kld if pretreat & nomi
outreg2 using "treat0.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

reg bwkg treat                            if postreat & nomi
outreg2 using "treat0.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
reg bwkg treat childmale momeduy lninc kld if postreat & nomi
outreg2 using "treat0.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label



//ecbm

ologit childhealth treat if nomi
outreg2 using "treat1.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label 
ologit childhealth treat bwkg if nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat ecbm if nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat bwkg ecbm childmale momeduy lninc kld if nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label


ologit childhealth treat if pretreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat bwkg if pretreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat ecbm if pretreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat bwkg ecbm childmale momeduy lninc kld if pretreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label


ologit childhealth treat if postreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat bwkg if postreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat ecbm if postreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label
ologit childhealth treat bwkg ecbm childmale momeduy lninc kld if postreat & nomi
outreg2 using "treat1.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label



//as-if random experiment
//birth weight is not matched

use "SARS_child_random.dta",clear

mark nomi if !mi(treat,bwkg,childmale,momeduy,lninc,kld) 

psmatch2 treat childmale momeduy lninc kld if nomi, out(childhealth) neighbor(1) ate noreplace logit 

*psgraph

*pstest

gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2

tab childhealth if treat==1
tab childhealth if treat==0

sum childmale momeduy phinc bwkg lninc kld if treat==1
sum childmale momeduy phinc bwkg lninc kld if treat==0

reg bwkg treat
outreg2 using "treat2.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label


ologit childhealth treat
outreg2 using "treat3.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

ologit childhealth treat bwkg
outreg2 using "treat3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

ologit childhealth treat ecbm
outreg2 using "treat3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

ologit childhealth treat bwkg ecbm
outreg2 using "treat3.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label




/*
//as-if random experiment
//birth weight is matched

use "SARS_child_random.dta",clear

mark nomi if !mi(treat,bwkg,childmale,momeduy,lninc,kld) 

psmatch2 treat childmale bwkg momeduy lninc kld if nomi, out(childhealth) neighbor(1) ate noreplace logit 

*psgraph

*pstest

gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)
drop if paircount !=2

tab childhealth if treat==1
tab childhealth if treat==0

sum childmale momeduy phinc bwkg lninc kld if treat==1
sum childmale momeduy phinc bwkg lninc kld if treat==0

ologit childhealth treat
outreg2 using "treat4.xls", replace dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

ologit childhealth treat ecbm
outreg2 using "treat4.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label













reg childhealth treat
ttest childhealth , by(treat)

outreg2 using "treat2.xls", append dec(3) alpha(0.01, 0.05, 0.10) symbol(***, **, +) ctitle (Model 1) label

sum _pscore childhealth childmale bwkg momeduy lninc kld if treat==0

sum _pscore childhealth childmale bwkg momeduy lninc kld if treat==1


save "SARS_child_asif_random.dta",replace







































