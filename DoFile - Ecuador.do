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

cd "C:\Users\ncach\OneDrive\My Documents\Research\GitHub Repositories\Ecuador-Dollarization"

set scheme scientific


* DOWNLOAD AND PREPARE DATASET
* ==============================================================================

* Downlad dataset
import excel "https://github.com/ncachanosky/Ecuador-Dollarization/blob/main/data.xlsx?raw=true", ///
			 sheet("STATA") cellrange(A1:AG430) firstrow clear
			 
* Set as Panel Data
tsset id YEAR

* Update labels: Country and year
label variable COUNTRY			"Country"
label variable YEAR				"Year"
* Update labels: Macro
label variable GDPcap_PPP_MAD	"GDP per capita (PPP)"
label variable GDPcap_PPP_WDI	"GDP per capita (PPP) WDI"
label variable IND				"Industry share of GDP"
label variable MAN				"Manufacturing share of GDP"
label variable TRADE			"Trade Openness"
label variable NATRES			"Nat. resources (%GDP)"
label variable HCI				"Human Capital index"
label variable INV				"Investment share of GDP"
label variable GROSS_K			"Gross capital formation"
label variable X_SHARE			"Export share (%GDP)"
* Update labels: Social
label variable POVERTY			"Poverty rate"
label variable GINI				"GINI coefficient"
label variable UNEMP			"Unemployment"
label variable LABOR_SHARE		"Labor compensation share"
label variable INFANT			"Infant mortality rate (x 1000)"
label variable LIFE_EXP			"Life expectancy at birh"
label variable URBAN			"Urban population (% total)"
* Update labels: Institutional
label variable EFW				"EFW Index"
label variable EFW_A1			"EFW Area 1"
label variable EFW_A2			"EFW Area 2"
label variable EFW_A3			"EFW Area 3"
label variable EFW_A4			"EFW Area 4"
label variable EFW_A5			"EFW Area 5"
label variable VDEM_LIB			"V-Dem: Liberal Democracy"
label variable VDEM_ROL			"V-Dem: Ruleof Law"
label variable VDEM_NEO			"V-Dem: Neopatrimonial"
label variable VDEM_CORR		"V-Dem: Political corruption"
label variable POLITY_V			"Polity V"


* Rename variables
rename GDPcap_PPP_MAD     GDPcap

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
* GDP PER CAPITA
synth GDPcap IND MAN INV UNEMP 												 ///
	  GDPcap(1981) GDPcap(1999),											 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_GDP) replace 

matrix list e(V_matrix)


* ==============================================================================	   
* UNEMPLOYMENT
synth UNEMP GDPcap IND TRADE X_SHARE FDI									 ///
	  UNEMP(1990) UNEMP(1999),											     ///
	  mspeperiod(1990(1)2000)												 ///
	  resultsperiod(1990(1)2018)											 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY)                            ///
	  keep(resout_UNEMP) replace

matrix list e(V_matrix)


* ==============================================================================	   
* GINI
synth GINI FDI URBAN INV HCI												 ///
	  GINI(1992) GINI(1995), counit(1 3 4 5 6 8 9 10 11)					 ///
	  mspeperiod(1990(1)2000) resultsperiod(1990(1)2016)					 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY)                            ///
	  keep(resout_GINI) replace

matrix list e(V_matrix)


* ==============================================================================
* PLOT BUILDER
* ==============================================================================

* GDP ESTIMATIONS
* ------------------------------------------------------------------------------

use resout_GDP, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   GDP		// Original GDP serioes
rename _Y_synthetic GDP1	// Synthetic Model 1 estimation
 

label variable YEAR "Year"
label variable GDP1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, real GDP per capita (PPP)"
twoway line GDP  YEAR, 														 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(4000(2000)12000)					 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line GDP1 YEAR, 														 ///
	   lcolor("red") color(%75)												 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_GDP_SCA.pdf
	  
	   
* PLOT ACCUMULATED SPREAD
gen     SPREAD = GDP - GDP1
replace SPREAD = sum(SPREAD)

label variable SPREAD "Accumulated spread, Dollarized Ecuador - Synthetic Ecuador"

* TITLE: Spread
twoway line SPREAD YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 							 			 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)

graph export Fig_GDP_spread.pdf

	  
* PLOT SYNTHETIC GAP
gen            GDP_GAP = (GDP/GDP1 - 1)*100
label variable GDP_GAP "Synthetic GAP (%)"

*TITLE: Spread (%)
twoway line GDP_GAP YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red") color(%75)	
	 
graph export Fig_GDP_GAP.pdf, replace
	 
* UNEMPLOYMENT
* ------------------------------------------------------------------------------

use resout_UNEMP, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   UNEMP		// Original GDP serioes
rename _Y_synthetic UNEMP1		// Synthetic Model 1 estimation
 

label variable YEAR   "Year"
label variable UNEMP1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, real GDP per capita (PPP)"
twoway line UNEMP  YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0(2)20)							 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line UNEMP1 YEAR, 													 ///
	   lcolor("red") color(%75)												 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_UNEMP_SCA.pdf, replace
	  
	   

* GINI
* ------------------------------------------------------------------------------

use resout_GINI, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   GINI		// Original GDP serioes
rename _Y_synthetic GINI1		// Synthetic Model 1 estimation
 

label variable YEAR   "Year"
label variable GINI1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, real GDP per capita (PPP)"
twoway line GINI  YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(30(10)60)						 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	 ||line GINI1 YEAR, 													 ///
	   lcolor("red") color(%75)												 ///
	   text(58 1991 "More income inequality", placement(e) size(vsmall))	 ///
	   text(32 1991 "Less income inequality", placement(e) size(vsmall))	 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_GINI_SCA.pdf, replace
	  

	   
*|==============================================================================
*|THE END|======================================================================
*|==============================================================================
