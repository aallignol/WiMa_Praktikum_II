/*
Code for lecture on data manipulation in SAS
Arthur Allignol <arthur.allignol@uni-ulm.de>
*/

* Import the data;

proc import datafile = '/folders/myshortcuts/WiMa_Praktikum/lectures/illustration/df.csv'
    out = df
    dbms = csv
    replace;
run;

proc print data = df(obs = 5);
run;

proc contents data = df;
run;

* change format of a_factor;

data df;
    set df;
    newfactor = input(a_factor, 3.);
run;

/***********
* Labels 
************/

data df;
	set df;
	label visit_1 = "Measure at first visit (mm)"
		visit_2 = "Measure at second visit (mm)"
		visit_3 = "Measure at third visit (mm)";
run;

proc means data = df;
var visit_1 visit_2 visit_3;
run;
		

* Create labels for the categorical variables;

proc format;
    value dis 1 = 'Horrible disease' 0='Healthy';
    value factor_one 1 = 'Factor present' 0 = 'Factor absent';
    value factor_two 1-2='low' 3 = 'medium' 4-5 = 'high';
run;

* an example in proc freq;
proc freq data = df;
    format disease dis. another_factor factor_two.;
    tables disease * another_factor;
run;

/**********************
* Play with dates;
************************/

data some_dates;
    time1 = '15:00't;
    date1 = '18jun2016'd;
    datetime1 = '3nov1995:15:00:00'dt;
run;


data test_date;
    time1 = 1090013;  format time1  datetime.;
    date1 = 9013;    format date1  date9.;
    time2 = time1;    format time2  timeampm.;
    date2 = date1;    format date2  month.;
    date3 = date1;    format date3  DDMMYYB10.;
    
    new_date = date1 - 360;
    new_date0 = new_date; format new_date0 date9.;
    new_date2 = month(new_date);	
    
run;

proc print data = test_date;
run;

/******************
* Text processing
******************/

data text1;
    x1 = 'cats ';
    x2 = ' apples';
    x3 = 'and dogs';

    all1 = cat(of x1-x3); /* same as cat(' ', of x1, x2, x3) */
    all2 = cats(of x1-x3);
    all3 = catt(of x1-x3);
    all4 = catx("|", of x1-x3);

    put all1=;
    put all2=;
    put all3=;
    put all4=;
run;

data text2;
    expr1 = 'A; simple; sentence';
    new = compress(expr1, ";");
    put new=;

    expr2 = '122-ll43 76';
    new2 = compress(expr2, "-", 'd');
    put new2=;

    expr3 = '1   2   4   5     7';
    new3 = compress(expr3, , 's');
    put new3=;
run;
    
data text3;
    a = count("banana", "a");
    put a=;

    where = "university of california";
    i = index(where,"cal");
    put i=;

    hihi = reverse(where);
    put hihi=;

    up = upcase(where);
    put up=;

    new = translate(where, 'UC', 'uc');
    put new=;

	new2 = tranwrd(where, 'university', 'beach');
    put new2=;
run;

/**************************
* Data manipulation
**************************/

* Row subscripting;

data ulm;
	set df;
	if upcase(center) eq 'ULM' then delete;
run;
	
data high;
	set df(where = (another_factor in (4 5)));
run;

* Column subscripting;

data visit;
	set df;
	keep visit:;
	run;
	
data visit2;
	set df;
	drop id--center;
	run;
	
data numeric;
	set df;
	* keep the numeric variables;
	keep id-numeric-visit_3_d;
	run;

data char;
	set df;
	* keep the character variables;
	keep id-character-visit_3_d;
	run;
	
data sans_visit;
	set df;
	drop visit_1-visit_3;
	run;
	
/********************************
* PROC SQL
*********************************/

proc sql;
	create table new as
		select visit_1, visit_2, visit_3
		from df
quit;

proc sql;
	create table new_new as
		select id as pat,
			   exp(visit_1) as exp_visit1,
			   visit_2, 
			   visit_3,
			   visit_1_d format=date9.
		from df
		where center in ("ulm", "Freiburg")
		order by pat desc;
quit;

proc print data = new_new;
run;

/**************
* arrays
***************/

data test_array;
	set df;
	array x visit_1-visit_3;
	array res{3};
	do i=1 to dim(x);
		res{i} = x{i} * 10;
		end;
	keep visit_1-visit_3 res:;
run;


/********************************
* Data reshaping
*********************************/

* Using proc transpose;
proc transpose data = df
	out = long1(rename=(col1=measure)) name = visit;
	by id;
	var visit_1-visit_3;
run;

proc transpose data = df
	out = long2(rename=(col1=date)) name = visit;
	by id;
	var visit_1_d--visit_3_d;
run;

* and merge;
data df_long;
	merge long1
		  long2
		  df(keep = id a_factor another_factor disease center);
	by id;
run;

* Using a data step;
data df_long2;
	set df;
	
	array m visit_1-visit_3;
	array d visit_1_d--visit_3_d;
	
	do _i = 1 to dim(m);
		measure = m(_i);
		date = d(_i);
		visit = _i;
		output;
	end;
	
	format date date9.;
	keep id center a_factor another_factor disease measure date visit;
run;

proc print data=df_long2(obs=6);
run;

*check;
proc means data = df;
	var visit_1-visit_3;
	run;

* need to sort before using the by statement in proc means;
proc sort data = df_long
	out = df_long;
	by visit;
proc means data = df_long;
	var measure;
	by visit;
	run;
	
proc sort data = df_long2
	out = df_long2;
	by visit;
proc means data = df_long2;
	var measure;
	by visit;
	run;
	
	
/********************
* Combine and Merge
*********************/

data d1;
	input x y $;
	datalines;
	1 a
	4 b
	5 g
	7 y
	;
run;

data d2;
	input x y $;
	datalines;
	6 r
	9 g
	4 j
	6 t
	;
run;

data d3;
	set d2(rename=(x=z y=w));
	run;

* Combine by rows;

data row_bind;
	set d1 d2;
proc print data = row_bind;
run;

* Combine by columns;
data col_bind;
	set d1;
	set d3;
proc print data = col_bind;
run;

* merge via row numbers;
data col_bind2;
	merge d1 d3;
	run;

/***********
* Merge
************/

data dd1;
	input id letter $;
	datalines;
	20 k
	1  j
	3  h
	7  a
	13 c
	8  s
	;
run;

data dd2;
	input id digit;
	datalines;
	13 3
	14 8
	7  7
	1  6
	54 0
	;
run;

* before merging need to sort both data;
proc sort data=dd1
	out=dd1_sort;
	by id;
	run;
proc sort data=dd2
	out=dd2_sort;
	by id;
	run;
	
* default is full join;
data ddmerge;
	merge dd1_sort dd2_sort;
	by id;
run;

* natural join: need to use in=;
data ddmerge_natural;
	merge dd1_sort(in=in1) dd2_sort(in=in2);
	by id;
	if in1 eq 0 or in2 eq 0 then delete;
run;

* left join;
data ddmerge_left;
	merge dd1_sort(in=in1) dd2_sort(in=in2);
	by id;
	if in1 eq 0 then delete;
run;


*** Merge with proc sql;
proc sql;
	create table ddmerge_natural_sql as 
		select *
		from dd1 inner join dd2
		on dd1.id=dd2.id;
quit;

data dd2_alt;
	set dd2(rename=(id=pat));
run;
proc sql;
	create table ddmerge_natural_sql2 as 
		select *
		from dd1 inner join dd2_alt
		on dd1.id=dd2_alt.pat;
quit;

* left join;
proc sql;
	create table ddmerge_left_sql as
	select *
	from dd1 left join dd2
	on dd1.id=dd2.id;
quit;

****************************************************************************;
****************************************************************************;
****************************************************************************;

proc contents data= df;
run;

proc print data = df;
run;
