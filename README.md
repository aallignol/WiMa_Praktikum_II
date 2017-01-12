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

## Programm ##

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

