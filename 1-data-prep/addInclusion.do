
* path of project data directory
local dataDir: env PROJECT_DATA



* G0 Mother (pregnancy) based files - include here all files related to the pregnancy and/or mother

* If no mother variables are required, KEEP this section and remove the instruction below to run it..

clear

use "`dataDir'/alspac-original/mz_6a.dta", clear
gen inc_mz_6a = 1
save "`dataDir'/alspac-original/mz_6a_inc.dta", replace


use "`dataDir'/alspac-original/b_4f.dta", clear
gen inc_b_4f = 1
save "`dataDir'/alspac-original/b_4f_inc.dta", replace

use "`dataDir'/alspac-original/d_4b.dta", clear
gen inc_d_4b = 1
save "`dataDir'/alspac-original/d_4b_inc.dta", replace

use "`dataDir'/alspac-original/cp_3a.dta", clear
gen inc_cp_3a = 1
save "`dataDir'/alspac-original/cp_3a_inc.dta", replace

use "`dataDir'/alspac-original/kj_7a.dta", clear
gen inc_kj_7a = 1
save "`dataDir'/alspac-original/kj_7a_inc.dta", replace


* child clinic
use "`dataDir'/alspac-original/F11_5d.dta", clear
gen inc_F11_5d = 1
save "`dataDir'/alspac-original/F11_5d_inc.dta", replace

use "`dataDir'/alspac-original/tf4_6a.dta", clear
gen inc_tf4_6a = 1
save "`dataDir'/alspac-original/tf4_6a_inc.dta", replace


* F24 is too large so split into two parts
use aln-FKSO1091 using "`dataDir'/alspac-original/F24_6a.dta", clear
gen inc_F24_6a = 1
save "`dataDir'/alspac-original/F24_6a_part1_inc.dta", replace

use aln qlet FKSO1092-FKDP0010 using "`dataDir'/alspac-original/F24_6a.dta", clear
gen inc_F24_6a = 1
save "`dataDir'/alspac-original/F24_6a_part2_inc.dta", replace


use "`dataDir'/alspac-original/cp_3a.dta", clear
gen inc_cp_3a = 1
save "`dataDir'/alspac-original/cp_3a_inc.dta", replace

use "`dataDir'/alspac-original/ccj_r1b.dta", clear
gen inc_ccj_r1b = 1
save "`dataDir'/alspac-original/ccj_r1b_inc.dta", replace


use "`dataDir'/alspac-original/ccs_r1b.dta"
gen inc_ccs_r1b = 1
save "`dataDir'/alspac-original/ccs_r1b_inc.dta", replace

use "`dataDir'/alspac-original/YPD_1a.dta"
gen inc_YPD_1a = 1
save "`dataDir'/alspac-original/YPD_1a_inc.dta", replace



