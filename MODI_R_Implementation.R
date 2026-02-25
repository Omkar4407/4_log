Transportation -> MODI
                   Supply
        23 27 16 18 30
        12 17 20 51 40
        22 28 12 32 53
Demand  22 35 25 41

> #same package
  > cost_mat=matrix(c(23,27,16,18,12,17,20,51,22,28,12,32),nrow=3,byrow=TRUE);
> row_sign = c('=','=','=');
> #row_rhs = Supply
  > supply = c(30,40,53);
> col_sign= c('=','=','=','=');
> #col_rhs = Demand
  > demand = c(22,35,25,41)
> 
> model2=lp.transport(cost_mat,direction="min",row_sign,supply,col_sign,demand);
> model2$solution
[,1] [,2] [,3] [,4]
[1,]    0    0    0   30
[2,]    5   35    0    0
[3,]   17    0   25   11
> model2
Success: the objective function is 2221 
> model2$objval
[1] 2221