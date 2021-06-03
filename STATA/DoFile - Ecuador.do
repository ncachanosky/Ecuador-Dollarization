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
set scheme scientific

cd "C:\Users\ncach\OneDrive\My Documents\Research\GitHub Repositories\Ecuador-Dollarization"


* DOWNLOAD AND PREPARE DATASET
* ==============================================================================

* Downlad dataset
import excel "https://github.com/ncachanosky/Ecuador-Dollarization/blob/main/data.xlsx?raw=true", ///
			 sheet("STATA") cellrange(A1:AJ430) firstrow clear

* Set as Panel Data
tsset id YEAR

* Update labels: Country and year
label variable COUNTRY			"Country"
label variable YEAR				"Year"
* Update labels: Macro
label variable GDPcap_PPP_MAD	"GDP per capita (PPP)"
label variable GDPcap_PPP_WDI	"GDP per capita (PPP) WDI"
label variable TFP_PWT          "TFP (US = 1)"
label variable TFP_PWT			"TFP (2017 = 1)"
label variable TFP_CB			"TFP (CB)"
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
* TFP: PENN WORLD TABLES
synth TFP_PWT2 GDPcap IND TRADE HCI INV FDI LABOR_SHARE GROSS_K				 ///
	  TFP_PWT2(1985) TFP_PWT2(1990), counit(1 2 3 4 5 9 10 11)				 ///
	  xperiod(1985(1)1999) mspeperiod(1985(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1985(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP1) replace

matrix list e(V_matrix)


* TFP: THE CONFERENCE BOARD
synth TFP_CB INV FDI HCI TRADE LABOR_SHARE									 ///
	  TFP_CB(1995) TFP_CB(1999), 											 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP2) replace

matrix list e(V_matrix)


* ==============================================================================
* UNEMPLOYMENT
synth UNEMP GDPcap IND TRADE X_SHARE FDI									 ///
	  UNEMP(1990) UNEMP(1999),											     ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_UNEMP) replace

matrix list e(V_matrix)


* ==============================================================================
* GINI
synth GINI FDI URBAN INV HCI												 ///
	  GINI(1992) GINI(1995), counit(1 3 4 5 6 8 9 10 11)					 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)		 					 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2017) unitnames(COUNTRY) ///
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
rename _Y_treated   GDP		// Original GDP series
rename _Y_synthetic GDP1	// Synthetic Model 1 estimation


label variable YEAR "Year"
label variable GDP1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, real GDP per capita (PPP)"
twoway line GDP GDP1 YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(4000(2000)12000)					 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red") lcolor(%75 %75)									 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_GDP_SCA.pdf, replace
	  
	   
* PLOT ACCUMULATED SPREAD
gen     SPREAD = GDP - GDP1
replace SPREAD = sum(SPREAD)

label variable SPREAD "Accumulated spread, Dollarized Ecuador - Synthetic Ecuador"

* TITLE: Spread
twoway line SPREAD YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 							 			 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("green") color(%75)

graph export Fig_GDP_spread.pdf, replace


* PLOT SYNTHETIC GAP
gen            GDP_GAP = (GDP/GDP1 - 1)*100
label variable GDP_GAP "Synthetic GAP (%)"

*TITLE: Spread (%)
twoway line GDP_GAP YEAR, 													 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("green") color(%75)	
	 
graph export Fig_GDP_GAP.pdf, replace


* TFP: PENN WORLD TABES
* ------------------------------------------------------------------------------
use resout_TFP1, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   TFP			// Original TFP (PWT) series
rename _Y_synthetic TFP1		// Synthetic Model 1 estimation


label variable YEAR   "Year"
label variable TFP1   "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: TFP (constant prices), PENN WORLD TABLE (2017 = 1)"
twoway line TFP TFP1 YEAR,													 ///
	   xlabel(,grid labsize(small)) xlabel(1985(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0.8(0.1)1.1)						 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red") lcolor(%75 %75)									 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_TFP1_SCA.pdf, replace	 

tsfilter hp TFP_c  = TFP,  trend(TFP_t)
tsfilter hp TFP1_c = TFP1, trend(TFP1_t)

label variable TFP_c  "TFP (cyclical component)"
label variable TFP1_c "Synthetic TFP (cyclical component)"

summarize TFP_c TFP1_c if YEAR > 2000

* TFP: THE CONFERENCE BOARD
* ------------------------------------------------------------------------------
use resout_TFP2, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   TFP			// Original TFP (PWT) series
rename _Y_synthetic TFP1		// Synthetic Model 1 estimation


label variable YEAR   "Year"
label variable TFP1   "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: TFP (% change), THE CONFERENCE BOARD"
twoway line TFP TFP1 YEAR,													 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(-5(1)5)							 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red") lcolor(%75 %75)									 ///
	   yline(0) legend(position(6) rows(1) size(vsmall))

graph export Fig_TFP2_SCA.pdf, replace		 

summarize TFP TFP1 if YEAR > 2000


* UNEMPLOYMENT
* ------------------------------------------------------------------------------
use resout_UNEMP, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   UNEMP		// Original unemployment serioes
rename _Y_synthetic UNEMP1		// Synthetic model estimation


label variable YEAR   "Year"
label variable UNEMP1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, unemployment rate"
twoway line UNEMP UNEMP1 YEAR, 												 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0(2)16)							 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red") lcolor(%75 %75)									 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_UNEMP_SCA.pdf, replace


* GINI
* ------------------------------------------------------------------------------
use resout_GINI, clear 
tsset _time
 
rename _time        YEAR
rename _Y_treated   GINI		// Original GINI serioes
rename _Y_synthetic GINI1		// Synthetic model estimation


label variable YEAR  "Year"
label variable GINI1 "Ecuador (Synthetic Model)"

drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: GINI Coefficient"
twoway line GINI GINI1 YEAR, 												 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(30(10)60)						 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red") lcolor(%75 %75)									 ///
	   text(58 1991 "More income inequality", placement(e) size(vsmall))	 ///
	   text(32 1991 "Less income inequality", placement(e) size(vsmall))	 ///
	   legend(position(6) rows(1) size(vsmall))


graph export Fig_GINI_SCA.pdf, replace

*|==============================================================================
*|THE END|======================================================================
*|==============================================================================