
**********************************************************************************************
*family relations W3
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"	

**********************************************************************************************
*Rename old T1 

use "W3_family_relations.dta",clear

rename hhsizex3 fcount3
rename cid childcode
rename id childid

//keep related variables
keep sampleid vhhid childcode childid fcount3  ///
t1p*code t1p*birthyear t1p*age t1p*sex 

save "W3_family_relations_T1_old.dta",replace

**********************************************************************************************
*Rename new T1 

use "W3_family_relations.dta",clear

rename hhsizex3 fcount3
rename cid childcode
rename id childid

//keep related variables
keep sampleid vhhid childcode childid fcount3  ///
newp*code newp*birthyr newp*age newp*sex newp*reason 

save "W3_family_relations_T1_new.dta",replace

**********************************************************************************************
*Rename new T2

use "W3_family_relations.dta",clear

rename hhsizex3 fcount3
rename cid childcode
rename id childid

forval i=1/10 {
forval j=1/5 {
	rename newp`i'child`j'code newp`i'childcode`j'
}
}
//keep related variables
keep sampleid vhhid childcode childid fcount3  ///
newp*code newp*spocode newp*childcode* newp*dadcode newp*momcode

save "W3_family_relations_T2_new.dta",replace

**********************************************************************************************
*Reshape old T1

use "W3_family_relations_T1_old.dta", clear
	 
//reshape requires rename
forval i=1/10{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyear byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'	 
}

reshape long code byear age sex, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code
	 
save "W3_fam_T1_long_old.dta",replace

**********************************************************************************************
*Reshape new T1

use "W3_family_relations_T1_new.dta", clear
	 
//reshape requires rename
forval i=1/10{
	 rename newp`i'code code`i' 
	 rename newp`i'birthyr byear`i'
	 rename newp`i'age age`i'
	 rename newp`i'sex sex`i'
	 rename newp`i'reason reason`i'
}

reshape long code byear age sex reason, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code
	 
save "W3_fam_T1_long_new.dta",replace
**********************************************************************************************
*Reshape new T2

use "W3_family_relations_T2_new.dta", clear	 

forval i=1/10{
	 rename newp`i'code code`i'
	 rename newp`i'dadcode dadcode`i'
	 rename newp`i'momcode momcode`i'
	 rename newp`i'spocode spocode`i'
	 
	 forval j=1/5{
	 rename newp`i'childcode`j' childcode`j'p`i'
	 }
}
		 
reshape long code  ///
		dadcode momcode spocode  ///
		childcode1p childcode2p childcode3p childcode4p childcode5p,  ///
		i(sampleid) j(numb)
		
drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code

save "W3_fam_T2_long_new.dta",replace

**********************************************************************************************
*Merge new T1 & T2

merge 1:1 sampleid code using "W3_fam_T1_long_new.dta"

drop _merge

duplicates report sampleid
tab fcount3
	  
save "W3_fam_T12_long_new.dta", replace  

**********************************************************************************************
*Match old T1 with W1 & W2

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T1_long_old.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta"

//matched==1057

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta"

//matched==1481

drop if _merge==2

drop _merge
	  
save "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_old.dta", replace

**********************************************************************************************
*Append 

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"	

use "W3_fam_T12_long_old.dta"

append using "W3_fam_T12_long_new.dta"

sort sampleid
	 
**********************************************************************************************
*Reshape to wide for checking

drop norder
bysort sampleid: gen norder=_n

drop numb

drop t2marstat edu empsts fatherid motherid fcount famsizeall famsizeco famsizenonco fcount2 ta2count  ///
allfamilycount ta3count reason newp*

reshape wide code sex byear age marstat mar2stat dadcode momcode spocode-childcode6p, i(sampleid) j(norder)

order sampleid vhhid
 
save "W3_fam_T12_wide.dta", replace

**********************************************************************************************
*Check #1

use "W3_fam_T12_wide.dta", clear

gen relatwrong=.
	
	*-----------------------------------------------*
	*Logic 1: A claimed B as his/her spouse, then B should claim A as her/his spouse:
	*only if they are both new fam members
	*-----------------------------------------------*
	
	forval i=1/12{
		forval j=1/12{
		gen whether`i'claim`j'spo=[spocode`i'==code`j'] if spocode`j'==code`i' & spocode`j'!=. & code`i'!=.
		//if j claimed i as spouse, then i should claim j as spouse
	}
	}
	
	*-----------------------------------------------*
	*Logic 2: A claimed A as spouse - wrong (herself)
	*-----------------------------------------------*
	
	forval i=1/12{
	tab whether`i'claim`i'spo
	}
	//whether i claimed i (self) as spo: 
	//No observations, no one claimed him/herself as his/her own spo
	
	forval i=1/12{
		forval j=1/12 {
		tab whether`i'claim`j'spo
	}
	}
	
	//1 is good, 0 is bad: xx cases with wrong spo code that j claimed i as spocode while i did not claim j as spocode
	
	forval i=1/12{
	forval j=1/12 {
	replace relatwrong=1 if whether`i'claim`j'spo==0
	}
	}
	
	forval i=1/12{
	forval j=1/12{
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
	
	forval i=1/12{
	forval j=1/12{
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
	
	forval i=1/12{
	forval j=1/12{
	forval k=1/12{
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
	
	forval i=1/12{
	forval j=1/12{
	forval k=1/6{
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
	
	forval i=1/12{
		forval j=1/12 {
		forval k=1/6 {
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
	
		forval i=1/12{
		forval j=1/12 {
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
		
		forval i=1/12{
		forval j=1/12 {
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

	forval i=1/12{
	gen newp`i'relativeuniq=1
	}
	//Assume all cases have unique relative code

	forval i=1/12{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== momcode`i' &dadcode`i'!=. & momcode`i'!=.  
	}
	//compare dadcode and momcode when both exist; if the same, not unique -   0 case
	
	forval i=1/12{		
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== spocode`i' & dadcode`i'!=. & spocode`i'!=. 
	}
	//compare dadcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/12{		
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== spocode`i' & momcode`i'!=. & spocode`i'!=. 
	}
	//compare momcode and spocode when both exist; if the same, not unique -   0 case
	
	forval i=1/12{
	forval j=1/6{	
	replace newp`i'relativeuniq=0 if ///
	dadcode`i'== childcode`j'p`i' & dadcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare dadcode and childcode when both exist; if the same, not unique - 0 cases	
	
	forval i=1/12{
	forval j=1/6{	
	replace newp`i'relativeuniq=0 if ///
	momcode`i'== childcode`j'p`i' & momcode`i'!=.&childcode`j'p`i'!=. 
	}
	}
	//compare momcode and childcode when both exist; if the same, not unique - 0 case
	
    forval i=1/12{
	forval j=1/6{	
	replace newp`i'relativeuniq=0 if ///
	spocode`i'== childcode`j'p`i' & spocode`i'!=. & childcode`j'p`i'!=. 
	} 		
	}
	//compare spocode and childcode when both exist; if the same, not unique - 0 case
	
	forval i=1/12{
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

	forval i=1/12{
	forval j=1/12 {
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
	
	forval i=1/12{
	forval j=1/12 {
	replace relatwrong=1 if newp`j'pat2p`i'pa==1
	}
	}
	
	forval i=1/12{
	forval j=1/12 {
	drop newp`j'pat2p`i'pa
	}
	}

	count if relatwrong==1 //0 case
		
	*------------------------------------------------------------------*	
	*Logic 3: Couple's Parents cannot be the couple's children
	*A&B are married. C&D are A's Parents. C&D cannot be B's children
	*------------------------------------------------------------------*	
	
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	gen diffchild`i'0`j'0`k'= ///
	[momcode`i'==childcode`k'p`j'|dadcode`i'==childcode`k'p`j'] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. ///
	  & childcode`k'p`j'!=.
	}
	}
	}

	//j,k needs to be 00 format
	
	//if i and j are a couple, i's parents cannot be j's children
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	replace relatwrong=1 if diffchild`i'0`j'0`k'==1
	}
	}
	}
	
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	drop diffchild`i'0`j'0`k'
	}
	}
	}
	
	count if relatwrong==1   //1 case
	
	*---------------------------------------------------
	*Logic 4: A couple cannot share the same parents
	*If A and B are couple, A's parents cannot be B's parents
	*----------------------------------------------------
	
	forval i=1/12{
	forval j=1/12 {
	gen wrongpa`i'0`j'= ///
	[momcode`i'==momcode`j'&momcode`i'!=.|dadcode`i'==dadcode`j'&dadcode`i'!=. | ///
	 momcode`i'==dadcode`j'&momcode`i'!=.|dadcode`i'==momcode`j'&dadcode`i'!=. ] ///
	if spocode`i'==code`j' & spocode`i'!=. & code`j'!=. 
	}
	}	

	forval i=1/12{
	forval j=1/12 {
	replace relatwrong=1 if wrongpa`i'0`j'==1
	}
	}

	forval i=1/12{
	forval j=1/12 {
	drop wrongpa`i'0`j'
	}
	}

	count if relatwrong==1
	
	*---------------------------------------------------	
	*Logic 5: A's parents cannot be A's grandchildren
	*e.g.D221920000: parents' parents are child's child...
	*---------------------------------------------------
	
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	forval l=1/6{
	gen wronggrandp`i'0`j'0`k'0`l'= ///
	[momcode`i'==childcode`l'p`j'|dadcode`i'==childcode`l'p`j'] ///
	if childcode`k'p`i'==code`j' & code`j'!=. ///
	  & childcode`k'p`i'!=.& childcode`l'p`j'!=.
	}
	}
	}
	}
	
	//if i is j's father or mother, then i's parents canot be j's children
			
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	forval l=1/6{
	replace relatwrong=1 if wronggrandp`i'0`j'0`k'0`l'==1
	}
	}
	}
	}
		
	forval i=1/12{
	forval j=1/12 {
	forval k=1/6{
	forval l=1/6{
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

save "W3_fam_T12_wide_clean.dta",replace 

reshape long 

drop if code==.

drop norder
bysort sampleid:gen norder=_n

sort sampleid norder   
save "W3_fam_T12_long_clean",replace

**********************************************************************************************
*Match W3 with W1 & W2

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta"

//matched==1042

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta"

//matched==1458

drop if _merge==2

drop _merge
	  
save "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta", replace

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"

use "W3_fam_T12_long_clean",clear

gen famid=vhhid

replace famid= subinstr(vhhid, "D", "", .)
replace famid= substr(vhhid, 1, 8)

replace famid= subinstr(famid, "D", "", .)
replace famid= substr(famid, 1, 8)

egen faid = concat(famid dadcode) if code==childcode & dadcode!=.
egen moid = concat(famid momcode) if code==childcode & momcode!=.
egen chid = concat(famid childcode) if code==childcode & childcode!=.

gen fatherid2 = strofreal(fatherid, "%12.0f")
gen motherid2 = strofreal(motherid, "%12.0f")
gen childid2 = strofreal(childid, "%12.0f")

des fatherid2 motherid2 childid2
des faid moid chid 

replace fatherid2 = faid if fatherid2=="." & faid!=""
replace motherid2 = moid if motherid2=="." & moid!=""
replace childid2 = chid if childid2=="." & chid!=""

bysort sampleid (fatherid2) : replace fatherid2 = fatherid2[_N]
bysort sampleid (motherid2) : replace motherid2 = motherid2[_N]
bysort sampleid (childid2) : replace childid2 = childid2[_N]

destring fatherid2 motherid2 childid2,replace

format fatherid2 motherid2 childid2 %14.0g

rename fatherid fid
rename motherid mid
rename childid cid

rename fatherid2 fatherid
rename motherid2 motherid
rename childid2 childid

save "W3_fam_T12_long_clean.dta",replace 

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"

use "W3_fam_T12_long_clean.dta",clear

gen fam=substr(famid,1,6)

rename childid cid2
tostring cid2,replace
gen fid2=substr(string(fatherid,"%12.0f"),-3,.)
gen mid2=substr(string(motherid,"%12.0f"),-3,.)

egen chiid = concat(fam cid2) 
egen fatid = concat(fam fid2) 
egen motid = concat(fam mid2)

destring chiid fatid motid,replace

format chiid fatid motid %14.0g

rename fatherid fatherid_o
rename motherid motherid_o

rename chiid childid
rename fatid fatherid
rename motid motherid

replace fatherid=. if fatherid_o==.
replace motherid=. if motherid_o==.

save "W3_fam_T12_long_clean.dta",replace 

reshape wide
save "W3_fam_T12_wide_clean.dta",replace

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"

use "W3_fam_T12_long_clean.dta",clear

drop _merge

keep if motherid==.|fatherid==.

save "aaa.dta",replace

use "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/aaa.dta"

//matched==507

drop if _merge==1

sort sampleid

drop _merge

save "aaa.dta",replace

use "W3_fam_T12_long_clean.dta",clear

drop if motherid==.|fatherid==.

append using "aaa.dta"

save "W3_fam_T12_long_clean.dta",replace 

sort sampleid

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

save "W3_fam_T12_long_clean.dta",replace 

keep if motherid==.& fatherid==.

save "bbb.dta",replace

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

save "bbb.dta",replace

use "W3_fam_T12_long_clean.dta",clear

drop if motherid==.& fatherid==.

append using "bbb.dta"

sort sampleid

drop norder

bysort sampleid:gen norder=_n

save "W3_fam_T12_long_clean.dta",replace 

