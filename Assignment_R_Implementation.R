#ASSIGNMENT / HUNGARIAN
> LIBRARY(LPsOLVE)
Error in LIBRARY(LPsOLVE) : could not find function "LIBRARY"
> library(lpSolve)
> ?lp.assign
> cost_mat=matrix(c(85,75,65,125,75,90,78,66,132,78,75,66,57,114,69,80,72,60,120,72,76,64,56,112,68)nrow=5,byrow=TRUE)
Error: unexpected symbol in "cost_mat=matrix(c(85,75,65,125,75,90,78,66,132,78,75,66,57,114,69,80,72,60,120,72,76,64,56,112,68)nrow"
> cost_mat=matrix(c(85,75,65,125,75,90,78,66,132,78,75,66,57,114,69,80,72,60,120,72,76,64,56,112,68),nrow=5,byrow=TRUE)
> cost_mat
[,1] [,2] [,3] [,4] [,5]
[1,]   85   75   65  125   75
[2,]   90   78   66  132   78
[3,]   75   66   57  114   69
[4,]   80   72   60  120   72
[5,]   76   64   56  112   68
> model3=lp.assign(cost_mat,direction='min')
> model3$solution
[,1] [,2] [,3] [,4] [,5]
[1,]    0    0    0    0    1
[2,]    0    0    1    0    0
[3,]    0    0    0    1    0
[4,]    1    0    0    0    0
[5,]    0    1    0    0    0
> model3$objval
[1] 399