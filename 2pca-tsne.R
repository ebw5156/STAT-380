
#read master 
Master<-fread('./project/volume/data/interim/Master.csv')

Mastertext<-Master$text
MasterID<-Master$id
Master$id<-NULL
Master$text<-NULL
MasterR<-Master$reddit
#i tried doing something with the tf/idf but it wasnt working
#Master$reddit<-NULL
#MasterTerm<-Master$term
#Master$term<-NULL
#MasterDoc<-Master$doc_count
#MasterTC<-Master$term_count
#Master$doc_count<-NULL
#Master$term_count<-NULL
#MasterRN<-Master$rn
#Master$rn<-NULL
dummies <- dummyVars(reddit~., data = Master)
Final<-predict(dummies, newdata = Master)

pca<-prcomp(Final)
screeplot(pca)

# look at the rotation of the variables on the PCs
pca

# see the values of the scree plot in a table 
summary(pca)

# see a biplot of the first 2 PCs
biplot(pca)

# use the unclass() function to get the data in PCA space
pca_dt<-data.table(unclass(pca)$x)
#pca_dt2<-data.table(unclass(pca)$rotation)




# see a plot with the party data 
ggplot(pca_dt,aes(x=PC1,y=PC2))+geom_point()



tsne<-Rtsne(pca_dt,pca = F,perplexity=100,check_duplicates = F)
#tsne2<-Rtsne(Final,pca = T,perplexity=51,check_duplicates = F)
tsne_dt<-data.table(tsne$Y)
tsne2<-Rtsne(pca_dt,pca = F,perplexity=80,check_duplicates = F)
tsne_dt2<-data.table(tsne2$Y)

tsne_dt2$V3<-tsne_dt2$V1
tsne_dt2$V4<-tsne_dt2$V2
tsne_dt2<-subset(tsne_dt2,select=c(V3,V4))
FinalTsne<-cbind(tsne_dt,tsne_dt2)

k_bic<-Optimal_Clusters_GMM(FinalTsne[,.(V3,V4)],max_clusters = 10,criterion = "BIC")
#k_bic<-Optimal_Clusters_GMM(tsne_dt[,.(V1,V2)],max_clusters = 25,criterion = "BIC")

# now we will look at the change in model fit between successive k values
delta_k<-c(NA,k_bic[-1] - k_bic[-length(k_bic)])

# I'm going to make a plot so you can see the values, this part isnt necessary
del_k_tab<-data.table(delta_k=delta_k,k=1:length(delta_k))

# plot 
ggplot(del_k_tab,aes(x=k,y=-delta_k))+geom_point()+geom_line()+
  scale_x_continuous(breaks = scales::pretty_breaks(n = 10))+
  geom_text(aes(label=k),hjust=0, vjust=-1)




tsne_dt<-data.table(FinalTsne)
tsne_dt$reddit<-MasterR


train=tsne_dt[!reddit==11]
test=tsne_dt[reddit==11]

fwrite(train,'./project/volume/data/interim/train.csv')
fwrite(test,'./project/volume/data/interim/test.csv')
