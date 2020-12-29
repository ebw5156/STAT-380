#options(scipen = 999)
set.seed(999)
example_sub<-fread('./project/volume/data/processed/example_sub.csv')
train<-fread('./project/volume/data/interim/train.csv')
test<-fread('./project/volume/data/interim/test.csv')

#y.test<-y.test$reddit
#y.test$reddit<-NULL
#train$term<-NULL
#test$term<-NULL

y.train<-train$reddit
#y.train<-as.numeric(y.train)-1
y.test<-test$reddit


#y.test<-as.numeric(as.factor(y.test))-1
#master<- rbind(train,test)
dummies <- dummyVars(reddit~., data = train)
x.train<-predict(dummies, newdata = train)
x.test<-predict(dummies, newdata = test)



#train$reddit<-NULL
#test$reddit<-NULL

#put in matrix
dtrain <- xgb.DMatrix(x.train,label=y.train,missing=NA)
#dtrain<-dtrain-1
dtest <- xgb.DMatrix(x.test,label=y.test, missing=NA)

train

hyper_perm_tune<-NULL
########################
# Use cross validation #
########################

param <- list(  objective           = "multi:softprob",
                num_class           =10,
                gamma               =.002,
                booster             = "gbtree",
                eval_metric         = "mlogloss",
                eta                 = .003,
                max_depth           = 5,
                min_child_weight    = 8,
                subsample           = 0.003,
                colsample_bytree    = 0.003,
                tree_method = 'hist'
      
                
                
                
)


XGBm<-xgb.cv( params=param,nfold=1000,nrounds=20000,missing=NA,data=dtrain,print_every_n=1,early_stopping_rounds=800)

best_ntrees<-unclass(XGBm)$best_iteration

new_row<-data.table(t(param))

new_row$best_ntrees<-best_ntrees

test_error<-unclass(XGBm)$evaluation_log[best_ntrees,]$test_mlogloss_mean
new_row$test_error<-test_error
hyper_perm_tune<-rbind(new_row,hyper_perm_tune)

####################################
# fit the model to all of the data #
####################################



watchlist <- list( train = dtrain)

# now fit the full model

XGBm<-xgb.train( params=param,nrounds=best_ntrees,missing=NA,data=dtrain,watchlist=watchlist,print_every_n=1,)
pred<-predict(XGBm, newdata = dtest)
XGBm

result2<-matrix(pred,ncol=10,byrow=T,dimnames = )
g<-cbind(example_sub[,.(id)],result2,keep.rownames=T)
         

colnames(g)[colnames(g) %in% c("V1", "V2","V3","V4","V5","V6","V7","V8","V9","V10")] <- c("subredditcars", "subredditCooking","subredditMachineLearning","subredditmagicTCG","subredditpolitics","subredditReal_Estate","subredditscience","subredditStockMarket","subreddittravel","subredditvideogames")
l<-as.data.frame(g, check.names = !optional,col.names=colnames)

#colnames(g)<-c(example_sub$id,"subredditcars","subredditCooking","subredditMachineLearning","subredditmagicTCG","subredditpolitics","subredditReal_Estate","subredditscience","subredditStockMarket","subreddittravel","subredditvideogames")






write.csv(l, "./project/volume/data/processed/submit_17.csv", row.names = F)
fwrite(l,"./project/volume/data/processed/submit_17.csv",row.names =F)

