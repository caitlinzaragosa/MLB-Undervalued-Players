# MLB-Undervalued-Players
In this project, I am going to build a predictive model on how players would do in 2018 by looking at which players are “undervalued” and could be an inexpensive acquisition that would assist the team win the World Series.

## Introduction to Problem:

Predicting the performance of players in Major League Baseball seems to be a gift that everyone would die for, especially considering the lack of data on players prior to joining the MLB. Who wouldn’t want to make tons of money predicting who is going to be the next best player in baseball history? Beyond that, who wouldn’t want to pick the least expected (and expensive) player who is typically undervalued? In this project, I am going to build a predictive model on how players would do in 2018 by looking at which players are “undervalued” and could be an inexpensive acquisition that would assist the team win the World Series. 

## Defining Success:
Success for this problem will be defined as identifying your typically lower paid individuals that are predicted to be higher paid players. Success will also be identifying those players in lower salary tiers to have similar statistics and skills as top tier players. Beginning by categorizing salary into tiers, 1 being top tier and 4 being bottom tier, players that are currently in the lower tier (tier 1) who’s predicted outcome would be higher tier (tier 1) are who we are wanting to identify as the undervalued players.

## Data:
This data was acquired from “Sean Lahman’s Baseball Database” and contains complete profiles of individual players’ salaries, batting, pitching, and fielding statistics for Major League Baseball from 1871 to 2017. In deciding to use statistics from the MLB rather than information from the minor leagues and college experience, I decided that using this information would be more helpful for those undergoing a free agent acquisition rather than drafting players because it seems helpful to reduce the risk of inflating contracts in bidding wars. For those interested in getting involved with acquisition, this data and analyses will aide in getting the most bang for your buck by finding the undervalued MLB players. The “Pitching.csv” database was used to get pitcher statistics for all pitchers from 1871 to 2017. I decided to look at pitcher data because of the simplicity of the statistics since pitchers don’t typically bat. 

## Approach and Analytics:
1.) Exploring and cleaning up data: The first and most essential part of this project was tidying up data to ensure the information being used was relevant and in the correct format. In order to begin an analysis, I wanted to first combine salaries with an inner join to the pitchers database so that every player has the correlating salary. Because salaries tend to differ due to inflation, I wanted to look at data from the past 5 years so that players are still relevant for 2018 predictions and inflation isn’t affecting the predicted outcomes. I decided to take out all the categorical data (Team and League) and data that didn’t appear relevant (stint, intentional walks, sacrifices by opposing batters, sacrifice flies by opposing batters, and grounded double plays by opposing batter) after doing the inner merge. To address the issue of players being duplicated in the database (likely because they had played several years), I decided to aggregate the players together and use their mean scores to get an average of their performance. I scaled the salary to ensure normalization in our dataset and decided to look at the quartiles of the salaries to begin defining the tiers. 
Based on the quartiles of the salary, this was the breakdown of the tiers:

•	Tier 1= x<= -0.560813 (Q1)

•	Tier 2 = -0.560813 <= x <= 0 (Q2)

•	Tier 3 = 0<= x <=  0.123066 (Q3)

•	Tier 4 = x>0.123066 (Q4)


I assigned tiers according to the player’s salary and began setting up for model creation. 

2.) Analytics- NNet #1: To get an initial start on the analysis, I figured it would be a good methodology to first make a neural network that will predict the tiers of the players’ salaries to get an idea of who would be most likely to be undervalued or overvalued. If the model predicted tier 1 and the actual was a tier 4, this is an example of an undervalued player.  After setting up the training and testing set, the accuracy was 69.59%.

Because we have the actual value of the salaries, this model is being created on the knowledge that we know the tier, but it would be much more helpful to look at the qualities as well. The next step would be then performing a clustering technique to get an understanding of what statistics and aspects are being looked at to determine the value of the player. 


3.) Analytics- K-means: To begin the clustering process, I decided to go with using K-means instead of support vector machines due to the number of categories we would be classifying. SVM is typically more accurate, but unfortunately does not work in this problem since it is not a binary classification we are looking for. Determining the number of clusters was based on the scree plot that I had made. Looking at the elbow of the curve, it seemed as if I could go with 3 or 4 clusters.

 
I decided to go with 4 clusters to ensure that if there was an instance were either every cluster was made, one with the majority of each tier, or even fewer clusters with no clear majority, there would be an easy way to understand the clusters and perform an analysis. After taking out the actual tier values, I ran the K-means algorithm with 4 centers.
 
I decided that I had to figure out which tier was the majority of the cluster. By doing this, this would give me an idea of what the expected tiers should be for these players in the cluster because it can be assumed that the players must have similar characteristics as the ones in that cluster. The clustering percentages were: 

•	Cluster 1 had a majority of actual tier 1 players with a 54% majority

•	Cluster 2 had a majority of actual tier 4 players with a 43% majority

•	Cluster 3 had a majority of actual tier 3 players with a 50% majority

•	Cluster 4 had a majority of actual tier 3 players also with a 57% percent majority

Because cluster 1 had the most top tier players, I then re-labeled the tiers so that every player in cluster 1 would have a tier 1 salary. 


4.) Analytics- NNet #2: In order to see whether this would increase the accuracy of the trained predictions, I created another neural network model to run a prediction on the newly labeled salary tiers. The model increased in accuracy to 85.81%  

Due to the clustering technique done to modify the model, the accuracy increased by about 15%. The next step was comparing the more accurate predicted outcomes and the actual tiers of the players. Through clustering, we have found common characteristics between players that will add substance to the prediction because that should put similar performing players in the same cluster and tier. Now that the new neural network model has been trained with these more similar players being in the same category, the predictions should mean a lot more. This would give us insight to the players that are performing like top tier players and should be valued as such, but currently aren’t.

5.) Reviewing results: To being the comparison out the newly predicted tiers (cluster adjusted) and the current and actual tiers, I added a column to see if the player is overvalued, undervalued, or correctly valued with the following conditions: 

•	 If the prediction is greater than the original tier, then player is overvalued

    o	Predicted > current tier = overvalued
  
•	If the prediction is less than the original tier, then player is undervalued

    o	Predicted < current tier = undervalued
  
•	If the prediction is equal to the original tier, then the player is correctly valued

    o	Predicted = current tier = correctly valued
  
By summing up the number of those undervalued, I got a number of 125. This means that out of the dataset, there are 125 potentially undervalued players that are performing like higher tier players. Diving deeper into these 125 undervalued players, what would make the most difference are those who are currently valued at a 3 or 4 tiered player but are predicted to be a tier 1 player. This number came out to be 48, which means that these are the pitchers that are potentially going to be most undervalued players. In addition, Earned Run Average is a metric that can be used to see which players have an average ERA that is less than the mean ERA in their category. Out of the super undervalued players, it looks like there are 22 players with an average ERA that is less than the mean of the entire super undervalued players, which can be an important aspect to consider.

## Conclusion:  
It seems that by adding the clustered labels, the model increased, which means that the final model is the one that should be used for future predictions. The neural network model is now looking at similar characteristics and tiers, which is helpful considering the current information would be provided prior to a prediction, which supports the reason for using a supervised learning algorithm. For someone who is knowledgeable about the baseball industry, it might be easier to determine which metrics stand out more than this model. This model is not meant to predict exactly the players who should perform well in 2018, but should aide in giving you an understanding of which players are seen as less valuable yet have similar statistics and characteristics as the top tiered players that can then result in your informed prediction. In addition, this is also to be used for future player acquisition, not necessarily for drafting purposes, though this could give you some insight on what to be looking for in players ready to be drafted. Something to note with this project is that at the moment, there are currently limited resources with information containing those pitcher or player statistics prior to being drafted to the MLB. If someone wanted to take this model and use it for drafting purposes, one would need to use a dataset that contains statistics from college and minor league experiences. As of right now, it’s difficult to get ahold of these statistics, but by speculation, I suspect that this information will become more widely available as people become interested in predicting which players are ready to be drafted and will be successful. In addition, if someone is interested in predicting undervalued players that aren’t pitchers, one can simply input statistics of players for a particular position.  

