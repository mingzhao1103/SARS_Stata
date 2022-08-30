
**********************************************************************************************
*family relations W2
**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"	

**********************************************************************************************

use "W2B_fam_T12_wide_clean.dta",clear

forval i=1/9{
	 rename marstat`i' mar2stat`i' 

}
append using "W2M_fam_T12_wide_clean.dta"

duplicates report sampleid

save "W2_fam_T12_wide_clean.dta",replace

reshape long code sex byear age mar2stat dadcode momcode spocode  ///
childcode1p childcode2p childcode3p childcode4p childcode5p, i(sampleid) j(norder)

drop if code==.
drop relatwrong wrong

sort sampleid code  

duplicates list sampleid code

/*
  +----------------------------------+
  | group:   obs:    sampleid   code |
  |----------------------------------|
  |      1    218   204560002    102 | 2007
  |      1    219   204560002    102 |
  |      2    225   204560003    103 | 2010
  |      2    226   204560003    103 |
  +----------------------------------+
*/

drop in 219
drop in 224

sort sampleid norder

save "W2_fam_T12_long_clean.dta",replace 

**********************************************************************************************

use "W2_fam_T12_long_clean.dta",clear

gen famid=vhhid

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

save "W2_fam_T12_long_clean.dta",replace 

reshape wide
save "W2_fam_T12_wide_clean.dta",replace

**********************************************************************************************

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "W2_fam_T12_long_clean.dta",clear

gen fam=substr(string(childid,"%12.0f"),1,6)

gen cid2=substr(string(childid,"%12.0f"),-3,.)
gen fid2=substr(string(fatherid,"%12.0f"),-3,.)
gen mid2=substr(string(motherid,"%12.0f"),-3,.)

egen chid = concat(fam cid2) 
egen faid = concat(fam fid2) 
egen moid = concat(fam mid2)

destring chid faid moid,replace

format chid faid moid %14.0g

rename childid childid_o
rename fatherid fatherid_o
rename motherid motherid_o

rename chid childid
rename faid fatherid
rename moid motherid

replace fatherid=. if fatherid_o==.
replace motherid=. if motherid_o==.

save "W2_fam_T12_long_clean.dta",replace 













