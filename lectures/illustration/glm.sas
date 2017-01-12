/*
	linear model examples in SAS
	Arthur Allignol <arthur.allignol@uni-ulm.de>
*/

/*
	Challenger data -- logistic model
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/orings.csv'
    out = orings
    dbms = csv
    replace;
run;

data orings;
	set orings;
	total = 6;
run;

proc genmod data = orings;
	model damage/total = temp / dist=binomial
							link = logit
							lrci
							obstats;
run;

* Probit model;
proc genmod data = orings;
	model damage/total = temp / dist=binomial
							link = probit
							lrci;	
	store out=model_out;			
run;

data newdata;
	temp = 31;
run;

proc plm restore=model_out;
	score data=newdata predicted /ilink;
run;


/* 
	Plasma data
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/plasma.csv'
    out = plasma
    dbms = csv
    replace;
run;

data plasma;
	set plasma;
	
	yinv = 1 - y;
run;

proc genmod data = plasma;
	model yinv = fibrinogen globulin / dist=binomial
									lrci;
run;

* Alternatively;
proc genmod data = plasma descending;
	model y = fibrinogen globulin / dist=binomial
									lrci;
	estimate "Fibrinogen" fibrinogen 1 / exp;
run;


/*
	solder data -- Poisson regression
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/solder.csv'
    out = solder
    dbms = csv
    replace;
run;

* Poisson model;	
proc genmod data = solder;
	class opening(ref="L") solder(ref = "Thick") Mask(ref = "A1.5") PadType(ref="D4") ;
	model skips = opening solder mask padtype Panel / dist=poisson
													  lrci;
run;

* Negative binomial;
proc genmod data = solder;
	class opening(ref="L") solder(ref = "Thick") Mask(ref = "A1.5") PadType(ref="D4") ;
	model skips = opening solder mask padtype Panel / dist=negbin
													  lrci;
run;


/* 
	tb_real -- poisson regression with offset
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/tb_real.xlsx'
    out = tb_real
    dbms = xlsx
    replace;
run;

data tb_real;
	set tb_real;
	
	log_par = log(par);
run;

* Poisson regression with offset;
proc genmod data = tb_real;
	class type(ref="1") sex(ref="0") age(ref="0");
	model reactors = type sex age / dist=poisson
									offset=log_par
									lrci;
run; 


/* /\* */
/* 	rnes96 -- multinomial logit */
/* *\/ */

/* proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/rnes96.csv' */
/*     out = rnes96 */
/*     dbms = csv */
/*     replace; */
/* run; */


/* proc sort data = rnes96 out = rnes96_sorted; */
/* 	by descending party; */
/* run; */
/* proc logistic data = rnes96_sorted; */
/* 	class education(ref="MS"); */
/* 	model party(order=data) = age education income/ link = glogit		;								 */
/* run; */

