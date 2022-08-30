
**********************************************************************************************
*family relations W4
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

**********************************************************************************************
*Rename T1 

use "W4_family_relations.dta",clear

foreach var of varlist _all{      
	rename `var' `=lower("`var'")'   
}

rename ha1 fcount4
rename acode childcode

rename hb1 t1p1code
rename hbs1 t1p1sex
rename hb3 t1p1birthyear
rename hb3a t1p1age

forval i=2/12{
	rename hbs`i' t1p`i'sex
	rename hb3a`i' t1p`i'age
}

forval i=1/11{
	local j=1+`i'*6
	local k= `i'+1
	rename hb`j' t1p`k'code
}

forval i=1/11{
	local j=3+`i'*6
	local k= `i'+1
	rename hb`j' t1p`k'birthyear
}    

//keep related variables
keep sampleid vhhid childcode fcount4  ///
t1p*code t1p*birthyear t1p*age t1p*sex 

save "W4_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W4_family_relations.dta",clear

foreach var of varlist _all{      
	rename `var' `=lower("`var'")'   
}

rename ha1 fcount4
rename acode childcode

rename hc1 t2p1code
rename hc4code t2p1dadcode  
rename hc5code t2p1momcode
rename hc6code t2p1spocode
rename hc7code t2p1childcode1
rename hc8code t2p1childcode2 
rename hc9code t2p1childcode3 
rename hc10code t2p1childcode4 
rename hc11code t2p1childcode5

forval i=1/9{
	local j=1+`i'*11
	local k= `i'+1
	rename hc`j' t2p`k'code
}

forval i=2/10{
	rename hc4code`i' t2p`i'dadcode  
	rename hc5code`i' t2p`i'momcode
	rename hc6code`i' t2p`i'spocode
	rename hc7code`i' t2p`i'childcode1
	rename hc8code`i' t2p`i'childcode2 
	rename hc9code`i' t2p`i'childcode3 
	rename hc10code`i' t2p`i'childcode4 
	rename hc11code`i' t2p`i'childcode5
}

//keep related variables
keep sampleid vhhid childcode fcount4  ///
t2p*code t2p*dadcode t2p*momcode t2p*spocode t2p*childcode* 

save "W4_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W4_family_relations_T1.dta", clear
	 
//reshape requires rename
forval i=1/11{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyear byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'	 
}

reshape long code byear age sex, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code

drop t1p12*
	 
save "W4_fam_T1_long.dta",replace

**********************************************************************************************
*Reshape T2

use "W4_family_relations_T2.dta", clear	 

forval i=1/10{
	 rename t2p`i'code code`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/5{
	 rename t2p`i'childcode`j' childcode`j'p`i'
	 }
}

gen code11=.
gen dadcode11=.
gen momcode11=.
gen spocode11=.
gen childcode1p11=.
gen childcode2p11=.
gen childcode3p11=.
gen childcode4p11=.
gen childcode5p11=.
		 
reshape long code  ///
		dadcode momcode spocode  ///
		childcode1p childcode2p childcode3p childcode4p childcode5p,  ///
		i(sampleid) j(numb)
		
drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code

save "W4_fam_T2_long.dta",replace

**********************************************************************************************
*Merge T1 & T2

merge 1:1 sampleid code using "W4_fam_T1_long.dta"

drop _merge

duplicates report sampleid
tab fcount4
	  
save "W4_fam_T12_long.dta", replace  

**********************************************************************************************
*Match W4 with W1 & W2 &W3

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta"

//matched==890

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta"

//matched==912

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta"

//matched==738

drop if _merge==2

drop _merge
	  
save "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long_matched.dta", replace

**********************************************************************************************
*Reshape to wide for checking

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"

use "W4_fam_T12_long_matched.dta",clear

drop norder
bysort sampleid: gen norder=_n

drop numb  ///
marstat mar2stat childid fcount3 fcount2 ta2count allfamilycount ta3count fatherid motherid t2marstat edu empsts fcount famsizeall famsizeco famsizenonco

reshape wide code sex byear age dadcode momcode spocode-childcode5p, i(sampleid) j(norder)

order sampleid vhhid
 
save "W4_fam_T12_wide.dta", replace

**********************************************************************************************
*Check #1

use "W4_fam_T12_wide.dta", clear

gen relatwrong=.
	
	*-----------------------------------------------*
	*Logic 1: A claimed B as his/her spouse, then B should claim A as her/his spouse:
	*only if they are both new fam members
	*-----------------------------------------------*
	
	forval i=1/11{
		forval j=1/11{
		gen whether`i'claim`j'spo=[spocode`i'==code`j'] if spocode`j'==code`i' & spocode`j'!=. & code`i'!=.
		//if j claimed i as spouse, then i should claim j as spouse
	}
	}
	
	*-----------------------------------------------*
	*Logic 2: A claimed A as spouse - wrong (herself)
	*-----------------------------------------------*
	
	forval i=1/11{
	tab whether`i'claim`i'spo
	}
	//whether i claimed i (self) as spo: 
	//No observations, no one claimed him/herself as his/her own spo
	
	forval i=1/11{
		forval j=1/11 {
		tab whether`i'claim`j'spo
	}
	}
	
	//1 is good, 0 is bad: xx cases with wrong spo code that j claimed i as spocode while i did not claim j as spocode
	
	forval i=1/11{
	forval j=1/11 {
	replace relatwrong=1 if whether`i'claim`j'spo==0
	}
	}
	
	forval i=1/11{
	forval j=1/11{
	drop whether`i'claim`j'spo
	}
	}
	
	*----------------------------*
	*Logic 3:Check duplicated spocode
	*In one household, the spocode should be different for different persons
	*t2p1spocode-t2p11spocode should all be different in one household
	*One can only appear once as someone's spouse
	*----------------------------*

	gen duplicatespocode=.
	
	forval i=1/11{
	forval j=1/11{
	replace duplicatespocode=1 if spocode`i'==spocode`j'& spocode`i'!=. & spocode`i'!=. & `i'!=`j'
	}
	}
	count if duplicatespocode==1 
	replace relatwrong=1 if duplicatespocode==1 /*all are included in the 1st check*/
	drop duplicatespocode //no duplicated reporting cases
	
	*--------------------------------------
	*Logic 4: Parents as spouses?
	*C claimed A and B are dad and mom
	*A & B should be couple
	*--------------------------------------
	gen wrongcouplepa=.
	
	forval i=1/11{
	forval j=1/11{
	forval k=1/11{
	replace wrongcouplepa=1 if spocode`j'!= code`k' & dadcode`i'!=. & momcode`i'!=. & code`j'==dadcode`i' & code`k'==momcode`i'
	}
	}
	}
	//if j is i's dad and k is i's mom, j's spouse should be k
	
	count if wrongcouplepa==1 
	replace relatwrong=1 if wrongcouplepa==1
	drop wrongcouplepa
	
	*--------------------------------------
	*Logic 5: Parents as spouses?
	* A and B claimed the same children
	* A and B should be couple	
	*--------------------------------------	
	gen wrongcouplepa=.
	
	forval i=1/11{
	forval j=1/11{
	forval k=1/5{
	replace wrongcouplepa=1 if spocode`j'!=code`i' & childcode`k'p`i'==childcode`k'p`j' & spocode`j'!=. & childcode`k'p`i'!=. & `i'!=`j'
	}
	}
	}
	//check i and j share the same child, whether j's spouse is i
	count if wrongcouplepa==1 
	replace relatwrong=1 if  wrongcouplepa==1 
	drop wrongcouplepa

	
	*-------------------------------------------------------------
	*Logic 6: A claimed C as his/her child 
	*then C should claim A as her/his parent (among either mom or dad)
	*-----------------------------------------------*	 	
	gen wrongwhetherclaimpa=.
	
	forval i=1/11{
		forval j=1/11 {
		forval k=1/5 {
		replace wrongwhetherclaimpa=1 if childcode`k'p`i'==code`j' & dadcode`j'!=code`i' & dadcode`j'!=. & code`i'!=. & momcode`j'!=code`i' & momcode`j'!=. & code`i'!=.
		//if i's child is j but j's dad and mom are not i, then wrong	
	}
	}
	}
	*end: 
	count if wrongwhetherclaimpa==1 //1 case
	replace relatwrong=1 if wrongwhetherclaimpa==1
	drop wrongwhetherclaimpa

	*------------------------------------------------------------*	
	*Logic 7: C claimed A as his/her parents; 
	*then A should claim C as her/his child
	*-----------------------------------------------*
	gen wrongwhetherclaimchild=.
	
		forval i=1/11{
		forval j=1/11 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
		childcode3p`j'!=code`i' & ///
		childcode4p`j'!=code`i' & ///
		childcode5p`j'!=code`i' & ///
		dadcode`i'==code`j' & dadcode`i'!=. & code`j'!=.	
		}
		}
		//i said j is its dad, j said i is its child?
		
		forval i=1/11{
		forval j=1/11 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
		childcode3p`j'!=code`i' & ///
		childcode4p`j'!=code`i' & ///
		childcode5p`j'!=code`i' & ///
		momcode`i'==code`j' & momcode`i'!=.&code`j'!=.		
		}
		}
		//i said j is its mom, j said i is its child?
		
	count if wrongwhetherclaimchild==1 
	replace relatwrong=1 if wrongwhetherclaimchild==1
    drop wrongwhetherclaimchild

count
count if relatwrong==1  //0 case

drop relatwrong

**********************************************************************************************
*Check #2

gen relatwrong=.

    *---------------------------------------------------
	*Logic 1. Different relatives (spouse, mother, father) for the same person should NOT be the SAME
	*So A's parents cannot be A's spouse or children; vice versa
	*---------------------------------------------------

	forval i=1/11{
	gen newp`i'relativeuniq=1
	}
	//Assume all cases have unique relative code

	forval i=1/11{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== momcode`i' &dadcode`i'!=. & momcode`i'!=.  
	}
	//compare dadcode and momcode when both exist; if the same, not unique -   0 case
	
	forval i=1/11{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== spocode`i' & dadcode`i'!=. & spocode`i'!=. 
	}
	//compare dadcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/11{		
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== spocode`i' & momcode`i'!=. & spocode`i'!=. 
	}
	//compare momcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/11{
	forval j=1/5{	
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== childcode`j'p`i' & dadcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare dadcode and childcode when both exist; if the same, not unique - 0 cases	
	
	forval i=1/11{
	forval j=1/5{	
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== childcode`j'p`i' & momcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare momcode and childcode when both exist; if the same, not unique - 0 case
	
    forval i=1/11{
	forval j=1/5{	
	replace newp`i'relativeuniq=0 if ///
	spocode`i'== childcode`j'p`i' & spocode`i'!=. & childcode`j'p`i'!=. 
	} 		
	}
	//compare spocode and childcode when both exist; if the same, not unique - 0 case
	
	forval i=1/11{
	replace relatwrong=1 if newp`i'relativeuniq==0
	}

	drop newp*relativeuniq	
	count if relatwrong==1 // 0 case
		
	*---------------------------------------------------
	*Logic 2: Parents and their children cannot share the same dadcode/momcode
	*A's parents cannot be A's children's Parents	
	*---------------------------------------------------
	*the logit should be: once a code has been claimed as parents of the mother/father;
	*the child cannot use it as dadcode/momcode

	forval i=1/11{
	forval j=1/11 {
	gen newp`j'pat2p`i'pa= ///
	[dadcode`i'== dadcode`j'&dadcode`i'!=.|momcode`i'== momcode`j'&momcode`i'!=.| ///
	 dadcode`i'== momcode`j'&dadcode`i'!=.|momcode`i'== dadcode`j'&momcode`i'!=.] ///
	if childcode1p`i'==code`j'& childcode1p`i'!=. | ///
	   childcode2p`i'==code`j'& childcode2p`i'!=. | ///
	   childcode3p`i'==code`j'& childcode3p`i'!=. | ///
	   childcode4p`i'==code`j'& childcode4p`i'!=. | ///
	   childcode5p`i'==code`j'& childcode5p`i'!=. 

	}
	}
	
	//if i's child is j, i's dad cannot be j's dad, i's mom cannot be j's mom, 
	//i's dad cannot be j's mom and i's mom cannot be j's dad
	
	forval i=1/11{
	forval j=1/11 {
	replace relatwrong=1 if newp`j'pat2p`i'pa==1
	}
	}
	
	forval i=1/11{
	forval j=1/11 {
	drop newp`j'pat2p`i'pa
	}
	}

	count if relatwrong==1 //0 case
		
	*------------------------------------------------------------------*	
	*Logic 3: Couple's Parents cannot be the couple's children
	*A&B are married. C&D are A's Parents. C&D cannot be B's children
	*------------------------------------------------------------------*	
	
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	gen diffchild`i'0`j'0`k'= ///
	[momcode`i'==childcode`k'p`j'|dadcode`i'==childcode`k'p`j'] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. ///
	  & childcode`k'p`j'!=.
	}
	}
	}

	//j,k needs to be 00 format
	
	//if i and j are a couple, i's parents cannot be j's children
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	replace relatwrong=1 if diffchild`i'0`j'0`k'==1
	}
	}
	}
	
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	drop diffchild`i'0`j'0`k'
	}
	}
	}
	
	count if relatwrong==1   //1 case
	
	*---------------------------------------------------
	*Logic 4: A couple cannot share the same parents
	*If A and B are couple, A's parents cannot be B's parents
	*----------------------------------------------------
	
	forval i=1/11{
	forval j=1/11 {
	gen wrongpa`i'0`j'= ///
	[momcode`i'==momcode`j'&momcode`i'!=.|dadcode`i'==dadcode`j'&dadcode`i'!=. | ///
	 momcode`i'==dadcode`j'&momcode`i'!=.|dadcode`i'==momcode`j'&dadcode`i'!=. ] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. 
	}
	}	

	forval i=1/11{
	forval j=1/11 {
	replace relatwrong=1 if wrongpa`i'0`j'==1
	}
	}

	forval i=1/11{
	forval j=1/11 {
	drop wrongpa`i'0`j'
	}
	}

	count if relatwrong==1
	
	*---------------------------------------------------	
	*Logic 5: A's parents cannot be A's grandchildren
	*e.g.D221920000: parents' parents are child's child...
	*---------------------------------------------------
	
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	forval l=1/5{
	gen wronggrandp`i'0`j'0`k'0`l'= ///
	[momcode`i'==childcode`l'p`j'|dadcode`i'==childcode`l'p`j'] ///
	if childcode`k'p`i'==code`j' & code`j'!=. ///
	  & childcode`k'p`i'!=.& childcode`l'p`j'!=.
	}
	}
	}
	}
	
	//if i is j's father or mother, then i's parents canot be j's children
			
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	forval l=1/5{
	replace relatwrong=1 if wronggrandp`i'0`j'0`k'0`l'==1
	}
	}
	}
	}
		
	forval i=1/11{
	forval j=1/11 {
	forval k=1/5{
	forval l=1/5{
	drop wronggrandp`i'0`j'0`k'0`l'
	}
	}
	}
	}		

count if relatwrong==1  //0 case

drop relatwrong


**********************************************************************************************
*Correct
*......
**********************************************************************************************

save "W4_fam_T12_wide_clean.dta",replace 

reshape long 

drop if code==.

drop norder
bysort sampleid:gen norder=_n

sort sampleid norder   
save "W4_fam_T12_long_clean",replace

**********************************************************************************************

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"

use "W4_fam_T12_long_clean",clear

gen famid=vhhid

replace famid= subinstr(vhhid, "D", "", .)
replace famid= substr(vhhid, 1, 8)

replace famid= subinstr(famid, "D", "", .)
replace famid= substr(famid, 1, 8)

gen fam=substr(famid,1,6)

gen cid=string(childcode)
gen fid=string(dadcode)
gen mid=string(momcode)

egen chid = concat(fam cid) if cid!="."
egen faid = concat(fam fid) if fid!="." 
egen moid = concat(fam mid) if mid!="."

bysort sampleid (chid) : replace chid = chid[_N]
bysort sampleid (faid) : replace faid = faid[_N]
bysort sampleid (moid) : replace moid = moid[_N]

destring chid faid moid,replace

format chid faid moid %14.0g

rename chid childid
rename faid fatherid
rename moid motherid

save "W4_fam_T12_long_clean.dta",replace 

reshape wide
save "W4_fam_T12_wide_clean.dta",replace

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"

use "W4_fam_T12_long_clean.dta",clear

keep if motherid==.|fatherid==.

save "aaa.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/aaa.dta"

//matched==711

drop if _merge==1

drop _merge

destring cid fid mid,replace

save "aaa.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/aaa.dta"

//matched==846

drop if _merge==1

drop _merge

save "aaa.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/aaa.dta"

//matched==798

drop if _merge==1

drop _merge

save "aaa.dta",replace

sort sampleid

use "W4_fam_T12_long_clean.dta",clear

drop if motherid==.|fatherid==.

destring cid fid mid,replace

append using "aaa.dta"

sort sampleid

save "W4_fam_T12_long_clean.dta",replace 

drop father mother
gen father=string(fatherid,"%12.0f")
gen mother=string(motherid,"%12.0f")

bysort sampleid (father) : replace father = father[_N]
bysort sampleid (mother) : replace mother = mother[_N]

gen father1=father
gen mother1=mother

destring father1,replace
destring mother1,replace

format father1 mother1 %12.0g

drop fatherid motherid

rename father1 fatherid
rename mother1 motherid

save "W4_fam_T12_long_clean.dta",replace 

keep if motherid==.& fatherid==.

save "bbb.dta",replace

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"

use "bbb.dta",clear

gen did=strofreal(dadcode)
gen mid=strofreal(momcode)

egen faid = concat(fam did) if code==childcode
egen moid = concat(fam mid) if code==childcode
replace faid="" if did=="."
replace moid="" if mid=="."

drop fatherid motherid

bysort sampleid (faid) : replace faid = faid[_N]
bysort sampleid (moid) : replace moid = moid[_N]

destring faid,gen(faid1)
destring moid,gen(moid1)

format faid1 moid1 %12.0g

rename faid1 fatherid 
rename moid1 motherid

drop faid moid

destring mid did,replace

save "bbb.dta",replace

use "W4_fam_T12_long_clean.dta",clear

drop if motherid==.& fatherid==.

append using "bbb.dta"

sort sampleid

drop norder

bysort sampleid:gen norder=_n

save "W4_fam_T12_long_clean.dta",replace 


































