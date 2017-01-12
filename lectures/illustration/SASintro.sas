proc import datafile='/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/sleep.csv'
	out=sleep
	dbms=csv
	replace;
run;


data sleep2;
    infile '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/sleep.csv'
    dsd
    delimiter = ','
    firstobs = 2;
input extra group id;

data sleep;
	set sleep;
	if extra < 0 and group eq 2 then group_with_no_meaning = 'A';
	else group_with_no_meaning = 'B';
run;

data sleep;
	set sleep;
	extra_1 = extra ** 2;
	extra_2 = log(extra_1);
	extra_3 = exp(extra);
	run;

data sleep_1;
	set sleep;
	if group eq 1 then delete;
	run;
	
data sleep_2;
	set sleep(where = (group eq '2'));
	run;

data sleep_short;
	set sleep;
	drop group_with_no_meaning;
	run;
	
data sleep_short;
	set sleep_short;
	keep id group extra;
	run;
	
proc contents data=sleep;
run;

proc print data=sleep(where = (group = "1"));
	var group extra;
	run;
	
	
ods html file = '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/test.html';

proc means data = sleep;
	var extra;
	by group;
	run;
	
ods html close;
	
ods trace on;
proc univariate data = sleep;
	var extra;
	run;
ods trace off;



ods output Univariate.extra.BasicMeasures = basic;
proc univariate noprint data = sleep;
	var extra;
	run;
ods output close;

ods rtf file = '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/test.rtf';
proc print data = basic;
run;
ods rtf close;
	
