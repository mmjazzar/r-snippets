
#Following packages are being used so install these if not installed
install.packages("twitteR")
library(twitteR)
install.packages("devtools")
library(devtools)

#Package sentiment has been archived so install it from archive location
install_url("https://cran.r-project.org/src/contrib/Archive/sentiment/sentiment_0.2.tar.gz")
library(sentiment)
library(plyr)
install.packages("wordcloud")
library(wordcloud)


#Package slam has been archived so install it from archive location
install_url("https://cran.r-project.org/src/contrib/Archive/slam/slam_0.1-37.tar.gz")
library(slam)

#Set authentication with Twitter. Copy keys generated in step-1
api_key <- ""
api_secret <- ""
access_token <- ""
access_token_secret <- ""
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)



# tweets from twitter
# Here in this program search based on key word “demonetization” and number of #tweets ingested 1500, it can be increase/decrease by modifying parameter value of n
demonetization_tweets = searchTwitter("demonetization", n=1500, lang="en")
# filter text from tweets
demonetization_text = sapply(demonetization_tweets, function(x) x$getText())
#Prepare/clean data for sentiment analysis
# delete re-tweet entries
demonetization_text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", demonetization_text)
# remove @ word
demonetization_text = gsub("@\\w+", "", demonetization_text)
# delete punctuation
demonetization_text = gsub("[[:punct:]]", "", demonetization_text )
# remove Digits: 0 1 2 3 4 5 6 7 8 9
demonetization_text = gsub("[[:digit:]]", "", demonetization_text)
# delete html links
demonetization_text = gsub("http\\w+", "", deMonetization_text)
# delete unnecessary spaces like tab and space
demonetization_text = gsub("[ \t]{2,}", "", demonetization_text)
demonetization_text = gsub("^\\s+|\\s+$", "", demonetization_text)

# define error handling function 
try.error = function(x)
{
  # create missing value
  y = NA
  # tryCatch error
  try_error = tryCatch(tolower(x), error=function(e) e)
  
  # if not an error
  if (!inherits(try_error, "error"))
    y = tolower(x)
  # result
  return(y) 
}
demonetization_text = sapply(demonetization_text, try.error)
# remove NAs in demonetization_text
demonetization_text = demonetization_text [!is.na(demonetization_text)]
names(demonetization_text) = NULL

# Perform Sentiment Analysis by using naive bayes algorithm. 
#function classify_emotion is defined in “sentiment” package. 
# This function helps us to analyze some text and classify it in different types of #emotion: anger, disgust, #fear, joy, sadness, and surprise
class_emo = classify_emotion(demonetization_text, algorithm="bayes", prior=1.0)
# get emotion best fit
emotion = class_emo[,7]
# replace NA's by "unknown"
emotion[is.na(emotion)] = "unknown"
# function classify_polarity is defined in “sentiment” package.
# The classify_polarity function allows us to classify some text as positive or negative
class_pol = classify_polarity(demonetization_text, algorithm="bayes")
# get polarity best fit
polarity = class_pol[,4]

# Create data frame with the results and obtain some general statistics
# data frame with results

sent_df = data.frame(text= demonetization_text, emotion=emotion,
                     
                     polarity=polarity, stringsAsFactors=FALSE)

# sort data frame

sent_df = within(sent_df,
                 
                 emotion <- factor(emotion, levels=names(sort(table(emotion), decreasing=TRUE))))

#Separate the text by emotions and visualize the words with a comparison cloud
# separating text by emotion
emos = levels(factor(sent_df$emotion))
nemo = length(emos)
emo.docs = rep("", nemo)
for (i in 1:nemo)  
{
  tmp = demonetization_text[emotion == emos[i]]
  emo.docs[i] = paste(tmp, collapse=" ")
}
# remove stopwords
emo.docs = removeWords(emo.docs, stopwords("english"))
# create corpus
corpus = Corpus(VectorSource(emo.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emos


# comparison word cloud

comparison.cloud(tdm,colors = brewer.pal(nemo, "Dark2"),
                 
                 scale = c(2.5,.5), random.order = FALSE, title.size = 1.5)

                       
#getting  retweeted tweets
k <- subset(tweets.df, tweets.df$isRetweet ==TRUE )
nrow(k)
k1 <- k[order((k$retweetCount), decreasing = TRUE), ]

# get fav tweets
f <- subset(tweets.df, tweets.df$favoriteCount > 1 )
nrow(f)
f1 <- f[order((f$favoriteCount), decreasing = TRUE), ]

### adding more features
                       
# get top users tweets
top_authors <- tweets_by_author %>% arrange(desc(avg_score)) %>%  head(10)

tweets_top_authors <- tweets.df %>% filter()

tweets_top_authors <- subset(tweets.df, tweets.df$screenName %in% top_authors$`tweets.df$screenName`)

tweets_top_authors$text

# score of top users
ggplot(tweets_top_authors) +
  geom_point(aes(score, retweetCount, fill = screenName), size = 5, shape = 21) +
  theme_bw(15) +
  scale_fill_brewer("Author", type = "qual", palette = 3) +
  ggtitle("Score of top users") +
  xlab("# score") + ylab("# retweets")

# And let's see them again, in perspective to all tweets
ggplot(tweets.df) +
  geom_jitter(aes(score, retweetCount), size = 3, shape = 21, fill = "#444444", alpha=0.4) +
  theme_bw(15) +
  geom_point(data = tweets_top_authors,
             aes(score, retweetCount, fill = screenName), size = 6, shape = 21) +
  scale_fill_brewer("Author", type = "qual", palette = 3) +
  xlab("# favorites") + ylab("# retweets") +
  ggtitle("Score of them to all")

###########################################################
user <- getUser("RDataMining")
user$toDataFrame()
friends <- user$getFriends() # who this user follows
followers <- user$getFollowers() # this user's followers
followers2 <- followers[[1]]$getFollowers() # a follower's followers

                       
                       
############################### add score
tweets.df$score <- tweets.df$favoriteCount + tweets.df$retweetCount * 2

s <- tweets.df[order((tweets.df$score), decreasing = TRUE), ]


# Most influnce users score
p<-ggplot(data=s[1:5,], aes(x=screenName, y= score, fill = score)) +
  geom_bar(stat="identity") +
  theme_minimal()
p



### some table
tweets_by_author <-  tweets.df %>% 
  ddply(~ tweets.df$screenName, function(x) {
    data.frame(num_tweets = nrow(x),
               avg_favorites = mean(x$favoriteCount) %>% round(digits = 1),
               avg_retweets = mean(x$retweetCount) %>% round(digits = 1),
               avg_score = mean(x$score) %>% round(digits = 1)
    )}) %>%  arrange(desc(avg_score)) 


tweets_by_author %>% arrange(desc(num_tweets)) %>% head(10)


# get top users tweets
top_authors <- tweets_by_author %>% arrange(desc(avg_score)) %>%  head(10)

tweets_top_authors <- tweets.df %>% filter()

tweets_top_authors <- subset(tweets.df, tweets.df$screenName %in% top_authors$`tweets.df$screenName`)

tweets_top_authors$text

# score of top users
ggplot(tweets_top_authors) +
  geom_point(aes(score, retweetCount, fill = screenName), size = 5, shape = 21) +
  theme_bw(15) +
  scale_fill_brewer("Author", type = "qual", palette = 3) +
  ggtitle("Score of top users") +
  xlab("# score") + ylab("# retweets")

# And let's see them again, in perspective to all tweets
ggplot(tweets.df) +
  geom_jitter(aes(score, retweetCount), size = 3, shape = 21, fill = "#444444", alpha=0.4) +
  theme_bw(15) +
  geom_point(data = tweets_top_authors,
             aes(score, retweetCount, fill = screenName), size = 6, shape = 21) +
  scale_fill_brewer("Author", type = "qual", palette = 3) +
  xlab("# favorites") + ylab("# retweets") +
  ggtitle("Score of them to all")

