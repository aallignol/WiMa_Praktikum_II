# WiMa-Praktikum (Statistical methods and applications in R and SAS) #

Material from the lecture "WiMa-Praktikum II Stochastik"
Spring 2016

- The folder [lectures](/lectures/) contains the slides, either in pdf
  or html. [illustrations](/lectures/illustrations/) contains some
  data sets and source files (in R and/or SAS) used in the
  lectures. The csv files are all available in different R packages
  cited below and reproduced here for being read in SAS.

- The folder [exercises](/exercises/) contains the exercises given to
  the students. 2 groups per week then presented their solutions.
  
## Installation ##

Either click on [Download ZIP](TODO) or clone the repository

	$ git clone https://github.com/aallignol/WiMa_Praktikum_II.git
	
## Compilation of the lectures ##

A makefile is included in [lectures](/lectures/) for automatic
generation of the slides (either pdf or html). The html slides use
the [reveal.js](/https://github.com/hakimel/reveal.js/) framework. You
may have to change the path of the reveal.js files in the
makefile. The slides are compiled
using [knitr](https://github.com/yihui/knitr)
and [pandoc](https://github.com/jgm/pandoc) or LaTeX.

## Program ##

- Introduction to R and SAS and to reproducible research
- Graphics in R and SAS
- Simple inference, parametric and non-parametric tests
- Linear regression
- Generalized linear model
- Mixed models
- Survival analysis
- Recursive partitioning
- Variable selection and assessment of model performance
- Missing values

## References ##

The following references and sources were used for the development of
this course.

- *A handbook of statistical analyses using R*, third edition
  Torsten Hothorn and Brian S. Everitt
  CRC Press 2014
- *Linear Models with R*, 
  Julian J. Faraway
  Chapman & Hall/CRC
- *Extending the Linear Model with R*
  Julian J. Faraway
  Chapman & Hall/CRC
- *The Elements of Statistical Learning*
  Trevor Hastie, Robert Tibshirani, Jerome Freedman
  Springer
- *An Introduction to Statistical Learning*
  Gareth James, Daniela Witten, Trevor Hastie, Robert Tibshirani
  Springer
- *Survival analysis, techniques for censored and truncated data*, second edition
  John P. Klein, Melvin L. Moeschberger
  Springer
- *Applied survival analysis using R*
  Dirk F Moore
  Springer
- *Linear mixed-effects models using R*
  Andrzej Galecki, Thomasz Burzykowski
  Springer
- http://www.math.chalmers.se/Stat/Grundutb/GU/MSG500/A13/Lecture10.pdf
- http://socserv.socsci.mcmaster.ca/jfox/Courses/soc740/lecture-5-notes.pdf
- http://www.econ.uiuc.edu/~wsosa/econ471/GLSHeteroskedasticity.pdf
- http://www.gs.washington.edu/academics/courses/akey/56008/lecture/lecture9.pdf
- http://data.princeton.edu/wws509/
- http://socserv.socsci.mcmaster.ca/jfox/Courses/soc740/lecture-11-notes.pdf
- http://socserv.socsci.mcmaster.ca/jfox/Courses/soc761/mixed-models.pdf
- http://kbroman.org/Tools4RR/assets/lectures/01_intro.pdf
- http://www.stat.cmu.edu/~cshalizi/statcomp/14/
  
