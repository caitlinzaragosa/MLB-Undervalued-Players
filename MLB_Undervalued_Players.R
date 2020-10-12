install.packages("LiblineaR", dependencies = TRUE)
install.packages("tidyverse", dependencies=TRUE)
install.packages('e1071', dependencies=TRUE)
install.packages("factoextra", dependencie=TRUE)
install.packages("caret")
library(readr)
library(dplyr)
library(stringr)
library(ggplot2)
library(tidyverse)
library(LiblineaR)
library(caret)
library(dimRed)
library(factoextra)
options(scipen = 999)

pitchers = read.csv("Pitching.csv")
salaries = read.csv("Salaries.csv")
#add salaries to data
pitchers= inner_join(pitchers, salaries, on="Player")

#let's get the data from the last 5 years to ensure inflation doesn't skew our results
pitchers <- pitchers[pitchers$Year>=2013,]

#aggregate the data because we're looking at multiple years
pitchers <- na.omit(pitchers)

#clean up the data
pitchers$Team <- NULL
pitchers$League <- NULL
pitchers$Year <- NULL
pitchers$Stint <- NULL
pitchers$intentional_walks <- NULL
pitchers$sacrifices_by_opposing_batters <- NULL
pitchers$sacrifice_flies_by_opp_batters <- NULL
pitchers$grounded_double_plays_by_opp_batter <- NULL

pitchers <- aggregate(.~Player, pitchers, mean)

#scale the salary to normalize the dataset
pitchers$Salary <- scale(pitchers$Salary)

#summary to see the quartiles to determine the tiers of the salary
summary(pitchers)

#add tier labels to the dataset
#tier 1= x<= -0.560813 
#tier 2 = -0.560813 <= x <= 0
#tier 3 = 0<= x <=  0.123066
#tier 4 = x>0.123066

pitchers$sal_tier <- if_else(pitchers$Salary<= -0.560813, 4, if_else(-0.560813< pitchers$Salary & pitchers$Salary<0, 3, 
                            if_else(0<=pitchers$Salary & pitchers$Salary<0.123066, 2, if_else(pitchers$Salary>=0.123066, 1, 7589))))

#let's finally drop the player names
pitchers$Player <- NULL
#let's create a test and train set to start predicting outcomes using NNets
pitchers <- na.omit(pitchers)
set.seed(838)
trainIndex <- createDataPartition(pitchers$sal_tier, p = 0.8, list = FALSE, times = 1)
data_df_train <- pitchers[trainIndex, ] %>% as.matrix() %>% as.data.frame()
data_df_test <- pitchers[-trainIndex,] %>% as.matrix() %>% as.data.frame()
response_train <- pitchers$sal_tier[trainIndex]
trctrl <- trainControl(method = "repeatedcv",number = 10, repeats=3)
nnet_mod <- train(x = data_df_train,
                  y = as.factor(response_train),
                  method = "nnet",
                  trControl = trctrl,
                  tuneGrid = data.frame(size = 1,
                                        decay = 5e-4),
                  MaxNWts = 26000)
nnet_pred <- predict(nnet_mod,
                     newdata = data_df_test)
nnet_cm <- confusionMatrix(nnet_pred, as.factor(pitchers[-trainIndex, ]$sal_tier))
nnet_cm


#let's cluster our data to see what's going on
#let's remove the tier classifier to ensure the classification is being done on characteristics of the players
pitchers$sal_tier <- NULL
wss <- (nrow(pitchers)-1)*sum(apply(pitchers,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(pitchers, 
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")
#we can try it with 3 or 4 clusters-- we're going with 4 to mitigate potential difficulties
#with analyzing and identifying a successful cluster
kpitchers <- kmeans(pitchers, centers=4, nstart=20)
kpitchers$cluster
summary(kpitchers$cluster)
fviz_cluster(kpitchers, data=pitchers, geom="point",stand = FALSE, frame.type = "norm")

#now let's add all the data to a new dataframe called pitchers2
pitchers2 = read.csv("Pitching.csv")
salaries = read.csv("Salaries.csv")
#add salaries to data
pitchers2= inner_join(pitchers2, salaries, on="Player")

#let's get the data from the last 5 years to ensure inflation doesn't skew our results
pitchers2 <- pitchers2[pitchers2$Year>=2013,]

#aggregate the data because we're looking at multiple years
pitchers2 <- na.omit(pitchers2)

#clean up the data
pitchers2$Team <- NULL
pitchers2$League <- NULL
pitchers2$Year <- NULL
pitchers2$Stint <- NULL
pitchers2$intentional_walks <- NULL
pitchers2$sacrifices_by_opposing_batters <- NULL
pitchers2$sacrifice_flies_by_opp_batters <- NULL
pitchers2$grounded_double_plays_by_opp_batter <- NULL
pitchers2 <- aggregate(.~Player, pitchers2, mean)

#scale the salary to normalize the dataset
pitchers2$Salary <- scale(pitchers2$Salary)

#summary to see the quartiles to determine the tiers of the salary
summary(pitchers2)

#add tier labels to the dataset
#tier 1= x<= -0.560813 
#tier 2 = -0.560813 <= x <= 0
#tier 3 = 0<= x <=  0.123066
#tier 4 = x>0.123066

pitchers2$sal_tier <- if_else(pitchers2$Salary<= -0.560813, 4, if_else(-0.560813< pitchers2$Salary & pitchers2$Salary<0, 3, 
                                                                     if_else(0<=pitchers2$Salary & pitchers2$Salary<0.123066, 2, if_else(pitchers2$Salary>=0.123066, 1, 7589))))

#let's finally drop the player names
pitchers2$Player <- NULL

#let's split up the clusters into their own dataframes to begin an analysis
pitchers2$cluster <- kpitchers$cluster
clust1=pitchers2[pitchers2$cluster==1, ]
clust2=pitchers2[pitchers2$cluster==2, ]
clust3=pitchers2[pitchers2$cluster==3, ]
clust4=pitchers2[pitchers2$cluster==4, ]

#let's take the percentage of tiers in each cluster
sum(clust1$sal_tier==1)/nrow(clust1)
sum(clust1$sal_tier==2)/nrow(clust1)
sum(clust1$sal_tier==3)/nrow(clust1)
sum(clust1$sal_tier==4)/nrow(clust1)
#more tier 1 ~ 54%

sum(clust2$sal_tier==1)/nrow(clust2)
sum(clust2$sal_tier==2)/nrow(clust2)
sum(clust2$sal_tier==3)/nrow(clust2)
sum(clust2$sal_tier==4)/nrow(clust2)
#more tier 4 ~43%

sum(clust3$sal_tier==1)/nrow(clust3)
sum(clust3$sal_tier==2)/nrow(clust3)
sum(clust3$sal_tier==3)/nrow(clust3)
sum(clust3$sal_tier==4)/nrow(clust3)
#more tier 3 ~50%

sum(clust4$sal_tier==1)/nrow(clust4)
sum(clust4$sal_tier==2)/nrow(clust4)
sum(clust4$sal_tier==3)/nrow(clust4)
sum(clust4$sal_tier==4)/nrow(clust4)
#more tier 3 ~57%

#It looks like cluster 1 has the most top tier players in it... so let's label them all as tier 1!!!

pitchers2$sal_tier <- if_else(pitchers2$cluster==1, 1, if_else(pitchers2$cluster==2, 4, if_else(pitchers2$cluster==3, 3, 
                                                                                               if_else(pitchers2$cluster==4, 3, 7589))))


set.seed(838)
trainIndex <- createDataPartition(pitchers2$sal_tier, p = 0.8, list = FALSE, times = 1)
data_df_train <- pitchers2[trainIndex, ] %>% as.matrix() %>% as.data.frame()
data_df_test <- pitchers2[-trainIndex,] %>% as.matrix() %>% as.data.frame()
response_train <- pitchers2$sal_tier[trainIndex]
trctrl <- trainControl(method = "repeatedcv",number = 10, repeats=3)
nnet_mod2 <- train(x = data_df_train,
                  y = as.factor(response_train),
                  method = "nnet",
                  trControl = trctrl,
                  tuneGrid = data.frame(size = 1,
                                        decay = 5e-4),
                  MaxNWts = 26000)
nnet_pred2 <- predict(nnet_mod2,
                     newdata = data_df_test)
nnet_cm2 <- confusionMatrix(nnet_pred2, as.factor(pitchers2[-trainIndex, ]$sal_tier))
nnet_cm2


#this is a more accurate model due to clustering

#let's compare the outcomes from the models
#now let's add all the data to a new dataframe called pitchers3
pitchers3 = read.csv("Pitching.csv")
salaries = read.csv("Salaries.csv")
#add salaries to data
pitchers3= inner_join(pitchers3, salaries, on="Player")

#let's get the data from the last 5 years to ensure inflation doesn't skew our results
pitchers3 <- pitchers3[pitchers3$Year>=2013,]

#aggregate the data because we're looking at multiple years
pitchers3 <- na.omit(pitchers3)

#clean up the data
pitchers3$Team <- NULL
pitchers3$League <- NULL
pitchers3$Year <- NULL
pitchers3$Stint <- NULL
pitchers3$intentional_walks <- NULL
pitchers3$sacrifices_by_opposing_batters <- NULL
pitchers3$sacrifice_flies_by_opp_batters <- NULL
pitchers3$grounded_double_plays_by_opp_batter <- NULL
pitchers3 <- aggregate(.~Player, pitchers3, mean)

#scale the salary to normalize the dataset
pitchers3$Salary <- scale(pitchers3$Salary)

#summary to see the quartiles to determine the tiers of the salary
summary(pitchers3)

#add tier labels to the dataset
#tier 1= x<= -0.560813 
#tier 2 = -0.560813 <= x <= 0
#tier 3 = 0<= x <=  0.123066
#tier 4 = x>0.123066

pitchers3$sal_tier <- if_else(pitchers3$Salary<= -0.560813, 4, if_else(-0.560813< pitchers3$Salary & pitchers3$Salary<0, 3, 
                                                                       if_else(0<=pitchers3$Salary & pitchers3$Salary<0.123066, 2, if_else(pitchers3$Salary>=0.123066, 1, 7589))))

pitchers3$acc_nn_pred <- pitchers2$sal_tier

#if the prediction is greater than the original tier, then player is overvalued
  #acc_nn_pred > sal_tier = overvalued
#if the prediction is less than the original tier, then player is undervalued
#acc_nn_pred < sal_tier = undervalued
#make a comparison of undervalued, overvalued, or correctly valued players
pitchers3$value <- if_else(pitchers3$acc_nn_pred > pitchers3$sal_tier, "Overvalued", 
                           if_else(pitchers3$acc_nn_pred < pitchers3$sal_tier, "Undervalued", 
                            if_else(pitchers3$acc_nn_pred==pitchers3$sal_tier, "Correctly Valued", "NA")))

pitchers3$undervalued <- if_else(pitchers3$value=="Undervalued", 1, 0)

sum(pitchers3$undervalued)

#look at those who are valued at tier 4 and performing as tier 1 players
pitchers3$super_undervalued <- if_else(pitchers3$acc_nn_pred==1 & pitchers3$sal_tier>=3, 1, 0)
sum(pitchers3$super_undervalued)
super_undervalued= pitchers3[pitchers3$super_undervalued==1, ]

#could it be their era is great?
mean(super_undervalued$earned_run_avg)
good_era=super_undervalued$earned_run_avg < mean(super_undervalued$earned_run_avg)
under_w_good_era = super_undervalued[super_undervalued$earned_run_avg < mean(super_undervalued$earned_run_avg),]
