library(igraph)
edges=c('A','B','A','C','B','C','A','D','C','D','D','E','C','E')
g=graph(edges,directed=FALSE) #direction doesnot matter ie undirected
?graph
gr=graph(edges,directed=TRUE)
degree(g)# undirected so just the number of edges fromed usig the said variable
degree(gr,mode="in") #indegree
degree(gr,mode="out") # outdegree
g
gr
#total degree = indegree+outdegree -> per vertex

plot(g, vertex.size=30, vertex.label.cex=1.2, edge.width=2, edge.color = 'purple')
#plotting undirected graph
E(g)$weight = c(1,1,1,1,1,1,1) #this is the og ie same weightage
E(g)$weight = c(30,50,25,20,40,19,20) # after assigning, it modifies the graph accrodingly
plot(gr, edge.label=E(g)$weight) #directed wowowowow
plot(gr) #without weights



#agj matrix
adj_mat = matrix(c(0,1,1,1,0,
                   1,0,1,0,0,
                   1,1,0,1,1,
                   1,0,1,0,1,
                   0,0,1,1,0), nrow=5,byrow=TRUE)

#Assigning names
rownames(adj_mat) = colnames(adj_mat) = c('A','B','C','D','E')
agr = graph_from_adjacency_matrix(adj_mat, mode='undirected')
plot(agr)
E(g)$weight = c(30,25,50,20,40,19,20)
plot(agr, edge.label=E(g)$weight)

#MST
g2 = mst(agr)
plot(g2)
