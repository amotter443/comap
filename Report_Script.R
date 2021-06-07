#Omitted cleaning script, gradient descent, time & sankey data generation, a lot of the different
#iterations of ggplot visliaztion scripts written

#List of used packages
#readr,readxl,dplyr,data.table,stringr,tidytext,topicmodels,lexicon,textclean,sentimentr,
#lexicon,tidyr,psych,cluster,factoextra,lubridate,MASS,Metrics


#1. Cleaning 

#Remove commas and parentheses
pacifier$product_title<-gsub(",|\\(|\\)|\\.)","",x=pacifier$product_title,ignore.case = TRUE)

#Method for extracting boolean values
pacifier$title_baby_age<-grepl("month|[[:digit:]] m|[[:digit:]]m",x=pacifier$product_title,ignore.case = TRUE)

#Convert all new boolean features to zeroes and ones
pacifier[,c(14:31)]<-lapply(pacifier[,c(14:31)], as.integer)

#Calculate Review length 
pacifier$review_length<-nchar(pacifier$review_body)

#Omit emojis from review body and head
pacifier$review_body<-iconv(pacifier$review_body, from = "latin1", to = "ascii",sub = "byte")
pacifier$review_body<-replace_emoticon(pacifier$review_body, emoticon_dt = lexicon::hash_emojis)
pacifier$review_headline<-iconv(pacifier$review_headline, from = "latin1", to = "ascii",sub = "byte")
pacifier$review_headline<-replace_emoticon(pacifier$review_headline, emoticon_dt = lexicon::hash_emojis)
#Remove exteranous emojis that could not be translated by the lexicon 
pacifier$review_body<-gsub("<.*?\\>","",x=pacifier$review_body)
pacifier$review_body<-gsub(">","",x=pacifier$review_body)
pacifier$review_headline<-gsub("<.*?\\>","",x=pacifier$review_headline)
pacifier$review_headline<-gsub(">","",x=pacifier$review_headline)

#Merge review body and headline columns
#If the first 30 characters of both headline and body are the same, remove the headline data
pacifier$review_headline[which(substr(pacifier$review_body,1,30)==substr(pacifier$review_headline,1,30))]<-NA
#Add a period to the end of features w/ no end punctuation
pacifier$review_headline<-trimws(pacifier$review_headline)
pacifier$user_feedback<-NA
pacifier$user_feedback[-grep("[[:punct:]]$",pacifier$review_headline)]<-paste(pacifier$review_headline[-grep("[[:punct:]]$",pacifier$review_headline)],pacifier$review_body[-grep("[[:punct:]]$",pacifier$review_headline)],sep = ". ")
pacifier$user_feedback[grep("[[:punct:]]$",pacifier$review_headline)]<-paste(pacifier$review_headline[grep("[[:punct:]]$",pacifier$review_headline)],pacifier$review_body[grep("[[:punct:]]$",pacifier$review_headline)],sep = " ")
pacifier<-pacifier[,-c(10:11)]
pacifier$user_feedback<-gsub("NA\\.","",pacifier$user_feedback)
pacifier$user_feedback<-gsub("([[:punct:]])\\1{1,}", "\\1", pacifier$user_feedback)


#2 Feature Importance and Linear Modeling
feature_table <- data.table(feature = "", doesnt_contain = "", contains = "",
                            fourtofive_star = "", onetotwo_star = "", percent_high = "")
for (i in 14:29) {
  feature_table <- feature_table %>%  
    add_row( 
      feature = colnames(pacifier)[i],
      doesnt_contain = as.numeric(pacifier %>%
                                    filter(pacifier[,i] == 0) %>%
                                    summarize(mean(star_rating))),
      contains = as.numeric(pacifier %>%
                              filter(pacifier[,i] == 1) %>%
                              summarize(mean(star_rating))),
      fourtofive_star = as.numeric(pacifier %>%
                                     filter(pacifier[,i] == 1) %>%
                                     summarize(sum(star_rating==5 | star_rating==4))),
      onetotwo_star = as.numeric(pacifier %>%
                                   filter(pacifier[,i] == 1) %>%
                                   summarize(sum(star_rating==1 | star_rating==2))),
      percent_high = 100* (fourtofive_star / as.numeric(pacifier %>%
                                                          filter(pacifier[,i] == 1) %>%
                                                          summarize(n())))
    )
}
feature_table <- feature_table[-1,]
feature_table[,2:6]<-lapply(feature_table[,2:6],as.numeric)


#Linear Modeling
set.seed(75)
train_ind <- sample(seq_len(nrow(pacifier)), size = floor(0.75 * nrow(pacifier)))
reg <- pacifier[,c(5:9,11:12,14:29,34)]
train <- reg[train_ind, ]
test <- reg[-train_ind, ]

ols <- lm(star_rating ~ ., data = train)
lm.fitted <- abs(predict(ols,newdata=test))
error<-rmsle(test$star_rating,lm.fitted)
error
summary(lm)
plot(lm)

stepback <- stepAIC(ols, direction="backward")
summary(stepback)
plain<-lm(star_rating~1, data=train)
forward <- stepAIC(plain, direction="forward",scope =list(upper=ols, lower=plain))
summary(forward)
lm.fitted <- abs(predict(forward,newdata=test))
error<-rmsle(test$star_rating,lm.fitted)
error

pval<-as.data.frame(summary(forward)$coefficients[,4])  
pval$feature<-rownames(pval)
colnames(pval)<-c("p_value","feature")
feature_table<-feature_table%>%left_join(pval)%>%filter(!is.na(p_value))


#3. Sentiment Analysis

#Collect review-level average sentiment scores
sentences <- pacifier %>%select(review_id,user_feedback) %>% mutate(sentences = get_sentences(user_feedback)) 
sentiment <- sentiment_by(sentences$sentences,by=sentences$review_id)%>%select(review_id, ave_sentiment)
colnames(sentiment)[2]<-"user_review_sentiment"
pacifier <- pacifier%>%left_join(sentiment, by="review_id")

#Word level distribution bag of words
words <- pacifier %>% 
  unnest_tokens(word, user_feedback) %>%
  select(review_id, word) %>%
  count(word, sort = T) %>%
  anti_join(stop_words) %>%
  filter(n>=100) #n=40 for microwave
words <- words[-grep("\\d",words$word),]
summary(words$n)

#Claculate average star ratings per word
star <- data.frame(word = words$word)
for (i in 1:length(words$word)) {
  temp <- pacifier %>% filter(grepl(words$word[i], user_feedback))
  star[i,"rating"] <- mean(temp$star_rating)
}
rm('temp')
words <- words %>% left_join(star, by="word")

#How many reviews is the word in, how many 5 star reviews, and how many 1 star reviews?
appearances <- data.table(word = "", five_star = "", one_star = "", total_num = "")
for (i in 1:length(words$word)) {
  appearances <-  add_row(appearances, 
                          word = words$word[i],
                          five_star = as.numeric(pacifier %>% 
                                                   filter(grepl(words$word[i], user_feedback, ignore.case = T)) %>%
                                                   filter(star_rating > 4.00) %>%
                                                   summarize(n())),
                          one_star = as.numeric(pacifier %>% 
                                                  filter(grepl(words$word[i], user_feedback, ignore.case = T)) %>%
                                                  filter(star_rating < 2.00) %>%
                                                  summarize(n())),
                          total_num = as.numeric(pacifier %>% 
                                                   filter(grepl(words$word[i], user_feedback, ignore.case = T)) %>%
                                                   summarize(n()))
  )
}
appearances <- appearances[-1,]
appearances$five_star <- as.numeric(appearances$five_star)
appearances$one_star <- as.numeric(appearances$one_star)
appearances$total_num <- as.numeric(appearances$total_num)
words <- words %>% left_join(appearances, by="word")


#4. Clustering for user_feedback

#KMeans 
clustering.words<-data.matrix(words)
clustering.words<-clustering.words[,-1]
row.names(clustering.words)<-words$word
clustering.words<-scale(clustering.words)

#Use elbow method to determine optimal k value
k_tot.wthnss <- sapply(1:10,function(x){kmeans(clustering.words, x, nstart=50)$tot.withinss})
k_tot.wthnss
plot(1:10, k_tot.wthnss,type="b", pch = 1,xlab="K",ylab="Total within-clusters sum of squares")

#Create Kmeans and plot
k4<-kmeans(clustering.words,centers=4,nstart = 50)
#Text
words %>% as_tibble() %>% mutate(cluster = k4$cluster, words = row.names(clustering.words)) %>% 
  ggplot(aes(rating, total_num, color = factor(cluster), label = words))+ geom_text()+ labs(title = "Pacifier Word KMeans K=4")
#Points and Ellipses
words %>% as_tibble() %>% mutate(cluster = k4$cluster, words = row.names(clustering.words)) %>% 
  ggplot(aes(rating, total_num, color = factor(cluster), label = words)) + geom_point()+
  stat_ellipse(aes(x=rating, y=total_num,color=factor(cluster)),type = "norm")+ labs(title = "Pacifier KMeans Clusters K=4")

#Cbind k-means values to the dataset
words<-cbind(words,k4$cluster)
#Make successful and failing lists
successful<-words%>%filter(`k4$cluster`%in% c(1,2))
failing<-words%>%filter(`k4$cluster`==4)
successful<-successful[,-7]
failing<-failing[,-7]

#Hierarchical
hc.complete<-hclust(dist(clustering.words), method="complete")
hc.average<-hclust(dist(clustering.words), method="average")
hc.single<-hclust(dist(clustering.words), method="single")
hc.centroid<-hclust(dist(clustering.words), method="centroid")
k4_centroid<-cutree(hc.centroid, k=4)
k4_complete<-cutree(hc.complete, k=4)
k4_average<-cutree(hc.average,k=4)
k4_single<-cutree(hc.single,k=4)
#Plot complete hierarchical cluster
plot(hc.complete,main="Complete Linkage",xlab="",ylab="")