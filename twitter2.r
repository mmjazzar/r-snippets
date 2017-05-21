
palestine <- searchTwitter("palestine", n=5000)
israel <- searchTwitter("israel", n=5000)

# To DF
palestine <- twListToDF(palestine)
israel <- twListToDF(israel)

# adding time
palestine$timestamp <- as.Date(palestine$created)
israel$timestamp <- as.Date(israel$created)



# bining
tweets2 <- bind_rows(palestine %>% 
                      mutate(person = "palestine"),
                    israel %>% 
                      mutate(person = "israel"))


tweets2 <- bind_rows(s %>% 
                       mutate(person = "Jordan"))


# Selecting retweet only
tidy_tweets <- tweets2 %>%   subset(!str_detect(text, "^RT")) %>%
  mutate(text = str_replace_all(text, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  filter(!word %in% stop_words$word,str_detect(word, "[a-z]"))

  
frequency <- tidy_tweets %>% 
  group_by(person) %>% 
  count(word, sort = TRUE) %>% 
  left_join(tidy_tweets %>% 
              group_by(person) %>% 
              summarise(total = n())) %>%
  mutate(freq = n/total)


#
frequency <- frequency %>% 
  select(person, word, freq) %>% 
  spread(person, freq) 

# replacing na with 0
frequency[is.na(frequency)] <- 0



ggplot(frequency, aes(palestine, israel)) +
  geom_jitter(alpha = 0.1, size = 3.5, width = 0.35, height = 0.35) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")


ggplot(frequency, aes(palestine, israel)) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.25, height = 0.25) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")


#Comparing word usage

word_ratios <- tidy_tweets %>%
  subset(!str_detect(word, "^@")) %>%
  count(word, person) %>%
  filter(sum(n) >= 10) %>%
  ungroup() %>%
  spread(person, n, fill = 0) %>%
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>%
  mutate(logratio = log(palestine / israel)) %>%
  arrange(desc(logratio))


word_ratios %>% 
  arrange(abs(logratio))


word_ratios %>%
  group_by(logratio < 0) %>%
  top_n(15, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_col() +
  coord_flip() +
  ylab("log odds ratio (palestine/israel)") +
  scale_fill_discrete(name = "", labels = c("palestine", "israel"))

#############################
### words by time



words_by_time <- tidy_tweets %>%
  subset(!str_detect(word, "^@")) %>%
  mutate(time_floor = floor_date(timestamp, unit = "1 day")) %>%
  count(time_floor, person, word) %>%
  ungroup() %>%
  group_by(person, time_floor) %>%
  mutate(time_total = sum(n))%>%
  group_by(word) %>%
  mutate(word_total = sum(n))%>%
  ungroup() %>%
  rename(count = n) %>%
  subset(word_total > 10)


words_by_time



nested_data <- words_by_time %>%
  nest(-word, -person) 

nested_data


library(purrr)

nested_models <- nested_data %>%
  mutate(models = map(data, ~ glm(cbind(count, time_total) ~ time_floor, ., 
                                  family = "binomial")))

nested_models

library(broom)

slopes <- nested_models %>%
  unnest(map(models, tidy)) %>%
  filter(term == "time_floor") %>%
  mutate(adjusted.p.value = p.adjust(p.value))

top_slopes <- slopes %>% 
  subset(adjusted.p.value > 0.1)

top_slopes



words_by_time %>%
  inner_join(nested_models, by = c("word", "person")) %>%
  filter(person == "Jordan") %>%
  ggplot(aes(time_floor, count/time_total, color = word)) +
  geom_line(size = 1.3) +
  labs(x = NULL, y = "Word frequency")

# 7.5 Favorites and retweets

totals <- tidy_tweets %>% 
  group_by(person, id) %>% 
  summarise(rts = sum(retweetCount)) %>% 
  group_by(person) %>% 
  summarise(total_rts = sum(rts))


word_by_rts <- tidy_tweets %>% 
  group_by(id, word, person) %>% 
  summarise(rts = first(retweetCount)) %>% 
  group_by(person, word) %>% 
  summarise(retweets = median(rts), uses = n()) %>%
  left_join(totals) %>%
  filter(retweets != 0) %>%
  ungroup()

word_by_rts %>% 
  filter(uses >= 5) %>%
  arrange(desc(retweets))


word_by_rts %>%
  filter(uses >= 5) %>%
  group_by(person) %>%
  top_n(10, retweets) %>%
  arrange(retweets) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, retweets, fill = person)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ person, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of retweets for tweets containing each word")


# for fav
totals <- tidy_tweets %>% 
  group_by(person, id) %>% 
  summarise(favs = sum(favoriteCount)) %>% 
  group_by(person) %>% 
  summarise(total_favs = sum(favs))

word_by_favs <- tidy_tweets %>% 
  group_by(id, word, person) %>% 
  summarise(favs = first(favoriteCount)) %>% 
  group_by(person, word) %>% 
  summarise(favorites = median(favs), uses = n()) %>%
  left_join(totals) %>%
  filter(favorites != 0) %>%
  ungroup()

word_by_favs %>%
  filter(uses >= 5) %>%
  group_by(person) %>%
  top_n(10, favorites) %>%
  arrange(favorites) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, favorites, fill = person)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ person, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of favorites for tweets containing each word")



# looking for special word in tweets 
word_by_favs %>%
  filter(uses >= 5) %>%
  group_by(person) %>%
  top_n(10, favorites) %>%
  arrange(favorites) %>%
  ungroup() %>%
  mutate(word = factor(word, "king")) %>%
  ungroup() %>%
  ggplot(aes(word, favorites, fill = person)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ person, scales = "free", ncol = 2) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of favorites for tweets containing each word")
