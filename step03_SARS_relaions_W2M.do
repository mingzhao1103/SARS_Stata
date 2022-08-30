
**********************************************************************************************
*family relations W2M
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"	

**********************************************************************************************
*Rename T1

use "W2M_family_relations.dta",clear

rename hhsizex2 fcount2
rename childc childcode2

forval i=1/16 {
	rename t1p`i'marstat_w2 t1p`i'mar2stat

}

//keep related variables
keep sampleid vhhid childcode2 fcount2  ///
t1p*code t1p*birthyr t1p*age t1p*sex t1p*mar2stat ///
t1count W2COUNTALL W2TA3COUNT W2Count W2CountNon AllCountNon W2countall

save "W2M_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W2M_family_relations.dta",clear

rename hhsizex2 fcount2
rename childc childcode2

forval i=11/16 {
	rename hht2p`i'dadcode t2p`i'dadcode
	rename hht2p`i'momcode t2p`i'momcode
	rename hht2p`i'spocode t2p`i'spocode
	
	forval j=1/5{
	rename hht2p`i'childcode`j' t2p`i'childcode`j'
	}
}
 
//keep related variables
keep sampleid vhhid childcode2 fcount2  ///
t1count W2COUNTALL W2TA3COUNT W2Count W2CountNon AllCountNon W2countall  ///
t2p*code t2p*spocode t2p*childcode* t2p*dadcode t2p*momcode t2p*dadalive t2p*momalive

save "W2M_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W2M_family_relations_T1.dta", clear
	 
//reshape requires rename
forval i=1/16{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyr byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'
	 rename t1p`i'mar2stat mar2stat`i'
	 
}

reshape long code byear age sex mar2stat, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code
	 
save "W2M_fam_T1_long.dta",replace
	 
**********************************************************************************************
*Reshape T2

use "W2M_family_relations_T2.dta", clear	 

forval i=11/16{
	 rename t2p`i'code code`i'
	 rename t2p`i'dadalive dadalive`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momalive momalive`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/5{
	 rename t2p`i'childcode`j' childcode`j'p`i'
	 }
}
		 
reshape long code  ///
		dadalive dadcode momalive momcode spocode  ///
		childcode1p childcode2p childcode3p childcode4p childcode5p,  ///
		i(sampleid) j(numb)
		
drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code

save "W2M_fam_T2_long.dta",replace

**********************************************************************************************
*Merge T1 & T2

merge 1:1 sampleid code using "W2M_fam_T1_long.dta"

drop _merge

**update dead parents to missing:
replace dadcode=. if dadalive==-10
replace momcode=. if momalive==-10

duplicates report sampleid
tab fcount2
	  
save "W2M_fam_T12_long.dta", replace  
	 
**********************************************************************************************
*Reshape to wide for checking

bysort sampleid: gen norder=_n

drop dadalive momalive numb

reshape wide code sex byear age mar2stat dadcode momcode spocode-childcode5p, i(sampleid) j(norder)

order sampleid vhhid
 
save "W2M_fam_T12_wide.dta", replace

**********************************************************************************************
*Check & Correct
*......
*save "W2M_fam_T12_long_check4.dta",replace
*save "W2M_fam_T12_wide_check4.dta",replace

**********************************************************************************************
*Check #1

use "W2M_fam_T12_wide_check4.dta",clear

drop relatwrong

gen relatwrong=.
	
	*-----------------------------------------------*
	*Logic 1: A claimed B as his/her spouse, then B should claim A as her/his spouse:
	*only if they are both new fam members
	*-----------------------------------------------*
	
	forval i=1/7{
		forval j=1/7{
		gen whether`i'claim`j'spo=[spocode`i'==code`j'] if spocode`j'==code`i' & spocode`j'!=. & code`i'!=.
		//if j claimed i as spouse, then i should claim j as spouse
	}
	}
	
	*-----------------------------------------------*
	*Logic 2: A claimed A as spouse - wrong (herself)
	*-----------------------------------------------*
	
	forval i=1/7{
	tab whether`i'claim`i'spo
	}
	//whether i claimed i (self) as spo: 
	//No observations, no one claimed him/herself as his/her own spo
	
	forval i=1/7{
		forval j=1/7 {
		tab whether`i'claim`j'spo
	}
	}
	
	//1 is good, 0 is bad: xx cases with wrong spo code that j claimed i as spocode while i did not claim j as spocode
	
	forval i=1/7{
	forval j=1/7 {
	replace relatwrong=1 if whether`i'claim`j'spo==0
	}
	}
	
	forval i=1/7{
	forval j=1/7{
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
	
	forval i=1/7{
	forval j=1/7{
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
	
	forval i=1/7{
	forval j=1/7{
	forval k=1/7{
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
	
	forval i=1/7{
	forval j=1/7{
	forval k=1/2{
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
	
	forval i=1/7{
		forval j=1/7 {
		forval k=1/2 {
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
	
		forval i=1/7{
		forval j=1/7 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
		dadcode`i'==code`j' & dadcode`i'!=. & code`j'!=.	
		}
		}
		//i said j is its dad, j said i is its child?
		
		forval i=1/7{
		forval j=1/7 {
		replace wrongwhetherclaimchild=1 if ///
		childcode1p`j'!=code`i' & ///
		childcode2p`j'!=code`i' & ///
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

****************************************************************************************
*Check #2

gen relatwrong=.

    *---------------------------------------------------
	*Logic 1. Different relatives (spouse, mother, father) for the same person should NOT be the SAME
	*So A's parents cannot be A's spouse or children; vice versa
	*---------------------------------------------------

	forval i=1/7{
	gen newp`i'relativeuniq=1
	}
	//Assume all cases have unique relative code

	forval i=1/7{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== momcode`i' &dadcode`i'!=. & momcode`i'!=.  
	}
	//compare dadcode and momcode when both exist; if the same, not unique -   0 case
	
	forval i=1/7{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== spocode`i' & dadcode`i'!=. & spocode`i'!=. 
	}
	//compare dadcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/7{		
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== spocode`i' & momcode`i'!=. & spocode`i'!=. 
	}
	//compare momcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/7{
	forval j=1/2{	
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== childcode`j'p`i' & dadcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare dadcode and childcode when both exist; if the same, not unique - 0 cases	
	
	forval i=1/7{
	forval j=1/2{	
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== childcode`j'p`i' & momcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare momcode and childcode when both exist; if the same, not unique - 0 case
	
    forval i=1/7{
	forval j=1/2{	
	replace newp`i'relativeuniq=0 if ///
	spocode`i'== childcode`j'p`i' & spocode`i'!=. & childcode`j'p`i'!=. 
	} 		
	}
	//compare spocode and childcode when both exist; if the same, not unique - 0 case
	
	forval i=1/7{
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

	forval i=1/7{
	forval j=1/7 {
	gen newp`j'pat2p`i'pa= ///
	[dadcode`i'== dadcode`j'&dadcode`i'!=.|momcode`i'== momcode`j'&momcode`i'!=.| ///
	 dadcode`i'== momcode`j'&dadcode`i'!=.|momcode`i'== dadcode`j'&momcode`i'!=.] ///
	if childcode1p`i'==code`j'& childcode1p`i'!=. | ///
	   childcode2p`i'==code`j'& childcode2p`i'!=. 

	}
	}
	
	//if i's child is j, i's dad cannot be j's dad, i's mom cannot be j's mom, 
	//i's dad cannot be j's mom and i's mom cannot be j's dad
	
	forval i=1/7{
	forval j=1/7 {
	replace relatwrong=1 if newp`j'pat2p`i'pa==1
	}
	}
	
	forval i=1/7{
	forval j=1/7 {
	drop newp`j'pat2p`i'pa
	}
	}

	count if relatwrong==1 //0 case
		
	*------------------------------------------------------------------*	
	*Logic 3: Couple's Parents cannot be the couple's children
	*A&B are married. C&D are A's Parents. C&D cannot be B's children
	*------------------------------------------------------------------*	
	
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	gen diffchild`i'0`j'0`k'= ///
	[momcode`i'==childcode`k'p`j'|dadcode`i'==childcode`k'p`j'] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. ///
	  & childcode`k'p`j'!=.
	}
	}
	}

	//j,k needs to be 00 format
	
	//if i and j are a couple, i's parents cannot be j's children
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	replace relatwrong=1 if diffchild`i'0`j'0`k'==1
	}
	}
	}
	
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	drop diffchild`i'0`j'0`k'
	}
	}
	}
	
	count if relatwrong==1   //1 case
	
	*---------------------------------------------------
	*Logic 4: A couple cannot share the same parents
	*If A and B are couple, A's parents cannot be B's parents
	*----------------------------------------------------
	
	forval i=1/7{
	forval j=1/7 {
	gen wrongpa`i'0`j'= ///
	[momcode`i'==momcode`j'&momcode`i'!=.|dadcode`i'==dadcode`j'&dadcode`i'!=. | ///
	 momcode`i'==dadcode`j'&momcode`i'!=.|dadcode`i'==momcode`j'&dadcode`i'!=. ] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. 
	}
	}	

	forval i=1/7{
	forval j=1/7 {
	replace relatwrong=1 if wrongpa`i'0`j'==1
	}
	}

	forval i=1/7{
	forval j=1/7 {
	drop wrongpa`i'0`j'
	}
	}

	count if relatwrong==1
	
	*---------------------------------------------------	
	*Logic 5: A's parents cannot be A's grandchildren
	*e.g.D221920000: parents' parents are child's child...
	*---------------------------------------------------
	
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	forval l=1/2{
	gen wronggrandp`i'0`j'0`k'0`l'= ///
	[momcode`i'==childcode`l'p`j'|dadcode`i'==childcode`l'p`j'] ///
	if childcode`k'p`i'==code`j' & code`j'!=. ///
	  & childcode`k'p`i'!=.& childcode`l'p`j'!=.
	}
	}
	}
	}
	
	//if i is j's father or mother, then i's parents canot be j's children
			
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	forval l=1/2{
	replace relatwrong=1 if wronggrandp`i'0`j'0`k'0`l'==1
	}
	}
	}
	}
		
	forval i=1/7{
	forval j=1/7 {
	forval k=1/2{
	forval l=1/2{
	drop wronggrandp`i'0`j'0`k'0`l'
	}
	}
	}
	}		

count if relatwrong==1  //0 case

**********************************************************************************************

save "W2M_fam_T12_wide_clean.dta",replace 

reshape long 

drop if code==.
drop relatwrong

sort sampleid vhhid   
save "W2M_fam_T12_long_clean",replace 

**********************************************************************************************











