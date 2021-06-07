library(readr)
library(readxl)
library(dplyr)
library(data.table)
library(stringr)
library(tidytext)
library(topicmodels)
library(lexicon)
library(textclean)
library(sentimentr)
library(lexicon)
library(tidyr)
library(psych)
library(cluster)
library(factoextra)
library(lubridate)
library(MASS)
library(Metrics)

pacifier<-read_tsv("pacifier.tsv")

true_pacifier<-pacifier[,c(5,6)]
true_pacifier<-unique(true_pacifier)

true_pacifier<-true_pacifier[grep("pacifier|nipple|bink",x=true_pacifier$product_title,ignore.case=TRUE,value=FALSE),]
true_pacifier<-true_pacifier[-grep("glass baby bottle|stainless infant bottle|drool bib|teething bib|carrying case|bandana bib|pacifier pod|pacifier sterilizer|pacifier cl|shower game|pin t|pacifier bag|sterilizer|pacifier po|crib|brush|Replacement Nipple|cleaner|pacifier attacher|pad|sheep|nipple re|bottle wi|nipple shield|bag|nipple cream|pacifier box|pacifier hard|valentines day bottle|wipe|safety strap",x=true_pacifier$product_title,ignore.case=TRUE,value=FALSE),]

#Teething rail, non-hybrid teething products main objective isn't passifying and does not significanty impact data
#476 observations 10656 records
#361 observations 10461 records

pacifier<-pacifier[which(pacifier$product_parent %in% true_pacifier$product_parent),]
pacifier$title_length<-nchar(pacifier$product_title)

brands<-c("mam","avent","philips avent","natursutten","playtex","tommee tippee","nuk","dr. brown","wubbanub","mary meyer","gerber","hevea","dexbaby","fctry","baby fanatic","babypro","billy bob","billy-bob","born free","the first years","nuby","gumdrop","safety 1st","vital baby","rockstar","rock star","voberry","ummy","razbaby","pura","pullypalz","ulubulu","soothie","baby buddy","beardo","binkibear","cuddlesme","similac","pacipals","pacimals","paci plushies","mustachifier","munchkin","medela","lifefactory","kiinde","kidz-med","ken health","keep-it-kleen","jollypop","haba motley","evenflo","ecopiggy","chomp","chicco","bright starts","booginhead")
pacifier$is_branded<-grepl(paste(brands,collapse = "|"),x=pacifier$product_title,ignore.case = TRUE)
table(pacifier$is_branded)

related_brands<-c("natursutten","playtex","hevea","baby fanatic","babypro","born free","safety 1st","vital baby","rockstar","rock star","soothie","baby buddy","cuddlesme","pacipals","munchkin","lifefactory","kidz-med","ken health","keep-it-kleen","evenflo","bright starts")
unrelated_brands<-c("avent","philips avent","tommee tippee","nuk","dr. brown","wubbanub","mary meyer","gerber","dexbaby","fctry","billy bob","billy-bob","the first years","nuby","gumdrop","voberry","ummy","razbaby","pura","pullypalz","ulubulu","beardo","binkibear","similac","pacimals","paci plushies","mustachifier","medela","kiinde","jollypop","haba motley","ecopiggy","chomp","chicco","booginhead")

pacifier$product_title<-gsub(paste(unrelated_brands,collapse = "|"),"",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("natursutten","nature",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("playtex","play tech",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("hevea","hevean",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("babypro","baby pro",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("safety 1st","safety first",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("soothie","soothe",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("cuddlesme","cuddles",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("pacipals","pals",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("lifefactory","life factory",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("kidz-med","kids med",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("ken health","health",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("keep-it-kleen","keep clean",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("evenflo","even flow",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("freeflow","free flow",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("'s","",x=pacifier$product_title,ignore.case = TRUE)

#Remove commas and parentheses
pacifier$product_title<-gsub(",|\\(|\\)|\\.)","",x=pacifier$product_title,ignore.case = TRUE)

#How many pacifiers in each pack? 

#Start by standarizing pack values
pacifier$product_title<-gsub(" one","1",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("two","2",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("three","3",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("four","4",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("five","5",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("six","6",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("seven","7",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub(" eight","8",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("nine","9",x=pacifier$product_title,ignore.case = TRUE)

pacifier$product_title<-gsub("-pacs|-count|-pack|-pk|-pcs"," pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("/ pk"," pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub(" pk| ct.| ct| pcs"," pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub(" mam| count| ea"," pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("4 nipples","4 pack nipples",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("pack of 4","4 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("pack of 2","2 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("pack of 8","8 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("2 pacifiers|2pack|2 per pack|2pcs","2 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("3ct|set of 3|packof 3","3 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("1pk","1 pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("pack.","pack",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("2 front","two pack",x=pacifier$product_title,ignore.case = TRUE)

pacifier$packs<-str_extract(pacifier$product_title,"\\d{1,2}\\spack")
pacifier$packs<-gsub("pack","",x=pacifier$packs,ignore.case = TRUE)
pacifier$packs<-as.integer(pacifier$packs)
pacifier$product_title<-gsub("\\d{1,2}\\spack","",x=pacifier$product_title)


#Get rid of size, level, '100%' because of sparcity and conflict with other numeric values
pacifier$product_title<-gsub("[[:digit:]] ounce","",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("size[[:digit:]]|size [[:digit:]]|level [[:digit:]]","",x=pacifier$product_title,ignore.case = TRUE)
pacifier$product_title<-gsub("100%","",x=pacifier$product_title,ignore.case = TRUE)


#Baby age
pacifier$title_baby_age<-grepl("month|[[:digit:]] m|[[:digit:]]m",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_newborn_safe<-grepl("0 |0-",x=pacifier$product_title)
pacifier$product_title<-gsub("[[:digit:]]|months|month|mo ","",x=pacifier$product_title)

#Materials
pacifier$title_material<-grepl("plastic|rubber|bpa|silicone|latex|acrylic",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_bpa<-grepl("bpa",x=pacifier$product_title,ignore.case = TRUE)

#novelty
pacifier$title_novelty<-grepl("nfl|mlb|sports|personalized|soccer|john deere|hello kitty|pirate|rock n' roll|vampire|cowboy|crown|princess|colts|detroit|university of texas|green bay packrs|seattle|sherlock|mustache",x=pacifier$product_title,ignore.case = TRUE)

#Animals 
pacifier$title_animals<-grepl("giraffe|elephant|lamb|dog|kitten|monkey|zebra|bear|dragon|dino|duck|tiger|lion|reindeer|kitty|cow|bull|horse|owl|teddy|bunny|turtle|puppy|frog|caterpillar|alligator",x=pacifier$product_title,ignore.case = TRUE)

#Nipple vs pacifier
pacifier$title_nipple<-grepl("nip|nipple",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_pacifier<-grepl("pacifier",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_nip_and_pacifier<-grepl("pacifier",x=pacifier$product_title,ignore.case = TRUE)==TRUE & grepl("nip|nipple",x=pacifier$product_title,ignore.case = TRUE)==TRUE
  
#Color
pacifier$title_color<-grepl("green|blue|pink|purple|orange|red|brown|glow in the dark|tabby",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_blue_pink<-grepl("blue|pink",x=pacifier$product_title,ignore.case = TRUE)

#Key Phrases
pacifier$title_natural<-grepl("natural",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_soothe<-grepl("soothe",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_orthodontic<-grepl("orthodontic",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_soft<-grepl("soft|plush",x=pacifier$product_title,ignore.case = TRUE)
pacifier$title_baby<-grepl("baby|infant",x=pacifier$product_title,ignore.case = TRUE)



#Cleaning of columns to date

#Remove punctuation
pacifier$product_title<-gsub("[[:punct:]]","",x=pacifier$product_title,ignore.case = TRUE)

#Remove Marketplace and Product Category because no variation in values, Product ID because
#using Review ID as key field and product parent as unique identifier
pacifier<-pacifier[,-c(1,4,7)]

#Convert all boolean features to zeroes and ones
pacifier[,8]<-ifelse(pacifier$vine=="N"|pacifier$vine=="n",0,1)
pacifier[,9]<-ifelse(pacifier$verified_purchase=="N"|pacifier$verified_purchase=="n",0,1)
pacifier[,c(14:31)]<-lapply(pacifier[,c(14:31)], as.integer)



#REVIEW BODY AND TITLE

#Review length 
pacifier$review_length<-nchar(pacifier$review_body)

#Replace 100% with absolutely
pacifier$review_body<-gsub("100%|100 %","absolutely",x=pacifier$review_body)
pacifier$review_headline<-gsub("100%|100 %","absolutely",x=pacifier$review_headline)

#Get rid of emojis
pacifier$review_body<-iconv(pacifier$review_body, from = "latin1", to = "ascii",sub = "byte")
pacifier$review_body<-replace_emoticon(pacifier$review_body, emoticon_dt = lexicon::hash_emojis)
pacifier$review_headline<-iconv(pacifier$review_headline, from = "latin1", to = "ascii",sub = "byte")
pacifier$review_headline<-replace_emoticon(pacifier$review_headline, emoticon_dt = lexicon::hash_emojis)

pacifier$review_body<-gsub("<.*?\\>","",x=pacifier$review_body)
pacifier$review_body<-gsub(">","",x=pacifier$review_body)
pacifier$review_headline<-gsub("<.*?\\>","",x=pacifier$review_headline)
pacifier$review_headline<-gsub(">","",x=pacifier$review_headline)
#Manually fixing one outlier
pacifier$review_body[which(pacifier$review_id=="R2RXKMBSOKY6MC")]<-substr(pacifier$review_body[which(pacifier$review_id=="R2RXKMBSOKY6MC")],1,nchar(pacifier$review_body[which(pacifier$review_id=="R2RXKMBSOKY6MC")])-3)
pacifier[which(pacifier$review_id %in% c("R31ATQFUHQE5JB","R21AUAQC5770ED")),10]<-NA

#Get rid of parentheses
pacifier$review_body<-gsub("&#34;","",x=pacifier$review_body)
pacifier$review_headline<-gsub("&#34;","",x=pacifier$review_headline)

#Multiple letters
pacifier$review_body<-gsub("([[:alpha:]])\\1{2,}", "\\1", pacifier$review_body,ignore.case = TRUE)
pacifier$review_headline<-gsub("([[:alpha:]])\\1{2,}", "\\1", pacifier$review_headline,ignore.case = TRUE)


#Merge User feedback column
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

#Remove commonly occuring special characters
pacifier$user_feedback<-gsub("\\:\\)|\\(\\:","smile",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("\\:\\(","frown",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("bien|bueno","great",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("gracias","thanks",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("muy","very",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("chupete","pacifier",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback <- gsub("\\[.*?\\]", "", x=pacifier$user_feedback)

#Combined words, fix mispellings
pacifier$user_feedback<-gsub("unfortuely","unfortunately",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("pacifiers|paci","pacifier",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("pacifierfier","pacifier",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("nipples","nipple",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("loves","love",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("mam","",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("babies|baby's|child|infant","baby",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("preemie|prematurely","premature",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("months","month",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("hands","hand",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("bottles","bottle",x=pacifier$user_feedback,ignore.case = TRUE)
pacifier$user_feedback<-gsub("\\'s","",x=pacifier$user_feedback,ignore.case = TRUE)

#Delete where it says star ratings
rem <- c("five stars","5 star", "5star", "5-star", "five star",
         "four stars", "4 star", "4star", "4-star", "four star",
         "three stars","3 star", "3star", "3-star", "three star",
         "two stars","2 star", "2star", "2-star", "two star",
         "1 star", "1star", "1-star", "one star")
pacifier$user_feedback <- gsub(paste(rem,collapse="|"), "", x=pacifier$user_feedback,ignore.case = TRUE)

#Remove brands
pacifier$user_feedback<-gsub(paste(unrelated_brands,collapse = "|"),"",x=pacifier$user_feedback,ignore.case = TRUE)


#Write cleaned data to csv
write.csv(pacifier,"pacifier_final.csv",row.names = F)

