*|==============================================================================
*| TITLE
*| 20 Years of Dollarization in Ecuador: A Synthetic Control Analysis
*|
*| AUTHORS
*| Nicolas Cachanosky
*| Metropolitan State University of Denver | ncachano@msudenver.edu
*|
*| John Ramseur
*| Metropolitan State University of Denver | jramseur@msudenver.edu
*|
*| This version: 4-Jul-20
*|==============================================================================


* INSTALL SYNTHETIC CONTROL AND DEFINE SETTINGS
* ==============================================================================
ssc install synth, replace				
help synth

cd "\Users\ncach\OneDrive\My Documents\Research\Working Papers\Paper - Ecuador Dollarization"

set scheme scientific


* DOWNLOAD AND PREPARE DATASET
* ==============================================================================

* Downlad dataset
import excel "https://github.com/ncachanosky/research/blob/master/Dollarization%20in%20Ecuador/data.xlsx?raw=true", ///
			 sheet("STATA") cellrange(A1:t430) firstrow clear

* Set as Panel Data
tsset id YEAR

* Update labels
label variable COUNTRY            "Country"
label variable YEAR               "Year"
label variable GDPcap_PPP_MAD     "GDP per capita (PPP)"
label variable GDPcap_PPP_WDI	  "GDP per capita (PPP) WDI"
label variable IND                "Industry share of GDP"
label variable MAN                "Manufacturing share of GDP"
label variable TRADE              "Trade Openness"
label variable NATRES             "Nat. resources (%GDP)"
label variable HC                 "Human Capital index"
label variable INV                "Investment share of GDP"
label variable POVERTY			  "Poverty rate"
label variable GINI				  "GINI coefficient"
label variable UNEMP              "Unemployment"
label variable LABOR_SHARE		  "Labor compensation share"
label variable GROSS_K			  "Gross capital formation"
label variable X_SHARE			  "Export share (%GDP)"
label variable INFANT			  "Infant mortality rate (x 1000)"
label variable LIFE_EXP			  "Life expectancy at birh"

/*
label variable v2x_accountability "V-Dem: Accountability"
label variable v2x_civlib         "V-Dem: Civic Liberties"
label variable v2x_corr           "V-Dem: Corruption"
label variable v2x_rule           "V-Dem: Rule of Law"
label variable v2x_freexp         "V-Dem: Freedom of Expression"
label variable v2x_neopat         "V-Dem: Neopatrimonial"
label variable v2xcl_prpty        "V-Dem: Property Rights"
label variable EFW_PTY			  "EFW: Property Rights"
label variable EFW_BUS			  "EFW: Business Freedom"
label variable EFW_MON			  "EFW: Monetary Freedom"
label variable EFW_TRA			  "EFW: Trade Freedom"
label variable EFW_INV			  "EFW: Investment Freedom"
label variable EFW_FIN			  "EFW: Financial Freedom"
*/

* Rename variables
rename GDPcap_PPP_MAD     GDPcap
/*

rename v2x_accountability VDEM_ACC
rename v2x_civlib         VDEM_CIV
rename v2x_corr           VDEM_COR
rename v2x_rule           VDEM_RUL
rename v2x_freexp         VDEM_FOP
rename v2x_neopat         VDEM_NEO
rename v2xcl_prpty        VDEM_PRO
*/

* Linear interpolation of missing data
bysort COUNTRY: ipolate MAN YEAR, gen(MAN2)
drop   MAN
rename MAN2 MAN
label  variable MAN "Manufacturing share of GDP"

bysort COUNTRY: ipolate UNEMP YEAR, gen(UNEMP2)
drop   UNEMP
rename UNEMP2 UNEMP
label  variable UNEMP "Unemployment"

bysort COUNTRY: ipolate GINI YEAR, gen(GINI2)
drop   GINI
rename GINI2 GINI
label  variable GINI "GINI Coefficient"

* Adjust scales
replace INV     = INV*100
replace X_SHARE = X_SHARE * 100


* DATA ID REFERENCE
* ==============================================================================
/*
 1: Argentina
 2: Bolivia
 3: Brazil
 4: Chile
 5: Colombia
 6: Costa Rica
 7: Ecuador
 8: Mexico
 9: Paraguay
10: Peru
11: Uruguay
*/


* ==============================================================================	   
* SYNTHETIC CONTROL: GDP
* ==============================================================================
* COVARIATES ONLY
* Synthethic Control GDP Model 1
* RMSPE: 375.1125
synth GDPcap IND MAN INV UNEMP,												 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_GDP1) replace

matrix list e(V_matrix)



* COVARIATES + SELECTED OUTCOMES
* Synthetic Control GDP Model 2
* RMSPE: 315.6147	  
synth GDPcap IND MAN INV UNEMP 												 ///
	  GDPcap(1981) GDPcap(1999),											 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_GDP2) replace

matrix list e(V_matrix)


* ==============================================================================	   
* SYNTHETIC CONTROL: EXPORT SHARE OF GDP
* ==============================================================================
* COVARIATES ONLY
* Synthethic Control GDP Model 1
* RMSPE: 2.2023
synth X_SHARE NATRES IND TRADE GROSS_K GDPcap,								 ///
	  nested allopt	resultsperiod(1980(1)2017)								 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_XSHARE1) replace

matrix list e(V_matrix)


* COVARIATES + SELECTED OUTCOMES
* Synthetic Control GDP Model 2
* RMSPE: 1.3688	  
synth X_SHARE NATRES IND TRADE GROSS_K GDPcap								 ///
	  X_SHARE(1981) X_SHARE(1999),											 ///
	  nested allopt	resultsperiod(1980(1)2017)								 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_XSHARE2) replace

matrix list e(V_matrix)


* ==============================================================================
* SYNTHETIC CONTROL: INFANT MORTAILITY
* ==============================================================================
* COVARIATES ONLY
* Synthethic Control GDP Model 1
* RMSPE: 1.4960
synth INFANT HC LIFE_EXP GDPcap INV,										 ///
	  nested allopt	resultsperiod(1980(1)2017)								 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_INFANT1) replace

matrix list e(V_matrix)


* COVARIATES + SELECTED OUTCOMES
* Synthetic Control GDP Model 2
* RMSPE: 0.8621  
synth INFANT HC LIFE_EXP GDPcap INV											 ///
	  INFANT(1981) INFANT(1999),											 ///
	  nested allopt	resultsperiod(1980(1)2017)								 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_INFANT2) replace

matrix list e(V_matrix)


* ==============================================================================
* PLOT BUILDER
* ==============================================================================

* GDP ESTIMATIONS
* ------------------------------------------------------------------------------

use resout_GDP1, clear 
tsset _time
 
rename _Y_treated   GDP		// Original GDP serioes
rename _Y_synthetic GDP1	// Synthetic Model 1 estimation
 
merge 1:1 _time using resout_GDP2, nogenerate noreport

rename _time        YEAR	 
rename _Y_synthetic GDP2	// Synthetic Model 2 estimation

label variable YEAR "Year"
label variable GDP1 "Ecuador (Synthetic Model 1)"
label variable GDP2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
twoway line GDP  YEAR, 														 ///
	   title("Ecuador, real GDP per Capita (PPP)", size(medium))			 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(4000(2000)12000)					 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line GDP1 YEAR, 														 ///
	   lcolor("red") color(%75)												 ///
	 ||line GDP2 YEAR, 														 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	  
	   
* PLOT ACCUMULATED SPREAD
gen     SPREAD_1 = GDP - GDP1
gen     SPREAD_2 = GDP - GDP2

replace SPREAD_1 = sum(SPREAD_1)
replace SPREAD_2 = sum(SPREAD_2)

label variable SPREAD_1 "Accumulated spread, Ecuador - SCA Model 1"
label variable SPREAD_2 "Accumulated spread, Ecuador - SCA Model 2"

twoway line SPREAD_1 YEAR, 													 ///
	   title("Accumulated spread", size(medium))							 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 							 			 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line SPREAD_2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	  
	  
* PLOT SYNTHETIC GAP
gen GDP_GAP1 = (GDP/GDP1 - 1)*100
gen GDP_GAP2 = (GDP/GDP2 - 1)*100

label variable GDP_GAP1 "Synthetic GAP Model 1 (%)"
label variable GDP_GAP2 "Synthetic GAP Model 2 (%)"
	  
twoway line GDP_GAP1 YEAR, 													 ///
	   title("Spread (%)", size(medium))									 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line GDP_GAP2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	 
	 
* EXPORT SHARE OF GDP
* ------------------------------------------------------------------------------

use resout_XSHARE1, clear 
tsset _time
 
rename _Y_treated   X_SHARE		// Original export shage (%GDP) serioes
rename _Y_synthetic X_SHARE1	// Synthetic Model 1 estimation
 
merge 1:1 _time using resout_XSHARE2, nogenerate noreport

rename _time        YEAR	 
rename _Y_synthetic X_SHARE2	// Synthetic Model 2 estimation

label variable YEAR "Year"
label variable X_SHARE1 "Ecuador (Synthetic Model 1)"
label variable X_SHARE2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
twoway line X_SHARE  YEAR, 													 ///
	   title("Export share (%GDP)", size(medium))							 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))											 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line X_SHARE1 YEAR, 													 ///
	   lcolor("red") color(%75)												 ///
	 ||line X_SHARE2 YEAR, 													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	  
  
* PLOT ACCUMULATED SPREAD
gen     SPREAD_1 = X_SHARE - X_SHARE1
gen     SPREAD_2 = X_SHARE - X_SHARE2

label variable SPREAD_1 "spread, Ecuador - SCA Model 1"
label variable SPREAD_2 "spread, Ecuador - SCA Model 2"

twoway line SPREAD_1 YEAR, 													 ///
	   title("Synthetic pread", size(medium))								 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line SPREAD_2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))

	   
twoway line SPREAD_1 YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line SPREAD_2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	   
	  
* INFANT MORTALITY
* ------------------------------------------------------------------------------

use resout_INFANT1, clear 
tsset _time
 
rename _Y_treated   INFANT		// Original infant mortaility series
rename _Y_synthetic INFANT1		// Synthetic Model 1 estimation
 
merge 1:1 _time using resout_INFANT2, nogenerate noreport

rename _time        YEAR	 
rename _Y_synthetic INFANT2		// Synthetic Model 2 estimation

label variable YEAR "Year"
label variable INFANT1 "Ecuador (Synthetic Model 1)"
label variable INFANT2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
twoway line INFANT  YEAR, 													 ///
	   title("Infant mortality rate (per 1000)", size(medium))				 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line INFANT1 YEAR, 													 ///
	   lcolor("red") color(%75)												 ///
	 ||line INFANT2 YEAR, 													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))

  
* PLOT ACCUMULATED SPREAD
gen     SPREAD_1 = INFANT - INFANT1
gen     SPREAD_2 = INFANT - INFANT2

label variable SPREAD_1 "Spread, Ecuador - SCA Model 1"
label variable SPREAD_2 "Spread, Ecuador - SCA Model 2"

twoway line SPREAD_1 YEAR, 													 ///
	   title("Synthetic pread", size(medium))								 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))								 			 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line SPREAD_2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(2))


twoway line SPREAD_1 YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))								 			 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)												 ///
	 ||line SPREAD_2 YEAR,													 ///
	   lcolor("blue") color(%75)											 ///
	   legend(position(6) rows(2))	   
	   
	   
* ==============================================================================
* OTHER PLOTS
* ==============================================================================	   
import excel "https://github.com/ncachanosky/research/blob/master/Dollarization%20in%20Ecuador/data.xlsx?raw=true", ///
			 sheet("ANUAL") cellrange(A1:G30) firstrow clear
			 
tsset YEAR

label variable YEAR            "Year"
label variable RER             "Real effective exchange rate (anual average)"
label variable TERM_TRADE      "Terms of Trade (Goods & Services)"
label variable POVERTY         "Poverty rate"
label variable POVERTY_EXTREME "Extreme poverty rate"
label variable GINI			   "GINI coefficient"


* Real Exchange Rate
* ------------------------------------------------------------------------------
twoway line RER YEAR,														 ///
	   title("Real effective exchange rate and Terms of Trade", size(medium)) ///
	   xlabel(,grid labsize(small)) ylabel(,grid labsize(small))			 ///
	   xline(2000) xlabel(1990(2)2018) xtitle("")							 ///
	   lcolor("green") color(%75)											 ///
	 ||line TERM_TRADE YEAR,												 ///
	   lcolor("purple") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	   
	   
* Unemployment
* ------------------------------------------------------------------------------
twoway line UNEMP YEAR,														 ///
	   title("Unemployment rate", size(medium))								 ///
	   xlabel(,grid labsize(small)) ylabel(,grid labsize(small))			 ///
	   xline(2000) xlabel(1990(2)2018) ylabel(0(2)10) xtitle("") ytitle("")	 ///
	   lcolor("olive") color(%75) yline(0)

	   
* Poverty rates
* ------------------------------------------------------------------------------
twoway line POVERTY YEAR,													 ///
	   title("Poverty rates", size(medium)) 								 ///
	   xlabel(,grid labsize(small)) ylabel(,grid labsize(small))			 ///
	   xline(2000) xlabel(1990(2)2018)	xtitle("") ylabel(0(10)50)			 ///
	   lcolor("green") color(%75)											 ///
	 ||line POVERTY_EXTREME YEAR,											 ///
	   lcolor("purple") color(%75)											 ///
	   legend(position(6) rows(1) size(vsmall))
	   
	   
* GINI Coefficient
* ------------------------------------------------------------------------------
twoway line GINI YEAR,														 ///
	   title("GINI Coefficient", size(medium))								 ///
	   xlabel(,grid labsize(small)) ylabel(,grid labsize(small)) ytitle("")	 ///
	   xline(2000) xlabel(1990(2)2018) ylabel(30(10)70) xtitle("")			 ///
	   lcolor("gold") color(%75)

	   
*|==============================================================================
*|THE END|======================================================================
*|==============================================================================
