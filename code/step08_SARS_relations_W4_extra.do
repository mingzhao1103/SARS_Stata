
**********************************************************************************************
*family relations W4 extra
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

**********************************************************************************************
*Rename T1 

use "W4_family_relations_extra.dta",clear

foreach var of varlist _all{      
	rename `var' `=lower("`var'")'   
}

rename p_qtype qtype
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
keep sampleid vhhid childcode fcount4 qtype  ///
t1p*code t1p*birthyear t1p*age t1p*sex 

save "W4_family_relations_T1.dta",replace

**********************************************************************************************
*Rename T2

use "W4_family_relations_extra.dta",clear

foreach var of varlist _all{      
	rename `var' `=lower("`var'")'   
}

rename p_qtype qtype
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
keep sampleid vhhid childcode fcount4 qtype  ///
t2p*code t2p*dadcode t2p*momcode t2p*spocode t2p*childcode* 

save "W4_family_relations_T2.dta",replace

**********************************************************************************************
*Reshape T1

use "W4_family_relations_T1.dta", clear

drop t1p9* t1p10* t1p11* t1p12*
	 
//reshape requires rename
forval i=1/8{
	 rename t1p`i'code code`i' 
	 rename t1p`i'birthyear byear`i'
	 rename t1p`i'age age`i'
	 rename t1p`i'sex sex`i'	 
}

reshape long code byear age sex, i(sampleid) j(numb)

drop if code==.

order sampleid vhhid code numb
sort sampleid vhhid code
	 
save "W4_fam_T1_long.dta",replace

**********************************************************************************************
*Reshape T2

use "W4_family_relations_T2.dta", clear	 

drop t2p10* t2p9*

forval i=1/8{
	 rename t2p`i'code code`i'
	 rename t2p`i'dadcode dadcode`i'
	 rename t2p`i'momcode momcode`i'
	 rename t2p`i'spocode spocode`i'
	 
	 forval j=1/5{
	 rename t2p`i'childcode`j' childcode`j'p`i'
	 }
}
		 
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

use "W4_fam_T2_long.dta",clear

merge 1:1 sampleid code using "W4_fam_T1_long.dta"

drop _merge

duplicates report sampleid
tab fcount4
	  
save "W4_fam_T12_long.dta", replace  

**********************************************************************************************
*Match W4 with W1 & W2 & W3

use "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long.dta",clear

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3/W3_fam_T12_long_clean.dta"

//matched==160

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2/W2_fam_T12_long_clean.dta"

//matched==213

drop if _merge==2

drop _merge

merge 1:1 sampleid code using "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1/W1_fam_T12_long_clean.dta"

//matched==215

drop if _merge==2

drop _merge

save "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4/W4_fam_T12_long.dta", replace

**********************************************************************************************
*correct
*......
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

use "W4_fam_T12_long.dta", replace

save "W4_fam_T12_long_extra_clean.dta",replace

drop numb

bysort sampleid: gen numb = _n

drop sex byear age marstat mar2stat childid fcount3 norder t2marstat edu empsts fcount famsizeall famsizeco famsizenonco

reshape wide

save "W4_fam_T12_wide_exra_clean.dta",replace

**********************************************************************************************

























