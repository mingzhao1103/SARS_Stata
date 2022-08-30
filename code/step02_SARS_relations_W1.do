
**********************************************************************************************
*family relations W1
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1"	

**********************************************************************************************
*Rename T1

use "W1_family_relations.dta",clear

rename hhsize fcount
rename childc childcode
rename cid childid

forval i=1/10 {
	rename hht1p`i'sex t1p`i'sex
	rename hht1p`i'marstat t1p`i'marstat
	rename t1p`i'hedu t1p`i'edu
}

//keep related variables
keep sampleid vhhid childcode childid fatherid motherid fcount  ///
t1p*code t1p*birthyr t1p*age t1p*sex t1p*marstat t1p*edu t1p*empsts ///
famsizeall famsizeco famsizenonco 

save "W1_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W1_family_relations.dta",clear

rename hhsize fcount
rename childc childcode
rename cid childid

forval i=1/10 {
	rename hht2p`i'dadcode t2p`i'dadcode
	rename hht2p`i'momcode t2p`i'momcode
	rename hht2p`i'spocode t2p`i'spocode
	
	forval j=1/11{
	rename hht2p`i'childcode`j' t2p`i'childcode`j'
	}
}
 
//keep related variables
keep sampleid vhhid childcode childid fatherid motherid fcount  ///
famsizeall famsizeco famsizenonco  ///
t2p*code t2p*marstat t2p*spocode t2p*childcode* t2p*dadcode t2p*momcode t2p*dadalive t2p*momalive

save "W1_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W1_family_relations_T1.dta", clear
	 
//reshape requires rename
forval i=1/10{
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
	 
save "W1_fam_T1_long.dta",replace
	 
**********************************************************************************************
*Reshape T2

use "W1_family_relations_T2.dta", clear	 

forval i=1/10{
	 rename t2p`i'code code`i'
	 rename t2p`i'marstat t2marstat`i'
	 rename t2p`i'dadalive dadalive`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momalive momalive`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/11{
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

save "W1_fam_T2_long.dta",replace

**********************************************************************************************
*Merge T1 & T2

merge 1:1 sampleid code using "W1_fam_T1_long.dta"

drop _merge

**update dead parents to missing:
replace dadcode=. if dadalive==5
replace momcode=. if momalive==5
	  
**comparing Table 1 and Table 2 information
count if marstat!=t2marstat

duplicates report sampleid
tab fcount
	  
save "W1_fam_T12_long.dta", replace  
	 
**********************************************************************************************
*Reshape to wide for checking

bysort sampleid: gen norder=_n

drop dadalive momalive numb

reshape wide code sex byear age marstat t2marstat edu empsts dadcode momcode spocode-childcode11p, i(sampleid) j(norder)

order sampleid vhhid
 
save "W1_fam_T12_wide.dta", replace

**********************************************************************************************
*Check #1

use "W1_fam_T12_wide.dta", clear

gen relatwrong=.
	
	*-----------------------------------------------*
	*Logic 1: A claimed B as his/her spouse, then B should claim A as her/his spouse:
	*only if they are both new fam members
	*-----------------------------------------------*
	
	forval i=1/10{
		forval j=1/10{
		gen whether`i'claim`j'spo=[spocode`i'==code`j'] if spocode`j'==code`i' & spocode`j'!=. & code`i'!=.
		//if j claimed i as spouse, then i should claim j as spouse
	}
	}
	
	*-----------------------------------------------*
	*Logic 2: A claimed A as spouse - wrong (herself)
	*-----------------------------------------------*
	
	forval i=1/10{
	tab whether`i'claim`i'spo
	}
	//whether i claimed i (self) as spo: 
	//No observations, no one claimed him/herself as his/her own spo
	
	forval i=1/10{
		forval j=1/10 {
		tab whether`i'claim`j'spo
	}
	}
	
	//1 is good, 0 is bad: xx cases with wrong spo code that j claimed i as spocode while i did not claim j as spocode
	
	forval i=1/10{
	forval j=1/10 {
	replace relatwrong=1 if whether`i'claim`j'spo==0
	}
	}
	
	forval i=1/10{
	forval j=1/10{
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
	
	forval i=1/10{
	forval j=1/10{
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
	
	forval i=1/10{
	forval j=1/10{
	forval k=1/10{
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
	
	forval i=1/10{
	forval j=1/10{
	forval k=1/11{
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
	
	forval i=1/10{
		forval j=1/10 {
		forval k=1/11 {
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
	
		forval i=1/10{
		forval j=1/10 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
		childcode3p`j'!=code`i' & ///
		childcode4p`j'!=code`i' & ///
		childcode5p`j'!=code`i' & ///
		childcode6p`j'!=code`i' & ///
		childcode7p`j'!=code`i' & ///
		childcode8p`j'!=code`i' & ///
		childcode9p`j'!=code`i' & ///
		childcode10p`j'!=code`i' & ///
		childcode11p`j'!=code`i' & ///
		dadcode`i'==code`j' & dadcode`i'!=. & code`j'!=.	
		}
		}
		//i said j is its dad, j said i is its child?
		
		forval i=1/10{
		forval j=1/10 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
		childcode3p`j'!=code`i' & ///
		childcode4p`j'!=code`i' & ///
		childcode5p`j'!=code`i' & ///
		childcode6p`j'!=code`i' & ///
		childcode7p`j'!=code`i' & ///
		childcode8p`j'!=code`i' & ///
		childcode9p`j'!=code`i' & ///
		childcode10p`j'!=code`i' & ///
		childcode11p`j'!=code`i' & ///
		momcode`i'==code`j' & momcode`i'!=.&code`j'!=.		
		}
		}
		//i said j is its mom, j said i is its child?
		
	count if wrongwhetherclaimchild==1 
	replace relatwrong=1 if wrongwhetherclaimchild==1
    drop wrongwhetherclaimchild

count
count if relatwrong==1  

sort sampleid vhhid   
save "W1_fam_T12_wide_check1.dta",replace 

**********************************************************************************************
*Check #2

clear
set maxvar 32767
use "W1_fam_T12_wide_check1.dta",clear

drop relatwrong
gen relatwrong=.

    *---------------------------------------------------
	*Logic 1. Different relatives (spouse, mother, father) for the same person should NOT be the SAME
	*So A's parents cannot be A's spouse or children; vice versa
	*---------------------------------------------------

	forval i=1/10{
	gen newp`i'relativeuniq=1
	}
	//Assume all cases have unique relative code

	forval i=1/10{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== momcode`i' &dadcode`i'!=. & momcode`i'!=.  
	}
	//compare dadcode and momcode when both exist; if the same, not unique -   0 case
	
	forval i=1/10{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== spocode`i' & dadcode`i'!=. & spocode`i'!=. 
	}
	//compare dadcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/10{		
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== spocode`i' & momcode`i'!=. & spocode`i'!=. 
	}
	//compare momcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/10{
	forval j=1/11{	
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== childcode`j'p`i' & dadcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare dadcode and childcode when both exist; if the same, not unique - 0 cases	
	
	forval i=1/10{
	forval j=1/11{	
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== childcode`j'p`i' & momcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare momcode and childcode when both exist; if the same, not unique - 0 case
	
    forval i=1/10{
	forval j=1/11{	
	replace newp`i'relativeuniq=0 if ///
	spocode`i'== childcode`j'p`i' & spocode`i'!=. & childcode`j'p`i'!=. 
	} 		
	}
	//compare spocode and childcode when both exist; if the same, not unique - 0 case
	
	forval i=1/10{
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

	forval i=1/10{
	forval j=1/10 {
	gen newp`j'pat2p`i'pa= ///
	[dadcode`i'== dadcode`j'&dadcode`i'!=.|momcode`i'== momcode`j'&momcode`i'!=.| ///
	 dadcode`i'== momcode`j'&dadcode`i'!=.|momcode`i'== dadcode`j'&momcode`i'!=.] ///
	if childcode1p`i'==code`j'& childcode1p`i'!=. | ///
	   childcode2p`i'==code`j'& childcode2p`i'!=. | ///
	   childcode3p`i'==code`j'& childcode3p`i'!=. | ///
	   childcode4p`i'==code`j'& childcode4p`i'!=. | ///
	   childcode5p`i'==code`j'& childcode5p`i'!=. | /// 
	   childcode6p`i'==code`j'& childcode6p`i'!=. | ///
	   childcode7p`i'==code`j'& childcode7p`i'!=. | ///
	   childcode8p`i'==code`j'& childcode8p`i'!=. | ///
	   childcode9p`i'==code`j'& childcode9p`i'!=. | /// 
	   childcode10p`i'==code`j'& childcode10p`i'!=. | /// 
	   childcode11p`i'==code`j'& childcode11p`i'!=. 
	}
	}
	
	//if i's child is j, i's dad cannot be j's dad, i's mom cannot be j's mom, 
	//i's dad cannot be j's mom and i's mom cannot be j's dad
	
	forval i=1/10{
	forval j=1/10 {
	replace relatwrong=1 if newp`j'pat2p`i'pa==1
	}
	}
	
	forval i=1/10{
	forval j=1/10 {
	drop newp`j'pat2p`i'pa
	}
	}

	count if relatwrong==1 //0 case
		
	*------------------------------------------------------------------*	
	*Logic 3: Couple's Parents cannot be the couple's children
	*A&B are married. C&D are A's Parents. C&D cannot be B's children
	*------------------------------------------------------------------*	
	
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	gen diffchild`i'0`j'0`k'= ///
	[momcode`i'==childcode`k'p`j'|dadcode`i'==childcode`k'p`j'] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. ///
	  & childcode`k'p`j'!=.
	}
	}
	}

	//j,k needs to be 00 format
	
	//if i and j are a couple, i's parents cannot be j's children
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	replace relatwrong=1 if diffchild`i'0`j'0`k'==1
	}
	}
	}
	
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	drop diffchild`i'0`j'0`k'
	}
	}
	}
	
	count if relatwrong==1   //1 case
	
	*---------------------------------------------------
	*Logic 4: A couple cannot share the same parents
	*If A and B are couple, A's parents cannot be B's parents
	*----------------------------------------------------
	
	forval i=1/10{
	forval j=1/10 {
	gen wrongpa`i'0`j'= ///
	[momcode`i'==momcode`j'&momcode`i'!=.|dadcode`i'==dadcode`j'&dadcode`i'!=. | ///
	 momcode`i'==dadcode`j'&momcode`i'!=.|dadcode`i'==momcode`j'&dadcode`i'!=. ] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. 
	}
	}	

	forval i=1/10{
	forval j=1/10 {
	replace relatwrong=1 if wrongpa`i'0`j'==1
	}
	}

	forval i=1/10{
	forval j=1/10 {
	drop wrongpa`i'0`j'
	}
	}

	count if relatwrong==1
	
	*---------------------------------------------------	
	*Logic 5: A's parents cannot be A's grandchildren
	*e.g.D221920000: parents' parents are child's child...
	*---------------------------------------------------
	
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	forval l=1/11{
	gen wronggrandp`i'0`j'0`k'0`l'= ///
	[momcode`i'==childcode`l'p`j'|dadcode`i'==childcode`l'p`j'] ///
	if childcode`k'p`i'==code`j' & code`j'!=. ///
	  & childcode`k'p`i'!=.& childcode`l'p`j'!=.
	}
	}
	}
	}
	
	//if i is j's father or mother, then i's parents canot be j's children
			
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	forval l=1/11{
	replace relatwrong=1 if wronggrandp`i'0`j'0`k'0`l'==1
	}
	}
	}
	}
		
	forval i=1/10{
	forval j=1/10 {
	forval k=1/11{
	forval l=1/11{
	drop wronggrandp`i'0`j'0`k'0`l'
	}
	}
	}
	}		

count if relatwrong==1
	
list vhhid if relatwrong==1
/*
184. | D214460000 |
187. | D214500000 |
222. | D216880000 |
667. | D256260000 |
*/

**********************************************************************************************
*Correct

reshape long code sex byear age marstat t2marstat edu empsts dadcode momcode spocode  ///
childcode1p childcode2p childcode3p childcode4p childcode5p childcode6p childcode7p childcode8p childcode9p childcode10p childcode11p  ///
, i(sampleid) j(norder)

drop if code==.

replace momcode = . in 781
replace dadcode = . in 792
replace momcode = . in 939
replace dadcode = 201 in 2896

drop relatwrong

save "W1_fam_T12_long_clean.dta",replace 

reshape wide
save "W1_fam_T12_wide_clean.dta",replace 

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1"

use "W1_fam_T12_long_clean.dta",clear

gen fam=substr(string(childid,"%12.0f"),1,6)

gen cid2=substr(string(childid,"%12.0f"),-3,.)
gen fid2=substr(string(fatherid,"%12.0f"),-3,.)
gen mid2=substr(string(motherid,"%12.0f"),-3,.)

egen cid = concat(fam cid2) 
egen fid = concat(fam fid2) 
egen mid = concat(fam mid2)

destring cid fid mid,replace

format cid fid mid %14.0g

rename childid childid_o
rename fatherid fatherid_o
rename motherid motherid_o

rename cid childid
rename fid fatherid
rename mid motherid

replace fatherid=. if fatherid_o==.
replace motherid=. if motherid_o==.

save "W1_fam_T12_long_clean.dta",replace 






