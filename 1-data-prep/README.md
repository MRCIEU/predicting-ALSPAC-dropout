
# Preparing dataset for Ruchitha

This step is done by Louise Millard.
The derived data is sent to ALSPAC for an ID swap, before being sent onto Ruchitha.


We first add a flag indicating whether a participant is in a particular dataset, to keep track of this.
```bash
sbatch j-addInclusion.do
```

We derive a number of dataset, as described in the summary below.

```
sbatch j-alspacScript.do
```


## Checking

We check the number of participants in each dataset, the number who participated in each data 
collection event, and the number after merging mother and child data.

```bash
sbatch j-check-datasets.sh
```


## Summary of generated datasets:

Mother questionnaire data, mother.dta contains:
- mz_6a, cohort profile dataset
- b_4f, "Having a baby and your home and Lifestyle"
- d_4b, "About yourself"

Child based questionnaires, child-based-questionnaires.dta contains:
- cp_3a, cohort profile dataset
- kj_7a, "My son/daughter's health and behaviour"


Child completed questionnaires, child-completed-questionnaires.dta contains:
- cp_3a, cohort profile dataset
- ccj_r1b, "School life and me" (at 134 months)
- ccs_r1b, "Life of a 16+ Teenager" (at 198 months)
- YPD_1a, "Life @ 24+" (at 24 years)

Child clinic data:
- Focus @ 11 child clinic data: childC-F11_5d_inc.dta
- Teen Focus 4 (focus @ 17): childC-tf4_6a_inc.dta
- Focus @ 24 (part 1): childC-F24_6a_part1_inc.dta
- Focus @ 24 (part 2): childC-F24_6a_part2_inc.dta

Note Focus @ 24 is split in two due to the limit on the the number of variables that can be loaded into stata on blue pebble.

