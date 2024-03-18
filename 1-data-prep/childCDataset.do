local datasetName "`1'"

local dataDir: env PROJECT_DATA

use "`dataDir'/alspac-original/cp_3a_inc.dta", clear
sort aln qlet
gen in_kz=1

merge 1:1 aln qlet using "`dataDir'/alspac-original/`datasetName'.dta"
rename _merge _merge_`datasetName'


* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before tripquad, so replace the ***** line with additional variables.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file.  Note that mother based WoCs are set to .b

order aln qlet kz021, first
order tripquad, last

do "woc-scripts/child_completed_WoC.do"

* Check withdrawal of consent frequencies child completed=30
tab1 kz021, mis

* Remove non-alspac children.
drop if in_alsp!=1.

* Remove trips and quads.
drop if tripquad==1

drop in_alsp tripquad

save "`dataDir'/alspac-original/childC-`datasetName'.dta", replace
*outsheet using "`dataDir'/alspac-original/childC-`datasetName'.csv", comma replace
