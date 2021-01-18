######################################################################
#builds the random forest model
######################################################################

library(caret)
library(randomForest)
library(pROC)

RF.build<-function(inputData, rfname = "RandomForestModel.rds") {
  featureData <- read.table(inputData, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  featureDataMaster <- featureData
  labels <- featureData[,1]
  
  featureData <- featureData[,2:ncol(featureData)]
  featureData$Classification <- as.factor(featureData$Classification)
  
  #builds the model
  featureData <- na.roughfix(featureData)
  cvResults <- crossValidation(featureData)
  
  # creates ROC plot
  ROCplot(actualData = as.numeric(cvResults$obs), predData = cvResults$`1`)
  
  # writes training files
  falsePos <- findFalsePos(cvResults, featureDataMaster)
  write.table(falsePos, "FalsePositives.txt", col.names = TRUE, row.names = FALSE, quote = FALSE, sep ="\t")
  write.table(cvResults, "cvResults.txt", sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
  
  #trains final model
  rfFit <- finalModel(featureData, 50)
  
  #saves random forest as an RDS
  saveRDS(rfFit, rfname)
}

#################Functions used by RF.build#################

# Function used to perform K-fold Cross validation
crossValidation <-function(df, k = 10) {
  #set.seed(1990)
  indx <- createFolds(df$Classification, k=k)
  predictions <- data.frame()
  for (set in indx){
    test<- df[set,]
    train <- df[-set,]
    down_train <- downSample(x= train[, - ncol(train)], y= train$Classification)
    down_train$Classification <- NULL
    rfFit <- randomForest(Class ~ ., data= down_train, keep.forest = TRUE, 
                          scale = TRUE, 
                          importance = TRUE)
    class <- test$Classification
    test$Classification <- NULL
    prob <- predict(rfFit, test, type = "prob", na.action = na.roughfix)
    rowId <- as.data.frame(attributes(prob)$dimnames[1])
    colnames(rowId)[1] <- "row"
    prob <-  as.data.frame(prob)
    prob$obs <- class
    prob$row <- as.numeric(as.character(rowId$row))
    prob$pred <- predict(rfFit, test,type ="response", na.action = na.roughfix)
    predictions <- rbind(prob, predictions)
  }
  return(predictions)
}


# Creates the final RF model by combining all the models from the K-fold CV
finalModel <- function(df, k){
  #set.seed(1990)
  start = 1
  allModels <- vector("list", k)
  while(start < k+1){
    down_sub <- downSample(x= df[, - ncol(df)], y= df$Classification)
    down_sub$Classification <- NULL
    rfFit <-randomForest(Class ~ ., data= down_sub, keep.forest = TRUE, 
                         na.action = na.roughfix, 
                         scale = TRUE, 
                         importance = TRUE)
    #  rfFit <- lm(Classification ~ ., data= down_sub)
    allModels[[start]] <- rfFit 
    start = start +1
  }
  rf.all <- Reduce('combine', allModels)
  return(rf.all)
}


# Creates false positives file for manual review
findFalsePos <- function(predictions, masterData){
  falsePos <- subset(predictions, predictions$pred == "1" & predictions$obs == "0")
  print(falsePos$row[1])
  falsePos$Ticker <- masterData$Ticker[falsePos$row]
  falsePos$Date <- masterData$Date[falsePos$row]
  return(falsePos)
}


# creates new ROC plot.
ROCplot <- function(actualData, predData, fileName = "ROCplot.pdf"){
pdf(fileName, height = 10, width = 10)
rocobj <- plot.roc(actualData, predData, ci = TRUE, stratified=FALSE, print.auc=TRUE, show.thres=TRUE, 
                   main = "ROC Curve with CI")
ciobj <- ci.se(rocobj, specificities = seq(0,1,0.05)) # over a select set of specificities
plot(ciobj, type = "shape", col = "#CCE5FF")     # plot as a blue shape
plot(ci(rocobj, of = "thresholds", thresholds = "best"))
dev.off()
}
