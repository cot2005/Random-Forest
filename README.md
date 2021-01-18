# Random-Forest
## Training the Random-Forest model

Functions to test and build random forest binary classifier models. Input data table must be tab-delimited with pre-processessed and normalized feature data with the 
classification column called "Classification" denoting positive class with 1 and the negative class with 0. The first column of the data table must be labels and will
be disregarded in training and evaluation.

This basic version will use all the feature data and perform 10x (default) k-fold cross validation. It will create a ROC plot and a negative control (shuffled labels) 
ROC plot using the cross validation results. The final model will combine 50 (default) random forest models and write the final model as a .RDS object. Additionally,
the function will output results for the cross validation and false positive instances.

The input data must be formatted as follows with "###" designating numbers:
```
Label Feature1  Feature2  Feature3  ... FeatureN  Classification
Data1 ### ### ### ... ### 1
Data2 ### ### ### ... ### 0
Data3 ### ### ### ... ### 0
Data4 ### ### ### ... ### 1
...
```

## Predictions using the Random-Forest Model

Import the .rds object and call predict on the new test data set. The new data set must be pre-processed and normalized the same way as the training data set without a classification column (features in the same order, labels in the first column). Predict the class of the testData with the rfModel:
```
rfModel <- readRDS("rfModel.rds")
testData <- read.table("testData.txt", sep = "\t", header = T)
predict(rfModel, testData, type = "prob")
```

Returns data frame with probabilities for each outcome of each row corresponding to the rows in the test data set.
