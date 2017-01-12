/*
	linear model examples in SAS
	Arthur Allignol <arthur.allignol@uni-ulm.de>
*/

/*
	Simple linear regression
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/hubble.csv'
    out = hubble
    dbms = csv
    replace;
run;

proc contents data = hubble;
run;

/* Linear model with intercept */
proc glm data = hubble;
model velocity = distance;
run;

/* model without intercept */
proc glm data = hubble;
model velocity = distance / noint;
run;

/* diagnostic plots */
proc glm data = hubble plots=(diagnostics residuals);
model velocity = distance / noint;
run;


/*
	chredlin data
*/

proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/chredlin.csv'
    out = chredlin
    dbms = csv
    replace;
run;

proc contents data = chredlin;
run;

data chredlin;
	set chredlin;
	log_income = log(income);
run;

* Full model;
proc glm data = chredlin plots=(diagnostics residuals);
model involact = race  fire  theft  age  log_income / solution;
run;

* Model deleting the 2 influential observations;
* first output the cook''s distance to find the observations we want to delete;
proc glm data = chredlin plots=(diagnostics residuals);
model involact = race  fire  theft  age  log_income / solution;
output out = new cookd=cooksd;
run;

proc sort data = new out = new;
	by descending cooksd;
run;
data chr_no_outlier;
	set new;
	if _N_ <= 2 then delete;
run; 

proc glm data = chr_no_outlier plots=(diagnostics residuals);
model involact = race  fire  theft  age  log_income / solution;
run;


/* 
	Anorexia data
*/
proc import datafile= '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/anorexia.csv'
    out = anorexia
    dbms = csv
    replace;
run;

proc contents data = anorexia;
run;

data anorexia;
	set anorexia;
	weight_gain = postwt - prewt;
run;

proc glm data = anorexia;
	class Treat;
	model weight_gain = prewt Treat prewt * Treat / solution;
run;

* wrong reference level though;
data anorexia;
	set anorexia;
	
	treatment = 3 * (upcase(Treat) eq "CONT") + 
				2 * (upcase(Treat) eq "CBT") + 
				1 * (upcase(Treat) eq "FT");
				
proc glm data = anorexia;
	class treatment;
	model weight_gain = prewt treatment prewt * treatment / solution;
	estimate "FT VS CBT" treatment -1 1 0;
	contrast "FT VS CBT (contrast)" treatment -1 1 0;
run;
				
proc glm data = anorexia;
	class treatment;
	model weight_gain = prewt treatment prewt * treatment / solution;
	estimate "difference in slope FT VS CBT" prewt*treatment -1 1 0;
run;
