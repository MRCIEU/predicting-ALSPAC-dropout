
* path of project data directory
local dataDir: env PROJECT_DATA


**********
**********
** mother questionnaires

use "`dataDir'/alspac-original/mother.dta", clear

di _N

* check flags for being in core alspac vs alspac
tab mum_in_core mum_in_alsp

* keep only the mums that were in alspac in the beginning to give a homogeneous sample
keep if mum_in_core == 1

tab inc_b_4f, missing
tab inc_d_4b, missing


**********
**********
** child based questionnaires

use "`dataDir'/alspac-original/child-based-questionnaires.dta", clear

di _N

*tab in_core in_alsp

keep if	in_core == 1

tab inc_kj_7a, missing


**********
**********
** child completed questionnaires

use "`dataDir'/alspac-original/child-completed-questionnaires.dta", clear

di _N

keep if in_core == 1

* for each questionnaire count how many participants did vs didn't complete it

** Q at 134 months

tab inc_ccj_r1b, missing

count if ccj990b!=. & ccj990b >=0
count if ccj990b==. | ccj990b <0

** Q at 16 years
tab inc_ccs_r1b, missing

* number completed 16y questionnaire
count if ccs9990b!=. & ccs9990b>=0
count if ccs9990b==. | ccs9990b <0

** Q at 24 years
tab inc_YPD_1a, missing

* number completed 24y questionnaire
count if YPD9601!=. & YPD9601 >=0
count if YPD9601==. | YPD9601 <0


** child clinics

use "`dataDir'/alspac-original/childC-F11_5d_inc.dta", clear

di _N

keep if in_core == 1

tab inc_F11_5d, missing

* count those with vs without value for Year of F11+ visit
count if fe002 !=. & fe002>=0
count if fe002 ==. | fe002<0


use "`dataDir'/alspac-original/childC-tf4_6a_inc.dta", clear


di _N

keep if in_core == 1

tab inc_tf4_6a, missing

count if FJ002b!=. & FJ002b>=0
count if FJ002b==. | FJ002b<0


use "`dataDir'/alspac-original/childC-F24_6a_part1_inc.dta", clear


di _N

keep if in_core == 1

tab inc_F24_6a, missing

count if FKAR0041!=. & FKAR0041>=0
count if FKAR0041==. | FKAR0041<0


use "`dataDir'/alspac-original/childC-F24_6a_part2_inc.dta", clear

di _N

keep if in_core == 1
tab inc_F24_6a, missing

count if FKDP0001!=. & FKDP0001>=0
count if FKDP0001==. | FKDP0001<0



***
*** check N=15645 when merging mother + child data

use "`dataDir'/alspac-original/child-based-questionnaires.dta", clear

merge m:1 aln using "`dataDir'/alspac-original/mother.dta"

di _N


