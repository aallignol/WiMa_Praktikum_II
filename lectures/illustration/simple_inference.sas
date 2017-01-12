proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/USmelanoma.csv'
    out = USmelanoma
    dbms = csv
    replace;
run;

data usmelanoma;
	set usmelanoma;
	label Mortality="Mortality rate due to melanoma";
	mortality_150 = mortality <= 150;
	ocean_bin = ocean eq 'no';
	run;
	
proc format;
	value mort 0="Mortality rate > than 150" 1="Mortality rate <= than 150";
	value oce 0="Contiguous to an ocean" 1="non-contiguous to an ocean";
	run;
	
/* summarise mortality variable;
clm: confidence interval
q1, q3: 1st and 3rd quartile
maxdec: maximal number of decimals
*/
proc means data = usmelanoma mean std clm median q1 q3 min max maxdec=2;
	var mortality;
run;

/*
the nocum option removes the cumulative proportions from the resulting tables
binomial: computes the proportion
alpha specifies the alpha niveau for the confidence interval for the proportion
*/
proc freq data = usmelanoma;
	format mortality_150 mort.;
	tables mortality_150 / nocum binomial alpha = 0.05;
run;

/*
computes both the t-test for equal and non-equal variance
*/
proc ttest data = usmelanoma;
	format ocean_bin oce.;
	class ocean_bin;
	var mortality;
run;	

/* 
Only the coffee is missing
*/
proc npar1way data = usmelanoma;
	format ocean_bin oce.;
	class ocean_bin;
	var mortality;
run;

proc npar1way wilcoxon plots=none data = usmelanoma;
	foramt ocean_bin oce.;
	class ocean_bin;
	var mortality;
run;


proc freq data = usmelanoma;
	format mortality_150 mort. ocean_bin oce.;
	tables ocean_bin * mortality_150;
run;

/* 
in the case of 2x2 tables, fisher's exact test is also computed 
event if you only want the chisq
*/
proc freq data = usmelanoma;
	format mortality_150 mort. ocean_bin oce.;
	tables ocean_bin * mortality_150 / chisq;
run;

/*
relrisk option return OR, RR, ...
*/
proc freq data = usmelanoma;
	format mortality_150 mort. ocean_bin oce.;
	tables ocean_bin*mortality_150 / relrisk;
run;

* Correlation tests;
proc corr pearson spearman data = usmelanoma;
	where ocean eq "no";
	var mortality latitude;
run;
