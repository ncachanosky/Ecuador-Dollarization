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

cd "C:\Users\ncach\OneDrive\My Documents\Research\GitHub Repositories\Ecuador-Dollarization\STATA"


* DOWNLOAD AND PREPARE DATASET
* ==============================================================================

* Downlad dataset
import excel "https://github.com/ncachanosky/Ecuador-Dollarization/blob/main/STATA/data.xlsx?raw=true", ///
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
label variable TFP_PWT2			"TFP (2017 = 1)"
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
	  keep(resout_GDP_1) replace 

matrix list e(V_matrix), format(%9.4fc)


synth GDPcap IND MAN INV UNEMP,												 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) unitnames(COUNTRY) 							 ///
	  keep(resout_GDP_2) replace

matrix list e(V_matrix), format(%9.4fc)


* ==============================================================================
* TFP: PENN WORLD TABLES (USA = 1 | PPP)
synth TFP_PWT GDPcap IND TRADE HCI INV FDI LABOR_SHARE GROSS_K				 ///
	  TFP_PWT(1985) TFP_PWT(1990), counit(1 2 3 4 5 9 10 11)				 ///
	  xperiod(1985(1)1999) mspeperiod(1985(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1985(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_PWT1_1) replace

matrix list e(V_matrix)

synth TFP_PWT GDPcap IND TRADE HCI INV FDI LABOR_SHARE GROSS_K,				 ///
	  counit(1 2 3 4 5 9 10 11)												 ///
	  xperiod(1985(1)1999) mspeperiod(1985(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1985(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_PWT1_2) replace

matrix list e(V_matrix)


* TFP: PENN WORLD TABLES (2017 = 1 | PPP)
synth TFP_PWT2 GDPcap IND TRADE HCI INV FDI LABOR_SHARE GROSS_K				 ///
	  TFP_PWT2(1985) TFP_PWT2(1990), counit(1 2 3 4 5 9 10 11)				 ///
	  xperiod(1985(1)1999) mspeperiod(1985(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1985(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_PWT2_1) replace

matrix list e(V_matrix)

synth TFP_PWT2 GDPcap IND TRADE HCI INV FDI LABOR_SHARE GROSS_K,			 ///
	  counit(1 2 3 4 5 9 10 11)												 ///
	  xperiod(1985(1)1999) mspeperiod(1985(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1985(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_PWT2_2) replace

matrix list e(V_matrix)


* TFP: THE CONFERENCE BOARD (% CHANGE)
synth TFP_CB INV FDI HCI TRADE LABOR_SHARE									 ///
	  TFP_CB(1995) TFP_CB(1999), 											 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_CB_1) replace

matrix list e(V_matrix), format(%9.4fc)

synth TFP_CB INV FDI HCI TRADE LABOR_SHARE,									 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_TFP_CB_2) replace

matrix list e(V_matrix), format(%9.4fc)


* ==============================================================================
* UNEMPLOYMENT
synth UNEMP GDPcap IND TRADE X_SHARE FDI									 ///
	  UNEMP(1990) UNEMP(1999),											     ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_UNEMP_1) replace

matrix list e(V_matrix)


synth UNEMP GDPcap IND TRADE X_SHARE FDI,									 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)							 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2018) unitnames(COUNTRY) ///
	  keep(resout_UNEMP_2) replace

matrix list e(V_matrix)


* ==============================================================================
* GINI
synth GINI FDI URBAN INV HCI												 ///
	  GINI(1992) GINI(1995), counit(1 3 4 5 6 8 9 10 11)					 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)		 					 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2017) unitnames(COUNTRY) ///
	  keep(resout_GINI_1) replace

matrix list e(V_matrix)


synth GINI FDI URBAN INV HCI,												 ///
	  counit(1 3 4 5 6 8 9 10 11)											 ///
	  xperiod(1990(1)1999) mspeperiod(1990(1)1999)		 					 ///
	  nested allopt															 ///
	  trunit(7) trperiod(2000) resultsperiod(1990(1)2017) unitnames(COUNTRY) ///
	  keep(resout_GINI_2) replace

matrix list e(V_matrix)


* ==============================================================================
* PLOT BUILDER
* ==============================================================================

* GDP ESTIMATIONS
* ------------------------------------------------------------------------------
use resout_GDP_1, clear 
tsset _time
 
rename _Y_treated   GDP		// Original GDP series
rename _Y_synthetic GDP1	// SCA 1

merge 1:1 _time using resout_GDP_2, nogenerate noreport

rename _time        YEAR
rename _Y_synthetic GDP2	// SCA 2

label variable YEAR "Year"
label variable GDP1 "Ecuador (Synthetic Model 1)"
label variable GDP2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, real GDP per capita (PPP)"
twoway line GDP GDP1 GDP2 YEAR, 											 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(4000(2000)12000, format(%9.0fc))	 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red" "green") lcolor(%75 %75 %75)						 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_GDP_SCA.pdf, replace
	  
	   
* PLOT ACCUMULATED SPREAD
gen     SPREAD1 = GDP - GDP1
gen		SPREAD2 = GDP - GDP2
replace SPREAD1 = sum(SPREAD1)
replace SPREAD2 = sum(SPREAD2)

label variable SPREAD1 "Accumulated spread, Dollarized Ecuador - SCA Model 1"
label variable SPREAD2 "Accumulated spread, Dollarized Ecuador - SCA Model 2"

* TITLE: Spread
twoway line SPREAD1 SPREAD2 YEAR, 											 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small) format(%9.0fc)) 			 				 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red" "green") color(%75 %75) lpattern(dash shortdash)		 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_GDP_spread.pdf, replace


* PLOT SYNTHETIC GAP
gen            GDP_GAP1 = (GDP/GDP1 - 1)*100
gen            GDP_GAP2 = (GDP/GDP2 - 1)*100
label variable GDP_GAP1 "Synthetic GAP (%) (Model 1)"
label variable GDP_GAP2 "Synthetic GAP (%) (Model 2)"

*TITLE: Spread (%)
twoway line GDP_GAP1 GDP_GAP2 YEAR,											 ///
	   xlabel(,grid labsize(small)) xlabel(1980(5)2020)						 ///
	   ylabel(,grid labsize(small)) 										 ///
	   xtitle("") xline(2000) ytitle("") yline(0)							 ///
	   lcolor("red" "green") color(%75 %75) lpattern(dash shortdash)		 ///
	   legend(position(6) rows(1) size(vsmall))
	 
graph export Fig_GDP_GAP.pdf, replace


* TFP: PENN WORLD TABES (USA = 1)
* ------------------------------------------------------------------------------
use resout_TFP_PWT1_1, clear 
tsset _time
 
rename _Y_treated   TFP		// Original GDP series
rename _Y_synthetic TFP1	// SCA 1

merge 1:1 _time using resout_TFP_PWT1_2, nogenerate noreport

rename _time        YEAR
rename _Y_synthetic TFP2	// SCA 2

label variable YEAR "Year"
label variable TFP1 "Ecuador (Synthetic Model 1)"
label variable TFP2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: TFP (constant prices), PENN WORLD TABLE (2017 = 1)"
twoway line TFP TFP1 TFP2 YEAR,												 ///
	   xlabel(,grid labsize(small)) xlabel(1985(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0(0.1)1, format(%9.1f))			 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red" "green") lcolor(%75 %75 %75)						 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_TFP1_SCA.pdf, replace	 

* TFP: PENN WORLD TABES (2017 = 1)
* ------------------------------------------------------------------------------
use resout_TFP_PWT2_1, clear 
tsset _time
 
rename _Y_treated   TFP		// Original GDP series
rename _Y_synthetic TFP1	// SCA 1

merge 1:1 _time using resout_TFP_PWT2_2, nogenerate noreport

rename _time        YEAR
rename _Y_synthetic TFP2	// SCA 2

label variable YEAR "Year"
label variable TFP1 "Ecuador (Synthetic Model 1)"
label variable TFP2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: TFP (constant prices), PENN WORLD TABLE (2017 = 1)"
twoway line TFP TFP1 TFP2 YEAR,												 ///
	   xlabel(,grid labsize(small)) xlabel(1985(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0.7(0.1)1.2, format(%9.1f))		 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red" "green") lcolor(%75 %75 %75)						 ///
	   legend(position(6) rows(1) size(vsmall))

graph export Fig_TFP1_SCA.pdf, replace	 

tsfilter hp TFP_c  = TFP,  trend(TFP_t)
tsfilter hp TFP1_c = TFP1, trend(TFP1_t)
tsfilter hp TFP2_c = TFP2, trend(TFP2_t)

label variable TFP_c  "TFP (cyclical component)"
label variable TFP1_c "Synthetic TFP (cyclical component, model 1)"
label variable TFP2_c "Synthetic TFP (cyclical component, model 2)"

summarize TFP_c TFP1_c TFP2_c if YEAR > 2000


* TFP: THE CONFERENCE BOARD
* ------------------------------------------------------------------------------
use resout_TFP_CB_1, clear 
tsset _time
 
rename _Y_treated   TFP			// Original TFP (PWT) series
rename _Y_synthetic TFP1		// SCA 1

merge 1:1 _time using resout_TFP_CB_2, nogenerate noreport

rename _time        YEAR
rename _Y_synthetic TFP2		// SCA 2

label variable YEAR   "Year"
label variable TFP1   "Ecuador (Synthetic Model 1)"
label variable TFP2   "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: TFP (% change), THE CONFERENCE BOARD"
twoway line TFP TFP1 TFP2 YEAR,												 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(-5(1)5)							 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red" "green") lcolor(%75 %75 %75)						 ///
	   yline(0) legend(position(6) rows(1) size(vsmall))

graph export Fig_TFP3_SCA.pdf, replace		 

summarize TFP TFP1 TFP2 if YEAR > 2000


* UNEMPLOYMENT
* ------------------------------------------------------------------------------
use resout_UNEMP_1, clear 
tsset _time
 
rename _Y_treated   UNEMP		// Original unemployment serioes
rename _Y_synthetic UNEMP1		// SCA 1

merge 1:1 _time using resout_UNEMP_2, nogenerate noreport

rename _time        YEAR
rename _Y_synthetic UNEMP2		// SCA 2

label variable YEAR   "Year"
label variable UNEMP1 "Ecuador (Synthetic Model 1)"
label variable UNEMP2 "Ecuador (Synthetic Model 2)"

drop _Y_treated
drop _W_Weight
drop _Co_Number


* PLOT ECUADOR VS BOTH SYNTHETIC ESTIMATIONS
* TITLE: Ecuador, unemployment rate"
twoway line UNEMP UNEMP1 UNEMP2 YEAR, 										 ///
	   xlabel(,grid labsize(small)) xlabel(1990(5)2020)						 ///
	   ylabel(,grid labsize(small))	ylabel(0(2)16)							 ///
	   xtitle("") xline(2000) ytitle("")									 ///
	   color("black" "red" "green") lcolor(%75 %75 %75)						 ///
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