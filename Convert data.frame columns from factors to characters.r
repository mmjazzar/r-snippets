# Convert data.frame columns from factors to characters
# source:http://stackoverflow.com/questions/2851015/convert-data-frame-columns-from-factors-to-characters?rq=1

> head(bob)
phenotype                         exclusion
GSM399350 3- 4- 8- 25- 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-
GSM399351 3- 4- 8- 25- 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-
GSM399352 3- 4- 8- 25- 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-
GSM399353 3- 4- 8- 25+ 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-
GSM399354 3- 4- 8- 25+ 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-
GSM399355 3- 4- 8- 25+ 44+ 11b- 11c- 19- NK1.1- Gr1- TER119-


> class(bob$phenotype)
[1] "factor"



bob[] <- lapply(bob, as.character)

#or 

bob <- data.frame(lapply(bob, as.character), stringsAsFactors=FALSE)
