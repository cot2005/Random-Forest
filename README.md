# Random-Forest

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
