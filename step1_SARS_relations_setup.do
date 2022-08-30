
**********************************************************************************************
*family relations setup
**********************************************************************************************

**W1

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W1"	

use "HKPSSD1stWave_Corrected_Child_CASER_20140528.dta",clear

tostring sampleid interviewerid,replace

merge m:1 vhhid using "HKPSSD1stWave_Corrected_Family_CASER_20140528.dta"

keep if _merge==3 

save "W1_family_relations.dta",replace


**W2M

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"	

use "HKPSSD2ndWave_M_Child_CASER_11.5.2015.dta",clear

merge m:1 vhhid using "HKPSSD2ndWave_M_Family_CASER_11.5.2015.dta"

keep if _merge==3 

save "W2M_family_relations.dta",replace


**W2B

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W2"

use "HKPSSD2ndWave_B_Child_CASER_1.27.2015.dta",clear
 
merge m:1 vhhid using "HKPSSD2ndWave_B_Family_CASER_1.27.2015.dta"

keep if _merge==3 

save "W2B_family_relations.dta",replace	


**W3

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/Data W3"	

use "HKPSSD3rdWave_Child_CASER_7.25.2016.dta",clear

merge m:1 vhhid using "HKPSSD3rdWave_Family_CASER_7.25.2016.dta"

keep if _merge==3 

save "W3_family_relations.dta",replace	


**W4

clear
cd "/Users/mingzhao/Desktop/SARS_HKPSSD/RawData W4"	

use "PSSDW4Child_CASER (5 Sept).dta",clear

merge m:1 vhhid using "PSSDW4Family_CASER (5 Sept).dta"

keep if _merge==3 

save "W4_family_relations.dta",replace	


use "PSSDW4Individual_CASER (5 Sept).dta",clear

keep if birthyr==2001 | birthyr==2002 | birthyr==2003

rename p_VhhID vhhid

merge m:1 vhhid using "PSSDW4Family_CASER (5 Sept).dta"

keep if _merge==3

save "W4_family_relations_extra.dta",replace



