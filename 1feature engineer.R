library(data.table)
library(caret)
library(Metrics)
library(xgboost)
library(data.table)
library(Rtsne)
library(ggplot2)
library(caret)
library(ggplot2)
library(ClusterR)
library(text2vec)
library(data.table)
library(magrittr)
library(diplyr)
library(tidytext)
train<-fread('./project/volume/data/raw/training_data.csv')
test<-fread('./project/volume/data/raw/test_file.csv')
train_emb<-fread('./project/volume/data/raw/train_emb.csv')
test_emb<-fread('./project/volume/data/raw/test_emb.csv')

#test$variable<-0
id<-test$id
#train$text<-0
#test$value<-0
#melt training to get y prediction 
train<-melt(data = train, id.vars = c("id","text") , variable.name="reddit")
train<-train[value==1][order(id)][,.(id,reddit,text)]
train[order(train$reddit),]
table(train$reddit)

value<-colnames(example_sub, do.NULL = TRUE, prefix = "col")
colnames<-colnames(example_sub) <- value

train$reddit<-as.numeric((train$reddit))-1

#train['reddit']<-train$reddit_num


#train$reddit<-recode(train$reddit,'subredditcars'=1,'subredditCooking'=2,'subredditMachineLearning
#'=3,'subredditmagicTCG'=4,'subredditpolitics'=5,'subredditpolitics
#'=6,'subredditReal_Estate'=7,'subredditscience'=8,'subredditStockMarket'=9,'subreddittravel'=3,'subredditvideogames'=10)
#take values of 1
#train<-train[!(train$value=="0" ),]
test$reddit<-11
#bindings to make master 
New<-rbind(train,test)


embeddings<-rbind(test_emb,train_emb)
#create master



# define preprocessing function and tokenization function
#prep_fun = tolower
#tok_fun = word_tokenizer

#it_train = itoken(train$text, 
#                  preprocessor = prep_fun, 
#                  tokenizer = tok_fun, 
 #                 ids = train$id, 
#                  progressbar = FALSE)
#vocab = create_vocabulary(it_train)

#it_test = tok_fun(prep_fun(test$text))
# turn off progressbar because it won't look nice in rmd
#it_test = itoken(it_test, ids = test$id, progressbar = FALSE)


#dtm_test = create_dtm(it_test, vectorizer)
#remove stop words to 
#stop_words = c("i", "me", "my", "myself", "we", "our", "ours", "ourselves", "you", "your", "yours")
#t1 = Sys.time()
#vocab = create_vocabulary(it_train, stopwords = stop_words)

#pruned_vocab = prune_vocabulary(vocab, 
 #                               term_count_min = 1, 
  #                              doc_proportion_max = 0.5,
   #                             doc_proportion_min = 0.001)
#vectorizer = vocab_vectorizer(pruned_vocab)


# create dtm_train with new pruned vocabulary vectorizer
#t1 = Sys.time()
#dtm_train  = create_dtm(it_train, vectorizer)
#dtm_train<-melt(data = dtm_train, id.vars = c("reddit") , variable.name="reddit")


#as.matrix(dtm_train)
#check dim and unique terms

#dim(dtm_train)
#vocab$term<-as.numeric((vocab$term))-1

#vocab = create_vocabulary(it_train)
#vectorizer = vocab_vectorizer(vocab)
#dtm_train = create_dtm(it_train, vectorizer)

# define tfidf model
#tfidf = TfIdf$new()
# fit model to train data and transform train data with fitted model
#dtm_train_tfidf = fit_transform(dtm_train, tfidf)
# tfidf modified by fit_transform() call!
# apply pre-trained tf-idf transformation to test data
#dtm_test_tfidf = create_dtm(it_test, vectorizer)
#dtm_test_tfidf = transform(dtm_test_tfidf, tfidf)


#b = as.data.frame(as.matrix(dtm_train_tfidf))

#final_df <- as.data.frame(t(b))

#<-melt(data = final_df, id.vars = c("train_1") , variable.name="reddit")
#setDT(final_df, keep.rownames = TRUE)[]



Master<-cbind(New,embeddings)
#MasterF<-cbind(Master,pruned_vocab)
#MasterF<-cbind(MasterF,final_df)
fwrite(MasterF,'./project/volume/data/interim/Master.csv')

