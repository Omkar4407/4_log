#install pacakge -> lpSolve
#?lp -> to search about lpSolve, and get syntax n meanings n stuff
#Q 1. Max z = 10x1 + 6x2 + 4x3 ,
#Subject to (x1 + x2 + x3 <= 100 )
#(10x1 + 4x2 + 5x3 <= 600 )
#(2x1 + 2x2 + 6x3 <= 300 )
obj=c(10,6,4)
> const_mat=matrix(c(1,1,1,10,4,5,2,2,6),nrow=3,byrow=TRUE)
> const_dir=c('<=','<=','<=')
> const_rhs=c(100,600,300)
> const_mat
[,1] [,2] [,3]
[1,]    1    1    1
[2,]   10    4    5
[3,]    2    2    6
> model = lp(direction="max",obj,const_mat,const_dir,const_rhs)
> model
Success: the objective function is 733.3333 
> model$solution
[1] 33.33333 66.66667  0.00000
> model$objval
[1] 733.3333
