#Bayes Theorem

#Jahanvi -> To check the accuracy of the model do the following
#data=iris
#tdata=data[1:40,]
#test_data=data[141:150,]
#test_data_label=test_data[,5]
#test_data=test_data[,-5]
#model=naiveBayes(Species~., data=tdata)
#p=predict(model,test_data)

> data=iris
> summary(data)
Sepal.Length    Sepal.Width     Petal.Length    Petal.Width          Species  
Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100   setosa    :50  
1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300   versicolor:50  
Median :5.800   Median :3.000   Median :4.350   Median :1.300   virginica :50  
Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199                  
3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800                  
Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500                  
> library(e1071)
> touple=data.frame(Sepal.Length = 5.1,Sepal.Width = 3.5,Petal.Length = 1.4,Petal.Width = 0.2)
> ?naiveBayes
> model=naiveBayes(Species~.,data=data,laplace=1)
> # find the species it belongs to, prediction based on . ie all, where the dataset is named data, and laplace =1, ie apply smoothing ie it doesnt go to zero, but gives a very small numbe
  > model

> str(data)
'data.frame':	150 obs. of  5 variables:
  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
$ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
$ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
$ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
$ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
> touple
Sepal.Lenght Sepal.Width Petal.Length Petal.Width
1          5.1         3.5          1.4         0.2
> touple <- data.frame(
    +     Sepal.Length = 5.1,
    +     Sepal.Width  = 3.5,
    +     Petal.Length = 1.4,
    +     Petal.Width  = 0.2
    + )
> predict(model,touple)
[1] setosa
Levels: setosa versicolor virginica

> touple=data[97:103,]
> predict(model,touple)
[1] versicolor versicolor versicolor versicolor virginica  virginica  virginica 
Levels: setosa versicolor virginica

> data[97:103, "Species"]
[1] versicolor versicolor versicolor versicolor virginica  virginica  virginica 
Levels: setosa versicolor virginica

> #this checked the model

> #explicitly remove the 5ht column, so that its now taken into consideration during prediction - even though R already does this by itself
  > touple=data[144:150,]
> touple=touple[,-5]
> predict(model,touple)

[1] virginica virginica virginica virginica virginica virginica virginica
Levels: setosa versicolor virginica
